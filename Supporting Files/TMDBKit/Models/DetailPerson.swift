//
//  DetailPerson.swift
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

public struct DetailPerson: Person, Decodable {
    
    public let name: String
    public let gender: Gender?
    public var id: Int {
        return Int(ids[.tmdb]!)!
    }
    
    public let knownFor: String
    public let biography: String
    
    public let birthDate: Date? // yyyy-MM-dd
    public let birthPlace: String?
    public let deathDate: Date? // yyyy-MM-dd
    
    public private(set) var ids: [Id : String] = [:]
    public var cast: [Decodable] = []
    public var crew: [String : [Decodable]] = [:]
    public var guestAppearances: [(show: Show, episode: Episode)] = []
    
    private let headshot: String?
    private var backdrop: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case gender
        case id
        case knownFor = "known_for_department"
        case biography
        case birthDate = "birthday"
        case birthPlace = "place_of_birth"
        case deathDate = "deathday"
        case ids = "external_ids"
        case headshot = "profile_path"
        case backdrop = "tagged_images"
        case movieCredits = "movie_credits"
        case showCredits = "show_credits"
    }
    
    private enum TaggedImagesCodingKeys: String, CodingKey {
        case path = "file_path"
    }
    
    
    public func headshot(for size: ImageSize.Headshot) -> URL? {
        if let headshot = headshot {
            return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)" + headshot)
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
        
        name = try container.decode(String.self, forKey: .name)
        gender = try? container.decode(Gender.self, forKey: .gender)
        knownFor = try container.decode(String.self, forKey: .knownFor)
        biography = try container.decode(String.self, forKey: .biography)
        
        birthDate = try? container.decode(Date.self, forKey: .birthDate)
        birthPlace = try? container.decode(String.self, forKey: .birthPlace)
        deathDate = try? container.decode(Date.self, forKey: .deathDate)
        
        let id = try String(container.decode(Int.self, forKey: .id))
        ids = [.tmdb: id]
        if let nested = try? container.nestedContainer(keyedBy: Id.self, forKey: .ids) {
            ids[.imdb] = try nested.decode(String.self, forKey: .imdb)
            ids[.facebook] = try? nested.decode(String.self, forKey: .facebook)
            ids[.twitter] = try? nested.decode(String.self, forKey: .twitter)
            ids[.instagram] = try? nested.decode(String.self, forKey: .instagram)
        }
        
        headshot = try? container.decode(String.self, forKey: .headshot)
        
        let imageContainer = try container.nestedContainer(keyedBy: ResultsKeys.self, forKey: .backdrop)
        if var results = try? imageContainer.nestedUnkeyedContainer(forKey: .results) {
            while !results.isAtEnd {
                guard let taggedImageContainer = try? results.nestedContainer(keyedBy: TaggedImagesCodingKeys.self),
                    let backdrop = try? taggedImageContainer.decode(String.self, forKey: .path)
                    else { continue }
                self.backdrop = backdrop
                break
            }
        }
    }
}
