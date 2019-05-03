//
//  UIAlertController+Error.swift
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
    
    /**
     Creates and returns a view controller for displaying an error alert to the user.
     
     - Parameter error: The error to be presented.
     */
    convenience init(error: Error) {
        let message: String?
        
        if let recoverySuggestion = error.localizedRecoverySuggestion {
            message = "\(error.localizedDescription ) \(recoverySuggestion)"
        } else {
            message = error.localizedDescription
        }
        
        self.init(title: error.localizedFailureReason, message: message, preferredStyle: .alert)
        
        if let options = error.localizedRecoveryOptions {
            for (index, title) in options.enumerated() {
                let action = UIAlertAction(title: title, style: .default) { (_) in
                    error.recoveryAttempter?.attemptRecovery(fromError: error, optionIndex: index)
                }
                self.addAction(action)
            }
        } else {
            addAction(.ok)
        }
    }
}
