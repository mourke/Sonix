//
//  MediaItem+MovieInit.swift
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
    
    init(movie: Movie,
         logoURL: URL?,
         reviews: [Review],
         extras: [Video],
         torrents: [Torrent]) {
        let info = NSMutableAttributedString()
        
        if let review = reviews.compactMap({$0 as? RottenTomatoesReview}).first {
            let attachment = NSTextAttachment()
            attachment.image = review.image.scaled(to: CGSize(width: 13, height: 13))
            info.append(NSAttributedString(attachment: attachment))
            info.append(NSAttributedString(string: " \(NumberFormatter.localizedString(from: NSNumber(value: Float(review.rating)/100.0), number: .percent))\t"))
        }
        
        if let certification = movie.certification,
            let image = UIImage(named: certification) {
            let attachment = NSTextAttachment()
            attachment.image = image.withRenderingMode(.alwaysTemplate)
            info.append(NSAttributedString(attachment: attachment))
            info.append(NSAttributedString(string: "\t"))
        }
        
        if torrents.contains(where: {$0.quality > .quality720p}) {
            let attachment = NSTextAttachment()
            let image = UIImage(named: "HD")!
            attachment.image = image.withRenderingMode(.alwaysTemplate)
            info.append(NSAttributedString(attachment: attachment))
            info.append(NSAttributedString(string: "\t"))
        }
        
        if let runtime = movie.runtime {
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .short
            formatter.allowedUnits = [.hour, .minute]
            
            info.append(NSAttributedString(string: "\(formatter.string(from: TimeInterval(runtime) * 60)!)\t"))
        }
        
        if let genre = movie.genres.first {
            info.append(NSAttributedString(string: "\(genre)\t"))
        }
        
        if let date = movie.releaseDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            info.append(NSAttributedString(string: formatter.string(from: date)))
        }
        
        let id = movie.ids[.tmdb]!
        
        self.init(type: .movie,
                  title: movie.title,
                  id: Int(id)!,
                  socialIds: movie.ids,
                  subtitle: movie.tagline,
                  info: info,
                  overview: movie.overview,
                  backgroundArtworkURL: movie.backdrop(for: .original),
                  posterArtworkURL: movie.poster(for: .original),
                  logoArtworkURL: logoURL,
                  extras: (movie.extras + extras).compactMap { (video) in
                    return (title: video.title, id: video.id, thumbArtworkURL: video.thumbnailURL)
                  },
                  castAndCrew: movie.cast.compactMap { (person) in
                    return (name: person.name, role: person.character as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                  } +
                  movie.crew.compactMap { (person) in
                    return (name: person.name, role: person.job as String?, id: person.id, headshotArtworkURL: person.headshot(for: .medium))
                  },
                  reviews: reviews,
                  related: movie.similar.compactMap { (movie) in
                    return (title: movie.title, id: Int(movie.ids[.tmdb]!)!, posterArtworkURL: movie.poster(for: .medium))
                  },
                  torrents: [id : torrents],
                  seasons: [])
    }
}
