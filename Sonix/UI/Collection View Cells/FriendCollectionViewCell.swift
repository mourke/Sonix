//
//  FriendCollectionViewCell.swift
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

class FriendCollectionViewCell: PosterCollectionViewCell, UICollectionViewDataSource {
    
    @IBOutlet var friendsWatchingCollectionView: UICollectionView?
    @IBOutlet var detailTextLabel: UILabel?
    
    var friendAvatars: [URL] = [] {
        didSet {
            guard oldValue != friendAvatars else { return }
            friendsWatchingCollectionView?.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        friendsWatchingCollectionView?.register(UINib(nibName: "HeadshotCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "headshotCell")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.height * 0.05
        layer.masksToBounds = true
        highlightView?.layer.cornerRadius = 0
    }
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return friendAvatars.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "headshotCell", for: indexPath) as! HeadshotCollectionViewCell
        let url = friendAvatars[indexPath.row]
        
        cell.imageView?.kf.setImage(with: url, placeholder: UIImage(named: "PreloadAsset_Generic"))
        
        return cell
    }
    
    // MARK: - Gesture recognizer delegate
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return longPressGestureRecognizer != gestureRecognizer
    }
}
