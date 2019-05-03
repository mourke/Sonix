//
//  NavigationBarTableViewHeaderFooterView.swift
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

class NavigationBarTableViewHeaderFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet private var dateLabel: UILabel?
    @IBOutlet private var navigationTitleLabel: UILabel?
    @IBOutlet var accountButton: UIButton?
    
    
    let separatorView = UIView()
    
    
    override var textLabel: UILabel? {
        return navigationTitleLabel
    }
    
    override var detailTextLabel: UILabel? {
        return dateLabel
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let tableView = tableView {
            let height: CGFloat = 0.5
            let inset = traitCollection.horizontalSizeClass.spacingConstant
            separatorView.backgroundColor = tableView.separatorColor
            separatorView.frame.origin = CGPoint(x: inset + safeAreaInsets.left, y: frame.height - height)
            separatorView.frame.size = CGSize(width: frame.width - (2 * inset) - safeAreaInsets.left - safeAreaInsets.right, height: height)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(separatorView)
        updateDateLabel()
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        if newWindow == nil {
            NotificationCenter.default.removeObserver(self, name: .NSSystemClockDidChange, object: nil)
        }
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(updateDateLabel), name: .NSSystemClockDidChange, object: nil)
            updateUserImage()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUserImage()
    }
    
    private func updateUserImage() {
        let width: CGFloat = traitCollection.horizontalSizeClass == .compact ? 36 : 43
        accountButton?.setImage(Settings.image?.scaled(to: CGSize(width: width, height: width)).withCornerRadius(width/2).withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    @objc func updateDateLabel() {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        
        detailTextLabel?.text = formatter.string(from: Date()).localizedCapitalized
    }
}
