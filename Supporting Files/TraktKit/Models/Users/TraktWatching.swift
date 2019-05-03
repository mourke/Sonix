//
//  TraktWatching.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 8/1/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktWatching: Codable, Hashable {
    
    public var hashValue: Int {
        if let episode = episode {
            return episode.ids.trakt.hashValue
        } else if let show = show {
            return show.ids.trakt.hashValue
        } else if let movie = movie {
            return movie.ids.trakt.hashValue
        }
        return 0
    }
    
    public let expiresAt: Date
    public let startedAt: Date
    public let action: String
    public let type: String
    
    public var episode: TraktEpisode?
    public var show: TraktShow?
    public var movie: TraktMovie?
    
    enum CodingKeys: String, CodingKey {
        case expiresAt = "expires_at"
        case startedAt = "started_at"
        case action
        case type
        
        case episode
        case show
        case movie
    }
}
