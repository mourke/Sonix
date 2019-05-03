//
//  HomeTableViewController+Navigation.swift
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
import struct MediaPlayer.MPMediaItem.MPMediaType

extension HomeTableViewController: LongPressCollectionViewCellDelegate {
    
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int) {
        switch rail {
        case 0:
            if row < unFinished.count {
                let item = unFinished[row]
                
                if let episode = item.episode, let show = item.show {
                    
                } else if let movie = item.movie {
                    
                } else {
                    fatalError()
                }
            } else {
                let item = upNext[row - unFinished.count]
                let show = item.show
                let episode = item.episode
                
            }
        case 1:
            let item = watchlist[row]
            
            let id: Int
            let type: MPMediaType
            
            if let movie = item.movie {
                id = movie.ids.tmdb!
                type = .movie
            } else if let show = item.show {
                id = show.ids.tmdb!
                type = .tvShow
            } else {
                fatalError()
            }
            
            let url = URL(string: "sonix://showDetail»\(type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 2:
            let item = recommended[row]
            
            let id: Int
            let type: MPMediaType
            
            if let movie = item.movie {
                id = movie.ids.tmdb!
                type = .movie
            } else if let show = item.show {
                id = show.ids.tmdb!
                type = .tvShow
            } else {
                fatalError()
            }
            
            let url = URL(string: "sonix://showDetail»\(type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 3:
            let item = Array(social.keys)[row]
            
            if let movie = item.movie {
                
            } else if let show = item.show, let episode = item.episode {
                
            } else {
                fatalError()
            }
        case 4:
            let item = related?.related[row]
            
            let id: Int
            let type: MPMediaType
            
            if let movie = item as? TraktMovie {
                id = movie.ids.tmdb!
                type = .movie
            } else if let show = item as? TraktShow {
                id = show.ids.tmdb!
                type = .tvShow
            } else {
                fatalError()
            }
            
            let url = URL(string: "sonix://showDetail»\(type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 5:
            let item = history[row]
            
            let id: Int
            let type: MPMediaType
            
            if let movie = item.movie {
                id = movie.ids.tmdb!
                type = .movie
            } else if let show = item.show {
                id = show.ids.tmdb!
                type = .tvShow
            } else {
                fatalError()
            }
            
            let url = URL(string: "sonix://showDetail»\(type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 6:
            let cinema = cinemas.first!
            let movie = cinema.screenings[row]
            
        // TODO: figure this shit out.
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        longPressGestureRecognizer: UILongPressGestureRecognizer,
                        didTriggerForItemAt indexPath: IndexPath) {
        guard longPressGestureRecognizer.state == .began else { return }
        
        let cell = collectionView.cellForItem(at: indexPath)!
        let rail = collectionView.tag
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = cell
        alertController.popoverPresentationController?.sourceRect = cell.bounds
        
        let headerHandler: (HeaderAlertAction) -> Void = { (_) in
            self.collectionView(collectionView, didSelectItemAt: indexPath)
        }
        
        switch rail {
        case 0:
            if indexPath.row < unFinished.count {
                let item = unFinished[indexPath.row]
                
                let handler: (RowAlertAction) -> Void = { (_) in
                    self.unFinished.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
                
                let header: HeaderAlertAction
                let reset = RowAlertAction(title: NSLocalizedString("row_alert_action_remove_progress_title", comment: "The user wants to clear their playback progress (make it as though they hadn't seen it before) for a specific episode/movie."),
                                           image: UIImage(named: "Trash")) { (action) in
                    TraktManager.sharedManager.removePlaybackItem(id: item.id)?.resume()
                    handler(action)
                }
                let watched: RowAlertAction
                
                if let episode = item.episode, let show = item.show {
                    header = HeaderAlertAction(title: show.title,
                                               subtitle: show.year == nil ? nil : String(show.year!),
                                               detail: show.status?.capitalized,
                                               imageURL: show.posterImage) { _ in
                        let url = URL(string: "sonix://showDetail»\(MPMediaType.tvShow.rawValue)»\(show.ids.tmdb!)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
                        UIApplication.shared.open(url)
                    }
                    watched = RowAlertAction.toggleWatchedAction(itemType: .episodes,
                                                                 itemId: String(episode.ids.trakt),
                                                                 handler: handler)
                } else {
                    let movie = item.movie!
                    
                    header = HeaderAlertAction(title: movie.title,
                                               subtitle: movie.year == nil ? nil : String(movie.year!),
                                               detail: movie.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                               imageURL: movie.posterImage,
                                               handler: headerHandler)
                    watched = RowAlertAction.toggleWatchedAction(itemType: .movies,
                                                                 itemId: String(movie.ids.trakt),
                                                                 handler: handler)
                }
                
                alertController.addActions(header, reset, watched, .cancel)
            } else {
                let item = upNext[indexPath.row - unFinished.count]
                let show = item.show
                let episode = item.episode
                
                let handler: (RowAlertAction) -> Void = { (_) in
                    self.upNext.remove(at: indexPath.row - self.unFinished.count)
                    collectionView.reloadData()
                }
                
                let header = HeaderAlertAction(title: show.title,
                                               subtitle: show.year == nil ? nil : String(show.year!),
                                               detail: show.status?.capitalized,
                                               imageURL: show.posterImage) { _ in
                    let url = URL(string: "sonix://showDetail»\(MPMediaType.tvShow.rawValue)»\(show.ids.tmdb!)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
                    UIApplication.shared.open(url)
                }
                let stop = RowAlertAction(title: NSLocalizedString("row_alert_action_stop_tracking_title", comment: "The user does not want Sonix to track their progress watching this show any longer. They may continue watching this show but as far as Sonix is concerned, they are no longer watching it."),
                                          image: UIImage(named: "Stop Tracking")) { (action) in
                    try! TraktManager.sharedManager.hide(shows: [["ids": ["trakt": show.ids.trakt]]], from: .progressWatched)?.resume()
                    handler(action)
                }
                let watched = RowAlertAction.toggleWatchedAction(itemType: .episodes, itemId: String(episode.ids.trakt), handler: handler)
                
                alertController.addActions(header, stop, watched, .cancel)
            }
        case 1:
            let item = self.watchlist[indexPath.row]
            
            let header: HeaderAlertAction
            let watchlist: RowAlertAction
            let watched: RowAlertAction
            
            let handler: (RowAlertAction) -> Void = { (_) in
                self.watchlist.remove(at: indexPath.row)
                collectionView.reloadData()
            }

            if let movie = item.movie {
                header = HeaderAlertAction(title: movie.title,
                                           subtitle: movie.year == nil ? nil : String(movie.year!),
                                           detail: movie.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: movie.posterImage,
                                           handler: headerHandler)
                watchlist = .toggleWatchlistAction(itemType: .movies,
                                                   itemId: String(movie.ids.trakt),
                                                   handler: handler)
                watched = RowAlertAction.toggleWatchedAction(itemType: .movies,
                                                             itemId: String(movie.ids.trakt),
                                                             handler: handler)
            } else {
                let show = item.show!
                
                header = HeaderAlertAction(title: show.title,
                                           subtitle: show.year == nil ? nil : String(show.year!),
                                           detail: show.status?.capitalized,
                                           imageURL: show.posterImage,
                                           handler: headerHandler)
                watchlist = .toggleWatchlistAction(itemType: .shows,
                                                   itemId: String(show.ids.trakt),
                                                   handler: handler)
                watched = .toggleWatchedAction(itemType: .shows,
                                               itemId: String(show.ids.trakt),
                                               handler: handler)
            }
            
            alertController.addActions(header, watched, watchlist, .cancel)
        case 2:
            let item = recommended[indexPath.row]
            
            let header: HeaderAlertAction
            let watchlist: RowAlertAction
            let watched: RowAlertAction
            let hate: SplitRowAlertAction
            
            if let movie = item.movie {
                header = HeaderAlertAction(title: movie.title,
                                           subtitle: movie.year == nil ? nil : String(movie.year!),
                                           detail: movie.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: movie.posterImage,
                                           handler: headerHandler)
                hate = SplitRowAlertAction(images: UIImage(named: "Hate")!) { (_, _) in
                    TraktManager.sharedManager.hideRecommendedMovie(movieID: movie.ids.trakt)?.resume()
                    self.recommended.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
                watchlist = .toggleWatchlistAction(itemType: .movies, itemId: String(movie.ids.trakt))
                watched = .toggleWatchedAction(itemType: .movies, itemId: String(movie.ids.trakt))
            } else {
                let show = item.show!
                
                header = HeaderAlertAction(title: show.title,
                                           subtitle: show.year == nil ? nil : String(show.year!),
                                           detail: show.status?.capitalized,
                                           imageURL: show.posterImage,
                                           handler: headerHandler)
                hate = SplitRowAlertAction(images: UIImage(named: "Hate")!) { (_, _) in
                    TraktManager.sharedManager.hideRecommendedShow(showID: show.ids.trakt)?.resume()
                    self.recommended.remove(at: indexPath.row)
                    collectionView.reloadData()
                }
                watchlist = .toggleWatchlistAction(itemType: .shows, itemId: String(show.ids.trakt))
                watched = .toggleWatchedAction(itemType: .shows, itemId: String(show.ids.trakt))
            }
            
            alertController.addActions(header, watched, watchlist, hate, .cancel)
        case 4:
            let header: HeaderAlertAction
            let watchlist: RowAlertAction
            let watched: RowAlertAction
            
            if let movie = related!.related[indexPath.row] as? TraktMovie {
                header = HeaderAlertAction(title: movie.title,
                                           subtitle: movie.year == nil ? nil : String(movie.year!),
                                           detail: movie.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: movie.posterImage,
                                           handler: headerHandler)
                watchlist = RowAlertAction.toggleWatchlistAction(itemType: .movies, itemId: String(movie.ids.trakt))
                watched = RowAlertAction.toggleWatchedAction(itemType: .movies, itemId: String(movie.ids.trakt))
            } else {
                let show = related!.related[indexPath.row] as! TraktShow
                
                header = HeaderAlertAction(title: show.title,
                                           subtitle: show.year == nil ? nil : String(show.year!),
                                           detail: show.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: show.posterImage,
                                           handler: headerHandler)
                watchlist = RowAlertAction.toggleWatchlistAction(itemType: .shows, itemId: String(show.ids.trakt))
                watched = RowAlertAction.toggleWatchedAction(itemType: .shows, itemId: String(show.ids.trakt))
            }
            
            alertController.addActions(header, watched, watchlist, .cancel)
        case 5:
            let item = history[indexPath.row]
            
            let header: HeaderAlertAction
            let watched: RowAlertAction
            
            let handler: (RowAlertAction) -> Void = { (_) in
                self.history.remove(at: indexPath.row)
                collectionView.reloadData()
            }
            
            if let movie = item.movie {
                header = HeaderAlertAction(title: movie.title,
                                           subtitle: movie.year == nil ? nil : String(movie.year!),
                                           detail: movie.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: movie.posterImage,
                                           handler: headerHandler)
                watched = .toggleWatchedAction(itemType: .movies,
                                               itemId: String(movie.ids.trakt),
                                               handler: handler)
            } else {
                let show = item.show!
                
                header = HeaderAlertAction(title: show.title,
                                           subtitle: show.year == nil ? nil : String(show.year!),
                                           detail: show.status?.capitalized,
                                           imageURL: show.posterImage,
                                           handler: headerHandler)
                watched = .toggleWatchedAction(itemType: .shows,
                                               itemId: String(show.ids.trakt),
                                               handler: handler)
            }
            
            alertController.addActions(header, watched, .cancel)
        default:
            return
        }
        
        present(alertController, animated: true)
    }
}
