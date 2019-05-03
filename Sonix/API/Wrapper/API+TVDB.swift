//
//  API+TVDB.swift
//  Sonix
//
//  Copyright © 2018 Mark Bourke.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE
//

import Foundation
import PutKit.AFOAuthCredential
import class TMDBKit.CastMember

extension API {
    
    private static let credentialIdentifier = "TVDB_OAuth_Credential"
    
    /**
     Requests the access token with which every API request has to authenticated.
     
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an `OAuthCredential` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    private static func getJWTToken(_ callback: @escaping (Error?, OAuthCredential?) -> Void) -> URLSessionDataTask? {
        if let credential = OAuthCredential.retrieve(identifier: credentialIdentifier) {
            if credential.isExpired {
                OAuthCredential.delete(identifier: credentialIdentifier)
                return getJWTToken(callback)
            } else {
                callback(nil, credential)
                return nil
            }
        }
        
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: Endpoints.TVDB.base + Endpoints.TVDB.login)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["apikey": Endpoints.TVDB.apiKey], options: .prettyPrinted)
        
        return session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let token = dictionary?["token"] as? String {
                        let credential = OAuthCredential(token: token, of: "Bearer")
                        let secondsInDay: TimeInterval = 86400
                        credential.setExpiration(Date().addingTimeInterval(secondsInDay))
                        credential.store(identifier: credentialIdentifier)
                        
                        OperationQueue.main.addOperation {
                            callback(nil, credential)
                        }
                    } else {
                        error = NSError(domain: "com.thetvdb.api", code: 401, userInfo: [NSLocalizedDescriptionKey: dictionary?["Error"] ?? "Unknown Error"])
                    }
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                OperationQueue.main.addOperation {
                    callback(error, nil)
                }
            }
        }
    }
    
    /**
     Requests the refresh token after the access token has expired.
     
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an access token will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    private static func getRefreshToken(credential: OAuthCredential,
                                        callback: @escaping (Error?, OAuthCredential?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        var request = URLRequest(url: URL(string: Endpoints.TVDB.base + Endpoints.TVDB.refreshToken)!)
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("\(credential.tokenType) \(credential.accessToken)", forHTTPHeaderField: "Authorization")
        
        return session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let token = dictionary?["token"] as? String {
                        let secondsInDay: TimeInterval = 86400
                        credential.setExpiration(Date().addingTimeInterval(secondsInDay))
                        credential.setValue(token, forKey: "accessToken")
                        credential.store(identifier: credentialIdentifier)
                        
                        OperationQueue.main.addOperation {
                            callback(nil, credential)
                        }
                    } else {
                        error = NSError(domain: "com.thetvdb.api", code: 401, userInfo: [NSLocalizedDescriptionKey: dictionary?["Error"] ?? "Unknown Error"])
                    }
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                OperationQueue.main.addOperation {
                    callback(error, nil)
                }
            }
        }
    }
    
    /**
     Requests the actors for a given show.
     
     - Parameter id:        The TVDB id of the show.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `[TVDBActor]`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func actors(forShow id: Int,
                       callback: @escaping (Error?, [TVDBActor]) -> Void) -> URLSessionDataTask? {
        return getJWTToken { (error, credential) in
            guard let credential = credential else {
                return callback(error, [])
            }
            let session = URLSession.shared
            var request = URLRequest(url: URL(string: Endpoints.TVDB.base + Endpoints.TVDB.series + "/\(id)" +  Endpoints.TVDB.actors)!)
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("\(credential.tokenType) \(credential.accessToken)", forHTTPHeaderField: "Authorization")
            
            session.dataTask(with: request) { (data, response, error) in
                var error = error
                
                if let data = data {
                    do {
                        let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                        
                        var actors: [TVDBActor] = []
                        
                        (dictionary?["data"] as? [[String : Any]])?.forEach {
                            guard let id = $0["id"] as? Int,
                                let name = $0["name"] as? String,
                                let role = $0["role"] as? String else { return }
                            let image = $0["image"] as? String
                            
                            let actor = TVDBActor(name: name,
                                                  gender: nil,
                                                  id: id,
                                                  character: role,
                                                  headshot: image)
                            actors.append(actor)
                        }
                        
                        
                        OperationQueue.main.addOperation {
                            callback(nil, actors)
                        }
                    } catch let e {
                        error = e
                    }
                }
                
                if let error = error {
                    OperationQueue.main.addOperation {
                        callback(error, [])
                    }
                }
            }.resume()
        }
    }
}
