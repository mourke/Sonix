//
//  UIAlertController+PreferredAction.swift
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
    
    /// The preferred action for the user to take from an alert.
    @nonobjc var preferredAction: UIAlertAction? {
        get {
            let selector = "preferredAction"
            return perform(Selector(selector))?.takeUnretainedValue() as? UIAlertAction
        } set (action) {
            preferredAction?.checkView?.isHidden = true // Remove the checkmark from the current preferred action.
            let selector = "setPreferredAction:"
            perform(Selector(selector), with: action)
            updatePreferredAction()
        }
    }
    
    /// UIAlertAction's view property isn't always initialised when `preferredAction` is set. This function can be called from anywhere to update the checkmark on the preferredAction's view.
    private func updatePreferredAction() {
        preferredAction?.checkView?.image = UIImage(named: "Checkmark")
        preferredAction?.checkView?.isHidden = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
 
        updatePreferredAction()
    }
}
