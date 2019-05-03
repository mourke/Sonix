//
//  CastMember.swift
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

open class CastMember: Person, Codable {
    
    public let name: String
    public let gender: Gender?
    public let id: Int
    public let character: String
    
    private let headshot: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case gender
        case id
        case character
        case headshot = "profile_path"
    }
    
    open func headshot(for size: ImageSize.Headshot) -> URL? {
        if let headshot = headshot {
            return URL(string: "https://image.tmdb.org/t/p/\(size.rawValue)" + headshot)
        }
        return nil
    }
    
    public init(name: String,
                gender: Gender?,
                id: Int,
                character: String,
                headshot: String?) {
        self.name = name
        self.gender = gender
        self.id = id
        self.character = character
        self.headshot = headshot
    }
}
