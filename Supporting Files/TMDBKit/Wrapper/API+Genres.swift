//
//  API+Genres.swift
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
     Lists all the possible genres a movie can have.
     
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Genre` objects will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func movieGenres(_ callback: @escaping (Error?, [Genre]) -> Void) -> URLSessionDataTask {
        return genres(for: .movie, callback: callback)
    }
    
    /**
     Lists all the possible genres a show can have.
     
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Genre` objects will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func showGenres(_ callback: @escaping (Error?, [Genre]) -> Void) -> URLSessionDataTask {
        return genres(for: .tv, callback: callback)
    }
    
    private static func genres(for type: MediaType,
                               callback: @escaping (Error?, [Genre]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.genre + "/\(type)" + Endpoints.list)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    var genres: [Genre] = []
                    
                    if let genresDictionary = dictionary?["genres"] as? [[String : Any]] {
                        genres = try JSONDecoder().decode([Genre].self, from: JSONSerialization.data(withJSONObject: genresDictionary))
                    }
                    
                    OperationQueue.main.addOperation {
                        callback(nil, genres)
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
