//
//  API+Flixster.swift
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
     Retrieves nearby cinema screenings. Location services is not needed for this call, the api simply uses geo-ip methods to track the user's location.
     
     - Parameter date:      The date for which to fetch cinema listings.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Cinema`s will be returned, however, if it fails, the underlying error will be returned. Each cinema object contains an array of screenings, containing showtimes and metadata about the movie.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func nearbyCinemaScreenings(on date: Date = .init(), callback: @escaping (Error?, [Cinema]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.Flixster.base + Endpoints.Flixster.ticketing + Endpoints.Flixster.theaters)!
        
        let formatter =  DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        components.queryItems = [URLQueryItem(name: "showtimes", value: "true"),
                                 URLQueryItem(name: "fullMovieInfo", value: "true"),
                                 URLQueryItem(name: "date", value: formatter.string(from: date))]
        
        var request = URLRequest(url: components.url!)
        request.addValue("https://www.rottentomatoes.com/showtimes/", forHTTPHeaderField: "Referer")
        
        let task = session.dataTask(with: request) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    var cinemas: [Cinema] = []
                    
                    if let theaters = dictionary?["theaters"] as? [String : Any],
                    let movies = dictionary?["movies"] as? [String: Any] {
                        
                        for (_, value) in theaters {
                            guard
                                var dictionary = value as? [String : Any],
                                let showings = dictionary["movies"] as? [[String : Any]],
                                let data = try? JSONSerialization.data(withJSONObject: dictionary),
                                var cinema = try? JSONDecoder().decode(Cinema.self, from: data)
                                else {
                                    continue
                            }
                            
                            for var showing in showings {
                                guard let id = showing["id"] as? Int,
                                let movie = movies["\(id)"] as? [String : Any] else { continue }
                                
                                showing.merge(movie) { (_, new) in new } // Merge the showtimes dictionary with the movie metadata dictionary so the movies are aware of their own showtimes.
                                
                                guard
                                    let data = try? JSONSerialization.data(withJSONObject: showing),
                                    let screening = try? JSONDecoder().decode(Screening.self, from: data) else { continue }
                                
                                cinema.screenings.append(screening)
                            }
                            cinema.screenings.isEmpty ? () : cinemas.append(cinema)
                        }
                    }
                    
                    OperationQueue.main.addOperation {
                        callback(nil, cinemas)
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
     Fetches information about a movie.
     
     - Parameter id:    The Rotten Tomatoes id of the movie.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a movie dictionary will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func rottenTomatoesMovie(for id: Int, callback: @escaping (Error?, [String: Any]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        let task = session.dataTask(with: URL(string: Endpoints.Flixster.mobileBase + Endpoints.Flixster.movies + "/\(id)")!) { (data, response, error) in
            var error = error
            
            if let data = data,
                let reEncodedData = String(data: data, encoding: .isoLatin1)?.data(using: .utf8) // Api has the wrong content-type.
            {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: reEncodedData) as? [String : Any]
                    
                    if let code = dictionary?["errorCode"] as? Int,
                        let description = dictionary?["error"] as? String {
                        error = NSError(domain: "com.mourke.sonix.error", code: code, userInfo: [NSLocalizedDescriptionKey: description]) as Error
                    } else {
                        OperationQueue.main.addOperation {
                            callback(nil, dictionary ?? [:])
                        }
                    }
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                OperationQueue.main.addOperation {
                    callback(error, [:])
                }
            }
        }
        
        return task
    }
}
