//
//  Movie.swift
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

public struct Movie: Decodable {
    
    public let title: String
    public let originalTitle: String
    public let overview: String
    public let releaseDate: Date? // yyyy-MM-dd

    public let tagline: String?
    public let status: Status?
    public private(set) var genres: [String] = []
    
    public private(set) var cast: [CastMember] = []
    public private(set) var crew: [CrewMember] = []
    
    public private(set) var similar: [Movie] = []
    public private(set) var extras: [Video] = []
    
    public private(set) var ids: [Id : String]
    public private(set) var certification: String?
    public private(set) var digitalReleaseDate: Date? // yyyy-MM-dd'T'HH:MM:ss.SSSZ
    public let runtime: Int?
    
    private let poster: String?
    private let backdrop: String?
    
    public enum Status: String, Codable {
        case rumoured = "Rumoured"
        case planned = "Planned"
        case inProduction = "In Production"
        case post = "Post Production"
        case canceled = "Canceled"
        case released = "Released"
    }
    
    public enum ReleaseType: Int, Codable {
        case premiere = 1
        case theatrical = 3
        case digital = 4
        case physical = 5
        case tv = 6
    }
    
    private enum CodingKeys: String, CodingKey {
        case title
        case originalTitle = "original_title"
        case overview
        case releaseDate = "release_date"
        case tagline
        case status
        case genres
        case credits
        case similar
        case extras = "videos"
        case tmdbId = "id"
        case ids = "external_ids"
        case releases = "release_dates"
        case runtime
        case poster = "poster_path"
        case backdrop = "backdrop_path"
    }
    
    private enum ReleaseKeys: String, CodingKey {
        case country = "iso_3166_1"
        case releases = "release_dates"
    }
    
    private enum DatesKeys: String, CodingKey {
        case certification
        case type
        case releaseDate = "release_date"
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
        overview = try container.decode(String.self, forKey: .overview)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        if let releaseDate = try? container.decode(String.self, forKey: .releaseDate),
            let date = formatter.date(from: releaseDate) {
            self.releaseDate = date
        } else {
            releaseDate = nil
        }
        status = try? container.decode(Status.self, forKey: .status)
        tagline = try? container.decode(String.self, forKey: .tagline)
        
        if var nested = try? container.nestedUnkeyedContainer(forKey: .genres) {
            while !nested.isAtEnd {
                let genre = try nested.nestedContainer(keyedBy: GenresKeys.self)
                if let name = try? genre.decode(String.self, forKey: .name) {
                    genres.append(name)
                }
            }
        }
        
        if let nested = try? container.nestedContainer(keyedBy: CreditsKeys.self, forKey: .credits) {
            cast = (try? nested.decode([CastMember].self, forKey: .cast)) ?? []
            crew = (try? nested.decode([CrewMember].self, forKey: .crew)) ?? []
        }
        
        if let nested = try? container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .similar) {
            similar = (try? nested.decode([Movie].self, forKey: .results)) ?? []
        }
        
        if let nested = try? container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .extras) {
            extras = (try? nested.decode([Video].self, forKey: .results)) ?? []
        }
    
        if let nested = try? container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .releases),
            var results = try? nested.nestedUnkeyedContainer(forKey: .results)
        {
            while !results.isAtEnd {
                guard let release = try? results.nestedContainer(keyedBy: ReleaseKeys.self),
                    var dates = try? release.nestedUnkeyedContainer(forKey: .releases),
                    let country = try? release.decode(String.self, forKey: .country),
                    country == "US" else { continue }
                
                while !dates.isAtEnd {
                    guard let object = try? dates.nestedContainer(keyedBy: DatesKeys.self),
                        let certification = try? object.decode(String.self, forKey: .certification),
                        let type = try? object.decode(ReleaseType.self, forKey: .type),
                        let releaseDate = try? object.decode(String.self, forKey: .releaseDate),
                        type == .digital else { continue }
                    
                    self.certification = certification
                    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    self.digitalReleaseDate = formatter.date(from: releaseDate)!
                    
                    break
                }
                
                break
            }
        }
        
        let id = try String(container.decode(Int.self, forKey: .tmdbId))
        ids = [.tmdb: id]
        
        if let nested = try? container.nestedContainer(keyedBy: Id.self, forKey: .ids) {
            ids[.imdb] = try nested.decode(String.self, forKey: .imdb)
            ids[.facebook] = try? nested.decode(String.self, forKey: .facebook)
            ids[.twitter] = try? nested.decode(String.self, forKey: .twitter)
            ids[.instagram] = try? nested.decode(String.self, forKey: .instagram)
        }
        
        
        runtime = try? container.decode(Int.self, forKey: .runtime)
        
        poster = try? container.decode(String.self, forKey: .poster)
        backdrop = try? container.decode(String.self, forKey: .backdrop)
    }
}
