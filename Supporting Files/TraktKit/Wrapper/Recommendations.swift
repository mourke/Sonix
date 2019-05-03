//
//  Recommendations.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/14/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Public
    
    /**
     Personalized movie recommendations for a user. Results returned with the top recommendation first. By default, `10` results are returned. You can send a limit to get up to `100` results per page.
     
     🔒 OAuth: Required
     ✨ Extended Info
     */
    public func getRecommendedMovies(extended: [ExtendedType] = [.min], completion: @escaping ObjectsCompletionHandler<TraktMovie>) -> URLSessionDataTask? {
        return getRecommendations(.movies, extended: extended, completion: completion)
    }
    
    /**
     Hide a movie from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    public func hideRecommendedMovie<T: CustomStringConvertible>(movieID id: T, completion: SuccessCompletionHandler? = nil) -> URLSessionDataTask? {
        return hideRecommendation(type: .movies, id: id, completion: completion)
    }
    
    /**
     Personalized show recommendations for a user. Results returned with the top recommendation first.
     
     🔒 OAuth: Required
     ✨ Extended Info
     */
    public func getRecommendedShows(extended: [ExtendedType] = [.min], completion: @escaping ObjectsCompletionHandler<TraktShow>) -> URLSessionDataTask? {
        return getRecommendations(.shows, extended: extended, completion: completion)
    }
    
    /**
     Hide a show from getting recommended anymore.
     
     🔒 OAuth: Required
     */
    public func hideRecommendedShow<T: CustomStringConvertible>(showID id: T, completion: SuccessCompletionHandler? = nil) -> URLSessionDataTask? {
        return hideRecommendation(type: .shows, id: id, completion: completion)
    }
    
    // MARK: - Private
    
    @discardableResult
    private func getRecommendations<T>(_ type: WatchedType, extended: [ExtendedType] = [.min], completion: @escaping ObjectsCompletionHandler<T>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "recommendations/\(type)",
            withQuery: ["extended": extended.queryString()],
            isAuthorized: true,
            withHTTPMethod: .GET) else {
                completion(.error(error: nil))
                return nil
        }
        
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.Success,
                              completion: completion)
    }
    
    @discardableResult
    private func hideRecommendation<T: CustomStringConvertible>(type: WatchedType, id: T, completion: SuccessCompletionHandler?) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "recommendations/\(type)/\(id)",
            withQuery: [:],
            isAuthorized: true,
            withHTTPMethod: .DELETE) else {
                completion?(.fail)
                return nil
        }
        return performRequest(request: request,
                              expectingStatusCode: StatusCodes.SuccessNoContentToReturn,
                              completion: completion)
    }
}

