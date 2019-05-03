//
//  EpisodeDetailTableViewController.swift
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
import class TraktKit.TraktManager

class EpisodeDetailTableViewController: RailViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var detailLabel: UILabel?
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var subtitleLabel: UILabel?
    @IBOutlet var textView: UIExpandableTextView?
    @IBOutlet var playButton: BlurButton?
    @IBOutlet var progressView: MBCircularProgressBarView?
    @IBOutlet var dismissPanGestureRecognizer: UIPanGestureRecognizer?
    
    let interactor = EpisodeDetailPercentDrivenInteractiveTransition()
    var mediaItem: MediaItem!
    var torrents: [Torrent] {
        return mediaItem.torrents["\(mediaItem.id)"] ?? []
    }

    lazy var monogramNib = UINib(nibName: "MonogramCollectionViewCell", bundle: nil)
    
    override var transitioningDelegate: UIViewControllerTransitioningDelegate? {
        get {
           return self
        } set { }
    }
    
    override var modalPresentationStyle: UIModalPresentationStyle {
        get {
            return .custom
        } set { }
    }
    
    @IBAction func playButtonPressed(_ button: BlurButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = button
        alertController.popoverPresentationController?.sourceRect = button.bounds
        
        
        let actions: [UIAlertAction] = torrents.map { (torrent) in
            let subtitle = String(format: NSLocalizedString("torrent_seeds_peers_format", comment: "Format for the number of seeds and peers associated with a torrent: SEEDS: {The number of people who have completely finished downloading the torrent and are currently uploading it. E.g. 2121} • PEERS: {The number of people currently downloading the torrent. E.g. 599}."), torrent.seeds, torrent.peers)
            return RowAlertAction.init(title: torrent.quality.rawValue, subtitle: subtitle) { (_) in
                self.dismiss(animated: true) {
                    Handler.shared.queue(items: (self.mediaItem, torrent.url))
                }
            }
        }
        
        alertController.addActions(actions)
        alertController.addAction(.cancel)
        
        present(alertController, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TraktManager.sharedManager.getPlaybackProgress(type: .episodes) { [unowned self] (result) in
            switch result {
            case .success(let result):
                guard let progress = result.first(where: {$0.episode?.ids.tmdb == self.mediaItem.id}) else { return }
                OperationQueue.main.addOperation {
                    UIView.animate(withDuration: 0.85) {
                        self.progressView?.value = CGFloat(progress.progress)
                    }
                }
            default:
                break
            }
        }?.resume()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView?.kf.setImage(with: mediaItem.backgroundArtworkURL, placeholder: UIImage(named: "PreloadAsset_TV_Wide"))
        detailLabel?.text = mediaItem.subtitle
        titleLabel?.text = mediaItem.title
        subtitleLabel?.attributedText = mediaItem.info
        textView?.text = mediaItem.overview
        
        tableView.tableFooterView = UIView()
        
        imageView?.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        
        if let textView = textView {
            textView.compressView(toHeight: textView.bounds.width/2.0)
        }
        
        playButton?.isHidden = torrents.isEmpty
        
        if let subview = progressView {
            playButton?.vibrancyView.contentView.addSubview(subview)
        }
        
        updatePreferredContentSize()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        sizeHeaderView()
        
        progressView?.frame = playButton?.bounds ?? .zero
        
        if let textView = textView {
            textView.maxHeight = textView.bounds.width/2.0
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updatePreferredContentSize()
    }
    
    private func updatePreferredContentSize() {
        var size = tableView.contentSize
        size.height += tableView.safeAreaInsets.bottom
        preferredContentSize = size
    }
    
    private func sizeHeaderView() {
        let maxWidth = tableView.frame.width
        let headerView = tableView.tableHeaderView!
        
        guard maxWidth > 0 else { return }
        
        let size = headerView.systemLayoutSizeFitting(CGSize(width: maxWidth, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        
        if size != headerView.frame.size {
            headerView.frame.size = size
            tableView.reloadData()
        }
    }
    
    @IBAction private func handleDismissPan(_ sender: UIPanGestureRecognizer) {
        let superview = sender.view!
        let translation = sender.translation(in: superview)
        let velocity = sender.velocity(in: superview)
        let progress = translation.y/superview.bounds.height/2

        if tableView.contentOffset.y > 0 { return interactor.cancel() }
        
        switch sender.state {
        case .began:
            tableView.contentOffset = .zero
            tableView.bounces = false
            interactor.start()
            dismiss(animated: true)
        case .changed:
            interactor.update(progress)
        case .cancelled:
            tableView.bounces = true
            interactor.cancel()
        case .ended:
            tableView.bounces = true
            if interactor.shouldFinish {
                velocity.y < 0 ? interactor.cancel() : interactor.finish() // Stopping the gesture with an upward pan is interpreted as the user changing their mind and cancelling the dismiss.
            } else {
                velocity.y > 1000 ? interactor.finish() : interactor.cancel() // Fast swipe down no matter what the progress should dismiss the view.
            }
        default:
            break
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == dismissPanGestureRecognizer else { return true }
        let isRegular = traitCollection.horizontalSizeClass == .regular && traitCollection.verticalSizeClass == .regular
        return tableView.contentOffset.y <= 0 && !isRegular ? true : false // Only handle dismiss when the user has scrolled to the top of the table view and the view isn't a form sheet
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = cell as! RailTableViewCell
        
        cell.backgroundColor = indexPath.row == 0 ? UIColor(named: "foregroundColor") : UIColor(named: "backgroundColor")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = super.tableView(tableView, numberOfRowsInSection: section)
        
        tableView.backgroundColor = rows == 1 ? UIColor(named: "foregroundColor") : UIColor(named: "backgroundColor") // Change the background colour to match the colour of the bottom-most rail.
        
        return rows
    }
}
