//
//  Settings.swift
//  Sonix
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
import PutKit
import TraktKit

struct Settings {
    
    static func refreshTraktAccountSettings(completion: (() -> Void)? = nil) {
        TraktManager.sharedManager.getSettings { result in
            switch result {
            case .success(let settings):
                if let name = settings.user.name,
                    let username = settings.user.username,
                    let avatar = settings.user.avatar,
                    let url = URL(string: avatar),
                    let data = try? Data.init(contentsOf: url),
                    let image = UIImage(data: data) {
                    Settings.name = name
                    Settings.username = username
                    Settings.image = image
                }
            default:
                break
            }
            completion?()
        }?.resume()
    }
    
    static func refreshPutIOAccountSettings(completion: (() -> Void)? = nil) {
        PutKit.accountSettings { (_, settings) in
            if let settings = settings {
                Settings.preferredSubtitleLanguageCode = settings.defaultSubtitleLanguageCode
            }
            completion?()
        }.resume()
    }
    
    static var name: String {
        get {
            return UserDefaults.standard.string(forKey: "traktName")!
        } set {
            UserDefaults.standard.set(newValue, forKey: "traktName")
        }
    }
    
    static var username: String {
        get {
            return UserDefaults.standard.string(forKey: "traktUsername")!
        } set {
            UserDefaults.standard.set(newValue, forKey: "traktUsername")
        }
    }
    
    static var image: UIImage? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "traktProfileImage") else { return nil }
            let image = UIImage(data: data)!
            return image.scaled(to: CGSize(width: 68, height: 68))
        } set {
            let data = newValue!.pngData()!
            UserDefaults.standard.set(data, forKey: "traktProfileImage")
        }
    }
    
    static var isSignedIn: Bool {
        return TraktManager.sharedManager.isSignedIn && Auth.shared().isUserAuthenticated
    }
    
    static var themeSongVolume: Float {
        get {
            return UserDefaults.standard.float(forKey: "themeSongVolume")
        } set (newVolume) {
            UserDefaults.standard.set(newVolume, forKey: "themeSongVolume")
        }
    }
    
    static var canStreamOnCellular: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "streamOnCellular")
        } set {
            UserDefaults.standard.set(newValue, forKey: "streamOnCellular")
        }
    }
    
    static var preferredQuality: TorrentQuality {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: "preferredQuality") {
                return TorrentQuality(rawValue)
            }
            return .unknown
        } set (newQuality) {
            UserDefaults.standard.set(newQuality.rawValue, forKey: "preferredQuality")
        }
    }
    
    static var preferredAppearance: UIUserInterfaceStyle {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "preferredAppearance")
            return UIUserInterfaceStyle(rawValue: rawValue)!
        } set (newAppearance) {
            UserDefaults.standard.set(newAppearance.rawValue, forKey: "preferredAppearance")
        }
    }
    
    static var preferredSubtitleLanguageCode: String? {
        get {
            return UserDefaults.standard.string(forKey: "preferredSubtitleLanguageCode")
        } set (newCode) {
            UserDefaults.standard.set(newCode, forKey: "preferredSubtitleLanguageCode")
            
            var codes: [String]? = nil
            
            if let newCode = newCode {
                codes = [newCode]
            }
            
            let accountSettings = AccountSettings(subtitleLanguageCodes: codes)
            PutKit.updateAccountSettings(new: accountSettings) { (error) in
                guard let _ = error else { return }
                
                // TODO: QUEUE TASK TO BE EXECUTED WHEN THE USER REGAINS INTERNET ACCESS.
            }.resume()
        }
    }
    
    static var clearsCacheOnExit: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "clearsCacheOnExit")
        } set {
            UserDefaults.standard.set(newValue, forKey: "clearsCacheOnExit")
        }
    }
}
