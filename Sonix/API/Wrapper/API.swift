//
//  API.swift
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

struct API {
    
    enum MediaType {
        case movies
        case shows
    }
    
    struct Endpoints {
        
        struct Fanart {
            static let apiKey = "f72fe7b32fdc330fe2cd6a9e288d3664"
            static let base = "http://webservice.fanart.tv/v3"
            static let tv = "/tv"
            static let movies = "/movies"
        }
        
        struct Trakt {
            static let clientId = "4db6991df26ba9d4c36224b556f182e251c7c3929b01c92b8486a8157af84afa"
            static let clientSecret = "c6e27fd4b20304309142db6cabfcb0de37b84d4eecbb07aecb00935403c32bb6"
            static let redirectURI = "sonix://trakt"
        }
        
        struct PutIO {
            static let apiSecret = "ZK5CUNU2XQPG4YZYWK2W"
            static let clientId = "3257"
            static let redirectURI = "sonix://putio"
        }
        
        struct YouTube {
            static let apiKey = "AIzaSyDxeMiIcIy03TeCIu1EcOxF9rctyH8PZzc"
            static let base = "https://www.googleapis.com/youtube/v3"
            static let search = "/search"
        }
        
        struct RottenTomatoes {
            static let base = "https://www.rottentomatoes.com/api/private"
            static let v1 = "/v1.0"
            static let v2 = "/v2.0"
            static let search = "/movies"
        }
        
        struct Flixster {
            static let base = "https://api.flixster.com/api/v2"
            static let mobileBase = "https://api.flixster.com/android/api/v2"
            static let movies = "/movies"
            static let ticketing = "/ticketing"
            static let theaters = "/theaters"
        }
        
        struct TVDB {
            static let base = "https://api.thetvdb.com"
            static let series = "/series"
            static let actors = "/actors"
            static let apiKey = "C59F77E0BB7EFB52"
            static let login = "/login"
            static let refreshToken = "/refresh_token"
        }
    }
}
