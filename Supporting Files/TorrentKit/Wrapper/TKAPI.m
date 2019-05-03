//
//  TKAPI.m
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

#import "TKAPI.h"
#import "TKTorrent.h"

NSString * const kTKEndpointMovies = @"https://yts.am/api/v2/list_movies.json";
NSString * const kTKEndpointShow   = @"https://tv-v2.api-fetch.website/show";

@implementation TKAPI

+ (NSURLSessionDataTask *)getTorrentsForShowID:(NSString *)imdbIdentifier
                                      callback:(void (^)(NSError * _Nullable, NSDictionary<NSNumber *, NSDictionary<NSNumber *, NSArray<TKTorrent *> *> *> *))callback {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kTKEndpointShow, imdbIdentifier]];
    
    return [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data,
                                                            NSURLResponse * _Nullable response,
                                                            NSError * _Nullable error) {
        NSMutableDictionary *seasons = [NSMutableDictionary dictionary];
        
        if (data != nil) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (error == nil) {
                for (NSDictionary *episodeDictionary in responseDictionary[@"episodes"]) {
                    NSNumber *season;
                    if ([episodeDictionary[@"season"] isKindOfClass:NSString.class]) {
                        season = [NSNumber numberWithInt:[episodeDictionary[@"season"] intValue]];
                    } else {
                        season = episodeDictionary[@"season"];
                    }
                    
                    NSNumber *episode;
                    if ([episodeDictionary[@"episode"] isKindOfClass:NSString.class]) {
                        episode = [NSNumber numberWithInt:[episodeDictionary[@"episode"] intValue]];
                    } else {
                        episode = episodeDictionary[@"episode"];
                    }
                                   
                    NSMutableArray *torrents = [NSMutableArray array];
                    
                    [episodeDictionary[@"torrents"] enumerateKeysAndObjectsUsingBlock:^(NSString *quality, NSDictionary *torrentDictionary, BOOL *stop) {
                        if (![torrentDictionary isKindOfClass:NSDictionary.class]) return;
                        
                        TKTorrent *torrent = [[TKTorrent alloc] initFromDictionary:torrentDictionary];
                        torrent.quality = quality;
                        
                        torrent == nil || [torrent.quality isEqualToString:@"0"] ?: [torrents addObject:torrent];
                    }];
                    
                    if (seasons[season] == nil) {
                        seasons[season] = @{episode: torrents};
                    } else {
                        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:seasons[season]];
                        [dictionary setObject:torrents forKey:episode];
                        seasons[season] = dictionary;
                    }
                }
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            callback(error, seasons);
        }];
    }];
}

+ (NSURLSessionDataTask *)getTorrentsForMovieID:(NSString *)imdbIdentifier
                                       callback:(void (^)(NSError * _Nullable, NSArray<TKTorrent *> *))callback {
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@?query_term=%@", kTKEndpointMovies, imdbIdentifier]];
    
    return [session dataTaskWithURL:URL completionHandler:^(NSData * _Nullable data,
                                                            NSURLResponse * _Nullable response,
                                                            NSError * _Nullable error) {
        NSMutableArray *torrents = [NSMutableArray array];
        
        if (data != nil) {
            NSDictionary *responseDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                               options:0
                                                                                 error:&error];
            
            if (error == nil) {
                for (NSDictionary *torrentDictionary in [responseDictionary[@"data"][@"movies"] firstObject][@"torrents"]) {
                    TKTorrent *torrent = [[TKTorrent alloc] initFromDictionary:torrentDictionary];
                    
                    torrent == nil ?: [torrents addObject:torrent];
                }
            }
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            callback(error, torrents);
        }];
    }];
}

@end
