//
//  RowAlertAction.swift
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

class RowAlertAction: UIAlertAction {
    
    convenience init(title: String? = nil,
                     subtitle: String? = nil,
                     image: UIImage? = nil,
                     handler: ((RowAlertAction) -> Void)? = nil) {
        let contentViewController = RowAlertContentViewController(nibName: "RowAlertContentViewController", bundle: nil)
        
        contentViewController.loadViewIfNeeded()
        
        contentViewController.textLabel?.text = title
        contentViewController.detailTextLabel?.text = subtitle
        contentViewController.imageView?.image = image?.withRenderingMode(.alwaysTemplate)
        
        if image == nil {
            contentViewController.textLabel?.textAlignment = .center
            contentViewController.detailTextLabel?.textAlignment = .center
        }
        
        self.init(contentViewController: contentViewController, style: .default) { (action) in
            handler?(action as! RowAlertAction)
        }
    }
    
    static func toggleWatchlistAction(itemType type: Type,
                                      itemId id: String,
                                      handler: ((RowAlertAction) -> Void)? = nil) -> RowAlertAction {
        let isAddedToWatchlist = false // TODO: Implement this
        let image = isAddedToWatchlist ? UIImage(named: "Remove From List") : UIImage(named: "Add To List")
        let title = isAddedToWatchlist ? NSLocalizedString("row_alert_action_remove_watchlist_title", comment: "The user wants to remove this movie/show from a list of movies/shows to be watched later.") : NSLocalizedString("row_alert_action_add_watchlist_title", comment: "The user wants to add this movie/show to a list of movies/shows to be watched later.")
        return RowAlertAction(title: title, image: image) { (action) in
            // TODO: Add item to watchlist
            handler?(action)
        }
    }
    
    static func toggleWatchedAction(itemType type: WatchedType,
                                    itemId id: String,
                                    handler: ((RowAlertAction) -> Void)? = nil) -> RowAlertAction {
        let isAddedToWatchHistory = false // TODO: Implement this
        let image: UIImage
        let title: String
        
        switch type {
        case .movies:
            fallthrough
        case .episodes:
            image = isAddedToWatchHistory ? UIImage(named: "Mark as unwatched")! : UIImage(named: "Mark as watched")!
            title = isAddedToWatchHistory ? NSLocalizedString("row_alert_action_remove_history_title", comment: "The user mistakenly thought that they had seen this movie/episode when they actually hadn't and would like to correct this mistake.") : NSLocalizedString("row_alert_action_add_history_title", comment: "The user has previously seen this movie/episode.")
        case .seasons:
            fallthrough
        case .shows:
            image = isAddedToWatchHistory ? UIImage(named: "Mark all as unwatched")! : UIImage(named: "Mark all as watched")!
            title = isAddedToWatchHistory ? NSLocalizedString("row_alert_action_remove_multiple_history_title", comment: "The user mistakenly thought that they had seen this show/season when they actually hadn't and would like to correct this mistake.") : NSLocalizedString("row_alert_action_add_multiple_history_title", comment: "The user has previously seen this show/season and would like to mark all episodes in the season/show as watched.")
        }
        
        return RowAlertAction(title: title, image: image) { (action) in
            // TODO: Add item to watch history
            handler?(action)
        }
    }
}
