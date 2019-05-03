//
//  HomeTableViewController+RailDelegate.swift
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

extension HomeTableViewController: RailDelegate {
    
    func numberOfRails() -> Int {
        return [!upNext.isEmpty || !unFinished.isEmpty, !watchlist.isEmpty, !recommended.isEmpty, !social.isEmpty, !(related?.related ?? []).isEmpty, !history.isEmpty, !(cinemas.first?.screenings ?? []).isEmpty].filter({$0}).count
    }
    
    func railIdForCell(at indexPath: IndexPath) -> Int {
        var row = indexPath.row + 1
        let dataSource: [[Any]] =  [[upNext, unFinished].map({$0}), watchlist, recommended, Array(social.keys), related?.related ?? [], history, cinemas.first?.screenings ?? []]
        
        for (index, item) in dataSource.enumerated() {
            row -= item.isEmpty ? 0 : 1
            if row == 0 { return index }
        }
        
        fatalError()
    }
    
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int {
        switch rail {
        case 3:
            return 2
        default:
            return 1
        }
    }
    
    func numberOfCells(on rail: Int) -> Int {
        switch rail {
        case 0:
            return upNext.count + unFinished.count
        case 1:
            return watchlist.count
        case 2:
            return recommended.count
        case 3:
            return social.keys.count
        case 4:
            return related?.related.count ?? 0
        case 5:
            return history.count
        case 6:
            return cinemas.first?.screenings.count ?? 0
        default:
            fatalError()
        }
    }
    
    func cell(at row: Int,
              in collectionView: RailCollectionView,
              on rail: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: 0)
        
        collectionView.register(friendNib, forCellWithReuseIdentifier: "friendCell")
        collectionView.register(posterNib, forCellWithReuseIdentifier: "posterCell")
        collectionView.register(upNextNib, forCellWithReuseIdentifier: "upNextCell")
        collectionView.register(heroNib, forCellWithReuseIdentifier: "heroCell")
        
        let cell: UICollectionViewCell
        
