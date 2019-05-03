//
//  SplitRowAlertContentViewController.swift
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

protocol SplitRowAlertContentViewControllerDelegate: class {
    func imageWasSelected(in splitRowAlertContentViewController: SplitRowAlertContentViewController, indexOfImage index: Int)
}

class SplitRowAlertContentViewController: UIViewController {
    
    weak var delegate: SplitRowAlertContentViewControllerDelegate?
    
    var stackView: UIStackView {
        return view as! UIStackView
    }
    
    private var imageViews: [UIImageView] = []
    
    /// `UIAlertController`'s gesture recognizer for recognizing `UIAlertAction` touches. We need to hijack this to stop the default highlighting and selecting behaviour to give the illusion of multiple `UIAlertAction`s mascarading as one `UIAlertAction` on a `UIStackView`.
    private lazy var parentLongPressGestureRecognizer = parent?.view.recursiveSubviews.compactMap({$0.gestureRecognizers}).flatMap({$0}).compactMap({$0 as? UILongPressGestureRecognizer}).first
    
    var images: [UIImage] = [] {
        didSet {
            guard oldValue != images else { return }
            
            stackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
            imageViews.removeAll()
            
            for image in images {
                let imageView = UIImageView()
                imageViews.append(imageView)
                
                imageView.image = image
                imageView.contentMode = .center
                
                stackView.addArrangedSubview(imageView)
            }
        }
    }
    
    var selectedImageIndex: Int? {
        didSet {
            guard selectedImageIndex != oldValue else { return }
            
            if let index = selectedImageIndex {
                let imageView = imageViews[index]
                imageView.tintColor = .white
                imageView.backgroundColor = view.tintColor
            } else {
                for imageView in imageViews {
                    imageView.backgroundColor = nil
                    imageView.tintColor = view.tintColor
                }
            }
        }
    }
    
    private var selectedImageView: UIImageView? {
        if let index = selectedImageIndex {
            return imageViews[index]
        }
        return nil
    }
    
    override func viewTintColorDidChange() {
        super.viewTintColorDidChange()
        
        selectedImageView?.backgroundColor = view.tintColor
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        guard let parent = parent else { return }
        
        let button = UIButton(type: .custom)
        parent.view.addSubview(button)
        
        button.frame = parent.view.bounds
        button.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        button.addTarget(self, action: #selector(alertControllerTouched(_:for:)), for: .allEvents)
        button.addTarget(self, action: #selector(stackViewSelected(_:for:)), for: .touchUpInside)
    }
    
    @objc private func alertControllerTouched(_ button: UIButton, for event: UIEvent) {
        imageViews.filter({$0 != selectedImageView}).forEach({$0.backgroundColor = nil}) // Unhighlight image views
        
        guard let gesture = parentLongPressGestureRecognizer,
            let touch = event.touches(for: button)?.first, let touches = event.allTouches else { return }
        
        if let highlightedImageView = highlightedImageView(for: touch) {
            gesture.perform(#selector(UIResponder.touchesCancelled(_:with:)), with: touches, with: event) // Remove highlighted background on other actions.
            if highlightedImageView != selectedImageView {
                highlightedImageView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
            }
        } else {
            switch touch.phase {
            case _ where gesture.state == .possible: // We manually cancelled it earlier to clear the highlighted UI when it was not actually cancelled. The `touch.phase` is `.moved` which will not display the highlighting correctly at this point.
                fallthrough
            case .began:
                gesture.perform(#selector(UIResponder.touchesBegan(_:with:)), with: touches, with: event)
            case .moved:
                gesture.setValue(UIGestureRecognizer.State.changed.rawValue, forKey: "state")
                gesture.perform(#selector(UIResponder.touchesMoved(_:with:)), with: touches, with: event)
            case .cancelled:
                gesture.perform(#selector(UIResponder.touchesCancelled(_:with:)), with: touches, with: event)
            case .ended:
                gesture.perform(#selector(UIResponder.touchesEnded(_:with:)), with: touches, with: event)
            case .stationary:
                break
            }
        }
    }
    
    @objc private func stackViewSelected(_ button: UIButton, for event: UIEvent) {
        guard
            let touch = event.touches(for: button)?.first,
            let imageView = highlightedImageView(for: touch) else { return }
        
        selectedImageIndex = imageViews.index(of: imageView)
        delegate?.imageWasSelected(in: self, indexOfImage: selectedImageIndex!)
    }
    
    private func highlightedImageView(for touch: UITouch) -> UIImageView? {
        let point = touch.location(in: view)
        return imageViews.first(where: {$0.frame.contains(point)})
    }
}
