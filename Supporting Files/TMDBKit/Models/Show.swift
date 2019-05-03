//
//  Show.swift
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

public struct Show: Decodable {
    
    public let title: String
    public let originalTitle: String
    public let overview: String
    public let firstAired: Date? // yyyy-MM-dd
    public let runtime: Int?
    
    public let status: Status?
    public let category: Category?
    public private(set) var network: String?
    public private(set) var genres: [String] = []
    
    public private(set) var creators: [SearchPerson] = []
    public var cast: [CastMember] = []
    public private(set) var crew: [CrewMember] = []
    
    public private(set) var similar: [Show] = []
    public private(set) var seasons: [Season] = []
    public private(set) var extras: [Video] = []
    
    public private(set) var ids: [Id: String]
    public private(set) var certification: String?
    
    private let poster: String?
    private let backdrop: String?
    
    public enum Status: String, Codable {
        case returning = "Returning Series"
        case planned = "Planned"
        case inProduction = "In Production"
        case ended = "Ended"
        case canceled = "Canceled"
        case pilot = "Pilot"
    }
    
    public enum Category: String, Codable {
        case scripted = "Scripted"
        case reality = "Reality"
        case documentary = "Documentary"
        case news = "News"
        case talkShow = "Talk Show"
        case miniseries = "Miniseries"
    }
    
    private enum CodingKeys: String, CodingKey {
        case title = "name"
        case originalTitle = "original_name"
        case overview
        case firstAired = "first_air_date"
        case runtime = "episode_run_time"
        case status
        case category = "type"
        case networks
        case genres
        case creators = "created_by"
        case credits
        case similar
        case seasons
        case extras = "videos"
        case ids = "external_ids"
        case tmdbId = "id"
        case ratings = "content_ratings"
        case poster = "poster_path"
        case backdrop = "backdrop_path"
    }
    
    private enum RatingsKeys: String, CodingKey {
        case country = "iso_3166_1"
        case certification = "rating"
    }
    
    public func poster(for size: ImageSize.Poster) -> URL? {
        if let poster = poster {
            return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)" + poster)
        }
        return nil
    }
    
    public func backdrop(for size: ImageSize.Backdrop) -> URL? {
        if let backdrop = backdrop {
            return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)" + backdrop)
        }
        return nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        originalTitle = try container.decode(String.self, forKey: .originalTitle)
        overview = (try? container.decode(String.self, forKey: .overview)) ?? ""
        let firstAired = try container.decode(String.self, forKey: .firstAired)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.firstAired = formatter.date(from: firstAired)
        
        if var nested = try? container.nestedUnkeyedContainer(forKey: .runtime) {
            runtime = try? nested.decode(Int.self)
        } else {
            runtime = nil
        }
        
        status = try? container.decode(Status.self, forKey: .status)
        category = try? container.decode(Category.self, forKey: .category)
        
        if var nested = try? container.nestedUnkeyedContainer(forKey: .networks) {
            while !nested.isAtEnd {
                let networks = try nested.nestedContainer(keyedBy: GenresKeys.self)
                network = try? networks.decode(String.self, forKey: .name)
                break
            }
        }
        
        if var nested = try? container.nestedUnkeyedContainer(forKey: .genres) {
            while !nested.isAtEnd {
                let genre = try nested.nestedContainer(keyedBy: GenresKeys.self)
                if let name = try? genre.decode(String.self, forKey: .name) {
                    genres.append(name)
                }
            }
        }
        
        if var nested = try? container.nestedUnkeyedContainer(forKey: .creators) {
            creators = (try? nested.decode([SearchPerson].self)) ?? []
        }
        
        if let nested = try? container.nestedContainer(keyedBy: CreditsKeys.self, forKey: .credits) {
            cast = (try? nested.decode([CastMember].self, forKey: .cast)) ?? []
            crew = (try? nested.decode([CrewMember].self, forKey: .crew)) ?? []
        }
        
        if let nested = try? container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .similar) {
            similar = (try? nested.decode([Show].self, forKey: .results)) ?? []
        }
        
        seasons = (try? container.decode([Season].self, forKey: .seasons)) ?? []
        
        if let nested = try? container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .extras) {
            extras = (try? nested.decode([Video].self, forKey: .results)) ?? []
        }
        
        let id = try String(container.decode(Int.self, forKey: .tmdbId))
        ids = [.tmdb: id]
        
        if let nested = try? container.nestedContainer(keyedBy: Id.self, forKey: .ids) {
            ids[.imdb] = try nested.decode(String.self, forKey: .imdb)
            ids[.tvdb] = try String(nested.decode(Int.self, forKey: .tvdb))
            ids[.facebook] = try? nested.decode(String.self, forKey: .facebook)
            ids[.twitter] = try? nested.decode(String.self, forKey: .twitter)
            ids[.instagram] = try? nested.decode(String.self, forKey: .instagram)
        }
        
        if let nested = try? container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .ratings),
            var results = try? nested.nestedUnkeyedContainer(forKey: .results) {
            while !results.isAtEnd {
                guard let rating = try? results.nestedContainer(keyedBy: RatingsKeys.self),
                    let country = try? rating.decode(String.self, forKey: .country),
                    country == "US" else { continue }
                certification = try? rating.decode(String.self, forKey: .certification)
                break
            }
        }
        
        poster = try? container.decode(String.self, forKey: .poster)
        backdrop = try? container.decode(String.self, forKey: .backdrop)
    }
}
