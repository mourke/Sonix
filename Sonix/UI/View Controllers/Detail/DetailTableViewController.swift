//
//  DetailTableViewController.swift
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

class DetailTableViewController: RailViewController {
    
    let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let navigationBarGradientView: GradientView = {
        let gradientView = GradientView()
        gradientView.topColor = UIColor.black.withAlphaComponent(0.5)
        gradientView.bottomColor = .clear
        return gradientView
    }()
    
    var headerHeight: CGFloat {
        let inset = tableView.safeAreaInsets.top
        return traitCollection.horizontalSizeClass == .compact ? 130 + inset : 245 + inset
    }
    
    var backgroundHeaderIsCovered: Bool {
        return tableView.contentOffset.y > -view.safeAreaInsets.top
    }
    
    lazy var posterNib = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    lazy var videoNib = UINib(nibName: "VideoCollectionViewCell", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.backgroundView = UIView()
        tableView.backgroundView?.addSubview(backgroundImageView)
        tableView.backgroundView?.addSubview(navigationBarGradientView)
        
        updateTableViewBackground()
    }
    
    func updateTableViewBackground() {
        var headerRect = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: headerHeight)
        if tableView.contentOffset.y < -headerHeight {
            headerRect.size.height = -(tableView.contentOffset.y)
        } else if tableView.contentOffset.y >= 0 {
            headerRect.size.height = 0
        }
        backgroundImageView.frame = headerRect
        
        navigationBarGradientView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.safeAreaInsets.top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollViewDidScroll(tableView) // Update the hidden status of UINavigationBar.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.backgroundOpacity = 1
        navigationController?.navigationBar.tintColor = UIColor(named: "accentColor")
        navigationController?.navigationBar.titleTextAttributes = nil
        
        transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] (context) in
            guard let `self` = self, context.isCancelled else { return }
            self.scrollViewDidScroll(self.tableView) // When interactive pop gesture is cancelled, update hidden status of UINavigationBar.
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateTableViewBackground()
        sizeHeaderView()
        
        tableView.contentInset.bottom = tableView.safeAreaInsets.bottom
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        tableView.contentInset.top = headerHeight
        
        if previousTraitCollection == nil { // Only scroll to top when the view has first loaded.
            tableView.contentOffset.y = -tableView.contentInset.top
        }
    }
    
    func sizeHeaderView() {
        let maxWidth = tableView.frame.width
        let headerView = tableView.tableHeaderView!
        
        guard maxWidth > 0 else { return }
        
        let size = headerView.systemLayoutSizeFitting(CGSize(width: maxWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        if size != headerView.frame.size {
            headerView.frame.size = size
            tableView.reloadData()
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView else { return }
        
        navigationController?.navigationBar.backgroundOpacity = backgroundHeaderIsCovered ? 1 : 0 
        navigationController?.navigationBar.tintColor = backgroundHeaderIsCovered ? UIColor(named: "accentColor") : .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: backgroundHeaderIsCovered ? UIColor.black : UIColor.clear]
        
        updateTableViewBackground()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return !backgroundHeaderIsCovered || traitCollection.userInterfaceStyle == .dark ? .lightContent : .default
    }
}
