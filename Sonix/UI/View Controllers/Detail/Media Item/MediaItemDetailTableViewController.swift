//
//  MediaItemDetailTableViewController.swift
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

class MediaItemDetailTableViewController: DetailTableViewController {

    lazy var monogramNib = UINib(nibName: "MonogramCollectionViewCell", bundle: nil)
    lazy var episodeNib = UINib(nibName: "EpisodeCollectionViewCell", bundle: nil)
    lazy var reviewNib = UINib(nibName: "ReviewCollectionViewCell", bundle: nil)
    lazy var ratingNib = UINib(nibName: "RatingCollectionViewCell", bundle: nil)
    
    var mediaItem: MediaItem!
    var seasonBeingDisplayed: Int? // Only set when mediaItem is a show.
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundImageView.kf.setImage(with: mediaItem.backgroundArtworkURL, placeholder: UIImage(named: "PreloadAsset_" + (mediaItem.type == .movie ? "Movie" : "TV") + "_Wide"))
        logoImageView.kf.setImage(with: mediaItem.logoArtworkURL) { [weak self] (image, _, _, _) in
            guard let `self` = self, image != nil else { return }
            let titleView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
            self.navigationItem.titleView = titleView
            titleView.addSubview(self.logoImageView)
            self.logoImageView.frame = titleView.bounds
            self.logoImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
        
        
        navigationItem.title = mediaItem.title
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedMediaItemInfoDetail",
            let destination = segue.destination as? InfoDetailViewController {
            destination.mediaItem = mediaItem
            destination.socialIds = Dictionary(uniqueKeysWithValues: mediaItem.socialIds.compactMap { (network, id) in
                switch network {
                case .imdb:
                    return (network, URL(string: "https://www.imdb.com/title/\(id)")!)
                case .tvdb:
                    return nil
                case .tmdb:
                    let type = mediaItem.type == .movie ? "movie" : "tv"
                    return (network, URL(string: "https://www.themoviedb.org/\(type)/\(id)")!)
                case .twitter:
                    return (network, URL(string: "https://twitter.com/\(id)")!)
                case .facebook:
                    return (network, URL(string: "https://facebook.com/\(id)")!)
                case .instagram:
                    return (network, URL(string: "https://instagram.com/\(id)")!)
                }
            })
            
            destination.loadViewIfNeeded()
            destination.view.translatesAutoresizingMaskIntoConstraints = false
            
            let attributedText = NSMutableAttributedString(attributedString: mediaItem.info)
            attributedText.addAttribute(.foregroundColor, value: UIColor(named: "secondaryLabelColor")!, range: NSRange(location: 0, length: attributedText.length))
            
            destination.detailLabel?.attributedText = attributedText
            destination.titleLabel?.text = mediaItem.title
            destination.imageView?.kf.setImage(with: mediaItem.posterArtworkURL, placeholder: UIImage(named: "PreloadAsset_" + (mediaItem.type == .movie ? "Movie" : "TV")))
            destination.textView?.text = mediaItem.overview
        } else if segue.identifier == "showEpisode",
            let destination = segue.destination as? EpisodeDetailTableViewController,
            let cell = sender as? EpisodeCollectionViewCell,
            let indexPath = cell.collectionView?.indexPath(for: cell) {
            let episode = episodes(for: seasonBeingDisplayed!)[indexPath.row]
            let torrents = mediaItem.torrents["\(episode.season):\(episode.number)"] ?? []
            
            destination.mediaItem = MediaItem(episode: episode, torrents: torrents)
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func episodes(for season: Int) -> [Episode] {
        return mediaItem.seasons.first(where: {$0.number == seasonBeingDisplayed})?.episodes ?? []
    }
    
    func changeSeason(to season: Int) {
        let episodesAlreadyLoaded = !self.mediaItem.seasons.first(where: {$0.number == season})!.episodes.isEmpty
        let completion: (Int) -> Void = { (season) in
            self.seasonBeingDisplayed = season
            self.tableView.reloadData()
        }
        
        if !episodesAlreadyLoaded {
            TMDBKit.getSeason(season, inShow: self.mediaItem.id) { (error, season) in
                if let season = season {
                    let index = self.mediaItem.seasons.index(of: season)!
                    self.mediaItem.seasons[index] = season
                    completion(season.number)
                } else {
                    self.present(UIAlertController(error: error!), animated: true)
                }
            }.resume()
        } else {
            completion(season)
        }
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! RailTableViewCell
        let layout = cell.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        cell.backgroundColor = (indexPath.row == 2 || indexPath.row == 3) ? UIColor(named: "foregroundColor") : UIColor(named: "backgroundColor")
        cell.separatorInset.left = (indexPath.row == 1 || indexPath.row == 3) ? .greatestFiniteMagnitude : layout.sectionInset.left + view.safeAreaInsets.left
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = super.tableView(tableView, numberOfRowsInSection: section)
        
        tableView.backgroundColor = rows == 3 || rows == 4 ?  UIColor(named: "foregroundColor") : UIColor(named: "backgroundColor") // Change the background colour to match the colour of the bottom-most rail.
        
        return rows
    }
}
