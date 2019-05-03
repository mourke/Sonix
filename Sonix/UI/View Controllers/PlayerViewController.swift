//
//  PlayerViewController.swift
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
import AVKit
import TraktKit
import MediaPlayer

class PlayerViewController: AVPlayerViewController {
    
    private var nowPlayingInfo: [String : Any]? {
        get {
            return MPNowPlayingInfoCenter.default().nowPlayingInfo
        } set {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = newValue
        }
    }
    
    private var playerTimeControlStatusKeyValueObservation: NSKeyValueObservation?
    private var currentItemStatusKeyValueObservation: NSKeyValueObservation?
    
    override var updatesNowPlayingInfoCenter: Bool {
        get {
            return false
        } set {}
    }
    
    /// A boolean value indicating that the player's content is being loaded in the background. Use this to indicate loading before the `player` variable has been set.
    var isPreloading: Bool = false {
        didSet {
            isPreloading ? loadingIndicatorView.startAnimating() : loadingIndicatorView.stopAnimating()
        }
    }
    
    private let loadingIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeListeners()
        if let item = player?.currentItem {
            self.scrobble(.stop, item: item)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loadingIndicatorView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        loadingIndicatorView.center = view.center
    }
    
    override var player: AVPlayer? {
        didSet {
            guard let player = player as? AVQueuePlayer else {
                assert(self.player == nil, "Only `AVQueuePlayer` objects may be used in this class.")
                removeListeners()
                return
            }
            
            addListeners()
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            
            currentItemStatusKeyValueObservation?.invalidate()
            currentItemStatusKeyValueObservation = player.currentItem?.observe(\.status) { [unowned self] (item, change) in
                guard item.status == .readyToPlay,
                    player.status == .readyToPlay,
                    player.currentTime() == .zero,
                    let id = item.asset.externalMetadata.first(where: {$0.commonKey == .commonKeyIdentifier})?.value as? Int,
                    let rawValue = item.asset.externalMetadata.first(where: {$0.commonKey == .commonKeyType})?.value as? UInt else { return }
                let type = MPMediaType(rawValue: rawValue)
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.itemDidFinish(_:)), name: .AVPlayerItemDidPlayToEndTime, object: item)
                self.nowPlayingInfo = item.asset.nowPlayingInfo
                
                TraktManager.sharedManager.getPlaybackProgress(type: type == .movie ? .movies : .episodes) { (result) in
                    switch result {
                    case .success(let result):
                        guard let progress = result.first(where: {$0.movie?.ids.tmdb == id || $0.episode?.ids.tmdb == id}) else { return }
                        let seconds = Double(progress.progress/100) * item.duration.seconds
                        player.seek(to: CMTime(seconds: seconds, preferredTimescale: 1))
                    default:
                        break
                    }
                }?.resume()
            }
            
