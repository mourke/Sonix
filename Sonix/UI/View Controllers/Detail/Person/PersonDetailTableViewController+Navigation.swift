//
//  PersonDetailTableViewController+Navigation.swift
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
import TMDBKit
import MediaPlayer.MPMediaItem

extension PersonDetailTableViewController: LongPressCollectionViewCellDelegate {
    
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int) {
        switch rail {
        case 0:
            let id = person.cast.compactMap({$0 as? Movie})[row].ids[.tmdb]!
            let url = URL(string: "sonix://showDetail»\(MPMediaType.movie.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 1:
            let id = person.cast.compactMap({$0 as? Show})[row].ids[.tmdb]!
            let url = URL(string: "sonix://showDetail»\(MPMediaType.tvShow.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 2:
            let episode = person.guestAppearances[row].episode
            let show = person.guestAppearances[row].show
            let url = URL(string: "sonix://showEpisode»\(show.ids[.tmdb]!)»\(episode.number)»\(episode.season)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        default:
            let index = rail - 3
            let item = Array(person.crew.values)[index][row]
            let id: Int
            let type: MPMediaType
            
            if let movie = item as? Movie {
                id = Int(movie.ids[.tmdb]!)!
                type = .movie
            } else {
                let show = item as! Show
                id = Int(show.ids[.tmdb]!)!
                type = .tvShow
            }
            
            let url = URL(string: "sonix://showDetail»\(type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
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
        
        let header: HeaderAlertAction
        let watched: RowAlertAction
        let watchlist: RowAlertAction
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        
        switch rail {
        case 0:
            let movie = person.cast.compactMap({$0 as? Movie})[indexPath.row]
            
            header = HeaderAlertAction(title: movie.title,
                                       subtitle: movie.releaseDate == nil ? nil : formatter.string(from: movie.releaseDate!),
                                       imageURL: movie.poster(for: .small)) { (_) in
                self.collectionView(collectionView, didSelectItemAt: indexPath)
            }
            watchlist = .toggleWatchlistAction(itemType: .movies, itemId: movie.ids[.tmdb]!)
            watched = .toggleWatchedAction(itemType: .movies, itemId: movie.ids[.tmdb]!)
        case 1:
            let show = person.cast.compactMap({$0 as? Show})[indexPath.row]
            
            header = HeaderAlertAction(title: show.title,
                                       subtitle: show.firstAired == nil ? nil : formatter.string(from: show.firstAired!),
                                       imageURL: show.poster(for: .small)) { (_) in
                self.collectionView(collectionView, didSelectItemAt: indexPath)
            }
            watchlist = .toggleWatchlistAction(itemType: .shows, itemId: show.ids[.tmdb]!)
            watched = .toggleWatchedAction(itemType: .shows, itemId: show.ids[.tmdb]!)
        case 2:
            let episode = person.guestAppearances[indexPath.row].episode
            let show = person.guestAppearances[indexPath.row].show
            
            header = HeaderAlertAction(title: show.title,
                                       subtitle: show.firstAired == nil ? nil : formatter.string(from: show.firstAired!),
                                       detail: nil,
                                       imageURL: show.poster(for: .small)) { _ in
                let url = URL(string: "sonix://showDetail»\(MPMediaType.tvShow.rawValue)»\(show.ids[.tmdb]!)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
                UIApplication.shared.open(url)
            }
            watched = .toggleWatchedAction(itemType: .episodes, itemId: String(episode.id))
            
            alertController.addActions(header, watched, .cancel)
            
            return present(alertController, animated: true)
        default:
            let index = rail - 3
            let item = Array(person.crew.values)[index][indexPath.row]
            
            if let movie = item as? Movie {
                header = HeaderAlertAction(title: movie.title,
                                           subtitle: movie.releaseDate == nil ? nil : formatter.string(from: movie.releaseDate!),
                                           imageURL: movie.poster(for: .small)) { (_) in
                    self.collectionView(collectionView, didSelectItemAt: indexPath)
                }
                watchlist = .toggleWatchlistAction(itemType: .movies, itemId: movie.ids[.tmdb]!)
                watched = .toggleWatchedAction(itemType: .movies, itemId: movie.ids[.tmdb]!)
            } else {
                let show = item as! Show
                header = HeaderAlertAction(title: show.title,
                                           subtitle: show.firstAired == nil ? nil : formatter.string(from: show.firstAired!),
                                           imageURL: show.poster(for: .small)) { (_) in
                    self.collectionView(collectionView, didSelectItemAt: indexPath)
                }
                watchlist = .toggleWatchlistAction(itemType: .shows, itemId: show.ids[.tmdb]!)
                watched = .toggleWatchedAction(itemType: .shows, itemId: show.ids[.tmdb]!)
            }
        }
        
        alertController.addActions(header, watched, watchlist, .cancel)
        
        present(alertController, animated: true)
    }
}
