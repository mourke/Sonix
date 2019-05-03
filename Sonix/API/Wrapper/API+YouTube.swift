//
//  API+YouTube.swift
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
import struct TMDBKit.Video

extension API {
    
    /**
     Requests movie extras from YouTube.
     
     - Parameter titled:    The title of the movie.
     - Parameter callback:  The closure called when the request completes. If the request completes successfully, an array of `Video`s will be returned, however, if it fails, the underlying error will be returned.
     
     - Returns: The request's unresumed `URLSessionTask`.
     */
    static func videos(forMovie titled: String,
                       callback: @escaping (Error?, [Video]) -> Void) -> URLSessionDataTask {
        let session = URLSession.shared
        
        var components = URLComponents(string: Endpoints.YouTube.base + Endpoints.YouTube.search)!
        
        components.queryItems = [URLQueryItem(name: "part", value: "snippet"),
                                 URLQueryItem(name: "channelId", value: "UCmQynT5NWU3Vsa9t0OGUhcA"),
                                 URLQueryItem(name: "q", value: titled),
                                 URLQueryItem(name: "type", value: "video"),
                                 URLQueryItem(name: "key", value: Endpoints.YouTube.apiKey),
                                 URLQueryItem(name: "maxResults", value: "50")]
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            var error = error
            
            if let data = data {
                do {
                    let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                    
                    var videos: [Video] = []
                    
                    (dictionary?["items"] as? [[String : Any]])?.forEach {
                        if let ids = $0["id"] as? [String : String],
                            let snippet = $0["snippet"] as? [String : Any],
                            let title = snippet["title"] as? String,
                            let id = ids["videoId"],
                            title.lowercased().contains(titled.lowercased()) // Sometimes weird things can be returned.
                        {
                            let category: Video.Category
                            
                            switch title {
                            case _ where title.contains(Video.Category.behindTheScenes.rawValue):
                                category = .behindTheScenes
                            case _ where title.contains(Video.Category.featurette.rawValue):
                                category = .featurette
                            case _ where title.contains(Video.Category.teaser.rawValue):
                                category = .teaser
                            case _ where title.contains(Video.Category.trailer.rawValue):
                                category = .trailer
                            case _ where title.contains(Video.Category.openingCredits.rawValue):
                                category = .openingCredits
                            case _ where title.contains(Video.Category.clip.rawValue):
                                fallthrough
                            default:
                                category = .clip
                            }
                            
                            let video = Video(id: id, title: title, resolution: 1080, category: category)
                            videos.append(video)
                        }
                    }
                    
                    
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
}
