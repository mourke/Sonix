//
//  MediaItem.swift
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
import MediaPlayer
import TMDBKit
import AVFoundation.AVMetadataItem
import Kingfisher

/// A class describing a movie/show/episode.
struct MediaItem {
    
    /// The type of the item (movie/tvShow/episode).
    let type: MPMediaType
    
    /// The title of the item.
    let title: String
    
    /// The item's TMDB id.
    let id: Int
    
    /// Social ids for the item eg. Facebook, Twitter, Instagram etc.
    let socialIds: [Id : String]
    
    /// A brief tagline for the item or the like.
    let subtitle: String?
    
    /// Information about the item such as certification, genre, release date and more.
    let info: NSAttributedString
    
    /// A brief synopsis of the item's plot.
    let overview: String
    
    /// The background artwork, if any.
    let backgroundArtworkURL: URL?
    
    /// The poster artwork, if any.
    let posterArtworkURL: URL?
    
    /// The logo associated with the item, if any.
    let logoArtworkURL: URL?
    
    /// Behind the scenes, bloopers and deleted scenes for the item.
    let extras: [(title: String, id: String, thumbArtworkURL: URL?)]
    
    /// The cast & crew that worked on the item.
    let castAndCrew: [(name: String, role: String?, id: Int, headshotArtworkURL: URL?)]
    
    /// The reviews (both critic and user) for the movie. This will be empty for all shows and episodes.
    let reviews: [Review]
    
    /// The items that are similar to this item.
    let related: [(title: String, id: Int, posterArtworkURL: URL?)]
    
    /// The torrents for the item subscripted by a TMDB id. For movies and episodes, simply subscript using the `id` parameter of the object. For shows, subscript by concatinating the episode's `season` and `number` parameter using a colon as a separator, e.g. "1:3" for Season 1 Episode 3.
    let torrents: [String : [Torrent]]
    
    /// The seasons in the show. This will be empty for all movies and episodes.
    var seasons: [Season]
    
    var nowPlayingInfo: [String : Any] {
        var dictionary: [String : Any] = [MPMediaItemPropertyTitle : title,
                                          MPMediaItemPropertyMediaType : type.rawValue]
        
        if let url = self.posterArtworkURL,
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { (size) -> UIImage in
                let scale = image.size.width/size.width
                let height = size.height * scale
                if let cropped = image.cgImage?.cropping(to: CGRect(origin: .zero, size: CGSize(width: image.size.width, height: height))) {
                    return UIImage(cgImage: cropped).scaled(to: size)
                }
                return image
            }
            
            dictionary[MPMediaItemPropertyArtwork] = artwork
        }
        
        return dictionary
    }
    
    var externalMetadata: [AVMetadataItem] {
        var items = [AVMetadataItem.init(key: .commonKeyTitle,
                                         value: title as NSString),
                     AVMetadataItem.init(key: .commonKeyDescription,
                                         value: overview as NSString),
                     AVMetadataItem.init(key: .commonKeyType,
                                         value: type.rawValue as NSNumber),
                     AVMetadataItem.init(key: .commonKeyIdentifier, value: id as NSNumber)]
        
        if let url = posterArtworkURL,
            let data = try? Data(contentsOf: url) {
            items.append(AVMetadataItem.init(key: .commonKeyArtwork,
                                             value: data as NSData))
        }
        
        return items
    }
    
    init(type: MPMediaType,
         title: String,
         id: Int,
         socialIds: [Id : String],
         subtitle: String?,
         info: NSAttributedString,
         overview: String,
         backgroundArtworkURL: URL?,
         posterArtworkURL: URL?,
         logoArtworkURL: URL?,
         extras: [(title: String, id: String, thumbArtworkURL: URL?)],
         castAndCrew: [(name: String, role: String?, id: Int, headshotArtworkURL: URL?)],
         reviews: [Review],
         related: [(title: String, id: Int, posterArtworkURL: URL?)],
         torrents: [String : [Torrent]],
         seasons: [Season]) {
        self.type = type
        self.title = title
        self.id = id
        self.socialIds = socialIds
        self.subtitle = subtitle
        self.info = info
        self.overview = overview
        self.backgroundArtworkURL = backgroundArtworkURL
        self.posterArtworkURL = posterArtworkURL
        self.logoArtworkURL = logoArtworkURL
        self.extras = extras
        self.castAndCrew = castAndCrew
        self.reviews = reviews
        self.related = related
        self.torrents = torrents
        self.seasons = seasons
    }
}
