//
//  UIAlertController+BlurStyle.swift
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

extension UIAlertController {
    
    /// The `UIBlurEffectStyle` of the alert controller's visual effect view.
    var blurStyle: UIBlurEffect.Style {
        get {
            return objc_getAssociatedObject(self, &AssociatedKey.blurStyle) as? UIBlurEffect.Style ?? .regular
        } set (style) {
            objc_setAssociatedObject(self, &AssociatedKey.blurStyle, style, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            
            updateAppearance()
        }
    }
    
    /**
     Creates and returns a view controller for displaying an alert to the user.
     
     - Parameter title:             The title of the alert. Use this string to get the user’s attention and communicate the reason for the alert.
     - Parameter message:           Descriptive text that provides additional details about the reason for the alert.
     - Parameter preferredStyle:    The style to use when presenting the alert controller. Use this parameter to configure the alert controller as an action sheet or as a modal alert.
     - Parameter blurStyle:         The `UIBlurEffectStyle` of the alert controller's visual effect view.
     */
    convenience init(title: String?,
                     message: String?,
                     preferredStyle: UIAlertController.Style,
                     blurStyle: UIBlurEffect.Style) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        self.blurStyle = blurStyle
        updateAppearance()
    }
    
    private struct AssociatedKey {
        static var blurStyle = "UIAlertController.blurStyle"
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateAppearance()
    }
    
    private func updateAppearance() {
        visualEffectView?.effect = UIBlurEffect(style: blurStyle)
        
        let traitCollection: UITraitCollection?
        
        switch blurStyle {
        case .extraLight:
            fallthrough
        case .light:
            traitCollection = UITraitCollection(userInterfaceStyle: .light)
        case .dark:
            traitCollection = UITraitCollection(userInterfaceStyle: .dark)
        case .prominent:
            fallthrough
        case .regular:
            traitCollection = nil
        }
    
        visualEffectView?.effectSubview?.backgroundColor = UIColor(named: "visualEffectSubviewBackgroundColor", in: nil, compatibleWith: traitCollection)
        cancelBackgroundView?.setValue(UIColor(named: "backgroundColor", in: nil, compatibleWith: traitCollection), forKeyPath: "backgroundView.backgroundColor")
    }
    
    private var visualEffectView: UIVisualEffectView? {
        if let presentationController = presentationController,
            presentationController.responds(to: Selector(("popoverView"))),
            let view = presentationController.value(forKey: "popoverView") as? UIView // We're on an iPad and visual effect view is in a different place.
        {
            return view.recursiveSubviews.compactMap({$0 as? UIVisualEffectView}).first
        }
        
        return view.recursiveSubviews.compactMap({$0 as? UIVisualEffectView}).first
    }
    
    private var cancelBackgroundView: UIView? {
        return actions.first(where: {$0.style == .cancel})?.view?.superview?.subviews.first(where: {type(of: $0) == NSClassFromString("_UIAlertControlleriOSActionSheetCancelBackgroundView")})
    }
}
