//
//  API+Details.swift
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
     Requests details about a movie from TMDB.
     
     - Parameter id:        The tmdb identification code for the movie.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `Movie` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func getMovie(for id: Int, callback: @escaping (Error?, Movie?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.movie + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language),
                                 URLQueryItem(name: "append_to_response", value: "credits,external_ids,videos,similar,release_dates")]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let movie = try JSONDecoder().decode(Movie.self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, movie)
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
     Requests details about a show from TMDB.
     
     - Parameter id:        The tmdb identification code for the show.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `Show` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func getShow(for id: Int, callback: @escaping (Error?, Show?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.tv + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language),
                                 URLQueryItem(name: "append_to_response", value: "content_ratings,credits,external_ids,videos,similar")]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let show = try JSONDecoder().decode(Show.self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, show)
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
     Requests details about a season from TMDB.
     
     - Parameter season:    The season's number.
     - Parameter id:        The tmdb identification code for the show of which the season is a part.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `Season` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func getSeason(_ season: Int,
                                 inShow id: Int,
                                 callback: @escaping (Error?, Season?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.tv + "/\(id)" + Endpoints.season + "/\(season)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language),
                                 URLQueryItem(name: "append_to_response", value: "videos")]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    let season = try decoder.decode(Season.self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, season)
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
     Requests details about a person from TMDB.
     
     - Parameter id:        The tmdb identification code for the person.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `DetailPerson` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func getPerson(for id: Int, callback: @escaping (Error?, DetailPerson?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.person + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language),
                                 URLQueryItem(name: "append_to_response", value: "combined_credits,external_ids,tagged_images")]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    var person = try decoder.decode(DetailPerson.self, from: data)
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    var guestAppearanceIds: [String : Show] = [:]
                    
                    if let credits = dictionary?["combined_credits"] as? [String : [[String : Any]]] {
                        credits["cast"]?.forEach { (item) in
                            let type = item["media_type"] as? String
                            if type == "movie",
                                let data = try? JSONSerialization.data(withJSONObject: item),
                                let movie = try? decoder.decode(Movie.self, from: data)
                            {
                                person.cast.append(movie)
                            } else if type == "tv",
                                let data = try? JSONSerialization.data(withJSONObject: item),
                                let show = try? decoder.decode(Show.self, from: data),
                                let episodes = item["episode_count"] as? Int,
                                let creditId = item["credit_id"] as? String {
                                if episodes < 10 // We don't know for sure what episodes the actor guest starred in so we guess and confirm later. If the actor appeared in less than ten episodes they were probably an extra. This is done to save on bandwith.
                                {
                                    guestAppearanceIds[creditId] = show
                                } else {
                                    person.cast.append(show)
                                }
                            }
                        }
                        credits["crew"]?.forEach { (item) in
                            let type = item["media_type"] as? String
                            let department = item["department"] as? String
                            if type == "movie",
                                let data = try? JSONSerialization.data(withJSONObject: item),
                                let movie = try? decoder.decode(Movie.self, from: data),
                                let department = department
                            {
                                var crew = person.crew[department] ?? []
                                crew.append(movie)
                                person.crew[department] = crew
                            } else if type == "tv",
                                let data = try? JSONSerialization.data(withJSONObject: item),
                                let show = try? decoder.decode(Show.self, from: data),
                                let department = department {
                                var crew = person.crew[department] ?? []
                                crew.append(show)
                                person.crew[department] = crew
                            }
                        }
                    }
                    
                    let group = DispatchGroup()
                    
                    guestAppearanceIds.forEach { (id, show) in
                        group.enter()
                        getTVCredit(for: id) { (error, _, episodes, seasons) in
                            defer { group.leave() }
                            guard error == nil else { return }
                            if !episodes.isEmpty && seasons.isEmpty {
                                episodes.forEach {
                                    person.guestAppearances.append((show, $0))
                                }
                            } else {
                                person.cast.append(show)
                            }
                        }.resume()
                    }
                    
                    group.notify(queue: .main) {
                        callback(nil, person)
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
     Requests the episodes or seasons an actor was in from TMDB.
     
     - Parameter id:        The tmdb identification code for the credit.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, the character the person played, an array of `Episode`s and an array of `Season`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func getTVCredit(for id: String,
                                   callback: @escaping (Error?, String?, [Episode], [Season]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.credit + "/\(id)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    if let media = dictionary?["media"] as? [String : Any],
                        let type = dictionary?["media_type"] as? String,
                        type == "tv",
                        let character = media["character"] as? String,
                        let episodesDictionary = media["episodes"] as? [[String : Any]],
                        let seasonsDictionary = media["seasons"] as? [[String : Any]] {
                        var episodes: [Episode] = []
                        var seasons: [Season] = []
                        
                        if let data = try? JSONSerialization.data(withJSONObject: episodesDictionary) {
                            episodes = (try? decoder.decode([Episode].self, from: data)) ?? []
                        }
                        if let data = try? JSONSerialization.data(withJSONObject: seasonsDictionary) {
                            seasons = (try? decoder.decode([Season].self, from: data)) ?? []
                        }
                        
                        OperationQueue.main.addOperation {
                            callback(nil, character, episodes, seasons)
                        }
                    } else {
                        OperationQueue.main.addOperation {
                            callback(nil, nil, [], [])
                        }
                    }
                } catch let e {
                    error = e
                }
            }
            
            if let error = error {
                OperationQueue.main.addOperation {
                    callback(error, nil, [], [])
                }
            }
        }
        
        return task
    }
    
    /**
     Requests an episode from TMDB.
     
     - Parameter showId:    The tmdb identification code of the show to which the episode belongs.
     - Parameter episode:   The episode number.
     - Parameter season:    The season to which the episode belongs.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an `Episode` object will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func getEpisode(showId: Int,
                                  episode: Int,
                                  season: Int,
                                  callback: @escaping (Error?, Episode?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.tv + "/\(showId)" + Endpoints.season + "/\(season)" + Endpoints.episode + "/\(episode)")!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        return session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    decoder.dateDecodingStrategy = .formatted(formatter)
                    
                    let episode = try decoder.decode(Episode.self, from: data)
                    
                    OperationQueue.main.addOperation {
                        callback(nil, episode)
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
}

