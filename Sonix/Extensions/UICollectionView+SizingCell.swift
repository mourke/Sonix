//
//  UICollectionView+SizingCell.swift
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

import UIKit.UICollectionView

extension UICollectionView {
    
    private struct AssociatedKey {
        static var sizingViews = "UICollectionView.sizingViews"
    }
    
    private var sizingViews: [UICollectionReusableView] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.sizingViews) as? [UICollectionReusableView] ?? []
        } set {
            objc_setAssociatedObject(self, &AssociatedKey.sizingViews, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    override open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        sizingViews.forEach({$0.sizingTraitCollection = self.traitCollection})
    }
    
    func dequeueSizingCell<C: UICollectionViewCell>(of type: C.Type) -> C {
        if let view = sizingViews.first(where: {Swift.type(of: $0) == type}) as? C {
            view.sizingTraitCollection = traitCollection
            view.isSizingView = true
            return view
        } else if let view = Bundle.main.loadNibNamed(String(describing: type), owner: self, options: nil)?.first as? C {
            sizingViews.append(view)
            return dequeueSizingCell(of: type)
        } else {
            fatalError("Nib named: \(String(describing: type)) does not exist.")
        }
    }
    
    func dequeueSizingHeader<H: UICollectionReusableView>(of type: H.Type) -> H  {
        if let view = sizingViews.first(where: {Swift.type(of: $0) == type}) as? H {
            view.sizingTraitCollection = traitCollection
            view.isSizingView = true
            return view
        } else if let view = Bundle.main.loadNibNamed(String(describing: type), owner: self, options: nil)?.first as? H {
            sizingViews.append(view)
            return dequeueSizingHeader(of: type)
        } else {
            fatalError("Nib named: \(String(describing: type)) does not exist.")
        }
    }
}
