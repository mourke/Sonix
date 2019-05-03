//
//  ExtrasVideo.swift
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

public struct Video: Codable {
    
    public let id: String
    public let title: String
    public let resolution: Int
    public let category: Category
    
    public var url: URL {
        return URL(string: "https://www.youtube.com/watch?v=\(id)")!
    }
    
    public var thumbnailURL: URL {
        return URL(string: "https://i.ytimg.com/vi/\(id)/hqdefault.jpg")!
    }
    
    private enum CodingKeys: String, CodingKey {
        case id = "key"
        case title = "name"
        case resolution = "size"
        case category = "type"
    }
    
    public enum Category: String, Codable {
        case clip = "Clip"
        case teaser = "Teaser"
        case trailer = "Trailer"
        case featurette = "Featurette"
        case openingCredits = "Opening Credits"
        case behindTheScenes = "Behind the Scenes"
    }
    
    public init(id: String,
                title: String,
                resolution: Int,
                category: Category) {
        self.id = id
        self.title = title
        self.resolution = resolution
        self.category = category
    }
}
