//
//  TraktTrendingList.swift
//  TraktKit
//
//  Created by Mark Bourke on 14/7/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktTrendingList: Codable {
    
    public let likes: Int
    public let comments: Int
    public let list: TraktList
    
    enum CodingKeys: String, CodingKey {
        case likes = "like_count"
        case comments = "comment_count"
        case list
    }
}
