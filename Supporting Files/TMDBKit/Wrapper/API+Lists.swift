//
//  API+Lists.swift
//  TMDBKit
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

extension TMDBKit {
    
    /**
     Requests a list for a specific id.
     
     - Parameter id:        The tmdb id of the list.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, the contents of the list (an array of `Movie` and/or `Show` objects) will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func list(for id: String,
                            callback: @escaping (Error?, [Decodable]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: "https://api.themoviedb.org/4" + Endpoints.list + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        var request = URLRequest(url: components.url!)
        
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Endpoints.bearer)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let results = dictionary?["results"] as? [[String : Any]?] {
                        let decoder = JSONDecoder()
                        let items: [Decodable] = try results.compactMap {
                            guard let object = $0 else { return nil }
                            let data = try JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
                            return (try? decoder.decode(Movie.self, from: data)) ?? (try? decoder.decode(Show.self, from: data))
                        }
                        
                        OperationQueue.main.addOperation {
                            callback(nil, items)
                        }
                    } else {
                        let description = dictionary?["status_message"] as? String ?? ""
                        let code = dictionary?["status_code"] as? Int ?? 0
                        
                        error = NSError(domain: "org.tmdb.kit.error", code: code, userInfo: [NSLocalizedDescriptionKey: description]) as Error
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
        }
        
        return task
    }
    
    /**
     Creates a list with a given name.
     
     - Parameter name:      The name the list is to have.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, the id of the list will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func createList(named name: String, callback: @escaping (Error?, String?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4" + Endpoints.list)!)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Endpoints.bearer)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["name": name,
                                                                        "iso_639_1": "en"],
                                                       options: .prettyPrinted)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let id = dictionary?["id"] as? Int {
                        OperationQueue.main.addOperation {
                            callback(nil, String(id))
                        }
                    } else {
                        let description = dictionary?["status_message"] as? String ?? ""
                        let code = dictionary?["status_code"] as? Int ?? 0
                        
                        error = NSError(domain: "org.tmdb.kit.error", code: code, userInfo: [NSLocalizedDescriptionKey: description]) as Error
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
        
        return task
    }
    
    /**
     Adds items (movies or shows) to a given list.
     
     - Important: Only the person who created the list has permission to modify it.
     
     - Parameter items:     The items to be added to the list in the format: id: Type. e.g. ["123": .movie, "124": .tv].
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, the closure is called with `nil` passed in for the error, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func add(items: [String: MediaType],
                           toList id: String,
                           callback: ((Error?) -> Void)? = nil) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4" + Endpoints.list + "/\(id)" + Endpoints.items)!)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Endpoints.bearer)", forHTTPHeaderField: "Authorization")
        
        var dictionary: [[String: String]] = [[:]]
        
        for (id, type) in items {
            dictionary.append(["media_type": type.rawValue, "media_id": id])
        }
        
        request.httpBody = try! JSONSerialization.data(withJSONObject: ["items": dictionary],
                                                       options: .prettyPrinted)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let success = dictionary?["success"] as? Bool, success {
                        error = nil
                    } else {
                        let description = dictionary?["status_message"] as? String ?? ""
                        let code = dictionary?["status_code"] as? Int ?? 0
                        
                        error = NSError(domain: "org.tmdb.kit.error", code: code, userInfo: [NSLocalizedDescriptionKey: description]) as Error
                    }
                } catch let e {
                    error = e
                }
            }
            
            OperationQueue.main.addOperation {
                callback?(error)
            }
        }
        
        return task
    }
    
    /**
     Perminantly deletes a given list.
     
     - Important: Only the person who created the list has permission to modify it.
     
     - Parameter id:        The tmdb id of the list.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, the closure is called with `nil` passed in for the error, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func delete(list id: String, callback: ((Error?) -> Void)? = nil) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var request = URLRequest(url: URL(string: "https://api.themoviedb.org/4" + Endpoints.list + "/\(id)")!)
        
        request.httpMethod = "DELETE"
        
        request.addValue("application/json;charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(Endpoints.bearer)", forHTTPHeaderField: "Authorization")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let success = dictionary?["success"] as? Bool, success {
                        error = nil
                    } else {
                        let description = dictionary?["status_message"] as? String ?? ""
                        let code = dictionary?["status_code"] as? Int ?? 0
                        
                        error = NSError(domain: "org.tmdb.kit.error", code: code, userInfo: [NSLocalizedDescriptionKey: description]) as Error
                    }
                } catch let e {
                    error = e
                }
            }
            
            OperationQueue.main.addOperation {
                callback?(error)
            }
        }
        
        return task
    }
}
