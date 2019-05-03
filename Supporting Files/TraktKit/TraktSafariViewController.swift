//
//  TraktSafariViewController.swift
//  TraktKit iOS
//
//  Created by Mark Bourke on 25/09/2018.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation
import SafariServices

public class TraktLogOutSafariViewController: SFSafariViewController, SFSafariViewControllerDelegate {
    
    private var completion: (() -> Void)?
    
    public static func `init`(completion: (() -> Void)? = nil) -> TraktLogOutSafariViewController {
        let `self` = TraktLogOutSafariViewController(url: URL(string: "https://trakt.tv/logout")!)
        self.completion = completion
        self.delegate = self
        return self
    }
    
    
    public func safariViewController(_ controller: SFSafariViewController, didCompleteInitialLoad didLoadSuccessfully: Bool) {
        finishedLoading()
    }
    
    public func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        finishedLoading()
    }
    
    private func finishedLoading() {
        dismiss(animated: true) { [weak self] in
            self?.completion?()
            self?.completion = nil // If the function is called twice, which it will be if the request completes successfully, the completion block won't be called twice.
        }
    }
}
