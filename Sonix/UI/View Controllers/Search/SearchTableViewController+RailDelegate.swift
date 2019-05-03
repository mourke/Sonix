//
//  SearchTableViewController+RailDelegate.swift
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

extension SearchTableViewController: RailDelegate {
    
    func numberOfRails() -> Int {
        return [!movies.isEmpty, !shows.isEmpty, !people.isEmpty].filter({$0}).count
    }
    
    func railIdForCell(at indexPath: IndexPath) -> Int {
        var row = indexPath.row + 1
        let dataSource: [[Any]] =  [movies, shows, people]
        
        for (index, item) in dataSource.enumerated() {
            row -= item.isEmpty ? 0 : 1
            if row == 0 { return index }
        }
        
        fatalError()
    }
    
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int {
        return 1
    }
    
    func cell(at row: Int,
              in collectionView: RailCollectionView,
              on rail: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: 0)
        
        collectionView.register(monogramNib, forCellWithReuseIdentifier: "monogramCell")
        collectionView.register(posterNib, forCellWithReuseIdentifier: "posterCell")
        
        let cell: UICollectionViewCell
        
        switch rail {
        case 0:
            fallthrough
        case 1:
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "posterCell", for: indexPath)
        case 2:
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
            let movie = movies[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            cell.textLabel?.text = movie.title
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: movie.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_Movie")) }
        case 1:
            let show = shows[indexPath.row]
            let cell = cell as! PosterCollectionViewCell
            
            cell.delegate = self
            
            cell.textLabel?.text = show.title
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: show.poster(for: .medium), placeholder: UIImage(named: "PreloadAsset_TV")) }
        case 2:
            let person = people[indexPath.row]
            let cell = cell as! MonogramCollectionViewCell
            
            cell.delegate = self
            
            cell.textLabel?.text = person.name
            cell.detailTextLabel?.text = nil
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: person.headshot(for: .medium), placeholder: UIImage(named: "PreloadAsset_Monogram")) }
        default:
            fatalError()
        }
    }
    
    func numberOfCells(on rail: Int) -> Int {
        switch rail {
        case 0:
            return movies.count
        case 1:
            return shows.count
        case 2:
            return people.count
        default:
            fatalError()
        }
    }
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? {
        switch rail {
        case 0:
            return NSLocalizedString("trending_movies_label", comment: "A list of movies that have a lot of people currently watching.")
        case 1:
            return NSLocalizedString("trending_shows_label", comment: "A list of shows that have a lot of people currently watching.")
        case 2:
            return NSLocalizedString("trending_people_label", comment: "A list of cast & crew members from movies that are currently popular.")
        default:
            fatalError()
        }
    }
    
    func sectionInset(of collectionView: RailCollectionView, on rail: Int) -> UIEdgeInsets {
        let constant = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass.spacingConstant ?? 0
        return UIEdgeInsets(top: 10, left: constant, bottom: rail == 3 ? 0 : 10, right: constant)
    }
}
