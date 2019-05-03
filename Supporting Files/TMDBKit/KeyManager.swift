//
//  KeyManager.swift
//  TMDBKit
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

import Foundation

class KeyManager {
    
    var workItems: [String : DispatchWorkItem] = [:]
    
    private var apiKeys: [String : Int]
    private let timeout: TimeInterval
    private let maxRequests: Int
    
    var apiKey: String {
        for (key, count) in apiKeys where count < maxRequests {
            requestMade(with: key)
            return key
        }
        
        if !Thread.isMainThread {
            var apiKey: String!
            DispatchQueue.main.sync { apiKey = self.apiKey }
            return apiKey
        }
        
        
        let semaphore = DispatchSemaphore(value: 0)
        let _ = semaphore.wait(timeout: .now() + timeout) // Freeze main queue to allow API cooldown.
        
        return self.apiKey
    }
    
    func requestMade(with apiKey: String) {
        apiKeys[apiKey]! += 1
        
        workItems[apiKey]?.cancel()
        
        workItems[apiKey] = DispatchWorkItem { [weak self] in
            self?.apiKeys[apiKey] = 0
        }
        
        DispatchQueue(label: "Timer Queue").asyncAfter(deadline: .now() + timeout, execute: workItems[apiKey]!)
    }
    
    init(apiKeys: [String : Int], timeout: TimeInterval, maxRequests: Int) {
        self.apiKeys = apiKeys
        self.timeout = timeout
        self.maxRequests = maxRequests
    }
}
