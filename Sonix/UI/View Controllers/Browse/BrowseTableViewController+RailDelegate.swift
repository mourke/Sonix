//
//  BrowseTableViewController+RailDelegate.swift
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

extension BrowseTableViewController: RailDelegate {
    
    func numberOfRails() -> Int {
        let rails = [!lists.isEmpty, !recentlyAdded.isEmpty, !anticipated.isEmpty].filter({$0}).count
        return rails == 0 ? rails : rails + 1 // Only add the genres rail when the other rails are loaded.
    }
    
    func railIdForCell(at indexPath: IndexPath) -> Int {
        var row = indexPath.row + 1
        let dataSource: [[Any]] =  [lists, recentlyAdded, anticipated, [0]]
        
        for (index, item) in dataSource.enumerated() {
            row -= item.isEmpty ? 0 : 1
            if row == 0 { return index }
        }
        
        fatalError()
    }
    
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int {
        switch rail {
        case 3 where traitCollection.horizontalSizeClass == .compact:
            return 2
        default:
            return 1
        }
    }
    
    func numberOfCells(on rail: Int) -> Int {
        switch rail {
        case 0:
            return lists.count
        case 1:
            return recentlyAdded.count
        case 2:
            return anticipated.count
        case 3:
            return 2
        default:
            fatalError()
        }
    }
    
    func cell(at row: Int,
              in collectionView: RailCollectionView,
              on rail: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: 0)
        
        collectionView.register(posterNib, forCellWithReuseIdentifier: "posterCell")
        collectionView.register(tableNib, forCellWithReuseIdentifier: "tableCollectionViewCell")
        collectionView.register(listNib, forCellWithReuseIdentifier: "listCell")
        
        let cell: UICollectionViewCell

        switch rail {
        case 0:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "listCell", for: indexPath)
        case 1,2:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath)
        case 3:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tableCollectionViewCell", for: indexPath)
        default:
            fatalError()
        }
        
        configure(cell, at: indexPath, on: rail)
        return cell
    }
    
    func configure(_ cell: UICollectionViewCell, at indexPath: IndexPath, on rail: Int) {
        switch rail {
        case 0:
            let list = lists[indexPath.row]
            let cell = cell as! ListCollectionViewCell
            
            cell.delegate = self
            
            cell.textLabel?.text = list.name
            let images = list.items.compactMap({$0.movie?.posterImage ?? $0.show?.posterImage})
            for (index, imageView) in cell.imageViews.enumerated() where !cell.isSizingView {
                imageView.kf.setImage(with: images[safe: index], placeholder: UIImage(named: "PreloadAsset_Movie"))
            }
        case 1:
            let movie = recentlyAdded[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            cell.textLabel?.text = movie.title
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.images.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_Movie")) }
        case 2:
            let item = anticipated[indexPath.row]
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
            let cell = cell as! TableCollectionViewCell
            
            cell.delegate = self
            
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = NSLocalizedString("browse_genre_title_movie", comment: "Presents the user with a list of movie genres.")
                cell.imageView?.image = UIImage(named: "Movies")
            case 1:
                cell.textLabel?.text = NSLocalizedString("browse_genre_title_show", comment: "Presents the user with a list of show genres.")
                cell.imageView?.image = UIImage(named: "10770")
            default:
                fatalError()
            }
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
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? {
        switch rail {
        case 0:
            return nil
        case 1:
            return NSLocalizedString("browse_recently_added_title", comment: "Presents the user with a list of movies that were recently made available.")
        case 2:
            return NSLocalizedString("browse_anticipated_title", comment: "Presents the user with a list of movies/shows that have not yet come out, but for which people are keenly waiting.")
        case 3:
            return NSLocalizedString("browse_genres_title", comment: "Presents the user with a list of movie/show genres.")
        default:
            fatalError()
        }
    }
    
    func interitemSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat {
        switch rail {
        case 3:
            return 0
        default:
            return 10
        }
    }
    
    func sectionInset(of collectionView: RailCollectionView, on rail: Int) -> UIEdgeInsets {
        let sizeClass = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass ?? .unspecified
        let constant = sizeClass.spacingConstant
        return UIEdgeInsets(top: 14, left: constant, bottom: rail == 3 ? 0 : sizeClass == .compact ? 10 : 28, right: constant)
    }
}
