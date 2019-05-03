//
//  PlaybackProgress.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/15/17.
//  Copyright © 2017 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct PlaybackProgress: Codable, Equatable {
    public let progress: Float
    public let pausedAt: Date
    public let id: Int
    public let type: String
    public var movie: TraktMovie?
    public var episode: TraktEpisode?
    public var show: TraktShow?
    
    enum CodingKeys: String, CodingKey {
        case progress
        case pausedAt = "paused_at"
        case id
        case type
        case movie
        case episode
        case show
    }
}

public func ==(_ lhs: PlaybackProgress, _ rhs: PlaybackProgress) -> Bool {
    return lhs.id == rhs.id
}
