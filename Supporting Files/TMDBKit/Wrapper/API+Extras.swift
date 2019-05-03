//
//  API+Extras.swift
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
     Requests extras for a movie or show from TMDB.
     
     - Parameter id:        The tmdb identification code for the movie/show.
     - Parameter type:      The type of the media for which extras are to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Video`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func videos(for id: String,
                              of type: MediaType,
                              callback: @escaping (Error?, [Video]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let endpoint: String
        
        switch type {
        case .movie:
            endpoint = Endpoints.movie
        case .tv:
            endpoint = Endpoints.tv
        }
        
        var components = URLComponents(string: Endpoints.base + endpoint + "/\(id)" + Endpoints.videos)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let videos = try JSONDecoder().decode([Video].self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, videos)
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
     Requests the people in the movie/show from TMDB.
     
     - Parameter id:        The tmdb identification code for the movie/show.
     - Parameter type:      The type of the media for which extras are to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Person`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func credits(for id: String,
                               of type: MediaType,
                               callback: @escaping (Error?, [Person]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let endpoint: String
        
        switch type {
        case .movie:
            endpoint = Endpoints.movie
        case .tv:
            endpoint = Endpoints.tv
        }
        
        var components = URLComponents(string: Endpoints.base + endpoint + "/\(id)" + Endpoints.credits)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    var people: [Person] = []
                    
                    (dictionary?["cast"] as? [[String : Any]])?.forEach {
                        let data = try! JSONSerialization.data(withJSONObject: $0) // Re-encode dictionary so we can parse it as a native object.
                        let cast = (try? JSONDecoder().decode([CastMember].self, from: data)) ?? []
                        
                        people += cast.map({$0 as Person})
                    }
                    
                    (dictionary?["crew"] as? [[String : Any]])?.forEach {
                        let data = try! JSONSerialization.data(withJSONObject: $0) // Re-encode dictionary so we can parse it as a native object.
                        let crew = (try? JSONDecoder().decode([CrewMember].self, from: data)) ?? []
                        
                        people += crew.map({$0 as Person})
                    }
                    
                    OperationQueue.main.addOperation {
                        callback(nil, people)
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
     Requests movies/shows similar to a given movie/show from TMDB.
     
     - Parameter id:        The tmdb identification code for the movie/show.
     - Parameter type:      The type of the media for which extras are to be fetched. Must be either `Show` or `Movie` otherwise an exception will be thrown.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of the previously specified type will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func similarItems<I: Decodable>(to id: String,
                                                  of type: I.Type,
                                                  callback: @escaping (Error?, [I]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        let endpoint: String
        
        if type == Movie.self {
            endpoint = Endpoints.movie
        } else if type == Show.self {
            endpoint = Endpoints.tv
        } else {
            fatalError()
        }
        
        var components = URLComponents(string: Endpoints.base + endpoint + "/\(id)" + Endpoints.similar)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    let items: [I]
                    
                    if let results = dictionary?["results"] as? [[String : Any]] {
                        let data = try JSONSerialization.data(withJSONObject: results)
                        items = try JSONDecoder().decode([I].self, from: data)
                    } else {
                        items = []
                    }
                    
                    OperationQueue.main.addOperation {
                        callback(nil, items)
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
}


