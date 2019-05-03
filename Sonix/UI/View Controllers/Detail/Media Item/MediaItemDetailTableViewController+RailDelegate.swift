//
//  MediaItemDetailTableViewController+RailDelegate.swift
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

extension MediaItemDetailTableViewController: RailDelegate {
    
    func numberOfRails() -> Int {
        return [!mediaItem.extras.isEmpty,
                !episodes(for: seasonBeingDisplayed ?? -1).isEmpty,
                !mediaItem.related.isEmpty,
                !mediaItem.reviews.isEmpty,
                !mediaItem.castAndCrew.isEmpty].filter({$0}).count
    }
    
    func railIdForCell(at indexPath: IndexPath) -> Int {
        var row = indexPath.row + 1
        let dataSource: [[Any]] =  [mediaItem.extras, episodes(for: seasonBeingDisplayed ?? -1), mediaItem.related, mediaItem.reviews, mediaItem.castAndCrew]
        
        for (index, item) in dataSource.enumerated() {
            row -= item.isEmpty ? 0 : 1
            if row == 0 { return index }
        }
        
        fatalError()
    }
    
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int {
        switch rail {
        case 1:
            return traitCollection.horizontalSizeClass == .compact ? 8 : 6
        default:
            return 1
        }
    }
    
    func numberOfCells(on rail: Int) -> Int {
        switch rail {
        case 0:
            return mediaItem.extras.count
        case 1:
            return episodes(for: seasonBeingDisplayed!).count
        case 2:
            return mediaItem.related.count
        case 3:
            return mediaItem.reviews.count
        case 4:
            return mediaItem.castAndCrew.count
        default:
            fatalError()
        }
    }
    
    func cell(at row: Int,
              in collectionView: RailCollectionView,
              on rail: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: 0)
        
        collectionView.register(posterNib, forCellWithReuseIdentifier: "posterCell")
        collectionView.register(monogramNib, forCellWithReuseIdentifier: "monogramCell")
        collectionView.register(videoNib, forCellWithReuseIdentifier: "videoCell")
        collectionView.register(episodeNib, forCellWithReuseIdentifier: "episodeCell")
        collectionView.register(reviewNib, forCellWithReuseIdentifier: "reviewCell")
        collectionView.register(ratingNib, forCellWithReuseIdentifier: "ratingCell")
        
        let cell: UICollectionViewCell
        
