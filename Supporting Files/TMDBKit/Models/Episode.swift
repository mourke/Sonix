//
//  Episode.swift
//  TMDBKit
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

public struct Episode: Codable, Equatable {
    
    public let title: String
    public let overview: String
    public let number: Int
    public let season: Int
    public let airDate: Date? // yyyy-MM-dd
    
    public let id: Int
    private let screenshot: String?
    
    public let crew: [CrewMember]
    public let guestStars: [CastMember]
    
    private enum CodingKeys: String, CodingKey {
        case title = "name"
        case overview
        case number = "episode_number"
        case season = "season_number"
        case screenshot = "still_path"
        case airDate = "air_date"
        case id
        case crew
        case guestStars = "guest_stars"
    }
    
    public func screenshot(for size: ImageSize.Screenshot) -> URL? {
        if let screenshot = screenshot {
            return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)" + screenshot)
        }
        return nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        number = try container.decode(Int.self, forKey: .number)
        season = try container.decode(Int.self, forKey: .season)
        airDate = try? container.decode(Date.self, forKey: .airDate)
        
        id = try container.decode(Int.self, forKey: .id)
        screenshot = try? container.decode(String.self, forKey: .screenshot)
        
        crew = (try? container.decode([CrewMember].self, forKey: .crew)) ?? []
        guestStars = (try? container.decode([CastMember].self, forKey: .guestStars)) ?? []
    }
}

public func ==(_ lhs: Episode, _ rhs: Episode) -> Bool {
    return lhs.id == rhs.id
}
