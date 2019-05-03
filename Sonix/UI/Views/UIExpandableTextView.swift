//
//  UIExpandableTextView.swift
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

@IBDesignable class UIExpandableTextView: UITextView {
    
    @IBInspectable var trailingText: String = {
        let localized = NSLocalizedString("ui_expandable_text_view_more", comment: "Allows the user to see the rest of the text in a truncated text view.")
        return localized.localizedLowercase
    }()
    
    @IBInspectable var ellipsesString = "..."
    @IBInspectable var trailingTextColor = UIColor(named: "accentColor")
    
    var maxHeight: CGFloat = .greatestFiniteMagnitude {
        didSet {
            guard maxHeight != oldValue else { return }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    private var originalText: String?
    private var _textColor: UIColor? = .black
    
    private (set) var isCompressed = false
    
    override var textColor: UIColor? {
        get {
           return _textColor
        } set(color) {
            _textColor = color
        }
    }
    
    override var text: String! {
        get {
            return super.text
        } set {
            super.text = newValue
            originalText = text
        }
    }
    
    private var textAttributes: [NSAttributedString.Key : Any] {
        guard let color = textColor, let font = font else { return [:] }
        return [.foregroundColor: color, .font: font]
    }
    
    private var trailingTextAttributes: [NSAttributedString.Key : Any] {
        guard let color = trailingTextColor, let font = font else { return [:] }
        return [.foregroundColor: color, .font: font]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedSetup()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        sharedSetup()
    }
    
    private func sharedSetup() {
        let selectGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(expandView))
        selectGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.direct.rawValue)]
        addGestureRecognizer(selectGestureRecognizer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if isCompressed {
            truncateAndUpdateText()
        }
    }
    
    func compressView(toHeight maxHeight: CGFloat) {
        guard !isCompressed else { return }
        isCompressed = true
        self.maxHeight = maxHeight
    }
    
    @objc private func expandView() {
        guard isCompressed else { return }
        isCompressed = false
        maxHeight = .greatestFiniteMagnitude
        untruncateAndUpdateText()
    }
    
    private func untruncateAndUpdateText() {
        if let string = originalText {
            attributedText = NSAttributedString(string: string, attributes: textAttributes)
        }
    }
    
    private func truncateAndUpdateText() {
        guard let text = originalText, !text.isEmpty else { return }
        
        let trailingText = " " + self.trailingText
        attributedText = text.truncateToSize(size: CGSize(width: bounds.size.width,
                                                          height: maxHeight),
                                             ellipsesString: ellipsesString,
                                             trailingText: trailingText,
                                             attributes: textAttributes,
                                             trailingTextAttributes: trailingTextAttributes)
    }
}
