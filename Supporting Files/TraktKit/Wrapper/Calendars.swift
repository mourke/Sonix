//
//  Calendars.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 11/15/15.
//  Copyright © 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    /**
     Returns all shows airing during the time period specified.
     
     🔒 OAuth: Required
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func myShows(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarShow>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/my/shows/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all new show premieres (season 1, episode 1) airing during the time period specified.
     
     🔒 OAuth: Required
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func myNewShows(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarShow>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/my/shows/new/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all show premieres (any season, episode 1) airing during the time period specified.
     
     🔒 OAuth: Required
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func mySeasonPremieres(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarShow>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/my/shows/premieres/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all movies with a release date during the time period specified.
     
     🔒 OAuth: Required
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func myMovies(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarMovie>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/my/movies/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all movies with a DVD release date during the time period specified.
     
     🔒 OAuth: Required
     ✨ Extended Info
     🎚 Filters
     */
    public func myDVDReleases(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarMovie>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/my/dvd/\(dateString)/\(days)",
                                            withQuery: [:],
                                            isAuthorized: true,
                                            withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all shows airing during the time period specified.
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func allShows(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarShow>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/all/shows/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: true,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all new show premieres (season 1, episode 1) airing during the time period specified.
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func allNewShows(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarShow>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/all/shows/new/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all show premieres (any season, episode 1) airing during the time period specified.
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func allSeasonPremieres(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarShow>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/all/shows/premieres/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
     Returns all movies with a release date during the time period specified.
     
     - parameter startDateString: Start the calendar on this date. E.X. `2014-09-01`
     - parameter days: Number of days to display. Example: `7`.
     */
    public func allMovies(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarMovie>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/all/movies/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    /**
 */
    public func allDVD(startDateString dateString: String, days: Int, completion: @escaping ObjectsCompletionHandler<CalendarMovie>) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "calendars/all/dvd/\(dateString)/\(days)",
                                           withQuery: [:],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
}
