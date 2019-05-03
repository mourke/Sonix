//
//  BrowseTableViewController+Navigation.swift
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
import TMDBKit

extension BrowseTableViewController: LongPressCollectionViewCellDelegate {
    
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int) {
        switch rail {
        case 0:
            let list = lists[row]
            
        // TODO: do this when paginated vc is done
        case 1:
            let movie = recentlyAdded[row]
            
            TMDBKit.find(Movie.self, withId: movie.imdbId, ofType: .imdb) { (error, movie) in
                if let movie = movie {
                    let url = URL(string: "sonix://showDetail»\(MPMediaType.movie.rawValue)»\(movie.ids[.tmdb]!)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
                    UIApplication.shared.open(url)
                } else {
                    let alertController = UIAlertController(error: error!)
                    self.present(alertController, animated: true)
                }
            }.resume()
        case 2:
            let item = anticipated[row]
            
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
            // TODO: do this when paginated vc is done
            switch row {
            case 0:
                break
            case 1:
                break
            default:
                fatalError()
            }
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
        
        switch rail {
        case 1:
            let movie = recentlyAdded[indexPath.row]
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            
            let header = HeaderAlertAction(title: movie.title,
                                           subtitle: formatter.string(from: movie.releaseDate),
                                           detail: movie.genres.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: movie.images.poster(for: .small)) { (_) in
                self.collectionView(collectionView, didSelectItemAt: indexPath)
            }
            let watchlist = RowAlertAction.toggleWatchlistAction(itemType: .movies, itemId: movie.imdbId)
            let watched = RowAlertAction.toggleWatchedAction(itemType: .movies, itemId: movie.imdbId)
            
            alertController.addActions(header, watched, watchlist, .cancel)
        case 2:
            let item = anticipated[indexPath.row]
            let header: HeaderAlertAction
            let watchlist: RowAlertAction
            
            if let movie = item.movie {
                header = HeaderAlertAction(title: movie.title,
                                           subtitle: movie.year == nil ? nil : String(movie.year!),
                                           detail: movie.genres?.map({$0.capitalized}).prefix(3).joined(separator: ", "),
                                           imageURL: movie.posterImage) { (_) in
                    self.collectionView(collectionView, didSelectItemAt: indexPath)
                }
                watchlist = .toggleWatchlistAction(itemType: .movies, itemId: String(movie.ids.trakt))
            } else {
                let show = item.show!
                
                header = HeaderAlertAction(title: show.title,
                                           subtitle: show.year == nil ? nil : String(show.year!),
                                           detail: show.status?.capitalized,
                                           imageURL: show.posterImage) { (_) in
                    self.collectionView(collectionView, didSelectItemAt: indexPath)
                }
                watchlist = .toggleWatchlistAction(itemType: .shows, itemId: String(show.ids.trakt))
            }
            
            alertController.addActions(header, watchlist, .cancel)
        default:
            return
        }
        
        present(alertController, animated: true)
    }
}
