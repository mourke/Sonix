//
//  UIAlertAction+Extension.swift
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

extension UIAlertAction {
    
    /// The action's `UIAlertController` instance, if any.
    var alertController: UIAlertController? {
        get {
            return value(forKey: "_alertController") as? UIAlertController
        } set (controller) {
            setValue(controller, forKey: "_alertController")
        }
    }
    
    /// A custom child view controller of `UIAlertAction` that can be used to display anything on a `UIAlertAction`'s view.
    var contentViewController: UIViewController? {
        get {
            return value(forKey: "contentViewController") as? UIViewController
        } set (controller) {
            controller?.viewIfLoaded?.translatesAutoresizingMaskIntoConstraints = false
            setValue(controller, forKey: "contentViewController")
        }
    }
    
    /// A block to execute when the user selects the action. This block has no return value and takes the selected action object as its only parameter.
    var handler: ((UIAlertAction) -> Void)? {
        guard let block = value(forKey: "handler") else { return nil }
        let pointer = UnsafeRawPointer(Unmanaged<AnyObject>.passUnretained(block as AnyObject).toOpaque())
        return unsafeBitCast(pointer, to: (@convention(block) (UIAlertAction) -> Void).self)
    }
    
    /// A `UIAlertAction` with style `.cancel` and a localized 'cancel' title.
    static var cancel: UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("ui_alert_action_cancel", comment: "The user wants to cancel an action they previously initiated."), style: .cancel)
    }
    
    /// A `UIAlertAction` with style `.default` and a localized 'ok' title.
    static var ok: UIAlertAction {
        return UIAlertAction(title: NSLocalizedString("ui_alert_action_ok", comment: "The user understands what they have read."), style: .default)
    }
    
    /**
     Create and return an action with the specified title and behavior.
     
     - Parameter contentViewController: The custom view controller to use in lieu of the standard `title` and `message`. This view controller will be asked for its height (50 is the lowest height, if anything lower is returned it is ignored) but its width will be fixed automatically by its parent.
     - Parameter style:                 Additional styling information to apply to the button. Use the style information to convey the type of action that is performed by the button. For a list of possible values, see the constants in UIAlertAction.Style.
     - Parameter handler:               A block to execute when the user selects the action. This block has no return value and takes the selected action object as its only parameter.
     */
    convenience init(contentViewController: UIViewController,
                     style: UIAlertAction.Style,
                     handler: ((UIAlertAction) -> Void)? = nil) {
        self.init(title: "", style: style, handler: handler)
        self.contentViewController = contentViewController
    }
    
    /// The image view on the right-hand side of the alert action's view.
    var checkView: UIImageView? {
        get {
            guard let view = view else { return nil }
            let checkView = view.value(forKeyPath: "_checkView") as? UIImageView
            
            if checkView == nil {
                view.perform(Selector(("_loadCheckView")))
                return self.checkView
            }
            
            return checkView
        }
    }
    
    /// The alert action's view.
    var view: UIView? {
        return value(forKey: "_representer") as? UIView
    }
}
