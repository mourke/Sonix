//
//  Lists.swift
//  TraktKit
//
//  Created by Mark Bourke on 14/7/18.
//  Copyright © 2018 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Trending
    
    /**
     Returns all lists with the most likes and comments over the last 7 days.
     
     📄 Pagination
     */
    public func getTrendingLists(page: Int, limit: Int, completion: @escaping TrendingListsCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "lists/trending",
            withQuery: [
                "page": "\(page)",
                "limit": "\(limit)"],
            isAuthorized: false,
            withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
     Returns the most popular movies. Popularity is calculated using the rating percentage and the number of ratings.
     
     📄 Pagination
     */
    public func getPopularLists(page: Int, limit: Int, completion: @escaping PopularListsCompletionHandler) -> URLSessionDataTask? {
        guard var request = mutableRequest(forPath: "lists/popular",
                                           withQuery: [
                                            "page": "\(page)",
                                            "limit": "\(limit)"],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
