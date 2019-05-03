//
//  PersonDetailTableViewController+RailDelegate.swift
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

extension PersonDetailTableViewController: RailDelegate {
    
    func numberOfRails() -> Int {
        return [!person.cast.compactMap({$0 as? Movie}).isEmpty,
                !person.cast.compactMap({$0 as? Show}).isEmpty,
                !person.guestAppearances.isEmpty].filter({$0}).count + person.crew.keys.count
    }
    
    func railIdForCell(at indexPath: IndexPath) -> Int {
        var row = indexPath.row + 1
        var dataSource: [[Any]] =  [person.cast.compactMap({$0 as? Movie}), person.cast.compactMap({$0 as? Show}), person.guestAppearances]
        dataSource.append(contentsOf: Array(person.crew.values))
        
        for (index, item) in dataSource.enumerated() {
            row -= item.isEmpty ? 0 : 1
            if row == 0 { return index }
        }
        
        fatalError()
    }
    
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int {
        return 1
    }
    
    func numberOfCells(on rail: Int) -> Int {
        switch rail {
        case 0:
            return person.cast.compactMap({$0 as? Movie}).count
        case 1:
            return person.cast.compactMap({$0 as? Show}).count
        case 2:
            return person.guestAppearances.count
        default:
            let index = rail - 3
            return Array(person.crew.values)[index].count
        }
    }
    
    func cell(at row: Int,
              in collectionView: RailCollectionView,
              on rail: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: 0)
        
        collectionView.register(posterNib, forCellWithReuseIdentifier: "posterCell")
        collectionView.register(videoNib, forCellWithReuseIdentifier: "videoCell")
        
        let cell: UICollectionViewCell
        
        switch rail {
        case 2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        default:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath)
        }
        
        configure(cell, at: indexPath, on: rail)
        return cell
    }
    
    func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath, on rail: Int) {
        switch rail {
        case 0:
            let cell = cell as! PosterCollectionViewCell
            let movie = person.cast.compactMap({$0 as? Movie})[indexPath.row]
            
            cell.textLabel?.text = movie.title
            cell.delegate = self
            
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_TV")) }
        case 1:
            let cell = cell as! PosterCollectionViewCell
            let show = person.cast.compactMap({$0 as? Show})[indexPath.row]
            
            cell.textLabel?.text = show.title
            cell.delegate = self
            
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_TV")) }
        case 2:
            let cell = cell as! VideoCollectionViewCell
            let appearance = person.guestAppearances[indexPath.row]
            
            cell.textLabel?.text = appearance.show.title
            cell.detailTextLabel?.text = appearance.episode.title
            
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: appearance.episode.screenshot(for: .medium), placeholder: UIImage(named: "PreloadAsset_TV_Wide")) }
        default:
            let cell = cell as! PosterCollectionViewCell
            let index = rail - 3
            let item = Array(person.crew.values)[index][indexPath.row]
            
            cell.delegate = self
            
            if let movie = item as? Movie {
                cell.textLabel?.text = movie.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_Movie")) }
            } else {
                let show = item as! Show
                cell.textLabel?.text = show.title
                if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_TV")) }
            }
        }
    }
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? {
        switch rail {
        case 0:
            return NSLocalizedString("detail_movies", comment: "Presents the user with a list of movies in which an actor starred.")
        case 1:
            return NSLocalizedString("detail_tv_shows", comment: "Presents the user with a list of movies in which an actor interpreted a role.")
        case 2:
            return NSLocalizedString("detail_person_guest_appearances", comment: "The episodes in which the person has appeared as an extra but not as a returning, regular cast member.")
        default:
            let index = rail - 3
            return Array(person.crew.keys)[index]
        }
    }
}
