//
//  HomeTableViewController.swift
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

import UIKit
import TraktKit

class HomeTableViewController: RailViewController {
    
    var upNext: [(show: TraktShow, episode: TraktEpisode)] = []
    var unFinished: [PlaybackProgress] = []
    var watchlist: [TraktListItem] = []
    var recommended: [(show: TraktShow?, movie: TraktMovie?)] = []
    var social: [TraktWatching: [Friend]] = [:]
    var related: (item: TraktHistoryItem, related: [Codable])?
    var history: [TraktHistoryItem] = []
    var cinemas: [Cinema] = []
    
    lazy var upNextNib = UINib(nibName: "UpNextCollectionViewCell", bundle: nil)
    lazy var posterNib = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    lazy var friendNib = UINib(nibName: "FriendCollectionViewCell", bundle: nil)
    lazy var heroNib = UINib(nibName: "HeroCollectionViewCell", bundle: nil)
    
    @IBAction func reloadView() {
        upNext.removeAll(); unFinished.removeAll(); watchlist.removeAll(); recommended.removeAll()
        social.removeAll(); history.removeAll(); cinemas.removeAll(); related = nil
        
        tableView.reloadData()
        tableView.backgroundView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as? UIView
        tableView.separatorStyle = .none
        
        loadContent {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.separatorStyle = .singleLine
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadView()
        
        view.addSubview(statusBarBackgroundView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if presentedViewController == nil { // Only show navigation bar on push, not on a modal present.
            navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView && (scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating) else { return }
        
        statusBarBackgroundView.alpha = min(tableView.contentOffset.y, 1)
        statusBarBackgroundView.frame.size = UIApplication.shared.statusBarFrame.size
        statusBarBackgroundView.frame.origin = CGPoint(x: 0, y: tableView.contentOffset.y)
    }
    
    func loadContent(completion: @escaping () -> Void) {
        let group = DispatchGroup()
        var errors: [Error?] = []
        
        group.enter()
        API.unFinished {
            errors.append($0)
            self.unFinished = $1
            group.leave()
        }.forEach({$0.resume()})
        
        group.enter()
        API.upNext {
            errors.append($0)
            self.upNext = $1
            group.leave()
        }?.resume()
        
        group.enter()
        API.watchlist {
            errors.append($0)
            self.watchlist = $1
            group.leave()
        }.forEach({$0.resume()})
        
        group.enter()
        API.recommended {
            errors.append($0)
            self.recommended = $1
            group.leave()
        }.forEach({$0.resume()})
        
        group.enter()
        API.friendsActivity {
            errors.append($0)
            self.social = $1
            group.leave()
        }?.resume()
        
        group.enter()
        API.relatedToHistory {
            errors.append($0)
            self.history = $1
            if let item = $2 {
                self.related = (item: item, related: $3)
            }
            group.leave()
        }?.resume()
        
        group.enter()
        API.nearbyCinemaScreenings {
            errors.append($0)
            self.cinemas = $1
            group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            if errors.filter({$0 == nil}).isEmpty, // Everything failed.
                let error = errors.first! {
                let backgroundView = ErrorView.init(error)
                backgroundView.retryHandler = { [weak self] in
                    self?.reloadView()
                }
                self.tableView.separatorStyle = .none
                self.tableView.backgroundView = backgroundView
                self.tableView.refreshControl?.endRefreshing()
            } else {
                self.tableView.backgroundView = nil
                completion()
            }
        }
    }
}
