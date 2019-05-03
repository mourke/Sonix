//
//  BrowseTableViewController.swift
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
import PopcornKit

class BrowseTableViewController: RailViewController {
    
    var lists: [TraktList] = []
    var recentlyAdded: [Movie] = []
    var anticipated: [TraktAnticipated] = []

    lazy var listNib = UINib(nibName: "ListCollectionViewCell", bundle: nil)
    lazy var posterNib = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    lazy var tableNib = UINib(nibName: "TableCollectionViewCell", bundle: nil)
    
    
    @IBAction func reloadView() {
        lists.removeAll(); recentlyAdded.removeAll(); anticipated.removeAll();
        
        tableView.reloadData()
        tableView.backgroundView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as? UIView
        tableView.separatorStyle = .none
        tableView.tableFooterView?.isHidden = true
        
        loadContent {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
            self.tableView.separatorStyle = .singleLine
            self.tableView.tableFooterView?.isHidden = false
        }
    }
    
    @IBAction func randomItem() {
        let movie = arc4random_uniform(2) == 0
        
        let completion: (Error?, Any?) -> Void = { (error, item) in
            let alertController: UIAlertController
            
            if let error = error {
                alertController = UIAlertController(error: error)
            } else {
                let contentViewController = RandomItemAlertContentViewController(nibName: "RandomItemAlertContentViewController", bundle: nil)
                contentViewController.loadView()
                
                alertController = UIAlertController(contentViewController: contentViewController, preferredStyle: .alert)
                
                let rollAgain = UIAlertAction(title: NSLocalizedString("random_item_alert_action_roll_again_title", comment: "The user does not want to watch the randomly selected movie/show and would like to be suggested another."), style: .default) { _ in
                    self.randomItem()
                }
                
                alertController.addAction(.cancel)
                
                if let movie = item as? Movie {
                    contentViewController.titleLabel?.text = movie.title
                    contentViewController.descriptionLabel?.text = movie.synopsis
                    contentViewController.ratingView?.rating = movie.rating
                    contentViewController.imageView?.kf.setImage(with: movie.images.poster(for: .small), placeholder: UIImage(named: "PreloadAsset_Movie"))
                    
                    let play = UIAlertAction(title: NSLocalizedString("random_item_alert_action_play_title", comment: "The user likes what they've read so far and want to play the movie/show."), style: .default) { (_) in
                        TorrentKit.torrentsFor(movieId: movie.imdbId) { (error, torrents) in
                            if let error = error {
                                self.present(UIAlertController(error: error), animated: true)
                            } else {
                                // TODO: Make handler for choosing quality
                            }
                        }.resume()
                    }
                    
                    alertController.addAction(play)
                } else if let show = item as? PartialShow {
                    contentViewController.titleLabel?.text = show.title
                    contentViewController.descriptionLabel?.text = show.releaseYear
                    contentViewController.ratingView?.rating = show.rating
                    contentViewController.imageView?.kf.setImage(with: show.images.poster(for: .small), placeholder: UIImage(named: "PreloadAsset_TV"))
                    
                    let play = UIAlertAction(title: NSLocalizedString("random_item_alert_action_play_title", comment: "The user likes what they've read so far and want to play the movie/show."), style: .default) { (_) in
                        TorrentKit.torrentsFor(showId: show.imdbId) { (error, torrents) in
                            if let error = error {
                                self.present(UIAlertController(error: error), animated: true)
                            } else {
                                // TODO: Make handler for choosing quality
                            }
                        }.resume()
                    }
                    
                    alertController.addAction(play)
                }
                
                alertController.addAction(rollAgain)
            }
            
            self.present(alertController, animated: true)
        }
        
        movie ? PopcornKit.randomMovie(completion).resume() : PopcornKit.randomShow(completion).resume()
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
        API.lists {
            errors.append($0)
            self.lists = $1
            group.leave()
        }?.resume()
        
        group.enter()
        PopcornKit.movies(on: 1, filter: .year, genre: .all, query: nil, order: .descending) {
            errors.append($0)
            self.recentlyAdded = $1
            group.leave()
        }.resume()
        
        group.enter()
        API.anticipated {
            errors.append($0)
            self.anticipated = $1
            group.leave()
        }.forEach({$0.resume()})

        
        group.notify(queue: .main) {
            if errors.filter({$0 == nil}).isEmpty, // Everything failed.
                let error = errors.first! {
                let backgroundView = ErrorView.init(error)
                backgroundView.retryHandler = { [weak self] in
                    self?.reloadView()
                }
                completion()
                self.tableView.separatorStyle = .none
                self.tableView.backgroundView = backgroundView
            } else {
                self.tableView.backgroundView = nil
                completion()
            }
        }
    }

}
