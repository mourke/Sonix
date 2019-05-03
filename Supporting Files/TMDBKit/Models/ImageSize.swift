//
//  ImageSize.swift
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

public struct ImageSize {
    
    public typealias RawValue = String
    
    public enum Backdrop: RawValue {
        case small = "w300"
        case medium = "w780"
        case large = "w1280"
        case original = "original"
    }
    
    public enum Poster: RawValue {
        case small = "w154"
        case medium = "w342"
        case large = "w780"
        case original = "original"
    }
    
    public enum Screenshot: RawValue {
        case small = "w92"
        case medium = "w500"
        case large = "w780"
        case original = "original"
    }
    
    public enum Headshot: RawValue {
        case small = "w45"
        case medium = "w185"
        case large = "h632"
        case original = "original"
    }
}