        switch rail {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upNextCell", for: indexPath)
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCell", for: indexPath)
        case 1,2,4,5:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath)
        case 6:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "heroCell", for: indexPath)
        default:
            fatalError()
        }
        
        configure(cell, at: indexPath, on: rail)
        return cell
    }
    
    func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath, on rail: Int) {
        switch rail {
        case 0:
            let cell = cell as! UpNextCollectionViewCell
            
            cell.delegate = self
            
            if indexPath.row < unFinished.count {
                let item = unFinished[indexPath.row]
                
                cell.playCircularProgressBarView?.value = CGFloat(item.progress)
                
                if let episode = item.episode, let show = item.show {
                    cell.textLabel?.text = episode.title
                    cell.subtitleTextLabel?.text = show.title
                    
                    let format = NSLocalizedString("season_episode_label_title_format", comment: "Format for a label detailing a show's season and episode number: Season {Number of season}, Episode {Number of episode}.")
                    cell.detailTextLabel?.text = String(format: format, episode.season, episode.number)
                    if !cell.isSizingView { cell.imageView?.kf.setImage(with: episode.screenshotImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
                } else if let movie = item.movie {
                    cell.textLabel?.text = movie.title
                    cell.subtitleTextLabel?.text = movie.genres?.compactMap({$0.capitalized}).prefix(3).joined(separator: ", ")
                    
                    if let runtime = movie.runtime {
                        let formatter = DateComponentsFormatter()
                        formatter.unitsStyle = .full
                        formatter.includesTimeRemainingPhrase = true
                        formatter.allowedUnits = [.hour, .minute]
                        
                        let remaining = TimeInterval(Float(runtime) - (Float(runtime) * item.progress/100))
                        cell.detailTextLabel?.text = formatter.string(from: remaining * 60)
                    } else {
                        cell.detailTextLabel?.text = nil
                    }
                    
                    if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.backdropImage, placeholder: UIImage(named: "PreloadAsset_Movie")) }
                } else {
                    fatalError()
                }
            } else {
                let item = upNext[indexPath.row - unFinished.count]
                let show = item.show
                let episode = item.episode
                
                cell.playCircularProgressBarView?.value = 0
                cell.textLabel?.text = episode.title
                cell.subtitleTextLabel?.text = show.title
                
                let format = NSLocalizedString("season_episode_label_title_format", comment: "Format for a label detailing a show's season and episode number: Season {Number of season}, Episode {Number of episode}.")
                cell.detailTextLabel?.text = String(format: format, episode.season, episode.number)
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: episode.screenshotImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
            }
        case 1:
            let item = watchlist[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            if let movie = item.movie {
                cell.textLabel?.text = movie.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.posterImage, placeholder: UIImage(named: "PreloadAsset_Movie")) }
            } else if let show = item.show {
                cell.textLabel?.text = show.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.posterImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
            } else {
                fatalError()
            }
        case 2:
            let item = recommended[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            if let movie = item.movie {
                cell.textLabel?.text = movie.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.posterImage, placeholder: UIImage(named: "PreloadAsset_Movie")) }
            } else if let show = item.show {
                cell.textLabel?.text = show.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.posterImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
            } else {
                fatalError()
            }
        case 3:
            let item = Array(social.keys)[indexPath.row]
            let cell = cell as! FriendCollectionViewCell
            
            cell.delegate = self
            
            cell.friendAvatars = social[item]?.compactMap({$0.user.avatar}).compactMap({URL(string: $0)}) ?? []
            
            if let movie = item.movie {
                cell.textLabel?.text = movie.title
                cell.detailTextLabel?.text = nil
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.backdropImage, placeholder: UIImage(named: "PreloadAsset_Movie")) }
            } else if let show = item.show, let episode = item.episode {
                cell.textLabel?.text = show.title
                cell.detailTextLabel?.text = String(format: NSLocalizedString("season_episode_label_title_short_format", comment: "Shorthand for the format of a label detailing a show's season and episode number: S{Number of season} E{Number of episode}."), episode.season, episode.number) + " - \(episode.title ?? "")"
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.backdropImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
            } else {
                fatalError()
            }
        case 4:
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            if let movie = related?.related[indexPath.row] as? TraktMovie {
                cell.textLabel?.text = movie.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.posterImage, placeholder: UIImage(named: "PreloadAsset_Movie")) }
            } else if let show = related?.related[indexPath.row] as? TraktShow {
                cell.textLabel?.text = show.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.posterImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
            }
        case 5:
            let item = history[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            if let movie = item.movie {
                cell.textLabel?.text = movie.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.posterImage, placeholder: UIImage(named: "PreloadAsset_Movie")) }
            } else if let show = item.show {
                cell.textLabel?.text = show.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.posterImage, placeholder: UIImage(named: "PreloadAsset_TV")) }
            } else {
                fatalError()
            }
        case 6:
            let cinema = cinemas.first!
            let movie = cinema.screenings[indexPath.row]
            let cell = cell as! HeroCollectionViewCell
            
            cell.delegate = self
            
            cell.textLabel?.text = movie.title
            cell.detailButton?.setTitle(cinema.name.uppercased(), for: .normal)
            let showtimes = Array(Set(movie.performances.values.flatMap({$0}).map({$0.date}))).sorted().map({DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .short)})
            cell.subtitleTextLabel?.text = String(format: NSLocalizedString("cinema_times_format", comment: "Format for displaying movie showtimes: Showing at {Localized string of the cinema showings. E.g. '3:30 PM, 9:15 PM'}"), showtimes.joined(separator: ", "))
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.imageURL, placeholder: UIImage(named: "PreloadAsset_Movie")) }
        default:
            fatalError()
        }
    }
    
    func showsHeaderButton(on rail: Int) -> Bool {
        switch rail {
        case 5,6:
            return true
        default:
            return false
        }
    }
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? {
        switch rail {
        case 0:
            return NSLocalizedString("home_up_next_title", comment: "Presents the user with a list of movies and or episodes that they are in the middle of watching or the next unwatched episode in a series they are watching.")
        case 1:
            return NSLocalizedString("home_watchlist_title", comment: "Presents the user with the list of movies/shows they have previously created with the intention of watching at a later date.")
        case 2:
            return NSLocalizedString("home_recommended_title", comment: "Presents the user with a list of movies/shows based upon their previous watch history.")
        case 3:
            return NSLocalizedString("home_social_feed_title", comment: "Presents the user with a list of the episodes/movies their friends are currently watching.")
        case 4:
            let format = NSLocalizedString("home_similar_title_format", comment: "Presents the user with similar movies/shows based upon a movie/show they have previously watched. This is different from recommended because the items are not specifically tailored to them.")
            
            return String(format: format, related?.item.movie?.title ?? related?.item.show?.title ?? "")
        case 5:
            return NSLocalizedString("home_history_title", comment: "Presents the user with a list of movies/shows they have previously watched and may want to watch again.")
        case 6:
            return NSLocalizedString("home_local_movies_title", comment: "Presents the user with a list of movies that are currently showing in their local cinema.")
        default:
            fatalError()
        }
    }
}
