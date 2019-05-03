//
//  InfoDetailViewController.swift
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
import enum TMDBKit.Id
import class TraktKit.TraktManager

class InfoDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var titleLabel: UILabel?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var playButton: BlurButton?
    @IBOutlet var progressView: MBCircularProgressBarView?
    @IBOutlet var detailLabel: UILabel?
    @IBOutlet var textView: UIExpandableTextView?
    
    var socialIds: [Id : URL] = [:]
    var mediaItem: MediaItem!
    var torrents: [Torrent] {
        return mediaItem.torrents["\(mediaItem.id)"] ?? []
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        progressView?.frame = playButton?.bounds ?? .zero
        
        if let textView = textView {
            textView.maxHeight = textView.bounds.width/2.0
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        TraktManager.sharedManager.getPlaybackProgress(type: .movies) { [unowned self] (result) in
            switch result {
            case .success(let result):
                guard let progress = result.first(where: {$0.movie?.ids.tmdb == self.mediaItem?.id}) else { return }
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
        
        if let subview = progressView {
            playButton?.vibrancyView.contentView.addSubview(subview)
        }
        
        playButton?.isHidden = torrents.isEmpty
        imageView?.layer.borderColor = UIColor(named: "borderColor")?.cgColor
        
        if let textView = textView {
            textView.compressView(toHeight: textView.bounds.width/2.0)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedSocial",
            let destination = segue.destination as? UICollectionViewController {
            let collectionView = destination.collectionView!
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
    @IBAction func playButtonPressed(_ button: BlurButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.sourceView = button
        alertController.popoverPresentationController?.sourceRect = button.bounds
        
        let actions: [UIAlertAction] = torrents.map { (torrent) in
            let size = ByteCountFormatter.string(fromByteCount: Int64(torrent.size), countStyle: .file)
            let subtitle = String(format: NSLocalizedString("torrent_seeds_peers_format", comment: "Format for the number of seeds and peers associated with a torrent: SEEDS: {The number of people who have completely finished downloading the torrent and are currently uploading it. E.g. 2121} • PEERS: {The number of people currently downloading the torrent. E.g. 599}."), torrent.seeds, torrent.peers)
            return RowAlertAction.init(title: "\(torrent.quality.rawValue) (\(size))", subtitle: subtitle) { (_) in
                Handler.shared.queue(items: (self.mediaItem, torrent.url))
            }
        }
        
        alertController.addActions(actions)
        alertController.addAction(.cancel)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Collection view data source
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return socialIds.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SocialCollectionViewCell
        let network = Array(socialIds.keys).sorted(by: { $0.rawValue < $1.rawValue })[indexPath.row]
        
        switch network {
        case .imdb:
            cell.logoImageView?.image = UIImage(named: "IMDB Logo")
            cell.logoImageView?.tintColor = UIColor(named: "imdbColor")
        case .tvdb:
            fatalError("TVDB does not support searching by person, please remove this item from the data source.")
        case .tmdb:
            cell.logoImageView?.image = UIImage(named: "TMDB Logo")
            cell.logoImageView?.tintColor = UIColor(named: "tmdbColor")
        case .twitter:
            cell.logoImageView?.image = UIImage(named: "Twitter Logo")
            cell.logoImageView?.tintColor = UIColor(named: "twitterColor")
        case .facebook:
            cell.logoImageView?.image = UIImage(named: "Facebook Logo")
            cell.logoImageView?.tintColor = UIColor(named: "facebookColor")
        case .instagram:
            cell.logoImageView?.image = UIImage(named: "Instagram Logo")
            cell.logoImageView?.tintColor = UIColor(named: "instagramColor")
        }
        
        
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let network = Array(socialIds.keys).sorted(by: { $0.rawValue < $1.rawValue })[indexPath.row]
        let url = socialIds[network]!
        UIApplication.shared.open(url)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let constant = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass.spacingConstant ?? 0
        return UIEdgeInsets(top: 0, left: constant, bottom: 0, right: constant)
    }
}
