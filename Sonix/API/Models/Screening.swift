//
//  Screening.swift
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

enum ScreeningType: String, Codable {
    case typeStandard = "STANDARD"
    case type3d = "THREE_D"
    case type4k = "FOUR_K"

    case typeImax = "IMAX"
    case type3dImax = "IMAX_3D"
    case type4kImax = "IMAX_4K"

    case type3d4k = "THREE_D_4K"
    case type3d4kImax = "IMAX_3D_4K"
}

struct Screening: Decodable {
    
    let title: String
    let id: Int
    let releaseDate: Date // yyyy-MM-dd
    let imageURL: URL?
    let certification: String
    let consensus: String
    let runtime: String
    let trailer: URL?
    let performances: [ScreeningType: [(date: Date, ticketURL: URL?)]]
    
    private enum CodingKeys: String, CodingKey {
        case title
        case id
        case releaseDate
        case certification = "mpaa"
        case images = "poster"
        case runtime = "runningTime"
        case trailer
        case presentations
        case reviews
    }
    
    private enum ImageKeys: String, CodingKey {
        case image = "bounded320"
    }
    
    private enum ReviewsKeys: String, CodingKey {
        case rottenTomatoes
    }
    
    private enum RottenTomatoesKeys: String, CodingKey {
        case consensus
    }
    
    private enum TrailerKeys: String, CodingKey {
        case url = "hd"
    }
    
    private enum PresentationKeys: String, CodingKey {
        case name
        case traitGroups
    }
    
    private enum TraitGroupKeys: String, CodingKey {
        case performances
    }
    
    private enum ParserError: Error {
        case failedToParse
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try container.decode(String.self, forKey: .title)
        id = try container.decode(Int.self, forKey: .id)
        runtime = try container.decode(String.self, forKey: .runtime)
        certification = try container.decode(String.self, forKey: .certification)
        
        releaseDate = try {
            let dateString = try container.decode(String.self, forKey: .releaseDate)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            if let date = formatter.date(from: dateString) { return date } else { throw ParserError.failedToParse }
        }()
        
        let imageContainer = try container.nestedContainer(keyedBy: ImageKeys.self, forKey: .images)
        let image = try imageContainer.decode(String.self, forKey: .image)
        imageURL = image == "https://static6.flixster.com/static/images/poster.blank.det.gif" ? nil : URL(string: image)
        
        let trailerContainer = try container.nestedContainer(keyedBy: TrailerKeys.self, forKey: .trailer)
        trailer = try? trailerContainer.decode(URL.self, forKey: .url)
        
        let reviewsContainer = try container.nestedContainer(keyedBy: ReviewsKeys.self, forKey: .reviews)
        let rottenTomatoesContainer = try reviewsContainer.nestedContainer(keyedBy: RottenTomatoesKeys.self, forKey: .rottenTomatoes)
        
        consensus = try rottenTomatoesContainer.decode(String.self, forKey: .consensus).replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        if consensus.isEmpty { throw ParserError.failedToParse }
        
        var presentationArrayContainer = try container.nestedUnkeyedContainer(forKey: .presentations)
        
        var performances: [ScreeningType: [(date: Date, ticketURL: URL?)]] = [:]
        
        while !presentationArrayContainer.isAtEnd {
            let presentationContainer = try presentationArrayContainer.nestedContainer(keyedBy: PresentationKeys.self)
            let type = try presentationContainer.decode(ScreeningType.self, forKey: .name)
            var traitGroupsArrayContainer = try presentationContainer.nestedUnkeyedContainer(forKey: .traitGroups)
            
            var performance: [(date: Date, ticketURL: URL?)] = []
            
            while !traitGroupsArrayContainer.isAtEnd {
                let traitGroupsContainer = try traitGroupsArrayContainer.nestedContainer(keyedBy: TraitGroupKeys.self)
                let performances = try traitGroupsContainer.decode([Any].self, forKey: .performances) as! [[String : Any]]
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                
                performances.forEach {
                    guard let dateString = $0["isoDate"] as? String,
                        let date = formatter.date(from: dateString) else { return }
                    
                    let url: URL?
                    
                    if let urlString = $0["ticketUrl"] as? String {
                        url = URL(string: urlString)
                    } else {
                        url = nil
                    }
                    
                    performance.append((date: date, ticketURL: url))
                }
            }
            
            performances[type] = performance
        }
        
        self.performances = performances
    }
}
