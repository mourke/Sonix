//
//  EpisodeDetailPresentationController.swift
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

class EpisodeDetailPresentationController: UIPresentationController {
    
    private var sizeOfFormSheet = CGSize(width: 524, height: 572)
    private var preferredContentSizeForChildContentContainer: CGSize = .zero
    
    private lazy var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let tap = UITapGestureRecognizer(target:self, action:#selector(dimmingViewTapped))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var dismissGrabberImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "Dismiss Grabber"))
        presentedView?.addSubview(imageView)
        imageView.sizeToFit()
        return imageView
    }()
    
    @objc private func dimmingViewTapped(_ gesture: UIGestureRecognizer) {
        if gesture.state == .recognized {
            presentingViewController.dismiss(animated: true)
        }
    }
    
    override var shouldPresentInFullscreen: Bool {
        return false
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        preferredContentSizeForChildContentContainer = container.preferredContentSize
        
        if let presentedView = presentedView {
            presentedView.frame = frameOfPresentedViewInContainerView
            dismissGrabberImageView.center.x = presentedView.center.x
            dismissGrabberImageView.frame.origin.y = 9
        }
    }
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        
        if let containerView = containerView {
            dimmingView.frame = containerView.bounds
            dimmingView.alpha = 0
            containerView.insertSubview(dimmingView, at: 0)
        }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.alpha = 1
        })
        
        if let presentedView = presentedView {
            presentedView.layer.masksToBounds = true
            presentedView.layer.cornerRadius = 10
        }
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak self] context in
            self?.dimmingView.alpha = 0
        })
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return super.frameOfPresentedViewInContainerView }
        
        let isRegular = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        
        if !isRegular {
            var size = preferredContentSizeForChildContentContainer
            let maxHeight = containerView.frame.height - containerView.safeAreaInsets.top
            let originY = maxHeight - size.height
            let heightTooBig = originY < 0
            
            let origin = CGPoint(x: 0, y: containerView.safeAreaInsets.top + (heightTooBig ? 0 : originY))
            size = heightTooBig ? CGSize(width: size.width, height: maxHeight) : size
            return CGRect(origin: origin, size: size)
        } else {
            let origin = CGPoint(x: containerView.frame.midX - sizeOfFormSheet.width/2.0, y: containerView.frame.midY - sizeOfFormSheet.height/2.0)
            
            return CGRect(origin: origin, size: sizeOfFormSheet)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let isRegular = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        
        dismissGrabberImageView.isHidden = isRegular
        presentedView?.layer.maskedCorners = isRegular ? [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner] : [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        
        if let bounds = containerView?.bounds {
            dimmingView.frame = bounds
            presentedView?.frame.size.width = bounds.size.width // Actual presentedView size is calculated from the contentSize of the tableView but in order to have the correct with in compact trait environments we must change the width here to have the correct height calculated.
        }
    }
}
