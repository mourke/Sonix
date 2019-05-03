//
//  API+Images.swift
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
     Requests a poster URL from TMDB.
     
     - Parameter id:        The tmdb id of the item.
     - Parameter type:      The type of the media to which the `id` parameter refers.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func poster(for id: String,
                              of type: MediaType,
                              size: ImageSize.Poster,
                              callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        return posters(for: [(id: id, type: type, size: size)]) {
            callback($0, $1[id]!)
        }
    }
    
    /**
     Requests poster URLs from TMDB.
     
     - Parameter info:      An array of tuples providing information about the media for which images are to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func posters(for info: [(id: String, type: MediaType, size: ImageSize.Poster)],
                               callback: @escaping (Error?, [String: URL?]) -> Void) -> URLSessionDataTask {
        var ids: [String: MediaType] = [:]
        info.forEach { ids[$0.id] = $0.type }
        return items(for: ids) {
            var posters: [String: URL?] = [:]
            for (index, item) in $1.enumerated() {
                if let movie = item as? Movie {
                    posters[movie.ids[.tmdb]!] = movie.poster(for: info[index].size)
                } else if let show = item as? Show {
                    posters[show.ids[.tmdb]!] = show.poster(for: info[index].size)
                }
            }
            callback($0, posters)
        }
    }
    
    /**
     Requests a backdrop URL from TMDB.
     
     - Parameter id:        The tmdb id of the item.
     - Parameter type:      The type of the media to which the `id` parameter refers.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func backdrop(for id: String,
                                of type: MediaType,
                                size: ImageSize.Backdrop,
                                callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        return backdrops(for: [(id: id, type: type, size: size)]) {
            callback($0, $1[id]!)
        }
    }
    
    /**
     Requests backdrop URLs from TMDB.
     
     - Parameter info:      An array of tuples providing information about the media for which images are to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func backdrops(for info: [(id: String, type: MediaType, size: ImageSize.Backdrop)],
                                 callback: @escaping (Error?, [String: URL?]) -> Void) -> URLSessionDataTask {
        var ids: [String: MediaType] = [:]
        info.forEach { ids[$0.id] = $0.type }
        return items(for: ids) {
            var backdrops: [String: URL?] = [:]
            for (index, item) in $1.enumerated() {
                if let movie = item as? Movie {
                    backdrops[movie.ids[.tmdb]!] = movie.backdrop(for: info[index].size)
                } else if let show = item as? Show {
                    backdrops[show.ids[.tmdb]!] = show.backdrop(for: info[index].size)
                }
            }
            callback($0, backdrops)
        }
    }
    
    /**
     Requests a season poster URL from TMDB.
     
     - Parameter id:        The tmdb id of the item.
     - Parameter season:    The season whose poster art is to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func seasonPoster(forShowId id: String,
                                    season: Int,
                                    callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.tv + "/\(id)" + Endpoints.season + "/\(season)" + Endpoints.images)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    var url: URL?
                    
                    if let posters = dictionary?["posters"] as? [[String : Any]],
                        let poster = posters.first?["file_path"] as? String,
                        let width = posters.first?["width"] as? Int {
                        let string = "https://image.tmdb.org/t/p/w\(width)" + poster
                        url = URL(string: string)
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
     Requests an episode screenshot from TMDB.
     
     - Parameter id:        The tmdb id for the show.
     - Parameter season:    The season number of the episode whose screenshot is to be fetched.
     - Parameter episode:   The episode number of the episode whose screenshot is to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func episodeScreenshot(forShowId id: String,
                                         season: Int,
                                         episode: Int,
                                         callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.tv + "/\(id)" + Endpoints.season + "/\(season)" + Endpoints.episode + "/\(episode)" + Endpoints.images)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    var url: URL?
                    
                    if let stills = dictionary?["stills"] as? [[String : Any]],
                        let screenshot = stills.first?["file_path"] as? String {
                        let string = "https://image.tmdb.org/t/p/\(ImageSize.Screenshot.large.rawValue)" + screenshot
                        url = URL(string: string)
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
     Requests episode screenshots from TMDB.
     
     - Parameter info:      An array of tuples providing information about the media for which images are to be fetched.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `URL`s along with information to identify the episode with which this image belongs will be returned, however, if it fails, the underlying error will be returned.
     
     - Important: The `URLSessionTask`s will be automatically started when this method is called.
     */
    public static func episodeScreenshots(for info: [(showId: String, season: Int, episode: Int)],
                                          callback: @escaping (Error?, [(showId: String, season: Int, episode: Int, url: URL?)]) -> Void) {
        var screenshots: [(showId: String, season: Int, episode: Int, url: URL?)] = []
        
        guard info.count > 0 else { return callback(nil, screenshots) }
        let group = DispatchGroup()
        var error: Error?
        
        info.forEach {
            group.enter()
            let id = $0.showId
            let season = $0.season
            let episode = $0.episode
            episodeScreenshot(forShowId: id, season: season, episode: episode) {
                error = $0
                screenshots.append((showId: id, season: season, episode: episode, url: $1))
                group.leave()
            }.resume()
        }
        
        group.notify(queue: .main) {
            callback(error, screenshots)
        }
    }
    
    
    
    /**
     Requests a character headshot from TMDB.
     
     - Parameter id:        The tmdb identification code for the person.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, a `URL` will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    public static func characterHeadshot(for id: String, callback: @escaping (Error?, URL?) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.base + Endpoints.person + "/\(id)" + Endpoints.images)!
        
        components.queryItems = [URLQueryItem(name: "api_key", value: Endpoints.apiKey),
                                 URLQueryItem(name: "language", value: language)]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    var url: URL?
                    
                    if let profiles = dictionary?["profiles"] as? [[String : Any]],
                        let headshot = profiles.first?["file_path"] as? String,
                        let width = profiles.first?["width"] as? Int {
                        let string = "https://image.tmdb.org/t/p/w\(width)" + headshot
                        url = URL(string: string)
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
}

