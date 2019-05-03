//
//  TraktAnticipated.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 7/23/16.
//  Copyright © 2016 Maximilian Litteral. All rights reserved.
//

import Foundation

public struct TraktAnticipated: Codable {
    
    // Extended: Min
    public let listCount: Int
    public var movie: TraktMovie?
    public var show: TraktShow?
    
    enum CodingKeys: String, CodingKey {
        case listCount = "list_count"
        case movie
        case show
    }
}
