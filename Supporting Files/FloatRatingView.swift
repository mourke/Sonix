//
//  FloatRatingView.swift
//  Rating Demo
//
//  Created by Glen Yi on 2014-09-05.
//  Copyright (c) 2014 On The Pursuit. All rights reserved.
//
import UIKit

@objc public protocol FloatRatingViewDelegate {
    /**
     Returns the rating value when touch events end
     */
    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float)
    
    /**
     Returns the rating value as the user pans
     */
    @objc optional func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Float)
}

/**
 A simple rating view that can set whole, half or floating point ratings.
 */
@IBDesignable
open class FloatRatingView: UIView {
    
    // MARK: Properties
    
    open weak var delegate: FloatRatingViewDelegate?
    
    /**
     Array of empty image views
     */
    open var emptyImageViews: [UIImageView] = []
    
    /**
     Array of full image views
     */
    open var fullImageViews: [UIImageView] = []
    
    /**
     Sets the empty image (e.g. a star outline)
     */
    @IBInspectable open var emptyImage: UIImage? {
        didSet {
            // Update empty image views
            for imageView in emptyImageViews {
                imageView.image = emptyImage
            }
            refresh()
        }
    }
    
    /**
     Sets the full image that is overlayed on top of the empty image.
     Should be same size and shape as the empty image.
     */
    @IBInspectable open var fullImage: UIImage? {
        didSet {
            // Update full image views
            for imageView in fullImageViews {
                imageView.image = fullImage
            }
            refresh()
        }
    }
    
    /**
     Sets the empty and full image view content mode.
     */
    var imageContentMode: UIView.ContentMode = .scaleAspectFit
    
    /**
     Minimum rating.
     */
    @IBInspectable open var minRating: Int  = 0 {
        didSet {
            // Update current rating if needed
            if rating < Float(minRating) {
                rating = Float(minRating)
                refresh()
            }
        }
    }
    
    /**
     Max rating value.
     */
    @IBInspectable open var maxRating: Int = 5 {
        didSet {
            if maxRating != oldValue {
                removeImageViews()
                initImageViews()
                
                // Relayout and refresh
                setNeedsLayout()
                refresh()
            }
        }
    }
    
