//
//  RailViewController+UICollectionView.swift
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

extension RailViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self as! RailDelegate).numberOfCells(on: collectionView.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (self as! RailDelegate).cell(at: indexPath.row, in: collectionView as! RailCollectionView, on: collectionView.tag)
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        (self as! RailDelegate).cellSelected(at: indexPath.row, in: collectionView as! RailCollectionView, on: collectionView.tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as? SectionHeaderCollectionReusableView
            else {
                fatalError()
        }
        
        header.button?.removeTarget(self, action: nil, for: .touchUpInside)
        header.button?.addTarget(self, action: #selector(headerButtonPressed(_:)), for: .touchUpInside)
        configure(header, in: collectionView as! RailCollectionView, on: collectionView.tag)
        
        return header
    }
    
    @objc private func headerButtonPressed(_ button: UIButton) {
        if let header = button.superview as? SectionHeaderCollectionReusableView,
            let rail = header.collectionView?.tag {
            (self as! RailDelegate).headerButtonPressed(button, on: rail)
        }
    }
    
    func configure(_ header: SectionHeaderCollectionReusableView, in collectionView: RailCollectionView, on rail: Int) {
        header.textLabel?.text = (self as! RailDelegate).headerTitle(in: collectionView, on: rail)
        header.button?.setTitle((self as! RailDelegate).headerButtonTitle(on: rail), for: .normal)
        header.button?.constraints.first(where: {$0.firstAttribute == .width && type(of: $0) == NSLayoutConstraint.self})?.priority = (self as! RailDelegate).showsHeaderButton(on: rail) ? UILayoutPriority(1) : UILayoutPriority(999)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let collectionView = collectionView as! RailCollectionView
        
        guard (self as! RailDelegate).headerTitle(in: collectionView, on: collectionView.tag) != nil else { return .zero }
        
        
        let collectionViewLayout = collectionViewLayout as! RailCollectionViewFlowLayout
        
        let header = collectionView.dequeueSizingHeader(of: SectionHeaderCollectionReusableView.self)
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(row: 0, section: section))
        
        attributes.size.width = view.frame.width - collectionViewLayout.sectionInset.right - collectionView.safeAreaInsets.left - collectionViewLayout.sectionInset.left - collectionView.safeAreaInsets.right
        configure(header, in: collectionView, on: collectionView.tag)
        
        return header.preferredLayoutAttributesFitting(attributes).size
    }
}
