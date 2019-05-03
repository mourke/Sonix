//
//  API+Trakt.swift
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
import TraktKit
import TMDBKit

extension API {
    
    static func unFinished(callback: @escaping (Error?, [PlaybackProgress]) -> Void) -> [URLSessionDataTask] {
        let group = DispatchGroup()
        var requests: [URLSessionDataTask?] = []
        
        var playbackProgress: [PlaybackProgress] = []
        var error: Error?
        
        let completion: (ObjectsResultType<PlaybackProgress>) -> Void = { (result) in
            switch result {
            case .success(var result):
                let imageGroup = DispatchGroup()
                
                var ids: [String : TMDBKit.MediaType] = [:]
                result.forEach {
                    guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return }
                    let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                    ids[String(id)] = type
                }
                
                imageGroup.enter()
                TMDBKit.items(for: ids) {
                    for item in $1 {
                        if let movie = item as? Movie, let index = result.index(where: {
                            guard let lhs = $0.movie?.ids.tmdb,
                                let rhs = movie.ids[.tmdb] else { return false }
                            return String(lhs) == rhs
                        }) {
                            result[index].movie?.posterImage = movie.poster(for: .small)
                            result[index].movie?.backdropImage = movie.backdrop(for: .medium)
                        } else if let show = item as? Show {
                            result.filter({
                                guard let lhs = $0.show?.ids.tmdb,
                                    let rhs = show.ids[.tmdb] else { return false }
                                return String(lhs) == rhs
                            }).forEach {
                                let index = result.index(of: $0)!
                                result[index].show?.posterImage = show.poster(for: .small)
                                result[index].show?.backdropImage = show.backdrop(for: .medium)
                            }
                            
                        }
                    }
                    imageGroup.leave()
                }.resume()
                
                imageGroup.enter()
                TMDBKit.episodeScreenshots(for: result.compactMap {
                    guard let id = $0.show?.ids.tmdb, let episode = $0.episode else { return nil }
                    return (String(id), episode.season, episode.number)
                }) { (_, screenshots) in
                    for (id, season, episode, url) in screenshots {
                        guard let index = result.index(where: {$0.show?.ids.tmdb == Int(id) && $0.episode?.number == episode && $0.episode?.season == season}) else { continue }
                        result[index].episode?.screenshotImage = url
                    }
                    imageGroup.leave()
                }
                
                imageGroup.notify(queue: .main) {
                    playbackProgress.append(contentsOf: result)
                    group.leave()
                }
            case .error(let result):
                error = error == nil ? result : error
                group.leave()
            }
        }
        
        group.enter()
        requests.append(TraktManager.sharedManager.getPlaybackProgress(type: .movies, extended: [.full], completion: completion))
        
        group.enter()
        requests.append(TraktManager.sharedManager.getPlaybackProgress(type: .episodes, extended: [.full], completion: completion))
        
        group.notify(queue: .main) {
            callback(error, playbackProgress)
        }
        
