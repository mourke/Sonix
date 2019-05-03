//
//  AppDelegate.swift
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

import UIKit
import class PutKit.Auth
import class TraktKit.TraktManager
import Reachability
import GoogleCast
import AVFoundation.AVFAudio.AVAudioSession

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability = .forInternetConnection()
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let auth = Auth.shared()
        auth.apiSecret = API.Endpoints.PutIO.apiSecret
        auth.redirectURI = URL(string: API.Endpoints.PutIO.redirectURI)!
        auth.clientId = API.Endpoints.PutIO.clientId
        
        TraktManager.sharedManager.setClientID(clientID: API.Endpoints.Trakt.clientId, clientSecret: API.Endpoints.Trakt.clientSecret, redirectURI: API.Endpoints.Trakt.redirectURI)
        
        if !Settings.isSignedIn {
            UIApplication.shared.open(URL(string: "sonix://startOnBoarding")!)
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .moviePlayback, options: [.allowAirPlay, .allowBluetooth, .allowBluetoothA2DP])

        let options = GCKCastOptions(discoveryCriteria: GCKDiscoveryCriteria(applicationID: "BA77F9C3"))
        GCKCastContext.setSharedInstanceWith(options, error: nil)
        
        reachability.startNotifier()
        window?.tintColor = UIColor(named: "accentColor")
        
        UITabBar.appearance(for: UITraitCollection(userInterfaceStyle: .dark), whenContainedInInstancesOf: [UITabBarController.self]).barStyle = .black
        UITabBar.appearance(for: UITraitCollection(userInterfaceStyle: .light), whenContainedInInstancesOf: [UITabBarController.self]).barStyle = .default
        
        UINavigationBar.appearance(for: UITraitCollection(userInterfaceStyle: .dark), whenContainedInInstancesOf: [UINavigationController.self]).barStyle = .black
        UINavigationBar.appearance(for: UITraitCollection(userInterfaceStyle: .light), whenContainedInInstancesOf: [UINavigationController.self]).barStyle = .default
        
        UISearchBar.appearance(for: UITraitCollection(userInterfaceStyle: .dark), whenContainedInInstancesOf: [UINavigationController.self]).keyboardAppearance = .dark
        UISearchBar.appearance(for: UITraitCollection(userInterfaceStyle: .light), whenContainedInInstancesOf: [UINavigationController.self]).keyboardAppearance = .light
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        UpdateManager.shared.checkVersion(.daily)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        guard let sourceApplicationIdentifier = options[.sourceApplication] as? String else { return false }
        
        if url.scheme == "sonix" {
            if (sourceApplicationIdentifier == "com.apple.SafariViewService" || sourceApplicationIdentifier == "com.apple.mobilesafari") {
                let query = url.queryDictionary
                let code = query["code"]!
                if url.host == "trakt" {
                    try! TraktManager.sharedManager.getTokenFromAuthorizationCode(code: code) { _ in
                        Settings.refreshTraktAccountSettings()
                    }
                } else if url.host == "putio" {
                    PutKit.Auth.shared().credential(for: code) { (_, _) in
                        Settings.refreshPutIOAccountSettings()
                    }.resume()
                }
                
                return true
            } else if sourceApplicationIdentifier == Bundle.main.bundleIdentifier {
                Handler.shared.handle(url)
            }
        } else if url.scheme == "magnet" {
            Handler.shared.queue(items: (nil, url))
        }
        
        return false
    }
}

