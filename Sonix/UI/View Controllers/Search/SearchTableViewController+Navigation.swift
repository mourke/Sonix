//
//  SearchTableViewController+Navigation.swift
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

extension SearchTableViewController: LongPressCollectionViewCellDelegate {
    
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int) {
        let id: Int
        let type: MPMediaType
        switch rail {
        case 0:
            id = Int(movies[row].ids[.tmdb]!)!
            type = .movie
        case 1:
            id = Int(shows[row].ids[.tmdb]!)!
            type = .tvShow
        case 2:
            id = people[row].id
            type = .person
        default:
            fatalError()
        }
        
        let url = URL(string: "sonix://showDetail»\(type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
        UIApplication.shared.open(url)
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
            let movie = movies[indexPath.row]
            
            header = HeaderAlertAction(title: movie.title,
                                       subtitle: movie.releaseDate == nil ? nil : formatter.string(from: movie.releaseDate!),
                                       imageURL: movie.poster(for: .small)) { (_) in
                self.collectionView(collectionView, didSelectItemAt: indexPath)
            }
            watchlist = .toggleWatchlistAction(itemType: .movies, itemId: movie.ids[.tmdb]!)
            watched = .toggleWatchedAction(itemType: .movies, itemId: movie.ids[.tmdb]!)
        case 1:
            let show = shows[indexPath.row]
            
            header = HeaderAlertAction(title: show.title,
                                       subtitle: show.firstAired == nil ? nil : formatter.string(from: show.firstAired!),
                                       imageURL: show.poster(for: .small)) { (_) in
                self.collectionView(collectionView, didSelectItemAt: indexPath)
            }
            watchlist = .toggleWatchlistAction(itemType: .shows, itemId: show.ids[.tmdb]!)
            watched = .toggleWatchedAction(itemType: .shows, itemId: show.ids[.tmdb]!)
        default:
            return
        }
    
        alertController.addActions(header, watched, watchlist, .cancel)
        
        present(alertController, animated: true)
    }
}
