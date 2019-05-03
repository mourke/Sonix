//
//  ThemeSongManager.swift
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
import AVFoundation

/// Class for managing TV Show and Movie Theme songs.
public class ThemeSongManager: NSObject, AVAudioPlayerDelegate {
    
    /// Global player ref.
    private var player: AVAudioPlayer?
    
    /// Global download task ref.
    private var task: URLSessionTask?
    
    /// Creates new instance of ThemeSongManager class
    public static let shared = ThemeSongManager()
    
    /**
     Starts playing TV Show theme music.
     
     - Parameter id: TVDB id of the show.
     */
    public func playThemeSongForShow(withId id: String) {
        playThemeSong(from: URL(string: "http://tvthemes.plexapp.com/\(id).mp3")!)
    }
    
    /**
     Starts playing Movie theme music.
     
     - Parameter name: The name of the movie.
     */
    public func playThemeSongForMovie(named name: String) {
        var components = URLComponents(string: "https://itunes.apple.com/search")!
        
        components.queryItems = [URLQueryItem(name: "term", value: "\(name) soundtrack"),
                                 URLQueryItem(name: "media", value: "music"),
                                 URLQueryItem(name: "attribute", value: "albumTerm"),
                                 URLQueryItem(name: "limit", value: "1")]
        
        URLSession.shared.dataTask(with: components.url!) { (data, _, _) in
            guard let data = data else { return }
            do {
                let dictionary = try JSONSerialization.jsonObject(with: data) as? [String : Any]
                
                if let array = dictionary?["results"] as? [Any],
                    let dictionary = array.first as? [String : Any],
                    let preview = dictionary["previewUrl"] as? String {
                    self.playThemeSong(from: URL(string: preview)!)
                }
            } catch let error {
                print(error)
            }
            
        }.resume()
    }
    
    /**
     Starts playing theme music from URL.
     
     - Parameter url: Valid url pointing to a track.
     */
    private func playThemeSong(from url: URL) {
        if let player = player, player.isPlaying { player.stop() }
        
        self.task = URLSession.shared.dataTask(with: url) { (data, _, _) in
            do {
                if let data = data {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
                    
                    let player = try AVAudioPlayer(data: data)
                    player.volume = 0
                    player.numberOfLoops = NSNotFound
                    player.delegate = self
                    player.play()
                    
                    let adjustedVolume = Settings.themeSongVolume * 0.25
                    player.setVolume(adjustedVolume, fadeDuration: 3.0)
                    
                    self.player = player
                }
            } catch let error {
                print(error)
            }
        }
        task?.resume()
    }
    
    /// Stops playing theme music, if previously playing.
    public func stopTheme() {
        let delay = 1.0
        player?.setVolume(0, fadeDuration: delay)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.player?.stop()
            self.task?.cancel()
            self.task = nil
        }
    }
}
