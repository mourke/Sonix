//
//  TraktList.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public enum ListPrivacy: String, Codable {
    case `private`
    case friends
    case `public`
}

public struct TraktList: Codable, Equatable {
    public let allowComments: Bool
    public let commentCount: Int
    public let createdAt: Date
    public let description: String?
    public let displayNumbers: Bool
    public var itemCount: Int
    public var likes: Int
    public let name: String
    public let privacy: ListPrivacy
    public let updatedAt: Date
    public let ids: ListId
    public let user: User
    public var items: [TraktListItem] = []

    enum CodingKeys: String, CodingKey {
        case allowComments = "allow_comments"
        case commentCount = "comment_count"
        case createdAt = "created_at"
        case description
        case displayNumbers = "display_numbers"
        case itemCount = "item_count"
        case likes
        case name
        case privacy
        case updatedAt = "updated_at"
        case ids
        case user
    }
}

public func ==(_ lhs: TraktList, _ rhs: TraktList) -> Bool {
    return lhs.ids.trakt == rhs.ids.trakt
}
