//
//  BlurButton.swift
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

@IBDesignable class BlurButton: UIControl {
    
    /**
     The style of the blur background view  {UIBlurEffect.Style.extraLight=0, UIBlurEffect.Style.light=1, UIBlurEffect.Style.dark=2, UIBlurEffect.Style.regular=4, UIBlurEffect.Style.prominent=5}.
     */
    @IBInspectable var blurStyle: Int = 1 {
        didSet {
            guard let style = UIBlurEffect.Style(rawValue: blurStyle) else { fatalError("Blur Style Not Found.") }
            backgroundView.effect = UIBlurEffect(style: style)
            vibrancyView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: style))
        }
    }
    
    @IBInspectable private var image: String? {
        didSet {
            if let named = image {
                setImage(UIImage(named: named)?.withRenderingMode(.alwaysTemplate), for: .normal)
            } else {
                setImage(nil, for: .normal)
            }
        }
    }
    
    private(set) var backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    private(set) var vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .regular)))
    
    private var images: [UIControl.State: UIImage?] = [:]
    
    let imageView = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.isUserInteractionEnabled = false
        addSubview(backgroundView)
        backgroundView.contentView.addSubview(vibrancyView)
        vibrancyView.contentView.addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundView.frame = bounds
        vibrancyView.frame = bounds
        imageView.frame = bounds
        
        layer.cornerRadius = frame.width/2
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
    override var intrinsicContentSize: CGSize {
        return imageView.intrinsicContentSize
    }
    
    private func updateImageView() {
        imageView.image = images[state] ?? images[.normal] ?? nil
    }
    
    func setImage(_ image: UIImage?, for state: UIControl.State) {
        images[state] = image
        updateImageView()
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        invalidateAppearance()
    }
    
    override var isHighlighted: Bool {
        didSet {
            invalidateAppearance()
        }
    }
    
    func invalidateAppearance() {
        let isDimmed = tintAdjustmentMode == .dimmed
        let color: UIColor = isDimmed ? tintColor : isHighlighted ? .white : .clear
        UIView.animate(withDuration: 0.25,
                       delay: 0.0,
                       options: [.allowUserInteraction, .curveEaseInOut],
                       animations:
            { [unowned self] in
                self.backgroundView.contentView.backgroundColor = color
        })
    }
}
