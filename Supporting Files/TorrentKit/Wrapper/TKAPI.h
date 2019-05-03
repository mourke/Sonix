//
//  TKAPI.h
//  TorrentKit
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TKTorrent;

NS_SWIFT_NAME(TorrentKit)
@interface TKAPI : NSObject

/**
 Fetches torrents for a specified movie from YTS.
 
 @param imdbIdentifier  The IMDB ID for the movie.
 @param callback        The closure called when the request completes. If the request completes successfully, an array of `TKTorrent` objects will be returned, however, if it fails, the underlying error will be returned. If there are no torrents available for the specified movie, an empty array will be returned.
 
 @return    The request's unresumed `NSURLSessionTask`.
 */
+ (NSURLSessionDataTask *)getTorrentsForMovieID:(NSString *)imdbIdentifier
                                       callback:(void (^)(NSError * _Nullable, NSArray<TKTorrent *> *))callback NS_SWIFT_NAME(torrentsFor(movieId:callback:));

/**
 Fetches torrents for a specified show from EZTV.
 
 @param imdbIdentifier  The IMDB ID for the show.
 @param callback        The closure called when the request completes. If the request completes successfully, a dictionary of season numbers will be returned. Inside each season dictionary contains another episode dictionary which, when subscripted with a valid episode number, returns an array of `TKTorrent` objects. If the request fails, the underlying error will be returned. If there are no episodes available for the specified show, an empty array will be returned.
 
 @return    The request's unresumed `NSURLSessionTask`.
 */
+ (NSURLSessionDataTask *)getTorrentsForShowID:(NSString *)imdbIdentifier
                                      callback:(void (^)(NSError * _Nullable, NSDictionary<NSNumber *, NSDictionary<NSNumber *, NSArray<TKTorrent *> *> *> *))callback NS_SWIFT_NAME(torrentsFor(showId:callback:));

@end

NS_ASSUME_NONNULL_END
