//
//  OverlappingCollectionViewFlowLayout.swift
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

class OverlappingCollectionViewFlowLayout: AdaptiveCollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var newRect = rect
        newRect.origin.x = 0
        newRect.size.width = super.collectionViewContentSize.width
        
        return super.layoutAttributesForElements(in: newRect)?.compactMap {
            let attributes = $0.copy() as! UICollectionViewLayoutAttributes
            adjustItemAttributes(attributes)
            return attributes
        }.filter({$0.frame.intersects(rect)})
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else { return nil }
        adjustItemAttributes(attributes)
        return attributes
    }
    
    func adjustItemAttributes(_ attributes: UICollectionViewLayoutAttributes) {
        attributes.frame.origin.x = (itemSize.width/2) * CGFloat(attributes.indexPath.row)
        attributes.zIndex = 100000 - attributes.indexPath.row // If you have more than 100000 friends watching the same thing go away please you deserve a negative z index.
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return super.collectionViewContentSize }
        let height = itemSize.height
        var width: CGFloat = 0
        
        for section in 0..<collectionView.numberOfSections {
            let items = collectionView.numberOfItems(inSection: section)
            width += itemSize.width + ((itemSize.width/2) * CGFloat(items - 1))
        }
        
        return CGSize(width: width, height: height)
    }
}
