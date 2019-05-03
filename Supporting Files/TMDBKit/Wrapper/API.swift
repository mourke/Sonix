//
//  API.swift
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

public struct TMDBKit {
    
    public enum MediaType: String {
        case movie = "movie"
        case tv = "tv"
    }
    
    static var language: String? {
        let locale = Locale.current
        
        guard let region = locale.regionCode, let language = locale.languageCode else { return nil }
        
        return "\(language)-\(region)"
    }
    
    struct Endpoints {
        private static let keyManager = KeyManager(apiKeys: ["7ad8b60d6bd837142cc4878b3b45305f": 0,
                                                             "be738f21665fdee783cea53fbbb99803": 0,
                                                             "901fa4892abc734e3c5c663106aecd30": 0,
                                                             "b70e10dcfb049ab5616c62edb2946e9e": 0,
                                                             "739eed14bc18a1d6f5dacd1ce6c2b29e": 0,
                                                             "c79da7428c2b13b32704c711dedfa501": 0,
                                                             "624e98a1d7efbd32993b39340c3d9611": 0,
                                                             "38f294747ee749570b4e4b934ab5de83": 0],
                                                   timeout: 10,
                                                   maxRequests: 40)
        
        static var apiKey: String {
            return keyManager.apiKey
        }
        
        static let base = "https://api.themoviedb.org/3"
        static let bearer = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYmYiOjE1MzEzNDEzNjYsInN1YiI6IjViNDY2MTJkYzNhMzY4NTNmMjAwMDRlYSIsImp0aSI6Ijg5MDAxNSIsImF1ZCI6IjdhZDhiNjBkNmJkODM3MTQyY2M0ODc4YjNiNDUzMDVmIiwic2NvcGVzIjpbImFwaV9yZWFkIiwiYXBpX3dyaXRlIl0sInZlcnNpb24iOjF9.UOI3lJbW8USj1DrlCEP9p6ua3ueB8a07BfEubuW_ZqM"
        static let list = "/list"
        static let items = "/items"
        static let tv = "/tv"
        static let movie = "/movie"
        static let person = "/person"
        static let images = "/images"
        static let season = "/season"
        static let episode = "/episode"
        static let videos = "/videos"
        static let credits = "/credits"
        static let credit = "/credit"
        static let search = "/search"
        static let similar = "/similar"
        static let popular = "/popular"
        static let genre = "/genre"
        static let find = "/find"
    }
}
