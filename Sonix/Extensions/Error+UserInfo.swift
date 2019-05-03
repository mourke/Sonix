//
//  Error+UserInfo.swift
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

import Foundation.NSError

protocol ErrorRecoveryAttempting {
    
    /**
     Implemented to attempt a recovery from an error noted in a document-modal sheet.
     
     Invoked when an error alert is presented to the user in a document-modal sheet, and the user has selected an error recovery option specified by error. After recovery is attempted, your implementation should send delegate the message specified in `didRecoverSelector`, passing the provided contextInfo.
     
     The `didRecoverSelector` should have the following signature:
     
         - (void)didPresentErrorWithRecovery:(BOOL)didRecover contextInfo:(void *)contextInfo;
     where `didRecover` is `true` if the error recovery attempt was successful; otherwise it is `false`.
     
     - Parameter error:                 An `Error` object that describes the error, including error recovery options.
     - Parameter recoveryOptionIndex:   The index of the user selected recovery option in error’s localized recovery array.
     - Parameter delegate:              An object that is the modal delegate.
     - Parameter didRecoverSelector:    A selector identifying the method implemented by the modal delegate.
     - Parameter contextInfo:           Arbitrary data associated with the attempt at error recovery, to be passed to `delegate` in `didRecoverSelector`.
     */
    func attemptRecovery(fromError error: Error,
                         optionIndex recoveryOptionIndex: Int,
                         delegate: Any?,
                         didRecoverSelector: Selector?,
                         contextInfo: UnsafeMutableRawPointer?)
    
    /**
     Implemented to attempt a recovery from an error noted in an application-modal dialog.
     
     Invoked when an error alert is been presented to the user in an application-modal dialog, and the user has selected an error recovery option specified by error.
     
     - Parameter error:                 An `Error` object that describes the error, including error recovery options.
     
     - Parameter recoveryOptionIndex:   The index of the user selected recovery option in error's localized recovery array.
     
     - Returns: `true` if the error recovery was completed successfully, `false` otherwise.
     */
    @discardableResult
    func attemptRecovery(fromError error: Error,
                         optionIndex recoveryOptionIndex: Int) -> Bool
}

extension NSObject: ErrorRecoveryAttempting { }

extension Error {
    
    /** Return a complete sentence which describes why the operation failed. For instance, for NSFileReadNoPermissionError: "You don't have permission.". In many cases this will be just the "because" part of the error message (but as a complete sentence, which makes localization easier).  Default implementation of this picks up the value of NSLocalizedFailureReasonErrorKey from the userInfo dictionary. If not present, it consults the userInfoValueProvider for the domain, and if that returns nil, this also returns nil.
     */
    var localizedFailureReason: String? {
        return (self as NSError).localizedFailureReason
    }
    
    
    /** Return the string that can be displayed as the "informative" (aka "secondary") message on an alert panel. For instance, for NSFileReadNoPermissionError: "To view or change permissions, select the item in the Finder and choose File > Get Info.". Default implementation of this picks up the value of NSLocalizedRecoverySuggestionErrorKey from the userInfo dictionary. If not present, it consults the userInfoValueProvider for the domain, and if that returns nil, this also returns nil.
     */
    var localizedRecoverySuggestion: String? {
        return (self as NSError).localizedRecoverySuggestion
    }
    
    
    /** Return titles of buttons that are appropriate for displaying in an alert. These should match the string provided as a part of localizedRecoverySuggestion.  The first string would be the title of the right-most and default button, the second one next to it, and so on. If used in an alert the corresponding default return values are NSAlertFirstButtonReturn + n. Default implementation of this picks up the value of NSLocalizedRecoveryOptionsErrorKey from the userInfo dictionary. If not present, it consults the userInfoValueProvider for the domain, and if that returns nil, this also returns nil. nil return usually implies no special suggestion, which would imply a single "OK" button.
     */
    var localizedRecoveryOptions: [String]? {
        return (self as NSError).localizedRecoveryOptions
    }
    
    /* Return an object that conforms to the NSErrorRecoveryAttempting informal protocol. The recovery attempter must be an object that can correctly interpret an index into the array returned by localizedRecoveryOptions. The default implementation of this picks up the value of NSRecoveryAttempterErrorKey from the userInfo dictionary. If not present, it consults the userInfoValueProvider for the domain. If that returns nil, this also returns nil.
     */
    var recoveryAttempter: ErrorRecoveryAttempting? {
        return (self as NSError).recoveryAttempter as? ErrorRecoveryAttempting
    }
}
