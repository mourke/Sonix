//
//  HeaderAlertAction.swift
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

class HeaderAlertAction: UIAlertAction {
    
    convenience init(title: String? = nil,
         subtitle: String? = nil,
         detail: String? = nil,
         imageURL: URL? = nil,
         handler: ((HeaderAlertAction) -> Void)? = nil) {
        let contentViewController = HeaderAlertContentViewController(nibName: "HeaderAlertContentViewController", bundle: nil)
        
        contentViewController.loadViewIfNeeded()
        
        contentViewController.textLabel?.text = title
        contentViewController.subtitleTextLabel?.text = subtitle
        contentViewController.detailTextLabel?.text = detail
        contentViewController.imageView?.kf.setImage(with: imageURL, placeholder: UIImage(named: "PreloadAsset_Movie"))
        
        self.init(contentViewController: contentViewController, style: .default) { (action) in
            handler?(action as! HeaderAlertAction)
        }
    }
}
