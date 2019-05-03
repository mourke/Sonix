//
//  UserReview.swift
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

struct UserReview: Review {
    
    let author: String
    let rating: Double // 0 to 5
    let review: String
    
    enum CodingKeys: String, CodingKey {
        case author = "user"
        case rating = "score"
        case review
    }
    
    private enum UserKeys: String, CodingKey {
        case firstName
        case lastName
        case userName
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rating = try Double(container.decode(String.self, forKey: .rating)) ?? 0
        review = try container.decode(String.self, forKey: .review)
        let userContainer = try container.nestedContainer(keyedBy: UserKeys.self, forKey: .author)
        author = try userContainer.decode(String.self, forKey: .firstName) + " " + userContainer.decode(String.self, forKey: .lastName) + " (\(userContainer.decode(String.self, forKey: .userName)))"
    }
}