        return requests.compactMap({$0})
    }
    
    static func upNext(callback: @escaping (Error?, [(show: TraktShow, episode: TraktEpisode)]) -> Void) -> URLSessionDataTask? {
        return TraktManager.sharedManager.getWatchedShows(extended: [.full]) { (result) in
            let group = DispatchGroup()
            
            var upNext: [(show: TraktShow, episode: TraktEpisode)] = []
            var error: Error?
            
            switch result {
            case .success(let shows):
                for show in shows {
                    group.enter()
                    TraktManager.sharedManager.getShowWatchedProgress(showID: show.show.ids.trakt) { (result) in
                        switch result {
                        case .success(let result):
                            guard result.completed != result.aired, // trakt will sometimes return unaired episodes as up next to watch. This is undesired.
                                var episode = result.nextEpisode,
                                let id = show.show.ids.tmdb else { group.leave(); break }
                            TMDBKit.episodeScreenshot(forShowId: String(id), season: episode.season, episode: episode.number) {
                                episode.screenshotImage = $1
                                upNext.append((show.show, episode))
                                error = error == nil ? $0 : error
                                group.leave()
                            }.resume()
                        case .error(let result):
                            error = error == nil ? result : error
                            group.leave()
                        }
                    }?.resume()
                }
            case .error(let result):
                return OperationQueue.main.addOperation {
                    callback(result, [])
                }
            }
            
            group.notify(queue: .main) {
                TMDBKit.posters(for: upNext.compactMap({(String($0.show.ids.tmdb!), .tv, ImageSize.Poster.medium)})) { (_, posters) in
                    for (id, url) in posters {
                        guard let index = upNext.index(where: {$0.show.ids.tmdb == Int(id)}) else { continue }
                        upNext[index].show.posterImage = url
                    }
                    callback(error, upNext)
                }.resume()
            }
        }
    }
    
    static func watchlist(callback: @escaping (Error?, [TraktListItem]) -> Void) -> [URLSessionDataTask] {
        let group = DispatchGroup()
        var requests: [URLSessionDataTask?] = []
        
        var watchlist: [TraktListItem] = []
        var error: Error?
        
        let completion: TraktManager.ListItemCompletionHandler = { (result) in
            switch result {
            case .success(let result):
                watchlist.append(contentsOf: result)
            case .error(let result):
                error = error == nil ? result : error
            }
            group.leave()
        }
        
        group.enter()
        requests.append(TraktManager.sharedManager.getWatchlist(type: .movies, extended: [.full], completion: completion))
        
        group.enter()
        requests.append(TraktManager.sharedManager.getWatchlist(type: .shows, extended: [.full], completion: completion))
        
        group.notify(queue: .main) {
            TMDBKit.posters(for: watchlist.compactMap {
                guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return nil }
                let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                return (String(id), type, ImageSize.Poster.medium)
            }) { (_, posters) in
                for (id, url) in posters {
                    guard let index = watchlist.index(where: {($0.movie?.ids.tmdb ?? $0.show?.ids.tmdb) == Int(id)}) else { continue }
                    watchlist[index].movie?.posterImage = url
                    watchlist[index].show?.posterImage = url
                }
                callback(error, watchlist)
            }.resume()
        }
        
        return requests.compactMap({$0})
    }
    
    static func recommended(callback: @escaping (Error?, [(TraktShow?, TraktMovie?)]) -> Void) -> [URLSessionDataTask] {
        let group = DispatchGroup()
        var requests: [URLSessionDataTask?] = []
        
        var recommended: [(show: TraktShow?, movie: TraktMovie?)] = []
        var error: Error?
        
        group.enter()
        requests.append(TraktManager.sharedManager.getRecommendedShows(extended: [.full]) { (result) in
            switch result {
            case .success(let result):
                result.forEach {
                    recommended.append(($0, nil))
                }
            case .error(let result):
                error = error == nil ? result : error
            }
            group.leave()
        })
        
        group.enter()
        requests.append(TraktManager.sharedManager.getRecommendedMovies(extended: [.full]) { (result) in
            switch result {
            case .success(let result):
                result.forEach {
                    recommended.append((nil, $0))
                }
            case .error(let result):
                error = error == nil ? result : error
            }
            group.leave()
        })
        
        group.notify(queue: .main) {
            TMDBKit.posters(for: recommended.compactMap {
                guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return nil }
                let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                return (String(id), type, ImageSize.Poster.medium)
            }) { (_, posters) in
                for (id, url) in posters {
                    guard let index = recommended.index(where: {($0.movie?.ids.tmdb ?? $0.show?.ids.tmdb) == Int(id)}) else { continue }
                    recommended[index].movie?.posterImage = url
                    recommended[index].show?.posterImage = url
                }
                callback(error, recommended)
            }.resume()
        }
        
        return requests.compactMap({$0})
    }
    
    static func friendsActivity(callback: @escaping (Error?, [TraktWatching: [Friend]]) -> Void) -> URLSessionDataTask? {
        return TraktManager.sharedManager.getFriends { (result) in
            let group = DispatchGroup()
            
            var social: [TraktWatching: [Friend]] = [:]
            var error: Error?
            
            switch result {
            case .success(let friends):
                for friend in friends where friend.user.username != nil {
                    group.enter()
                    TraktManager.sharedManager.getWatching(username: friend.user.username!) { (result) in
                        switch result {
                        case .checkedIn(let watching):
                            var friends = social[watching] ?? []
                            friends.append(friend)
                            social[watching] = friends
                        case .error(let result):
                            error = error == nil ? result : error
                        case .notCheckedIn:
                            break
                        }
                        group.leave()
                    }?.resume()
                }
            case .error(let result):
                return OperationQueue.main.addOperation {
                    callback(result, [:])
                }
            }
            
            group.notify(queue: .main) {
                TMDBKit.backdrops(for: social.keys.compactMap {
                    guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return nil }
                    let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                    return (String(id), type, ImageSize.Backdrop.medium)
                }) { (_, posters) in
                    for (id, url) in posters {
                        guard let index = Array(social.keys).index(where: {($0.movie?.ids.tmdb ?? $0.show?.ids.tmdb) == Int(id)}) else { continue }
                        var watching = Array(social.keys)[index]
                        let friends = social.remove(at: social.index(forKey: watching)!).value
                        watching.movie?.backdropImage = url
                        watching.show?.backdropImage = url
                        
                        social[watching] = friends
                    }
                    callback(error, social)
                }.resume()
            }
        }
    }
    
    static func relatedToHistory(callback: @escaping (Error?, [TraktHistoryItem], TraktHistoryItem?, [Codable]) -> Void) -> URLSessionDataTask? {
        return TraktManager.sharedManager.getHistory(extended: [.full], pagination: Pagination(page: 1, limit: 30)) { (result) in
            switch result {
            case .success(let history):
                var items: [TraktHistoryItem] = []
                history.objects.forEach { (item) in
                    if let show = item.show {
                        // Duplicates can exist due to a user watching multiple episodes of the same show in sequence.
                        items.contains(where: {$0.show == show}) ? () : items.append(item)
                    } else {
                        items.append(item)
                    }
                }
                let randomItem = items[Int(arc4random_uniform(UInt32(items.count)))]
                
                let completion: ([Codable], Error?) -> Void = { (result, error) in
                    var result = result
                    if let error = error {
                        OperationQueue.main.addOperation {
                            callback(error, [], nil, [])
                        }
                    } else {
                        TMDBKit.posters(for: items.compactMap {
                            guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return nil }
                            let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                            return (String(id), type, ImageSize.Poster.medium)
                            } + result.compactMap {
                                if let movie = $0 as? TraktMovie, let id = movie.ids.tmdb {
                                    return (String(id), .movie, ImageSize.Poster.medium)
                                } else if let show = $0 as? TraktShow, let id = show.ids.tmdb {
                                    return (String(id), .tv, ImageSize.Poster.medium)
                                }
                                return nil
                        }) { (_, posters) in
                            for (id, url) in posters {
                                if let item = items.first(where: {
                                    ($0.movie?.ids.tmdb ?? $0.show?.ids.tmdb) == Int(id)
                                }) {
                                    let index = items.index(of: item)!
                                    
                                    items[index].movie?.posterImage = url
                                    items[index].show?.posterImage = url
                                } else if let index = result.firstIndex(where: {
                                    if let movie = $0 as? TraktMovie {
                                        return movie.ids.tmdb == Int(id)
                                    } else if let show = $0 as? TraktShow {
                                        return show.ids.tmdb == Int(id)
                                    }
                                    return false
                                }) {
                                    if var movie = result[index] as? TraktMovie {
                                        movie.posterImage = url
                                        result[index] = movie
                                    } else {
                                        var show = result[index] as! TraktShow
                                        show.posterImage = url
                                        result[index] = show
                                    }
                                }
                            }
                            callback(nil, items, randomItem, result)
                        }.resume()
                    }
                }
                if let movie = randomItem.movie {
                    TraktManager.sharedManager.getRelatedMovies(movieID: movie.ids.trakt, extended: [.full]) { (result) in
                        switch result {
                        case .success(let result):
                            completion(result, nil)
                        case .error(let error):
                            completion([], error)
                        }
                    }?.resume()
                } else {
                    let show = randomItem.show!
                    TraktManager.sharedManager.getRelatedShows(showID: show.ids.trakt, extended: [.full]) { (result) in
                        switch result {
                        case .success(let result):
                            completion(result, nil)
                        case .error(let error):
                            completion([], error)
                        }
                    }?.resume()
                }
            case .error(let error):
                OperationQueue.main.addOperation {
                    callback(error, [], nil, [])
                }
            }
        }
    }
    
    static func anticipated(callback: @escaping (Error?, [TraktAnticipated]) -> Void) -> [URLSessionDataTask] {
        let group = DispatchGroup()
        var requests: [URLSessionDataTask?] = []
        
        var anticipated: [TraktAnticipated] = []
        var error: Error?
        
        let completion: TraktManager.AnticipatedCompletionHandler = { (result) in
            switch result {
            case .success(let result):
                anticipated.append(contentsOf: result)
            case .error(let result):
                error = error == nil ? result : error
            }
            group.leave()
        }
        
        group.enter()
        requests.append(TraktManager.sharedManager.getAnticipatedShows(page: 1, limit: 10, extended: [.full], completion: completion))
        
        group.enter()
        requests.append(TraktManager.sharedManager.getAnticipatedMovies(page: 1, limit: 10, extended: [.full], completion: completion))
        
        group.notify(queue: .main) {
            TMDBKit.posters(for: anticipated.compactMap {
                guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return nil }
                let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                return (String(id), type, ImageSize.Poster.medium)
            }) { (_, posters) in
                for (id, url) in posters {
                    guard let index = anticipated.index(where: {($0.movie?.ids.tmdb ?? $0.show?.ids.tmdb) == Int(id)}) else { continue }
                    anticipated[index].movie?.posterImage = url
                    anticipated[index].show?.posterImage = url
                }
                callback(error, anticipated)
            }.resume()
        }
        
        return requests.compactMap({$0})
    }
    
    static func lists(callback: @escaping (Error?, [TraktList]) -> Void) -> URLSessionDataTask? {
        return TraktManager.sharedManager.getPopularLists(page: Int(arc4random_uniform(16)), limit: 6) { (result) in
            switch result {
            case .success(let result):
                var lists: [TraktList] = []
                let group = DispatchGroup()
                var error: Error?
                
                for var list in result.objects.map({$0.list}) {
                    group.enter()
                    TraktManager.sharedManager.getItemsForCustomList(username: list.user.ids.slug, listID: list.ids.trakt) { (result) in
                        switch result {
                        case .success(var result):
                            var ids: [String : TMDBKit.MediaType] = [:]
                            result.forEach {
                                guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return }
                                let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                                ids[String(id)] = type
                            }
                            
                            TMDBKit.posters(for: result.compactMap {
                                guard let id = $0.movie?.ids.tmdb ?? $0.show?.ids.tmdb else { return nil }
                                let type: TMDBKit.MediaType = $0.movie == nil ? .tv : .movie
                                return (String(id), type, ImageSize.Poster.medium)
                            }) { (_, posters) in
                                for (id, url) in posters {
                                    guard let index = result.index(where: {($0.movie?.ids.tmdb ?? $0.show?.ids.tmdb) == Int(id)}) else { continue }
                                    result[index].movie?.posterImage = url
                                    result[index].show?.posterImage = url
                                }
                                
                                list.items = result
                                lists.append(list)
                                group.leave()
                            }.resume()
                        case .error(let result):
                            error = error == nil ? result : error
                            group.leave()
                        }
                    }?.resume()
                }
                
                group.notify(queue: .main) {
                    callback(error, lists)
                }
            case .error(let result):
                OperationQueue.main.addOperation {
                    callback(result, [])
                }
            }
        }
    }
    
    static func listIsLiked(_ list: TraktList, callback: @escaping (Error?, Bool?) -> Void) -> URLSessionDataTask? {
        return TraktManager.sharedManager.getLikes(type: .lists) { (result) in
            let liked: Bool?
            let error: Error?
            
            switch result {
            case .success(let result):
                liked = result.compactMap({$0.list}).contains(list)
                error = nil
            case .error(let result):
                error = result
                liked = nil
            }
            
            OperationQueue.main.addOperation {
                callback(error, liked)
            }
        }
    }
}
