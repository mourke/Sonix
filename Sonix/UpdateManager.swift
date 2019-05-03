//
//  UpdateManager.swift
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

/**
 A manager class that automatically looks for new releases from github and presents them to the user.
 */
final class UpdateManager: NSObject {
    
    /**
     Determines the frequency in which the the version check is performed.
     
     - .immediately:    Version check performed every time the app is launched.
     - .daily:          Version check performedonce a day.
     - .weekly:         Version check performed once a week.
     */
    enum CheckType: Int {
        /// Version check performed every time the app is launched.
        case immediately = 0
        /// Version check performed once a day.
        case daily = 1
        /// Version check performed once a week.
        case weekly = 7
    }
    
    /// Designated Initialiser.
    static let shared = UpdateManager()
    
    /// The version that the user does not want installed. If the user has never clicked "Skip this version" this variable will be `nil`, otherwise it will be the last version that the user opted not to install.
    private var skipReleaseVersion: VersionString? {
        get {
            guard let data = UserDefaults.standard.data(forKey: "skipReleaseVersion") else { return nil }
            return VersionString.unarchive(data)
        } set {
            if let newValue = newValue {
                UserDefaults.standard.set(newValue.archived(), forKey: "skipReleaseVersion")
            } else {
                UserDefaults.standard.removeObject(forKey: "skipReleaseVersion")
            }
        }
    }
    
    /// The date of the last time `checkForUpdates:completion:` was called.
    var lastVersionCheckPerformedOnDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: "lastVersionCheckPerformedOnDate") as? Date
        } set {
            UserDefaults.standard.set(newValue, forKey: "lastVersionCheckPerformedOnDate")
        }
    }
    
    /// Returns the number of days it has been since `checkForUpdates:completion:` has been called.
    var daysSinceLastVersionCheckDate: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: lastVersionCheckPerformedOnDate ?? Date(), to: Date())
        return components.day!
    }
    
    private let url = URL(string: "https://api.github.com/repos/mourke/Sonix/releases")!
    private let window: UIWindow = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIViewController()
        window.windowLevel = .alert
        return window
    }()
    
    /**
     Checks github repository for new releases.
     
     - Parameter sucess: Optional callback indicating the status of the operation.
     */
    func checkVersion(_ checkType: CheckType, callback: ((_ success: Bool) -> Void)? = nil) {
        if checkType == .immediately || checkType.rawValue <= daysSinceLastVersionCheckDate {
            checkForUpdates(callback)
        }
    }
    
    private func checkForUpdates(_ callback: ((Bool) -> Void)? = nil) {
        lastVersionCheckPerformedOnDate = Date()
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            var updatesAvailable = error == nil
            
            if let data = data {
                do {
                    let array = try JSONSerialization.jsonObject(with: data) as? [[String : Any]]
                    
                    var releases: [VersionString] = []
                    
                    array?.forEach {
                        guard let tagName = $0["tag_name"] as? String,
                            let datePublished = $0["published_at"] as? String,
                            let versionString = VersionString(tagName: tagName, dateString: datePublished) else { return }
                        
                        releases.append(versionString)
                    }
                    
                    let sortedReleases = releases.sorted(by: {$0 > $1})
                    
                    if let latestRelease = sortedReleases.first,
                        let currentRelease = sortedReleases.filter({$0.buildNumber == UIApplication.shared.version}).first,
                        latestRelease > currentRelease && self.skipReleaseVersion?.buildNumber != latestRelease.buildNumber {
                        let localizedTitle = NSLocalizedString("update_manager_update_alert_title", comment: "Tells the user a new version of Sonix is available.")
                        let localizedMessageFormat = NSLocalizedString("update_manager_update_alert_message_format", comment: "Format for update alert: A new version of Sonix ({Version string. E.g. '1.0.0'}) is now available.")
                        
                        let alertController = UIAlertController(title: localizedTitle,
                                                                message: String(format: localizedMessageFormat, latestRelease.buildNumber),
                                                                preferredStyle: .alert)
                        
                        let skipLocalizedTitle = NSLocalizedString("update_manager_update_alert_action_skip", comment: "The user understands what they have read and wants to skip the current version.")
                        
                        alertController.addAction(UIAlertAction(title: skipLocalizedTitle, style: .default) { _ in
                            self.skipReleaseVersion = latestRelease
                        })
                        alertController.addAction(UIAlertAction.ok)
                        
                        self.window.makeKeyAndVisible()
                        self.window.rootViewController?.dismiss(animated: false) { // Make sure there are no other alerts being presented already.
                            self.window.rootViewController?.present(alertController, animated: true)
                        }
                    } else {
                        updatesAvailable = false
                    }
                } catch {
                    updatesAvailable = false
                }
            }
            OperationQueue.main.addOperation {
                callback?(updatesAvailable)
            }
        }.resume()
    }
}

class VersionString: NSObject, NSCoding {
    
    enum ReleaseType: String {
        case beta
        case stable
    }
    
    let date: Date
    let buildNumber: String
    let releaseType: ReleaseType
    
    init?(tagName: String, dateString: String) {
        self.buildNumber = tagName
        self.date = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            return formatter.date(from: dateString)!
        }()
        
        let components = tagName.components(separatedBy: ".")
        if let first = components.first, let _ = components[safe: 1], let _ = components[safe: 2] {
            if first == "0" // Beta release. Format will be 0.<major>.<minor>-<patch>.
            {
                self.releaseType = .beta
            } else // Stable release. Format will be <major>.<minor>.<patch>.
            {
                self.releaseType = .stable
            }
            return
        }
        return nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(buildNumber, forKey: "buildNumber")
        aCoder.encode(releaseType.rawValue, forKey: "releaseType")
    }
    
    required init?(coder aDecoder: NSCoder) {
        guard let date = aDecoder.decodeObject(forKey: "date") as? Date,
            let buildNumber = aDecoder.decodeObject(forKey: "buildNumber") as? String,
            let releaseTypeRawValue = aDecoder.decodeObject(forKey: "releaseType") as? String,
            let releaseType = ReleaseType(rawValue: releaseTypeRawValue) else { return nil }
        self.date = date
        self.buildNumber = buildNumber
        self.releaseType = releaseType
    }
    
    func archived() -> Data? {
        return try? NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
    }
    
    class func unarchive(_ data: Data) -> VersionString? {
        return (try? NSKeyedUnarchiver.unarchivedObject(ofClass: VersionString.self, from: data)) ?? nil
    }
}

func >(lhs: VersionString, rhs: VersionString) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedDescending
}

func <(lhs: VersionString, rhs: VersionString) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedAscending
}

func ==(lhs: VersionString, rhs: VersionString) -> Bool {
    return lhs.date.compare(rhs.date) == .orderedSame
}
