//
//  SearchTableViewController.swift
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
import TMDBKit

class SearchTableViewController: RailViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    var movies: [Movie] = []
    var shows: [Show] = []
    var people: [SearchPerson] = []
    var searchController: SearchController!
    var workItem: DispatchWorkItem!
    
    private var transformObserver: NSKeyValueObservation!
    
    lazy var posterNib = UINib(nibName: "PosterCollectionViewCell", bundle: nil)
    lazy var monogramNib = UINib(nibName: "MonogramCollectionViewCell", bundle: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = SearchController(searchResultsController: nil)
        
        searchController.searchBar.placeholder = NSLocalizedString("search_bar_placeholder_text", comment: "All the possible things the user can search for.")
        searchController?.searchResultsUpdater = self
        searchController?.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        tableView.backgroundView = Bundle.main.loadNibNamed("LoadingView", owner: nil)?.first as? UIView
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        
        textDidChange(in: searchController.searchBar as! SearchBar, query: nil) {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollViewDidScroll(tableView) // Update hidden status of UINavigationBar
        
        if let largeTitleView = navigationController?.navigationBar.largeTitleView,
            let largeTitleLabel = largeTitleView.subviews.first as? UILabel {
            transformObserver = largeTitleLabel.observe(\.transform) { [unowned self] (label, change) in
                let transform = self.traitCollection.horizontalSizeClass.spacingConstant - label.frame.origin.x
                guard label.transform.tx == 0 && transform != 0 else { return } // Prevents recursion
                label.transform.tx = transform
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        transformObserver.invalidate()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let managedSearchPalette = navigationController?.value(forKey: "_topPalette") as? UIView {
            let constant = traitCollection.horizontalSizeClass.spacingConstant
            let searchBar = searchController.searchBar
            let constraints = managedSearchPalette.constraints.filter({$0.firstItem === searchBar || $0.secondItem === searchBar}) + searchBar.constraints
            
            NSLayoutConstraint.deactivate(constraints)
            
            let indent: CGFloat = 8
            
            searchBar.leadingAnchor.constraint(equalTo: managedSearchPalette.leadingAnchor, constant: view.safeAreaInsets.left + constant - indent).isActive = true
            searchBar.topAnchor.constraint(equalTo: managedSearchPalette.topAnchor).isActive = true
            searchBar.trailingAnchor.constraint(equalTo: managedSearchPalette.trailingAnchor, constant: indent - constant - view.safeAreaInsets.right).isActive = true
            searchBar.bottomAnchor.constraint(equalTo: managedSearchPalette.bottomAnchor).isActive = true
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === tableView else { return }
        
        navigationController?.navigationBar.backgroundOpacity = tableView.contentOffset.y > -view.safeAreaInsets.top ? 1 : 0
    }
    
    // MARK: - Search results updating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBar = searchController.searchBar as? SearchBar, !searchController.isBeingPresented else { return }
        
        workItem?.cancel()
        
        workItem = DispatchWorkItem {
            searchBar.isLoading = true
            
            let query = searchBar.text ?? ""
            
            self.textDidChange(in: searchBar, query: query.isEmpty ? nil : query) {
                searchBar.isLoading = false
                self.tableView.reloadData()
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
    
    func textDidChange(in searchBar: SearchBar, query: String?, completion: @escaping () -> Void) {
        let group = DispatchGroup()
        var error: Error?
        
        group.enter()
        TMDBKit.popularItems(of: Movie.self, query: query) {
            error = $0 != nil ? $0 : error
            self.movies = $1
            group.leave()
        }.resume()
        
        group.enter()
        TMDBKit.popularItems(of: Show.self, query: query) {
            error = $0 != nil ? $0 : error
            self.shows = $1
            group.leave()
        }.resume()
        
        group.enter()
        TMDBKit.popularItems(of: SearchPerson.self, query: query) {
            error = $0 != nil ? $0 : error
            self.people = $1
            group.leave()
        }.resume()
        
        group.notify(queue: .main) {
            if self.movies.isEmpty && self.shows.isEmpty && self.people.isEmpty {
                if let error = error {
                    let backgroundView = ErrorView.init(error)
                    backgroundView.retryHandler = { [weak self] in
                        self?.textDidChange(in: searchBar, query: query, completion: completion)
                    }
                    self.tableView.separatorStyle = .none
                    self.tableView.backgroundView = backgroundView
                } else if let text = searchBar.text {
                    let backgroundView = Bundle.main.loadNibNamed("ErrorView", owner: nil)?.first as! ErrorView
                    let openQuote = Locale.current.quotationBeginDelimiter ?? "\""
                    let closeQuote = Locale.current.quotationEndDelimiter ?? "\""
                    
                    let format = NSLocalizedString("search_results_empty_description_format", comment: "Format for no results description: We didn't turn anything up for {The user's search query}. Try something else.")
                    backgroundView.descriptionLabel?.text = String(format: format, openQuote + text + closeQuote)
                    backgroundView.titleLabel?.text = NSLocalizedString("search_results_empty_title", comment: "No matching items were found for the search query.")
                    
                    backgroundView.retryButton?.isHidden = true
                    
                    self.tableView.separatorStyle = .none
                    self.tableView.backgroundView = backgroundView
                }
            } else {
                self.tableView.separatorStyle = .singleLine
                self.tableView.backgroundView = nil
            }
            
            completion()
        }
    }
}
