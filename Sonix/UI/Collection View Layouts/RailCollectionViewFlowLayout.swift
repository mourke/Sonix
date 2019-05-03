//
//  RailCollectionViewFlowLayout.swift
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

class RailCollectionViewFlowLayout: SnappingCollectionViewFlowLayout {
    
    /// The number of cells stacked vertically.
    var cellsPerColumn: Int = 1
    
    override var collectionView: RailCollectionView? {
        get {
            if let collectionView = super.collectionView {
                assert(collectionView is RailCollectionView, "Only RailCollectionViews may be used with this class")
                return (collectionView as! RailCollectionView)
            }
            
            return nil
        }
    }
    
    override var scrollDirection: UICollectionView.ScrollDirection {
        get {
            return .horizontal
        } set { }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView,
            collectionView.numberOfSections > 0,
            let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) else { return super.layoutAttributesForElements(in: rect) }
        
        var newRect = rect
        newRect.origin.x += headerAttributes.size.width // Super thinks collection view header is positioned such that it is before all the cells when it is not so we need to adjust the frame so that it will encompass the cells that are supposed to be on screen.

        var attributes: [UICollectionViewLayoutAttributes]? = super.layoutAttributesForElements(in: newRect)?.compactMap {
            if $0.representedElementKind == UICollectionView.elementKindSectionHeader {
                return nil
            } else {
                let attributes = $0.copy() as! UICollectionViewLayoutAttributes
                adjust(itemAttributes: attributes, headerSize: headerAttributes.size)
                return attributes
            }
        }
        
        attributes?.append(headerAttributes)
        
        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let collectionView = collectionView,
            elementKind == UICollectionView.elementKindSectionHeader,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
            else {
                return super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        }
        
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        let inset = collectionView.safeAreaInsets.left + sectionInset.left
        let originX = sectionHeadersPinToVisibleBounds ? inset + collectionView.contentOffset.x : inset
        
        let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section) ?? .zero
        
        attributes.size = size
        attributes.frame.origin = CGPoint(x: originX, y: 0)
        attributes.zIndex = 10

        return attributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard
            let attributes = super.layoutAttributesForItem(at: indexPath)?.copy() as? UICollectionViewLayoutAttributes,
            let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: indexPath.section)) else { return nil }
        adjust(itemAttributes: attributes, headerSize: headerAttributes.size)
        return attributes
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        if collectionView?.frame.height != collectionViewContentSize.height {
            collectionView?.invalidateIntrinsicContentSize()
        }
    }
    
    func adjust(itemAttributes attributes: UICollectionViewLayoutAttributes, headerSize: CGSize) {
        attributes.frame.origin.x -= headerSize.width
        attributes.frame.origin.y = headerSize.height + sectionInset.top
        let row: Int = {
            var totalCells = cellsPerColumn
            var column = 0

            while totalCells <= attributes.indexPath.row {
                totalCells += cellsPerColumn
                column += 1
            }

            let cellsInPreceedingColumns = totalCells - cellsPerColumn
            return attributes.indexPath.row - cellsInPreceedingColumns
        }()

        (0..<row).forEach { (_) in
            attributes.frame.origin.y += attributes.frame.height
            attributes.frame.origin.y += minimumInteritemSpacing
        }
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return super.collectionViewContentSize }

    
        var width = collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + sectionInset.right + sectionInset.left
        var height = sectionInset.top + sectionInset.bottom
        let sections = collectionView.numberOfSections
        let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        
        for section in 0..<sections {
            let items = collectionView.numberOfItems(inSection: section)

            if items == 0 && sections < 2 { // Collection view is empty.
                return .zero
            }
            
            for item in 0..<items {
                let indexPath = IndexPath(item: item, section: section)
                let size = delegate?.collectionView?(collectionView,
                                                     layout: collectionView.collectionViewLayout,
                                                     sizeForItemAt: indexPath) ?? itemSize
                let isInFirstRow = Float(item).remainder(dividingBy: Float(cellsPerColumn)) == 0
                if isInFirstRow // Add width spacing only for the first items in the column.
                {
                    width += size.width
                    if item != 0 { // Do not add spacing for the first cell.
                        width += minimumLineSpacing
                    }
                }
                
                if item < cellsPerColumn {
                    height += size.height // All rows are of equal height.
                    if item != 0 { // Do not add spacing for the first row.
                        height += minimumInteritemSpacing
                    }
                }
            }

            if section == 0 {
                let indexPath = IndexPath(item: 0, section: section)
                let size = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)?.size ?? .zero
                height += size.height
            }
        }

        return CGSize(width: width.rounded(.up), height: height.rounded(.up))
    }
}
