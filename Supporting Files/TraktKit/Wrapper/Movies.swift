//
//  Film.swift
//  TraktKit
//
//  Created by Maximilian Litteral on 6/11/15.
//  Copyright (c) 2015 Maximilian Litteral. All rights reserved.
//

import Foundation

extension TraktManager {
    
    // MARK: - Trending
    
    /**
    Returns all movies being watched right now. Movies with the most users are returned first.
    
    📄 Pagination
     */
    public func getTrendingMovies(page: Int, limit: Int, extended: [ExtendedType] = [.min], completion: @escaping TrendingMoviesCompletionHandler) -> URLSessionDataTask? {
        return getTrending(.movies, page: page, limit: limit, extended: extended, completion: completion)
    }
    
    // MARK: - Popular
    
    /**
    Returns the most popular movies. Popularity is calculated using the rating percentage and the number of ratings.
    
    📄 Pagination
    */
    public func getPopularMovies(page: Int, limit: Int, extended: [ExtendedType] = [.min], completion: @escaping MoviesCompletionHandler) -> URLSessionDataTask? {
        return getPopular(.movies, page: page, limit: limit, extended: extended, completion: completion)
    }
    
    // MARK: - Played
    
    /**
    Returns the most played (a single user can watch multiple times) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    public func getPlayedMovies(page: Int, limit: Int, period: Period = .weekly, completion: @escaping MostMoviesCompletionHandler) -> URLSessionDataTask? {
        return getPlayed(.movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Watched
    
    /**
    Returns the most watched (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    public func getWatchedMovies(page: Int, limit: Int, period: Period = .weekly, completion: @escaping MostMoviesCompletionHandler) -> URLSessionDataTask? {
        return getWatched(.movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Collected
    
    /**
    Returns the most collected (unique users) movies in the specified time `period`, defaulting to `weekly`. All stats are relative to the specific time `period`.
    
    📄 Pagination
    */
    public func getCollectedMovies(page: Int, limit: Int, period: Period = .weekly, completion: @escaping MostMoviesCompletionHandler) -> URLSessionDataTask? {
        return getCollected(.movies, page: page, limit: limit, period: period, completion: completion)
    }
    
    // MARK: - Anticipated
    
    /**
    Returns the most anticipated movies based on the number of lists a movie appears on.
    
    📄 Pagination
    */
    public func getAnticipatedMovies(page: Int, limit: Int, extended: [ExtendedType] = [.min], completion: @escaping AnticipatedCompletionHandler) -> URLSessionDataTask? {
        return getAnticipated(.movies, page: page, limit: limit, extended: extended, completion: completion)
    }
    
    // MARK: - Box Office
    
