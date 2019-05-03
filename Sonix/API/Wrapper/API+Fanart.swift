//
//  API+Fanart.swift
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

extension API {
    
    /**
     Requests Movie or TV Show logos from Fanart.tv.
     
     - Parameter id:    The imdb id of the movie or the tvdb id of the show.
     - Parameter type:  The type of the item.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func logo(for id: String,
                     of type: MediaType,
                     callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let endpoint = type == .movies ? Endpoints.Fanart.movies : Endpoints.Fanart.tv
        
        var components = URLComponents(string: Endpoints.Fanart.base + endpoint + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.Fanart.apiKey)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    let array: [[String : Any]]?
                    var url: URL?
                    
                    if type == .movies {
                        array = dictionary?["hdmovielogo"] as? [[String : Any]]
                    } else {
                        array = dictionary?["hdtvlogo"] as? [[String : Any]]
                    }
                    
                    if let logo = (array?.first(where: { ($0["lang"] as? String) == Locale.current.languageCode }) ?? array?.first)?["url"] as? String {
                        url = URL(string: logo)
                    }
                    
                    OperationQueue.main.addOperation {
                        callback(nil, url)
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
     Requests a Movie or TV Show's thumb image (widescreen poster art) from Fanart.tv.
     
     - Parameter id:    The imdb id of the movie or the tvdb id of the show.
     - Parameter type:  The type of the item.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func backgroundThumb(for id: String,
                                of type: MediaType,
                                callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let endpoint = type == .movies ? Endpoints.Fanart.movies : Endpoints.Fanart.tv
        
        var components = URLComponents(string: Endpoints.Fanart.base + endpoint + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.Fanart.apiKey)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    let array: [[String : Any]]?
                    var url: URL?
                    
                    if type == .movies {
                        array = dictionary?["moviethumb"] as? [[String : Any]]
                    } else {
                        array = dictionary?["tvthumb"] as? [[String : Any]]
                    }
                    
                    if let logo = (array?.first(where: { ($0["lang"] as? String) == Locale.current.languageCode }) ?? array?.first)?["url"] as? String {
                        url = URL(string: logo)
                    }
                    
                    OperationQueue.main.addOperation {
                        callback(nil, url)
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
     Requests Movie or TV Show thumb images (widescreen poster art) from Fanart.tv.
     
     - Parameter info:      An array of tuples providing information about the media for which images are to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a dictionary of `URL`s keyed by the id of the media will be returned, however, if it fails, the underlying error will be returned.
     
     - Important: The `URLSessionTask`s will be automatically started when this method is called.
     */
    static func backgroundThumbs(for info: [(id: String, type: MediaType)],
                                 callback: @escaping (Error?, [String: URL?]) -> Void) {
        var thumbs: [String: URL?] = [:]
        let group = DispatchGroup()
        var error: Error?
        
        info.forEach {
            group.enter()
            let id = $0.id
            backgroundThumb(for: id, of: $0.type) {
                thumbs[id] = $1
                error = $0
                group.leave()
            }.resume()
        }
        
        group.notify(queue: .main) {
            callback(error, thumbs)
        }
    }
}
