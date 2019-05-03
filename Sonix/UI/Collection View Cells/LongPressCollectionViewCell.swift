//
//  LongPressCollectionViewCell.swift
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

protocol LongPressCollectionViewCellDelegate: class {
    
    func collectionView(_ collectionView: UICollectionView, longPressGestureRecognizer: UILongPressGestureRecognizer, didTriggerForItemAt indexPath: IndexPath)
}

class LongPressCollectionViewCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    weak var delegate: LongPressCollectionViewCellDelegate?
    
    let longPressGestureRecognizer = UILongPressGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        longPressGestureRecognizer.addTarget(self, action: #selector(longPressDetected(_:)))
        longPressGestureRecognizer.delegate = self
        
        addGestureRecognizer(longPressGestureRecognizer)
    }
    
    @objc private func longPressDetected(_ gesture: UILongPressGestureRecognizer) {
        if let collectionView = collectionView, let delegate = delegate,
            let indexPath = collectionView.indexPath(for: self) {
            delegate.collectionView(collectionView, longPressGestureRecognizer: gesture, didTriggerForItemAt: indexPath)
        }
    }
}