    /**
    Returns the top 10 grossing movies in the U.S. box office last weekend. Updated every Monday morning.
    */
    public func getWeekendBoxOffice(extended: [ExtendedType] = [.min], completion: @escaping BoxOfficeMoviesCompletionHandler) -> URLSessionDataTask? {
        guard let request = mutableRequest(forPath: "movies/boxoffice",
                                           withQuery: ["extended": extended.queryString()],
                                           isAuthorized: false,
                                           withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Updates
    
    /**
    Returns all movies updated since the specified date. We recommended storing the date you can be efficient using this method moving forward.
    
    📄 Pagination
    */
    public func getUpdatedMovies(page: Int, limit: Int, startDate: Date?, completion: @escaping ObjectsCompletionHandler<Update>) -> URLSessionDataTask? {
        return getUpdated(.movies, page: page, limit: limit, startDate: startDate, completion: completion)
    }
    
    // MARK: - Summary
    
    /**
    Returns a single movie's details.
    */
    public func getMovieSummary<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.min], completion: @escaping MovieCompletionHandler) -> URLSessionDataTask? {
        return getSummary(.movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Aliases
    
    /**
    Returns all title aliases for a movie. Includes country where name is different.
    */
    public func getMovieAliases<T: CustomStringConvertible>(movieID id: T, completion: @escaping ObjectsCompletionHandler<Alias>) -> URLSessionDataTask? {
        return getAliases(.movies, id: id, completion: completion)
    }
    
    // MARK: - Releases
    
    /**
    Returns all releases for a movie including country, certification, and release date.
    
    - parameter id: Trakt.tv ID, Trakt.tv slug, or IMDB ID
    - parameter country: 2 character country code. Example: `us`.
    */
    public func getMovieReleases<T: CustomStringConvertible>(movieID id: T, country: String?, completion: @escaping ObjectsCompletionHandler<TraktMovieRelease>) -> URLSessionDataTask? {
        
        var path = "movies/\(id)/releases"
        
        if let country = country {
            path += "/\(country)"
        }
        
        guard let request = mutableRequest(forPath: path,
                                         withQuery: [:],
                                         isAuthorized: false,
                                         withHTTPMethod: .GET) else { return nil }
        return performRequest(request: request, expectingStatusCode: StatusCodes.Success, completion: completion)
    }
    
    // MARK: - Translations
    
    /**
    Returns all translations for a movie, including language and translated values for title, tagline and overview.
    */
    public func getMovieTranslations<T: CustomStringConvertible>(movieID id: T, language: String?, completion: @escaping MovieTranslationsCompletionHandler) -> URLSessionDataTask? {
        return getTranslations(.movies, id: id, language: language, completion: completion)
    }
    
    // MARK: - Comments
    
    /**
    Returns all top level comments for a movie. Most recent comments returned first.
    
    📄 Pagination
    */
    public func getMovieComments<T: CustomStringConvertible>(movieID id: T, completion: @escaping CommentsCompletionHandler) -> URLSessionDataTask? {
        return getComments(.movies, id: id, completion: completion)
    }
    
    // MARK: - People
    
    /**
    Returns all `cast` and `crew` for a movie. Each `cast` member will have a `character` and a standard `person` object.
    
    The `crew` object will be broken up into `production`, `art`, `crew`, `costume & make-up`, `directing`, `writing`, `sound`, and `camera` (if there are people for those crew positions). Each of those members will have a `job` and a standard `person` object.
    */
    public func getPeopleInMovie<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.min], completion: @escaping CastCrewCompletionHandler) -> URLSessionDataTask? {
        return getPeople(.movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Ratings
    
    /**
    Returns rating (between 0 and 10) and distribution for a movie.
    */
    public func getMovieRatings<T: CustomStringConvertible>(movieID id: T, completion: @escaping RatingDistributionCompletionHandler) -> URLSessionDataTask? {
        return getRatings(.movies, id: id, completion: completion)
    }
    
    // MARK: - Related
    
    /**
    Returns related and similar movies. By default, 10 related movies will returned. You can send a `limit` to get up to `100` items.
    
    **Note**: We are continuing to improve this algorithm.
    */
    public func getRelatedMovies<T: CustomStringConvertible>(movieID id: T, extended: [ExtendedType] = [.min], completion: @escaping MoviesCompletionHandler) -> URLSessionDataTask? {
        return getRelated(.movies, id: id, extended: extended, completion: completion)
    }
    
    // MARK: - Stats
    
    /**
    Returns lots of movie stats.
    */
    public func getMovieStatistics<T: CustomStringConvertible>(movieID id: T, completion: @escaping statsCompletionHandler) -> URLSessionDataTask? {
        return getStatistics(.movies, id: id, completion: completion)
    }
    
    // MARK: - Watching
    
    /**
    Returns all users watching this movie right now.
    */
    public func getUsersWatchingMovie<T: CustomStringConvertible>(movieID id: T, completion: @escaping ObjectsCompletionHandler<User>) -> URLSessionDataTask? {
        return getUsersWatching(.movies, id: id, completion: completion)
    }
}