            playerTimeControlStatusKeyValueObservation?.invalidate()
            playerTimeControlStatusKeyValueObservation = player.observe(\.timeControlStatus) { [unowned self] (player, change) in
                guard let currentItem = player.currentItem else { return }
                
                let elapsedPlaybackTime = currentItem.currentTime().seconds
                let duration = currentItem.duration.seconds
                
                self.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedPlaybackTime
                self.nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
                self.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = duration
                
                switch player.timeControlStatus {
                case .playing:
                    self.scrobble(.start, item: currentItem)
                case .paused:
                    self.scrobble(.pause, item: currentItem)
                default:
                    break
                }
            }
        }
    }
    
    private enum ScrobbleAction {
        case pause
        case start
        case stop
    }
    
    private func scrobble(_ action: ScrobbleAction, item: AVPlayerItem) {
        let elapsedPlaybackTime = item.currentTime().seconds
        let duration = item.duration.seconds
        let progress = Float(elapsedPlaybackTime/duration) * 100
        
        guard let id = item.asset.externalMetadata.first(where: {$0.commonKey == .commonKeyIdentifier})?.value as? Int,
            let rawValue = item.asset.externalMetadata.first(where: {$0.commonKey == .commonKeyType})?.value as? UInt,
            !progress.isNaN else { return }
        
        let buildDate = UIApplication.shared.buildDate
        let version = UIApplication.shared.version
        let type = MPMediaType(rawValue: rawValue)
        
        let json = ["ids": ["tmdb": id]]
        
        
        switch (type, action) {
        case (.movie, .pause):
            try? TraktManager.sharedManager.scrobblePause(movie: json,
                                                          progress: progress,
                                                          appVersion: version,
                                                          appBuildDate: buildDate)?.resume()
        case (.movie, .start):
            try? TraktManager.sharedManager.scrobbleStart(movie: json,
                                                          progress: progress,
                                                          appVersion: version,
                                                          appBuildDate: buildDate)?.resume()
        case (.movie, .stop):
            try? TraktManager.sharedManager.scrobbleStop(movie: json,
                                                         progress: progress,
                                                         appVersion: version,
                                                         appBuildDate: buildDate)?.resume()
        case (.episode, .pause):
            try? TraktManager.sharedManager.scrobblePause(episode: json,
                                                          progress: progress,
                                                          appVersion: version,
                                                          appBuildDate: buildDate)?.resume()
        case (.episode, .start):
            try? TraktManager.sharedManager.scrobbleStart(episode: json,
                                                          progress: progress,
                                                          appVersion: version,
                                                          appBuildDate: buildDate)?.resume()
        case (.episode, .stop):
            try? TraktManager.sharedManager.scrobbleStop(episode: json,
                                                         progress: progress,
                                                         appVersion: version,
                                                         appBuildDate: buildDate)?.resume()
        default:
            break
        }
    }
    
    private func addListeners() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let center = MPRemoteCommandCenter.shared()
        
        center.pauseCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self?.player else { return .commandFailed }
            player.pause()
            return player.timeControlStatus == .paused ? .success : .commandFailed
        }
        
        center.playCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self?.player else { return .commandFailed }
            player.play()
            return player.timeControlStatus == .playing ? .success : .commandFailed
        }
        
        center.changePlaybackPositionCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self?.player else { return .commandFailed }
            let event = event as! MPChangePlaybackPositionCommandEvent
            let time = CMTime(seconds: event.positionTime, preferredTimescale: 1)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            return .success
        }
        
        center.changePlaybackRateCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self?.player, let item = player.currentItem else { return .commandFailed }
            
            let event = event as! MPChangePlaybackRateCommandEvent
            let rate  = event.playbackRate
            
            player.rate =  rate
            
            if rate > 1 { // over 1 means fast forward
                return item.canPlayFastForward ? .success : .commandFailed
            } else if rate > 0 { // between 0 and 1 means slow forward
                return item.canPlaySlowForward ? .success : .commandFailed
            } else if rate < -1 { // under -1 means fast rewind
                return item.canPlayFastReverse ? .success : .commandFailed
            } else if rate == -1 { // rewind
                return item.canPlayReverse ? .success : .commandFailed
            } else { // between 0 and -1 means slow backward
                return item.canPlaySlowReverse ? .success : .commandFailed
            }
        }
        
        center.skipForwardCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self?.player else { return .commandFailed }
            let event = event as! MPSkipIntervalCommandEvent
            let time = player.currentTime() + CMTime(seconds: event.interval, preferredTimescale: 1)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            return .success
        }
        
        center.skipBackwardCommand.addTarget { [weak self] (event) -> MPRemoteCommandHandlerStatus in
            guard let player = self?.player else { return .commandFailed }
            let event = event as! MPSkipIntervalCommandEvent
            let time = player.currentTime() - CMTime(seconds: event.interval, preferredTimescale: 1)
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            return .success
        }
    }
    
    private func removeListeners() {
        UIApplication.shared.endReceivingRemoteControlEvents()
        playerTimeControlStatusKeyValueObservation?.invalidate()
        playerTimeControlStatusKeyValueObservation = nil
        currentItemStatusKeyValueObservation?.invalidate()
        currentItemStatusKeyValueObservation = nil
        nowPlayingInfo = nil
    }
    
    @objc private func itemDidFinish(_ notification: Notification) {
        guard let item = notification.object as? AVPlayerItem else { return }
        scrobble(.stop, item: item)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: item)
    }
}
