//
//  SplitRowAlertAction.swift
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

class SplitRowAlertAction: UIAlertAction, SplitRowAlertContentViewControllerDelegate {
    
    var images: [UIImage] = [] {
        didSet {
            let contentViewController = self.contentViewController as! SplitRowAlertContentViewController
            contentViewController.images = images
        }
    }
    
    var selectedImage: UIImage? = nil {
        didSet {
            let contentViewController = self.contentViewController as! SplitRowAlertContentViewController
            
            if let image = selectedImage {
                contentViewController.selectedImageIndex = images.index(of: image)
            } else {
                contentViewController.selectedImageIndex = nil
            }
        }
    }
    
    convenience init(images: UIImage...,
                     selectedImage: UIImage? = nil,
                     handler: ((SplitRowAlertAction, Int?) -> Void)? = nil) {
        self.init(images: images, selectedImage: selectedImage, handler: handler)
    }
    
    convenience init(images: [UIImage] = [],
                     selectedImage: UIImage? = nil,
                     handler: ((SplitRowAlertAction, Int?) -> Void)? = nil) {
        let contentViewController = SplitRowAlertContentViewController(nibName: "SplitRowAlertContentViewController", bundle: nil)
    
        contentViewController.loadViewIfNeeded()

        self.init(contentViewController: contentViewController, style: .default) { [unowned contentViewController] (action) in
            let action = action as! SplitRowAlertAction
            handler?(action, contentViewController.selectedImageIndex)
            action.alertController?.dismiss(animated: true)
        }
        
        contentViewController.delegate = self
        
        // Make sure `didSet` is called.
        defer {
            self.images = images
            self.selectedImage = selectedImage
        }
    }
    
    func imageWasSelected(in splitRowAlertContentViewController: SplitRowAlertContentViewController,
                          indexOfImage index: Int) {
        if let image = selectedImage, images.index(of: image) == index {
            selectedImage = nil
        } else {
            selectedImage = images[index]
        }
        
        handler?(self)
    }
}
