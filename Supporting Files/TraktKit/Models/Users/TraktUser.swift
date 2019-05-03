//
//  TraktUser.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 4/13/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct User: Codable {
    
    // Min
    public let username: String?
    public let isPrivate: Bool
    public let name: String?
    public let isVIP: Bool?
    public let isVIPEP: Bool?
    public let ids: UserId
    
    // Full
    public let joinedAt: Date?
    public let location: String?
    public let about: String?
    public let gender: String?
    public let age: Int?
    public let avatar: String?
    
    // VIP
    public let vipOG: Bool?
    public let vipYears: Int?
    
    enum CodingKeys: String, CodingKey {
        case username
        case isPrivate = "private"
        case name
        case isVIP = "vip"
        case isVIPEP = "vip_ep"
        case joinedAt = "joined_at"
        case location
        case about
        case gender
        case age
        case ids
        case avatar = "images"
        case vipOG = "vip_og"
        case vipYears = "vip_years"
    }
    
    enum ImageKeys: String, CodingKey {
        case avatar
    }
    
    enum AvatarKeys: String, CodingKey {
        case full
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        username = try? container.decode(String.self, forKey: .username)
        isPrivate = try container.decode(Bool.self, forKey: .isPrivate)
        name = try? container.decode(String.self, forKey: .name)
        isVIP = try? container.decode(Bool.self, forKey: .isVIP)
        isVIPEP = try? container.decode(Bool.self, forKey: .isVIPEP)
        joinedAt = try? container.decode(Date.self, forKey: .joinedAt)
        location = try? container.decode(String.self, forKey: .location)
        about = try? container.decode(String.self, forKey: .about)
        gender = try? container.decode(String.self, forKey: .gender)
        age = try? container.decode(Int.self, forKey: .age)
        vipOG = try? container.decode(Bool.self, forKey: .vipOG)
        vipYears = try? container.decode(Int.self, forKey: .vipYears)
        ids = try container.decode(UserId.self, forKey: .ids)
        
        let imageContainer = try? container.nestedContainer(keyedBy: ImageKeys.self, forKey: .avatar)
        let avatarContainer = try? imageContainer?.nestedContainer(keyedBy: AvatarKeys.self, forKey: .avatar)
        avatar = (try? avatarContainer??.decode(String.self, forKey: .full)) ?? nil
    }
}
