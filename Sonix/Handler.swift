//
//  AppDelegate+Handlers.swift
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
import struct MediaPlayer.MPMediaItem.MPMediaType
import TMDBKit
import TraktKit
import PutKit
import AVKit

class Handler: NSObject {
    
    /// The shared singleton instance
    static let shared = Handler()
    
    /// The root navigation controller in the app's hierarchy.
    private var rootNavigationController: UINavigationController? {
        let window: UIWindow? = UIApplication.shared.delegate?.window ?? nil
        let tabBarController = window?.rootViewController as? UITabBarController
        return tabBarController?.selectedViewController as? UINavigationController
    }
    
    /// The app's 'Main' storyboard.
    private var storyboard: UIStoryboard {
        return UIStoryboard(name: "Main", bundle: .main)
    }
    
    /**
     A method that converts a method signature into a selector and passes the specified parameters to the method.
     
     - Parameter methodSignature:   The name of the method's signature.
     - Parameter parameters:        The parameters to be passed to the method.
     */
    func performSelector(named methodSignature: String, parameters: [String]) {
        let selector = Selector(methodSignature + Array<String>(repeating: ":", count: parameters.count).joined())
        
        perform(selector, parameters: parameters)
    }
    
    /**
     The action handler for when the app is passed in urls.
     
     - Parameter url:   The url that the app was passed in with the sonix:// url scheme. The format of this url is expected to be: 'sonix://methodName'. Parameters can be added by appending '»parameter' as needed. Parameters must take a string form and will be converted into their actual types by the function.
     */
    func handle(_ url: URL) {
        let id = url.host!
        var pieces = id.components(separatedBy: "»")
        performSelector(named: pieces.removeFirst(), parameters: pieces)
    }
    
    /**
     Pushes a detail view controller to the navigation stack for the given TMDB id.
     
     - Parameter typeString:    The `MPMediaType` rawValue as a `String`. Either `.tvShow`, `.movie` or `.person`.
     - Parameter idString:      The media's TMDB id as a `String`.
     */
    @objc func showDetail(_ typeString: String, _ idString: String) {
        let type = MPMediaType(rawValue: UInt(typeString)!)
        let id = Int(idString)!
        
        let viewController: DetailTableViewController
        
        if type == .person {
            viewController = storyboard.instantiateViewController(withIdentifier: String(describing: PersonDetailTableViewController.self)) as! PersonDetailTableViewController
        } else {
            viewController = storyboard.instantiateViewController(withIdentifier: String(describing: MediaItemDetailTableViewController.self)) as! MediaItemDetailTableViewController
        }
        
        let loadingViewController = storyboard.instantiateViewController(withIdentifier: String(describing: LoadingViewController.self)) as! LoadingViewController
        rootNavigationController?.pushViewController(loadingViewController, animated: true)
        
        let presentViewController: ((UIViewController) -> Void) = { (viewController) in
            guard self.rootNavigationController?.visibleViewController === loadingViewController else { // Make sure we're still loading and the user hasn't dismissed the view.
                return
            }
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            transition.type = .fade
            self.rootNavigationController?.view.layer.add(transition, forKey: "fadeTransition")
            
            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + transition.duration) {
                    var viewControllers = self.rootNavigationController?.viewControllers ?? []
                    if let index = viewControllers.index(where: {$0 === loadingViewController}) {
                        viewControllers.remove(at: index)
                        self.rootNavigationController?.setViewControllers(viewControllers, animated: false)
                    }
                    self.rootNavigationController?.view.layer.removeAnimation(forKey: "fadeTransition")
                }
            }
            
