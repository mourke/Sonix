//
//  MediaItemDetailTableViewController+Navigation.swift
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
import XCDYouTubeKit
import AVKit.AVPlayerViewController
import TMDBKit

extension MediaItemDetailTableViewController: LongPressCollectionViewCellDelegate {
    
    func cellSelected(at row: Int, in collectionView: RailCollectionView, on rail: Int) {
        switch rail {
        case 0:
            let videoIdentifier = mediaItem.extras[row].id
            let playerViewController = AVPlayerViewController()
            present(playerViewController, animated: true)
            
            XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error: Error?) in
                if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                    let player = AVPlayer(url: streamURL)
                    playerViewController.player = player
                    player.play()
                } else if let error = error {
                    let alertController = UIAlertController(error: error)
                    self.present(alertController, animated: true)
                } else {
                    playerViewController.dismiss(animated: true)
                }
            }
        case 1:
            performSegue(withIdentifier: "showEpisode", sender: collectionView.cellForItem(at: IndexPath(row: row, section: 0)))
        case 2:
            let id = mediaItem.related[row].id
            let url = URL(string: "sonix://showDetail»\(mediaItem.type.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        case 4:
            let id = mediaItem.castAndCrew[row].id
            let url = URL(string: "sonix://showDetail»\(MPMediaType.person.rawValue)»\(id)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
            UIApplication.shared.open(url)
        default:
            fatalError()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        longPressGestureRecognizer: UILongPressGestureRecognizer,
                        didTriggerForItemAt indexPath: IndexPath) {
        guard longPressGestureRecognizer.state == .began else { return }

    }
}
