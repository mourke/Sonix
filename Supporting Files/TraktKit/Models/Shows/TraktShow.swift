//
//  TraktShow.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct Airs: Codable {
    public let day: String?
    public let time: String?
    public let timezone: String?
}

public struct TraktShow: Codable, Hashable {
    
    public var hashValue: Int {
        return ids.trakt.hashValue
    }
    
    
    // Extended: Min
    public let title: String
    public let year: Int?
    public let ids: ID
    
    // Extended: Full
    public let overview: String?
    public let firstAired: Date?
    public let airs: Airs?
    public let runtime: Int?
    public let certification: String?
    public let network: String?
    public let country: String?
    public let trailer: URL?
    public let homepage: URL?
    public let status: String?
    public let rating: Double?
    public let votes: Int?
    public let updatedAt: Date?
    public let language: String?
    public let availableTranslations: [String]?
    public let genres: [String]?
    public let airedEpisodes: Int?
    
    public var posterImage: URL?
    public var backdropImage: URL?
    
    enum CodingKeys: String, CodingKey {
        case title
        case year
        case ids
        
        case overview
        case firstAired = "first_aired"
        case airs
        case runtime
        case certification
        case network
        case country
        case trailer
        case homepage
        case status
        case rating
        case votes
        case updatedAt = "updated_at"
        case language
        case availableTranslations = "available_translations"
        case genres
        case airedEpisodes = "aired_episodes"
    }
}

public func == (lhs: TraktShow, rhs: TraktShow) -> Bool {
    return lhs.ids.trakt == rhs.ids.trakt
}