            self.rootNavigationController?.pushViewController(viewController, animated: false)
        }
        
        switch type {
        case .movie:
            TMDBKit.getMovie(for: id) { (error, movie) in
                if let movie = movie {
                    let group = DispatchGroup()
                    
                    var reviews: [Review] = []
                    var torrents: [Torrent] = []
                    var extras: [Video] = []
                    var logoURL: URL?
                    
                    if let imdbId = movie.ids[.imdb] {
                        group.enter()
                        API.logo(for: imdbId, of: .movies) { (_, url) in
                            logoURL = url
                            group.leave()
                        }.resume()
                        
                        group.enter()
                        TorrentKit.torrentsFor(movieId: imdbId) { (_, torrent) in
                            torrents = torrent
                            group.leave()
                        }.resume()
                    }
                    
                    group.enter()
                    API.videos(forMovie: movie.originalTitle) { (_, videos) in
                        extras = videos
                        group.leave()
                    }.resume()
                    
                    if let date = movie.releaseDate {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy"
                        
                        group.enter()
                        API.reviews(forMovie: movie.originalTitle, releaseYear: Int(formatter.string(from: date))!) { (_, review) in
                            reviews = review
                            group.leave()
                        }.resume()
                    }
                    
                    group.notify(queue: .main) {
                        let viewController = viewController as! MediaItemDetailTableViewController
                        let item = MediaItem(movie: movie, logoURL: logoURL, reviews: reviews, extras: extras, torrents: torrents)
                        viewController.mediaItem = item
                        presentViewController(viewController)
                    }
                } else if let error = error {
                    let viewController = UIViewController()
                    viewController.view = ErrorView.init(error)
                    presentViewController(viewController)
                } else {
                    fatalError()
                }
            }.resume()
        case .tvShow:
            TMDBKit.getShow(for: id) { (error, show) in
                if var show = show {
                    let group = DispatchGroup()
                    
                    var torrents: [String : [Torrent]] = [:]
                    var logoURL: URL?
                    var seasonBeingDisplayed = show.seasons.first(where: {$0.number != 0})?.number
                    
                    if let tvdbId = show.ids[.tvdb] {
                        group.enter()
                        API.logo(for: tvdbId, of: .shows) { (_, url) in
                            logoURL = url
                            group.leave()
                        }.resume()
                        
                        group.enter()
                        API.actors(forShow: Int(tvdbId)!) { (error, cast) in
                            cast.forEach { (actor) in
                                guard let index = show.cast.firstIndex(where: {$0.name == actor.name}) else { return }
                                let person = show.cast[index]
                                show.cast[index] = TVDBActor(name: person.name,
                                                             gender: person.gender,
                                                             id: person.id,
                                                             character: person.character,
                                                             headshot: actor.headshot)
                            }
                            group.leave()
                        }?.resume()
                    }
                    
                    if let imdbId = show.ids[.imdb] {
                        group.enter()
                        TorrentKit.torrentsFor(showId: imdbId) { (_, seasons) in
                            for (season, episodes) in seasons {
                                for (episode, torrent) in episodes {
                                    torrents["\(season.intValue):\(episode.intValue)"] = torrent
                                }
                            }
                            group.leave()
                        }.resume()
                        
                        group.enter()
                        TraktManager.sharedManager.getShowWatchedProgress(showID: imdbId) { (result) in
                            switch result {
                            case .success(let result):
                                if let season = result.nextEpisode?.season {
                                    seasonBeingDisplayed = season
                                }
                            default:
                                break
                            }
                            group.leave()
                        }?.resume()
                    }
                    
                    group.notify(queue: .main) {
                        let viewController = viewController as! MediaItemDetailTableViewController
                        let item = MediaItem(show: show, logoURL: logoURL, torrents: torrents)
                        viewController.mediaItem = item
                        if let season = seasonBeingDisplayed {
                            viewController.changeSeason(to: season)
                        }
                        presentViewController(viewController)
                    }
                    
                } else if let error = error {
                    let viewController = UIViewController()
                    viewController.view = ErrorView.init(error)
                    presentViewController(viewController)
                } else {
                    fatalError()
                }
            }.resume()
        case .person:
            TMDBKit.getPerson(for: id) { (error, person) in
                if let person = person {
                    let viewController = viewController as! PersonDetailTableViewController
                    viewController.person = person
                    presentViewController(viewController)
                } else if let error = error {
                    let viewController = UIViewController()
                    viewController.view = ErrorView.init(error)
                    presentViewController(viewController)
                } else {
                    fatalError()
                }
            }.resume()
        default:
            fatalError()
        }
    }
    
    /**
     Fetches torrents for a given episode and then presents an episode detail view controller.
     
     - Parameter showIdString:  The episode's show's tmbd identification code as a string.
     - Parameter episodeString: The episode's number as a string.
     - Parameter seasonString:  The episode's season as a string.
     */
    @objc func showEpisode(_ showIdString: String, _ episodeString: String, _ seasonString: String) {
        let group = DispatchGroup()
        
        var torrents: [String: [Torrent]] = [:]
        var episode: Episode?
        var error: Error?
        
        group.enter()
        TMDBKit.getEpisode(showId: Int(showIdString)!, episode: Int(episodeString)!, season: Int(seasonString)!) {
            error = error == nil ? $0 : error
            episode = $1
            group.leave()
        }.resume()
        
        group.enter()
        TMDBKit.getShow(for: Int(showIdString)!) {
            error = error == nil ? $0 : error
            if let imdbId = $1?.ids[.imdb] {
                group.enter()
                TorrentKit.torrentsFor(showId: imdbId) {
                    error = error == nil ? $0 : error
                    for (season, episodes) in $1 {
                        for (episode, torrent) in episodes {
                            torrents["\(season.intValue):\(episode.intValue)"] = torrent
                        }
                    }
                    group.leave()
                }.resume()
            }
            group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            if let episode = episode {
                let viewController = self.storyboard.instantiateViewController(withIdentifier: String(describing: EpisodeDetailTableViewController.self)) as! EpisodeDetailTableViewController
                let mediaItem = MediaItem(episode: episode, torrents: torrents["\(episode.season):\(episode.number)"] ?? [])
                
                viewController.mediaItem = mediaItem
                
                self.rootNavigationController?.present(viewController, animated: true)
            } else {
                let alertController = UIAlertController(error: error!)
                self.rootNavigationController?.present(alertController, animated: true)
            }
        }
    }
    
    /**
     Adds items to the play queue and begins playing the first item as soon as it's ready. If there are no available items in the queue when the video has finished/the player has been dismissed, all the previously started transfers will be cancelled.
     
     - Parameter items: An array of the media and the associated torrent url (whose quality the user has selected) for playing. If no metadata can be retrieved about the media it may be `nil`.
     */
    func queue(items: (media: MediaItem?, url: URL)...) {
        queue(items: items)
    }
    
    /**
     Adds items to the play queue and begins playing the first item as soon as it's ready. If there are no available items in the queue when the video has finished/the player has been dismissed, all the previously started transfers will be cancelled.
     
     - Parameter items: An array of the media and the associated torrent url (whose quality the user has selected) for playing. If no metadata can be retrieved about the media it may be `nil`.
     */
    func queue(items: [(media: MediaItem?, url: URL)]) {
        let playerViewController = PlayerViewController()
        playerViewController.isPreloading = true
        rootNavigationController?.present(playerViewController, animated: true)
        
        let handleError: ((Error) -> Void) = { [weak playerViewController] (error) in
            playerViewController?.isPreloading = false
            let alertController = UIAlertController(error: error)
            playerViewController?.present(alertController, animated: true)
        }
        
        let completion: ((URL, MediaItem?) -> Void) = { [weak playerViewController] (url, media) in
            let asset = AVAsset(url: url)
            asset.externalMetadata = media?.externalMetadata ?? []
            asset.nowPlayingInfo = media?.nowPlayingInfo ?? [:]
            let item = AVPlayerItem(asset: asset)
            
            if playerViewController?.player == nil {
                let player = AVQueuePlayer(playerItem: item)
                playerViewController?.player = player
                playerViewController?.player?.play() // item won't play if playerViewController is `nil`. PlayerViewController will be `nil` when it has been dismissed. This is expected behaviour
                playerViewController?.isPreloading = false
            } else if let player = playerViewController?.player as? AVQueuePlayer {
                player.insert(item, after: nil)
            }
        }
        
        let callback: ((Transfer, MediaItem?) -> Void) = { (transfer, media) in
            PutKit.transfer(for: transfer.id, error: { (error) in
                handleError(error!)
            }, progress: nil) { (transfer) in
                PutKit.file(for: transfer.fileId) { (error, file) in
                    guard let file = file else {
                        handleError(error!)
                        return
                    }
                    
                    if file.isFolder {
                        PutKit.listFiles(in: file.id) { (error, files, _) in
                            if let videoFile = files.first(where: {$0.contentType.contains("video")}) {
                                let url = PutKit.hlsURL(for: videoFile.id, subtitle: "all")
                                completion(url, media)
                            } else if let error = error {
                                handleError(error)
                            }
                        }.resume()
                    } else {
                        let url = PutKit.hlsURL(for: file.id, subtitle: "all")
                        completion(url, media)
                    }
                }.resume()
            }.resume()
        }
        
        PutKit.listTransfers { (error, transfers) in
            if let error = error {
                handleError(error)
                return
            }
            
            for item in items {
                let url = item.url
                if (url.scheme == "magnet") {
                    if let transfer = transfers.first(where: {$0.source == url.absoluteString}) {
                        callback(transfer, item.media)
                    } else {
                        PutKit.addTransfer(url: url, saveFolder: 0, callbackURL: nil) {
                            if let error = $0 {
                                handleError(error)
                            } else if let transfer = $1 {
                                callback(transfer, item.media)
                            }
                        }.resume()
                    }
                } else {
                    URLSession.shared.downloadTask(with: url) { (localTorrentURL, response, error) in
                        if let url = localTorrentURL, let response = response {
                            let suggestedFilename = response.suggestedFilename!
                            let destination = URL(fileURLWithPath: NSTemporaryDirectory() + suggestedFilename)
                            let manager = FileManager.default
                            
                            if !manager.fileExists(atPath: destination.path) {
                                do {
                                    try FileManager.default.moveItem(at: url, to: destination)
                                } catch let error {
                                    handleError(error)
                                    return
                                }
                            }
                            
                            let newName = suggestedFilename.replacingOccurrences(of: ".torrent", with: "")
                            if let transfer = transfers.first(where: {$0.name == newName}) {
                                callback(transfer, item.media)
                            } else {
                                PutKit.upload(torrent: destination, toFolder: 0, newName: nil) {
                                    if let error = $0 {
                                        handleError(error)
                                    } else if let transfer = $1 {
                                        callback(transfer, item.media)
                                    }
                                }.resume()
                            }
                        } else {
                            handleError(error!)
                        }
                    }.resume()
                }
            }
        }.resume()
    }
    
    /**
     Presents login view controllers, thus starting the on-boarding process.
     
     - Note:    This method replaces the application window's root view controller during the process and then reinitialises a new one based on whatever the initial view controller of the Main application storyboard is.
     */
    @objc func startOnBoarding() {
        let viewController = WelcomeOnBoardingViewController.init(from: storyboard)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .formSheet
        
        let rootViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()!
        let window: UIWindow? = UIApplication.shared.delegate?.window ?? nil
        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        rootViewController.present(navigationController, animated: true)
    }
}
