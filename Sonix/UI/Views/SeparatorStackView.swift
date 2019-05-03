//
//  SeparatorStackView.swift
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

@IBDesignable class SeparatorStackView: UIStackView {
    
    @IBInspectable var separatorColor: UIColor? = .black {
        didSet {
            invalidateSeparators()
        }
    }
    @IBInspectable var separatorWidth: CGFloat = 0.5 {
        didSet {
            invalidateSeparators()
        }
    }
    @IBInspectable private var separatorTopPadding: CGFloat = 0 {
        didSet {
            separatorInsets.top = separatorTopPadding
        }
    }
    @IBInspectable private var separatorBottomPadding: CGFloat = 0 {
        didSet {
            separatorInsets.bottom = separatorBottomPadding
        }
    }
    @IBInspectable private var separatorLeftPadding: CGFloat = 0 {
        didSet {
            separatorInsets.left = separatorLeftPadding
        }
    }
    @IBInspectable private var separatorRightPadding: CGFloat = 0 {
        didSet {
            separatorInsets.right = separatorRightPadding
        }
    }
    
    var separatorInsets: UIEdgeInsets = .zero {
        didSet {
            invalidateSeparators()
        }
    }
    
    private var separators: [UIView] = []
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        invalidateSeparators()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        invalidateSeparators()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        invalidateSeparators()
    }
    
    
    private func invalidateSeparators() {
        guard arrangedSubviews.count > 1 else {
            separators.forEach({$0.removeFromSuperview()})
            separators.removeAll()
            return
        }
        
        if separators.count > arrangedSubviews.count {
            separators.removeLast(separators.count - arrangedSubviews.count)
        } else if separators.count < arrangedSubviews.count {
            separators += Array<UIView>(repeating: UIView(), count: arrangedSubviews.count - separators.count)
        }
        
        separators.forEach({$0.backgroundColor = self.separatorColor; self.addSubview($0)})
        
        for (index, subview) in arrangedSubviews.enumerated() where arrangedSubviews.count >= index + 2 {
            let nextSubview = arrangedSubviews[index + 1]
            let separator = separators[index]
            
            let origin: CGPoint
            let size: CGSize
            
            if axis == .horizontal {
                let originX = (nextSubview.frame.maxX - subview.frame.minX)/2 + separatorInsets.left - separatorInsets.right
                origin = CGPoint(x: originX, y: separatorInsets.top)
                let height = frame.height - separatorInsets.bottom - separatorInsets.top
                size = CGSize(width: separatorWidth, height: height)
            } else {
                let originY = (nextSubview.frame.maxY - subview.frame.minY)/2 + separatorInsets.top - separatorInsets.bottom
                origin = CGPoint(x: separatorInsets.left, y: originY)
                let width = frame.width - separatorInsets.left - separatorInsets.right
                size = CGSize(width: width, height: separatorWidth)
            }
            
            separator.frame = CGRect(origin: origin, size: size)
        }
    }
}