        switch rail {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "episodeCell", for: indexPath)
        case 2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath)
        case 3 where indexPath.row == 0 && mediaItem.reviews.contains(where: {$0 is FlixsterReview}):
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ratingCell", for: indexPath)
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "reviewCell", for: indexPath)
        case 4:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "monogramCell", for: indexPath)
        default:
            fatalError()
        }
        
        configure(cell, at: indexPath, on: rail)
        return cell
    }
    
    func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath, on rail: Int) {
        switch rail {
        case 0:
            let video = mediaItem.extras[indexPath.row]
            let cell = cell as! VideoCollectionViewCell
            
            cell.textLabel?.text = video.title
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: video.thumbArtworkURL, placeholder: UIImage(named: "PreloadAsset_TV_Wide")) }
        case 1:
            let episode = episodes(for: seasonBeingDisplayed!)[indexPath.row]
            let cell = cell as! EpisodeCollectionViewCell
            
            cell.textLabel?.text = "\(NumberFormatter.localizedString(from: NSNumber(value: episode.number), number: .none)). \(episode.title)"
            if let date = episode.airDate {
                cell.detailTextLabel?.text = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            } else {
                cell.detailTextLabel?.text = NSLocalizedString("episode_not_aired_title", comment: "The episode was recorded but never ended up airing.")
            }
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: episode.screenshot(for: .medium), placeholder: UIImage(named: "PreloadAsset_TV_Wide")) }
        case 2:
            let related = mediaItem.related[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.textLabel?.text = related.title

            if !cell.isSizingView { cell.imageView?.kf.setImage(with: related.posterArtworkURL, placeholder: UIImage(named: "PreloadAsset_" + (mediaItem.type == .movie ? "Movie" : "TV"))) }
        case 3 where indexPath.row == 0 && mediaItem.reviews.contains(where: {$0 is FlixsterReview}):
            let rating = mediaItem.reviews.compactMap({$0 as? FlixsterReview}).first!
            let cell = cell as! RatingCollectionViewCell
            
            let formatter = NumberFormatter()
            formatter.maximumSignificantDigits = 2
            formatter.numberStyle = .decimal
            formatter.locale = .current

            cell.backgroundView?.backgroundColor = (rail == 2 || rail == 3) ? UIColor(named: "backgroundColor") : UIColor(named: "foregroundColor") // Opposing colour to rail
            
            cell.textLabel?.text = rating.rating
            cell.detailTextView?.text = rating.review
            cell.ratingView?.rating = Float(rating.averageRating)
        case 3 where indexPath.row == 1 && mediaItem.reviews.contains(where: {$0 is RottenTomatoesReview}):
            let review = mediaItem.reviews.compactMap({$0 as? RottenTomatoesReview}).first!
            let cell = cell as! ReviewCollectionViewCell
            
            cell.backgroundView?.backgroundColor = (rail == 2 || rail == 3) ? UIColor(named: "backgroundColor") : UIColor(named: "foregroundColor") // Opposing colour to rail
            
            cell.textLabel?.text = NumberFormatter.localizedString(from: NSNumber(value: Float(review.rating)/100.0), number: .percent)
            cell.detailTextView?.text = review.review
            cell.detailTextView?.isUserInteractionEnabled = false
            cell.detailTextView?.compressView(toHeight: 72)
            cell.subtitleTextLabel?.text = review.author.uppercased()
            cell.imageView?.image = review.image
        case 3:
            let review = mediaItem.reviews.filter({!($0 is FlixsterReview) || !($0 is RottenTomatoesReview)})[indexPath.row]
            let cell = cell as! ReviewCollectionViewCell
            
            cell.backgroundView?.backgroundColor = (rail == 2 || rail == 3) ? UIColor(named: "backgroundColor") : UIColor(named: "foregroundColor") // Opposing colour to rail
            
            if let userReview = review as? UserReview {
                cell.textLabel?.text = userReview.author
                cell.subtitleTextLabel?.text = nil
            } else if let criticReview = review as? CriticReview {
                cell.textLabel?.text = criticReview.publisher
                cell.subtitleTextLabel?.text = criticReview.author.uppercased()
            }
        
            cell.detailTextView?.text = review.review
            cell.detailTextView?.isUserInteractionEnabled = false
            cell.detailTextView?.compressView(toHeight: 72)
        case 4:
            let person = mediaItem.castAndCrew[indexPath.row]
            let cell = cell as! MonogramCollectionViewCell
            
            cell.textLabel?.text = person.name
            cell.detailTextLabel?.text = person.role
            
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: person.headshotArtworkURL, placeholder: UIImage(named: "PreloadAsset_Monogram")) }
        default:
            fatalError()
        }
    }
    
    func showsHeaderButton(on rail: Int) -> Bool {
        switch rail {
        case 1:
            return true
        default:
            return false
        }
    }
    
    func headerButtonTitle(on rail: Int) -> String? {
        switch rail {
        case 1:
            return NSLocalizedString("detail_more_seasons_button_title", comment: "The user wants to see all the seasons that the show contains.")
        default:
            return nil
        }
    }
    
    func headerButtonPressed(_ button: UIButton, on rail: Int) {
        switch rail {
        case 1:
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            mediaItem.seasons.forEach { [unowned self] in
                let action = UIAlertAction(title: $0.name, style: .default) { action in
                    let season = self.mediaItem.seasons.first(where: {$0.name == action.title})!
                    self.changeSeason(to: season.number)
                }
                alertController.addAction(action)
                if $0.number == self.seasonBeingDisplayed {
                    alertController.preferredAction = action
                }
            }
            
            alertController.addAction(.cancel)
            alertController.popoverPresentationController?.sourceView = button
            
            present(alertController, animated: true)
        default:
            fatalError()
        }
    }
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? {
        switch rail {
        case 0:
            return NSLocalizedString("detail_extras_title", comment: "Presents the user with a list of videos such as: behind the scenes, bloopers and deleted scenes for a given movie/show.")
        case 1:
            return mediaItem.seasons.first(where: {$0.number == seasonBeingDisplayed})?.name
        case 2:
            return NSLocalizedString("detail_related_title", comment: "Presents the user with a list of movies/shows that are similar to another movie/show.")
        case 3:
            return NSLocalizedString("detail_reviews_title", comment: "Presents the user with a list of reviews for the movie/show.")
        case 4:
            return NSLocalizedString("detail_people_title", comment: "Presents the user with a list of people who worked on the movie/show during its production.")
        default:
            fatalError()
        }
    }
    
    func interitemSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat {
        switch rail {
        case 1:
            return 0
        default:
            return 10
        }
    }
}
