//
//  EpisodeDetailTableViewController+RailDelegate.swift
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

extension EpisodeDetailTableViewController: RailDelegate {
    
    func numberOfRails() -> Int {
        return [!mediaItem.castAndCrew.isEmpty].filter({$0}).count
    }
    
    func railIdForCell(at indexPath: IndexPath) -> Int {
        var row = indexPath.row + 1
        let dataSource: [[Any]] =  [mediaItem.castAndCrew]
        
        for (index, item) in dataSource.enumerated() {
            row -= item.isEmpty ? 0 : 1
            if row == 0 { return index }
        }
        
        fatalError()
    }
    
    func numberOfCells(on rail: Int) -> Int {
        switch rail {
        case 0:
            return mediaItem.castAndCrew.count
        default:
            fatalError()
        }
    }
    
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int {
        return 1
    }
    
    func cell(at row: Int,
              in collectionView: RailCollectionView,
              on rail: Int) -> UICollectionViewCell {
        let indexPath = IndexPath(row: row, section: 0)
        
        collectionView.register(monogramNib, forCellWithReuseIdentifier: "monogramCell")
        
        let cell: UICollectionViewCell
        
        switch rail {
        case 0:
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
            let person = mediaItem.castAndCrew[indexPath.row]
            let cell = cell as! MonogramCollectionViewCell
            
            cell.textLabel?.text = person.name
            cell.detailTextLabel?.text = person.role
            
            if !cell.isSizingView { cell.imageView?.kf.setImage(with: person.headshotArtworkURL, placeholder: UIImage(named: "PreloadAsset_Monogram")) }
        default:
            fatalError()
        }
    }
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? {
        switch rail {
        case 0:
            return NSLocalizedString("detail_guest_stars_title", comment: "The people who worked on only this episode and do not usually appear in the rest of the show.")
        default:
            fatalError()
        }
    }
    
    func sectionInset(of collectionView: RailCollectionView, on rail: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 14, left: 24, bottom: 28, right: 24)
    }
    
    func lineSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat {
        return 8
    }
}
