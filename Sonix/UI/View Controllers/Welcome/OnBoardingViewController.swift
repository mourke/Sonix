//
//  OnBoardingViewController.swift
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

class OnBoardingViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var collectionView: UICollectionView?
    @IBOutlet var bigButton: UIButton?
    
    var cellType: WelcomeCollectionViewCell.Type {
        fatalError("Method must be overridden by subclass")
    }
    
    @IBAction func bigButtonPressed() { }
    
    override var storyboard: UIStoryboard? {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    var isCompact: Bool {
        return view.bounds.height < 600
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.register(UINib(nibName: String(describing: cellType), bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let collectionView = collectionView {
            let safeInset = collectionView.safeAreaInsets.top
            collectionView.contentInset.top = isCompact ? safeInset == 0 ? 20 : safeInset : safeInset == 0 ? 40 : 20
        }
    }
    
    func configure<C: WelcomeCollectionViewCell>(_ cell: C, at indexPath: IndexPath, on rail: Int) {
        fatalError("Method must be overridden by subclass")
    }

    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError("Method must be overridden by subclass")
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        fatalError("Method must be overridden by subclass")
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        fatalError("Method must be overridden by subclass")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cell = collectionView.dequeueSizingCell(of: cellType)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let rail = collectionView.tag
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        configure(cell, at: indexPath, on: rail)
        
        let insets = layout.sectionInset.left + layout.sectionInset.right + view.safeAreaInsets.left + view.safeAreaInsets.right
        attributes.size.width = view.frame.width - insets
        
        return cell.preferredLayoutAttributesFitting(attributes).size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let view = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: section))
        
        let maxWidth = collectionView.frame.width
        
        return view.systemLayoutSizeFitting(CGSize(width: maxWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if isCompact {
            return UIEdgeInsets(top: 35, left: 20, bottom: 20, right: 20)
        } else {
            return UIEdgeInsets(top: 75, left: 40, bottom: 40, right: 40)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}
