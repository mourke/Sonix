//
//  API+Search.swift
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
     Requests items currently popular on TMDB and optionally filters the results.
     
     - Parameter page:      The page on which to fetch results. Max. 1000.
     - Parameter type:      The type of the data to be fetched. Must be either `Movie`, `Show`, or `SearchPerson`.
     - Parameter query:     The name of a person for which to search. Defaults to `nil`.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of items will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func popularItems<I: Decodable>(of type: I.Type,
                                                  on page: UInt = 1,
                                                  query: String? = nil,
                                                  callback: @escaping (Error?, [I]) -> Void) -> URLSessionDataTask {
        assert(page <= 1000, "No more than 1000 pages can be requested")
        
        let session = URLSession.shared
        
        var endpoint: String
        
        if type == Movie.self {
            endpoint = Endpoints.movie
        } else if type == Show.self {
            endpoint = Endpoints.tv
        } else if type == SearchPerson.self {
            endpoint = Endpoints.person
        } else {
            fatalError()
        }
        
        if query != nil {
            endpoint = Endpoints.search + endpoint
        } else {
            endpoint = endpoint + Endpoints.popular
        }
        
        var components = URLComponents(string: Endpoints.base + endpoint)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language),
                                 URLQueryItem(name: "page", value: "\(page)"),
                                 URLQueryItem(name: "query", value: query)]
        
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
    
    /**
     Searches for objects in the tmdb database by an external id. For example, an IMDB ID.
     
     - Parameter type:      The type of the item being requested. Can be `Movie`, `Show`, `Episode`, `Season` or any `Person`.
     - Parameter id:        The external id of the item.
     - Parameter source:    The database to which the id belongs.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, the item will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func find<T: Decodable>(_ type: T.Type,
                                          withId id: String,
                                          ofType source: Id,
                                          callback: @escaping (Error?, T?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.find + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language),
                                 URLQueryItem(name: "external_source", value: source.rawValue)]
        
        return session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : [[String : Any]]]
                    let resultsDictionary: [String : Any]
                    
                    if type == Movie.self {
                        resultsDictionary = dictionary?["movie_results"]?.first ?? [:]
                    } else if type == Show.self {
                        resultsDictionary = dictionary?["tv_results"]?.first ?? [:]
                    } else if type == Episode.self {
                        resultsDictionary = dictionary?["tv_episode_results"]?.first ?? [:]
                    } else if type == Season.self {
                        resultsDictionary = dictionary?["tv_season_results"]?.first ?? [:]
                    } else if type == Person.self {
                        resultsDictionary = dictionary?["person_results"]?.first ?? [:]
                    } else {
                        fatalError()
                    }
                    
                    let data = try JSONSerialization.data(withJSONObject: resultsDictionary)
                    let item = try decoder.decode(T.self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, item)
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
     Bulk-search for items by TMDB id.
     
     - Parameter ids:       The tmdb id of the item and the type of the item.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Movie` and `Show` objects will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func items(for ids: [String: MediaType],
                             callback: @escaping (Error?, [Decodable]) -> Void) -> URLSessionDataTask {
        return createList(named: UUID().uuidString) { (error, id) in
            if let id = id {
                add(items: ids, toList: id) { (error) in
                    if let error = error {
                        OperationQueue.main.addOperation {
                            callback(error, [])
                        }
                        delete(list: id).resume()
                    } else {
                        list(for: id) { (error, contents) in
                            if let error = error {
                                OperationQueue.main.addOperation {
                                    callback(error, [])
                                }
                            } else {
                                var items: [Decodable] = []
                                
                                for item in contents {
                                    if let movie = item as? Movie {
                                        items.append(movie)
                                    } else if let show = item as? Show {
                                        items.append(show)
                                    } else {
                                        fatalError()
                                    }
                                }
                                
                                OperationQueue.main.addOperation {
                                    callback(nil, items)
                                }
                            }
                            
                            delete(list: id).resume()
                        }.resume()
                    }
                }.resume()
            } else {
                OperationQueue.main.addOperation {
                    callback(error, [])
                }
            }
        }
    }
}

