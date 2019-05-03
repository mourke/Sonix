//
//  API+RottenTomatoes.swift
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

enum RottenTomatoesError: Error {
    case errorParsingJSON
}

extension API {
    
    /**
     Retrieves Rotten Tomatoes reviews for a given movie.
     
     - Parameter titled:        The movie's title.
     - Parameter releaseYear:   Unfortunately, Rotten Tomatoes doesn't support searching by IMDB but instead opts to use their own arbitrary ID system. For this reason, the release date of the movie is needed to better match. If two movies with the exact same title came out on the exact same year, the first one (alphabetically sorted) will be returned.
     - Parameter callback:      The closure called when the request completes. If the request completes successfully, a `Reviews` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func reviews(forMovie titled: String,
                        releaseYear: Int,
                        callback: @escaping (Error?, [Review]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.RottenTomatoes.base + Endpoints.RottenTomatoes.v1 + Endpoints.RottenTomatoes.search)!
        
        components.queryItems = [URLQueryItem(name: "q", value: titled)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    guard let data = String(data: data, encoding: .ascii)?.data(using: .utf8) else { throw RottenTomatoesError.errorParsingJSON }// Make sure data is parsed correctly.
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    let movies = dictionary?["movies"] as? [[String : Any]] ?? []
                    
                    if movies.isEmpty { throw RottenTomatoesError.errorParsingJSON }
                    
                    for movie in movies {
                        guard
                            let title = movie["title"] as? String,
                            let year = movie["year"] as? Int,
                            let idString = movie["id"] as? String,
                            let id = Int(idString),
                            title == titled && releaseYear == year
                            else {
                                error = RottenTomatoesError.errorParsingJSON
                                continue
                        }
                        
                        error = nil
                        rottenTomatoesMovie(for: id) { (error, movie) in
                            var reviews: [Review?] = []
                            guard
                                let dictionary = movie["reviews"] as? [String : Any],
                                let critics = dictionary["critics"] as? [[String : Any]],
                                let users = dictionary["recent"] as? [[String : Any]],
                                let flixster = dictionary["flixster"] as? [String : Any],
                                let rottenTomatoes = dictionary["rottenTomatoes"] as? [String : Any] else
                            {
                                OperationQueue.main.addOperation {
                                    callback(error, [])
                                }
                                return
                            }
                            
                            let decoder = JSONDecoder()
                            
                            reviews.append(contentsOf: (try? decoder.decode([CriticReview].self, from: JSONSerialization.data(withJSONObject: critics))) ?? [])
                            reviews.append(contentsOf: (try? decoder.decode([UserReview].self, from: JSONSerialization.data(withJSONObject: users))) ?? [])
                            reviews.append(try? decoder.decode(FlixsterReview.self, from: JSONSerialization.data(withJSONObject: flixster)))
                            reviews.append(try? decoder.decode(RottenTomatoesReview.self, from: JSONSerialization.data(withJSONObject: rottenTomatoes)))
                            
                            OperationQueue.main.addOperation {
                                callback(nil, reviews.compactMap({$0}))
                            }
                        }.resume()
                        
                        break
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
