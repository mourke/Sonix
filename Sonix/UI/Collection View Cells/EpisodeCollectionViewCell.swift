//
//  EpisodeCollectionViewCell.swift
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

@objc class EpisodeCollectionViewCell: TableCollectionViewCell {
    
    @IBOutlet var watchedButton: UIButton?
    @IBOutlet var detailTextLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView?.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        // updateWatchedButtonImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView?.layer.cornerRadius = 5
    }
    
    private var watchedButtonImage: UIImage? {
        // TODO: Implement
        fatalError()
    }
    
    @IBAction func toggleWatched() {
        // TODO: Update watched status
        updateWatchedButtonImage()
    }
    
    func updateWatchedButtonImage() {
        watchedButton?.setImage(watchedButtonImage, for: .normal)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == accessoryView ? watchedButton : view
    }
}
