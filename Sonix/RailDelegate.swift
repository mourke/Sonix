//
//  RailDelegate.swift
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

/**
 A series of methods that must be implemented in order to have a functioning rail.
 */
protocol RailDelegate {

    /**
     The total number of rails in the rail view controller.
     
     - Returns: The number of rails.
     */
    func numberOfRails() -> Int
    
    /**
     The unqiue id of a rail.
     
     - Parameter indexPath: The indexPath of the rail's `RailTableViewCell`.
     
     - Returns: The unique id.
     */
    func railIdForCell(at indexPath: IndexPath) -> Int
    
    /**
     The number of cells on the specified rail.
     
     - Parameter rail:  The index of the rail.
     
     - Returns: The number of cells to be on the specified rail.
     */
    func numberOfCells(on rail: Int) -> Int
    
    /**
     The number of cells there are vertically downward per column.
     
     - Important: MUST be greater than 0 otherwise an exception will be raised.
     
     - Parameter section:           The section of the collectionView.
     - Parameter collectionView:    The corresponding collectionView.
     - Parameter rail:              The rail on which the collectionView resides.
     
     - Returns: The number of cells.
     */
    func cellsPerColumn(in section: Int, of collectionView: RailCollectionView, on rail: Int) -> Int
    
    /**
     The collection view cell that is at a specific index path on a rail.
     
     - Parameter row:               The row at which the cell can be found.
     - Parameter collectionView:    The collection view that this cell belongs to.
     - Parameter rail:              The index of the rail.
     
     - Returns: A collection view cell.
     */
    func cell(at row: Int, in collectionView: RailCollectionView, on rail: Int) -> UICollectionViewCell
    
    /**
     A boolean value indicating whether or not the specified rail should show a button on the right-hand side of its header. Defaults to `false`.
     
     - Parameter rail:  The index of the rail.
     
     - Returns: Returning `true` will show a button and `false` will hide said button and set its width to 0 so as to not interfere with other header elements.
     */
    func showsHeaderButton(on rail: Int) -> Bool
    
    /**
     The title of the button on the header corresponding to the rail. Defaults to "See all".
     
     - Parameter rail:  The index of the rail.
     
     - Returns: The title of the button.
     */
    func headerButtonTitle(on rail: Int) -> String?
    
    /**
     Called when the button on the header has been pressed.
     
     - Parameter button: The button that was pressed.
     - Parameter rail:   The index of the rail.
     */
    func headerButtonPressed(_ button: UIButton, on rail: Int)
    
    /**
     The title of the header corresponding to the rail. Defaults to `nil`.
     
     - Parameter collectionView:    The collection view for which the header title is being requested.
     - Parameter rail:              The index of the rail.
     
     - Returns: The title of the header.
     */
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String?
    
    /**
     Called when a cell in the rail has been selected.
     
     - Parameter row:               The row in the collectionView corresponding to the cell that has been pressed.
     - Parameter collectionView:    The collection view corresponding to the cell that has been pressed.
     - Parameter rail:              The index of the rail.
     */
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int)
    
    /**
     The section insets for the corresponding `RailCollectionView`'s layout. Defaults to 10, 15, 10, 15 (t,l,b,r).
     
     - Parameter collectionView:    The collection view whose layout is to be changed.
     - Parameter rail:              The index of the rail.
     
     - Returns: Section Insets.
     */
    func sectionInset(of collectionView: RailCollectionView, on rail: Int) -> UIEdgeInsets
    
    /**
     The minimumInteritemSpacing for the corresponding `RailCollectionView`'s layout. Defaults 10.
     
     - Parameter collectionView:    The collection view whose layout is to be changed.
     - Parameter rail:              The index of the rail.
     
     - Returns: Inter-item spacing.
     */
    func interitemSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat
    
    /**
     The minimumLineSpacing for the corresponding `RailCollectionView`'s layout. Defaults 10.
     
     - Parameter collectionView:    The collection view whose layout is to be changed.
     - Parameter rail:              The index of the rail.
     
     - Returns: Line spacing.
     */
    func lineSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat
}

// Optional methods.

extension RailDelegate {
    
    func headerTitle(in collectionView: RailCollectionView, on rail: Int) -> String? { return nil }
    
    func showsHeaderButton(on rail: Int) -> Bool { return false }
    
    func headerButtonTitle(on rail: Int) -> String? { return NSLocalizedString("collection_view_section_header_button_title", comment: "Allows the user to see more of the current truncated list.") }
    
    func headerButtonPressed(_ button: UIButton, on rail: Int) { }
    
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int) { }
    
    func sectionInset(of collectionView: RailCollectionView, on rail: Int) -> UIEdgeInsets {
        let sizeClass = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass ?? .unspecified
        let constant = sizeClass.spacingConstant
        return UIEdgeInsets(top: 14, left: constant, bottom: sizeClass == .compact ? 10 : 28, right: constant)
    }
    
    func interitemSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat {
        return 10
    }
    
    func lineSpacing(in collectionView: RailCollectionView, on rail: Int) -> CGFloat {
        let isCompact = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass == .compact
        return isCompact ? 8 : 30
    }
}
