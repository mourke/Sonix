//
//  MediaItem+ShowInit.swift
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
    
    init(show: Show,
         logoURL: URL?,
         torrents: [String : [Torrent]]) {
        let info = NSMutableAttributedString()
        
        if let genre = show.genres.first {
            info.append(NSAttributedString(string: "\(genre)\t"))
        }
        
        if let certification = show.certification,
            let image = UIImage(named: certification) {
            let attachment = NSTextAttachment()
            attachment.image = image.withRenderingMode(.alwaysTemplate)
            info.append(NSAttributedString(attachment: attachment))
            info.append(NSAttributedString(string: "\t"))
        }
        
        if let date = show.firstAired {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            info.append(NSAttributedString(string: "\(formatter.string(from: date))\t"))
        }
        
        if let runtime = show.runtime {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            formatter.allowedUnits = [.hour, .minute]
            
            info.append(NSAttributedString(string: "\(formatter.string(from: TimeInterval(runtime) * 60)!)\t"))
        }
        
        if let network = show.network {
            info.append(NSAttributedString(string: "\(network)\t"))
        }
        
        if let status = show.status?.rawValue {
            info.append(NSAttributedString(string: "\(status)\t"))
        }
        
        self.init(type: .tvShow,
                  title: show.title,
                  id: Int(show.ids[.tmdb]!)!,
                  socialIds: show.ids,
                  subtitle: nil,
                  info: info,
                  overview: show.overview,
                  backgroundArtworkURL: show.backdrop(for: .original),
                  posterArtworkURL: show.poster(for: .original),
                  logoArtworkURL: logoURL,
                  extras: show.extras.compactMap { (video) in
                    return (title: video.title, id: video.id, thumbArtworkURL: video.thumbnailURL)
                  },
                  castAndCrew: show.cast.compactMap { (person) in
                    return (name: person.name, role: person.character as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                    } +
                    show.crew.compactMap { (person) in
                        return (name: person.name, role: person.job as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                    }
                    +
                    show.creators.compactMap { (person) in
                        return (name: person.name, role: NSLocalizedString("show_creator", comment: "The person who created the show.") as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                  },
                  reviews: [],
                  related: show.similar.compactMap { (show) in
                    return (title: show.title, id: Int(show.ids[.tmdb]!)!, posterArtworkURL: show.poster(for: .medium))
                  },
                  torrents: torrents,
                  seasons: show.seasons)
    }
}

