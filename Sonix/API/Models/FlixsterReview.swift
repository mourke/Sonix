//
//  FlixsterReview.swift
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

struct FlixsterReview: Review {
    
    let author = "Flixster"
    let averageRating: Float // 0 to 5
    let numberOfRatings: Int
    
    var review: String {
        return String(format: NSLocalizedString("flixster_review_filler_format", comment: "Format for the padding for the flixster review section: Average of {Localized string of number of persons. E.g. '242'} ratings and reviews by users of Flixster."), NumberFormatter.localizedString(from: NSNumber(value: numberOfRatings), number: .decimal))
    }
    
    var rating: String {
        let formatter = NumberFormatter()
        formatter.maximumSignificantDigits = 2
        formatter.numberStyle = .decimal
        formatter.locale = .current
        
        return "\(formatter.string(from: NSNumber(value: averageRating))!)/\(NumberFormatter.localizedString(from: 5, number: .none))"
    }
    
    enum CodingKeys: String, CodingKey {
        case averageRating = "average"
        case numberOfRatings = "numScores"
    }
}
