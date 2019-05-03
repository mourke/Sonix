//
//  UIAlertController+ContentViewController.swift
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
    
    /// A custom child view controller of `UIAlertController` that can be used to display anything on the header section of an alert controller instance.
    var contentViewController: UIViewController? {
        get {
            return value(forKey: "contentViewController") as? UIViewController
        } set (controller) {
            controller?.viewIfLoaded?.translatesAutoresizingMaskIntoConstraints = false
            setValue(controller, forKey: "contentViewController")
        }
    }
    
    /**
     Creates and returns a view controller for displaying an alert to the user.
     
     - Parameter contentViewController: The custom child view controller of that can be used to display anything on the header section of an alert controller instance, replacing the classic `title` and `message` sections with your custom view.
     - Parameter preferredStyle:        The style to use when presenting the alert controller. Use this parameter to configure the alert controller as an action sheet or as a modal alert.
     - Parameter blurStyle:             The `UIBlurEffectStyle` of the alert controller's visual effect view.
     */
    convenience init(contentViewController: UIViewController,
                     preferredStyle: UIAlertController.Style,
                     blurStyle: UIBlurEffect.Style = .regular) {
        self.init(title: nil, message: nil, preferredStyle: preferredStyle, blurStyle: blurStyle)
        self.contentViewController = contentViewController
    }
    
    open override func overrideTraitCollection(forChild childViewController: UIViewController) -> UITraitCollection? {
        guard childViewController === contentViewController else { return nil }
        
        let traitCollection = childViewController.traitCollection
        let styleTraitCollection: UITraitCollection?
        
        switch blurStyle {
        case .extraLight:
            fallthrough
        case .light:
            styleTraitCollection = UITraitCollection(userInterfaceStyle: .light)
        case .dark:
            styleTraitCollection = UITraitCollection(userInterfaceStyle: .dark)
        case .prominent:
            fallthrough
        case .regular:
            styleTraitCollection = nil
        }
        
        return UITraitCollection(traitsFrom: [traitCollection, styleTraitCollection].compactMap({$0}))
    }
}