    /**
     Minimum image size.
     */
    @IBInspectable open var minImageSize: CGSize = CGSize(width: 5.0, height: 5.0) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    /**
     Set the current rating.
     */
    @IBInspectable open var rating: Float = 0 {
        didSet {
            if rating != oldValue {
                
                let majorNumber = rating.rounded(.down)
                
                // Early completion: Set rating to next whole number if almost there
                if let roundUp = roundUpRatingFractionAbove, (rating - majorNumber) > roundUp {
                    rating = rating.rounded(.up)
                }
                
                // If rating reached a whole number, trigger bounc / haptic feedback
                if rating == majorNumber || rating == majorNumber + 1 {
                    
                    if bouncy {
                        let bounceImageIndex: Int = Int(rating) - 1 // get index of matching image
                        bounceImageView(at: bounceImageIndex)
                    }
                    
                    if #available(iOS 10.0, *), hapticFeedbackEnabled {
                        feedbackGenerator?.selectionChanged()
                    }
                }
                
                refresh()
            }
        }
    }
    
    /**
     Sets whether or not the rating view can be changed by panning.
     */
    @IBInspectable open var editable: Bool = true
    
    /**
     Ratings change by 0.5. Takes priority over floatRatings property.
     */
    @IBInspectable open var halfRatings: Bool = false
    
    /**
     Ratings change by floating point values.
     */
    @IBInspectable open var floatRatings: Bool = false
    
    /**
     Stars bounce when filled
     */
    @IBInspectable open var bouncy: Bool = false
    
    /**
     Round up the rating if its fraction gets above this value. Should be between 0 and 1
     example: roundUpRatingFractionAbove = 0.7, values >= x.7 get bumped to (x+1).0
     */
    open var roundUpRatingFractionAbove: Float?
    
    /**
     Stars bounce when filled
     */
    @IBInspectable open var hapticFeedbackEnabled: Bool = false
    
    // Hack to enable @available properties until supported by Swift
    // cred: http://www.klundberg.com/blog/Swift-2-and-@available-properties
    private var _feedbackGenerator: AnyObject?
    @available(iOS 10.0, *)
    var feedbackGenerator: UISelectionFeedbackGenerator? {
        get {
            return _feedbackGenerator as? UISelectionFeedbackGenerator
        }
        set {
            _feedbackGenerator = newValue
        }
    }
    
    // MARK: Initializations
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initImageViews()
        
        if #available(iOS 10.0, *) {
            feedbackGenerator = UISelectionFeedbackGenerator()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initImageViews()
        
        if #available(iOS 10.0, *) {
            feedbackGenerator = UISelectionFeedbackGenerator()
        }
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        refresh()
    }
    
    // MARK: Helper methods
    fileprivate func initImageViews() {
        guard emptyImageViews.isEmpty && fullImageViews.isEmpty else {
            return
        }
        
        // Add new image views
        for _ in 0..<maxRating {
            let emptyImageView = UIImageView()
            emptyImageView.contentMode = imageContentMode
            emptyImageView.image = emptyImage
            emptyImageViews.append(emptyImageView)
            addSubview(emptyImageView)
            
            let fullImageView = UIImageView()
            fullImageView.contentMode = imageContentMode
            fullImageView.image = fullImage
            fullImageViews.append(fullImageView)
            addSubview(fullImageView)
        }
    }
    
    fileprivate func removeImageViews() {
        // Remove old image views
        for i in 0..<emptyImageViews.count {
            var imageView = emptyImageViews[i]
            imageView.removeFromSuperview()
            imageView = fullImageViews[i]
            imageView.removeFromSuperview()
        }
        emptyImageViews.removeAll(keepingCapacity: false)
        fullImageViews.removeAll(keepingCapacity: false)
    }
    
    // Refresh hides or shows full images
    fileprivate func refresh() {
        for i in 0..<fullImageViews.count {
            let imageView = fullImageViews[i]
            
            if rating >= Float(i+1) {
                imageView.layer.mask = nil
                imageView.isHidden = false
            } else if rating > Float(i) && rating < Float(i+1) {
                // Set mask layer for full image
                let maskLayer = CALayer()
                maskLayer.frame = CGRect(x: 0, y: 0, width: CGFloat(rating-Float(i))*imageView.frame.size.width, height: imageView.frame.size.height)
                maskLayer.backgroundColor = UIColor.black.cgColor
                imageView.layer.mask = maskLayer
                imageView.isHidden = false
            } else {
                imageView.layer.mask = nil;
                imageView.isHidden = true
            }
        }
    }
    
    // Calculates the ideal ImageView size in a given CGSize
    fileprivate func sizeForImage(_ image: UIImage, inSize size: CGSize) -> CGSize {
        let imageRatio = image.size.width / image.size.height
        let viewRatio = size.width / size.height
        
        if imageRatio < viewRatio {
            let scale = size.height / image.size.height
            let width = scale * image.size.width
            
            return CGSize(width: width, height: size.height)
        } else {
            let scale = size.width / image.size.width
            let height = scale * image.size.height
            
            return CGSize(width: size.width, height: height)
        }
    }
    
    // Calculates new rating based on touch location in view
    fileprivate func updateLocation(_ touch: UITouch) {
        guard editable else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        var newRating: Float = 0
        for i in stride(from: (maxRating-1), through: 0, by: -1) {
            let imageView = emptyImageViews[i]
            guard touchLocation.x > imageView.frame.origin.x else {
                continue
            }
            
            // Find touch point in image view
            let newLocation = imageView.convert(touchLocation, from: self)
            
            // Find decimal value for float or half rating
            if imageView.point(inside: newLocation, with: nil) && (floatRatings || halfRatings) {
                let decimalNum = Float(newLocation.x / imageView.frame.size.width)
                newRating = Float(i) + decimalNum
                if halfRatings {
                    newRating = Float(i) + (decimalNum > 0.75 ? 1 : (decimalNum > 0.25 ? 0.5 : 0))
                }
            } else {
                // Whole rating
                newRating = Float(i) + 1.0
            }
            break
        }
        
        // Check min rating
        rating = newRating < Float(minRating) ? Float(minRating) : newRating
        
        // Update delegate
        delegate?.floatRatingView?(self, isUpdating: rating)
    }
    
    /// Animates scale bounce of image view at index
    fileprivate func bounceImageView(at index: Int) {
        guard (0..<fullImageViews.count).contains(index) else { // safety check
            return
        }
        
        let imageView = fullImageViews[index] // get corresponding image
        UIView.animate(
            withDuration: 0.13,
            animations: {
                imageView.transform = CGAffineTransform.identity.scaledBy(x: 1.3, y: 1.3)
        },
            completion: { _ in
                UIView.animate(withDuration: 0.18, animations: {
                    imageView.transform = CGAffineTransform.identity
                })
        })
    }
    
    // MARK: UIView
    // Override to calculate ImageView frames
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard let emptyImage = emptyImage else {
            return
        }
        
        let desiredImageWidth = frame.size.width / CGFloat(emptyImageViews.count)
        let maxImageWidth = max(minImageSize.width, desiredImageWidth)
        let maxImageHeight = max(minImageSize.height, frame.size.height)
        let imageViewSize = sizeForImage(emptyImage, inSize: CGSize(width: maxImageWidth, height: maxImageHeight))
        let imageXOffset = (frame.size.width - (imageViewSize.width * CGFloat(emptyImageViews.count))) /
            CGFloat((emptyImageViews.count - 1))
        
        for i in 0..<maxRating {
            let imageFrame = CGRect(x: i == 0 ? 0 : CGFloat(i)*(imageXOffset+imageViewSize.width), y: 0, width: imageViewSize.width, height: imageViewSize.height)
            
            var imageView = emptyImageViews[i]
            imageView.frame = imageFrame
            
            imageView = fullImageViews[i]
            imageView.frame = imageFrame
        }
        
        refresh()
    }
    
    open override var intrinsicContentSize: CGSize {
        return CGSize(width: minImageSize.width * CGFloat(maxRating), height: minImageSize.height)
    }
    
    // MARK: Touch events
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        if #available(iOS 10.0, *) {
            feedbackGenerator?.prepare()
        }
        updateLocation(touch)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateLocation(touch)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Update delegate
        delegate?.floatRatingView(self, didUpdate: rating)
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Update delegate
        delegate?.floatRatingView(self, didUpdate: rating)
    }
}

