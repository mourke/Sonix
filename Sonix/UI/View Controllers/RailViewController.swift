//
//  RailViewController.swift
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

class RailViewController: UITableViewController {
    
    /// Because the `UITableViewCell` containing the `UICollectionView` is reusable, the `UICollectionView.contentOffset` can be shared between two cells displaying different content. This dictionary is used to keep track of the `UICollectionView`'s corresponding `UICollectionView.contentOffset`
    private var collectionViewOffsets: [Int: CGPoint] = [:]
    
    let statusBarBackgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        view.effectSubview?.backgroundColor = UIColor(named: "visualEffectSubviewBackgroundColor")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cellNib = UINib(nibName: "RailTableViewCell", bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: "collectionViewCell")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        tableView.reloadData()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self as! RailDelegate).numberOfRails()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "collectionViewCell", for: indexPath) as! RailTableViewCell
        
        if let collectionView = cell.collectionView {
            let layout = collectionView.collectionViewLayout as! RailCollectionViewFlowLayout
            let delegate = (self as! RailDelegate)
            
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.tag = delegate.railIdForCell(at: indexPath)
            
            layout.sectionHeadersPinToVisibleBounds = true
            layout.cellsPerColumn = delegate.cellsPerColumn(in: indexPath.section, of: collectionView, on: collectionView.tag)
            layout.minimumInteritemSpacing = delegate.interitemSpacing(in: collectionView, on: collectionView.tag)
            layout.minimumLineSpacing = delegate.lineSpacing(in: collectionView, on: collectionView.tag)
            layout.sectionInset = delegate.sectionInset(of: collectionView, on: collectionView.tag)
            
            cell.separatorInset.right = layout.sectionInset.right + view.safeAreaInsets.right
            cell.separatorInset.left = layout.sectionInset.left + view.safeAreaInsets.left
            
            collectionView.reloadData()
        }
        
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let collectionView = (cell as! RailTableViewCell).collectionView {
            collectionView.contentOffset = collectionViewOffsets[collectionView.tag] ?? CGPoint(x: -collectionView.safeAreaInsets.left, y: 0)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let collectionView = scrollView as? UICollectionView, !decelerate {
            collectionViewOffsets[collectionView.tag] = collectionView.contentOffset
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView {
            collectionViewOffsets[collectionView.tag] = collectionView.contentOffset
        }
    }
}
