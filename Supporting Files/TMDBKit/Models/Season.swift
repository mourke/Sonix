//
//  Season.swift
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

public struct Season: Codable, Equatable, Comparable {
    
    public let name: String
    public let overview: String
    public let number: Int
    
    public let episodes: [Episode]
    public let extras: [Video]
    
    public let id: Int
    private let poster: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case overview
        case number = "season_number"
        case poster = "poster_path"
        case id
        case episodes
        case extras = "videos"
    }
    
    private enum VideosKeys: String, CodingKey {
        case results
    }
    
    public func poster(for size: ImageSize.Poster) -> URL? {
        if let poster = poster {
            return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)" + poster)
        }
        return nil
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        overview = try container.decode(String.self, forKey: .overview)
        number = try container.decode(Int.self, forKey: .number)
        
        episodes = (try? container.decode([Episode].self, forKey: .episodes)) ?? []
        
        if let nested = try? container.nestedContainer(keyedBy: VideosKeys.self, forKey: .extras) {
            extras = (try? nested.decode([Video].self, forKey: .results)) ?? []
        } else {
            extras = []
        }
        
        id = try container.decode(Int.self, forKey: .id)
        poster = try? container.decode(String.self, forKey: .poster)
    }
}

public func ==(_ lhs: Season, _ rhs: Season) -> Bool {
    return lhs.number == rhs.number
}

public func <(_ lhs: Season, _ rhs: Season) -> Bool {
    return lhs.number < rhs.number
}
