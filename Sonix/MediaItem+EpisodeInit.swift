//
//  MediaItem+EpisodeInit.swift
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
import TMDBKit
import MediaPlayer.MPMediaItem

extension MediaItem {
    
    init(episode: Episode,
         torrents: [Torrent]) {
        let info = NSMutableAttributedString()
        
        if let date = episode.airDate {
            let string = DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
            info.append(NSAttributedString(string: "\(string)\t"))
        }
        
        if torrents.contains(where: {$0.quality >= .quality720p}) {
            let attachment = NSTextAttachment()
            let image = UIImage(named: "HD")!
            attachment.image = image.withRenderingMode(.alwaysTemplate)
            info.append(NSAttributedString(attachment: attachment))
            info.append(NSAttributedString(string: "\t"))
        }
        
        let subtitle = String(format: NSLocalizedString("season_episode_label_title_format", comment: "Format for a label detailing a show's season and episode number: Season {Number of season} • Episode {Number of episode}."), episode.season, episode.number).localizedUppercase
        
        self.init(type: .episode,
                  title: episode.title,
                  id: episode.id,
                  socialIds: [:],
                  subtitle: subtitle,
                  info: info,
                  overview: episode.overview,
                  backgroundArtworkURL: episode.screenshot(for: .original),
                  posterArtworkURL: nil,
                  logoArtworkURL: nil,
                  extras: [],
                  castAndCrew: episode.guestStars.compactMap { (person) in
                    return (name: person.name, role: person.character as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                    } +
                    episode.crew.compactMap { (person) in
                        return (name: person.name, role: person.job as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                  },
                  reviews: [],
                  related: [],
                  torrents: [String(episode.id) : torrents],
                  seasons: [])
    }
}
