//
//  AccountTableViewController.swift
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
import TraktKit
import class PutKit.Auth

class AccountTableViewController: UITableViewController {
    
    @IBAction func doneButtonPressed() {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let group = DispatchGroup()
        
        group.enter()
        Settings.refreshPutIOAccountSettings {
            group.leave()
        }
        
        group.enter()
        Settings.refreshTraktAccountSettings {
            group.leave()
        }
        
        group.notify(queue: .main) {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = Settings.name
            cell.detailTextLabel?.text = Settings.username
            cell.imageView?.image = Settings.image
            cell.imageView?.layer.cornerRadius = Settings.image.size.width/2
            cell.imageView?.layer.masksToBounds = true
        case 1:
            switch indexPath.row {
            case 0:
                cell.detailTextLabel?.text = Settings.canStreamOnCellular ? NSLocalizedString("settings_cell_on_label", comment: "This feature is currently enabled.") : NSLocalizedString("settings_cell_off_label", comment: "This feature is currently disabled.")
            case 1:
                let quality = Settings.preferredQuality.rawValue
                cell.detailTextLabel?.text = quality.isEmpty ? NSLocalizedString("settings_cell_any_label", comment: "The user doesn't mind what value this setting has.") : quality
            case 2:
                let text: String
                if let languageCode = Settings.preferredSubtitleLanguageCode,
                    let localizedString = Locale.current.localizedString(forLanguageCode: languageCode) {
                    text = localizedString
                } else {
                    text = NSLocalizedString("settings_cell_none_label", comment: "The user has been displayed with a list of options, but has chosen none of them.")
                }
                cell.detailTextLabel?.text = text
            case 3:
                cell.detailTextLabel?.text = Settings.preferredAppearance.localizedString
            case 4:
                cell.detailTextLabel?.text = Settings.clearsCacheOnExit ? NSLocalizedString("settings_cell_yes_label", comment: "The user would like for this feature to be enabled.") : NSLocalizedString("settings_cell_no_label", comment: "The user would not like for this feature to be enabled.")
            default:
                fatalError()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let text: String
                if let date = UpdateManager.shared.lastVersionCheckPerformedOnDate {
                    text = DateFormatter.localizedString(from: date, dateStyle: .short, timeStyle: .short)
                } else {
                    text = NSLocalizedString("settings_cell_never_label", comment: "The user has never checked for updates.")
                }
                cell.detailTextLabel?.text = text
            case 1:
                cell.detailTextLabel?.text = UIApplication.shared.version
            default:
                fatalError()
            }
        default:
            break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 1:
            switch indexPath.row {
            case 0:
                Settings.canStreamOnCellular = !Settings.canStreamOnCellular
                tableView.reloadRows(at: [indexPath], with: .none)
            case 1:
                let alertController = UIAlertController(title: tableView.cellForRow(at: indexPath)?.textLabel?.text, message: nil, preferredStyle: .actionSheet)
                let qualities: [TorrentQuality] = [.quality3D, .quality1080p, .quality720p, .quality480p]
                qualities.forEach { (quality) in
                    let title = quality.rawValue

                    let action = UIAlertAction(title: title, style: .default) { (_) in
                        Settings.preferredQuality = quality
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    alertController.addAction(action)
                    
                    if Settings.preferredQuality == quality {
                        alertController.preferredAction = action
                    }
                }
                let anyAction = UIAlertAction(title: NSLocalizedString("settings_cell_any_label", comment: "The user doesn't mind what value this setting has."), style: .default) { (_) in
                    Settings.preferredQuality = .unknown
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                alertController.addActions(.cancel, anyAction)
                
                if Settings.preferredQuality == .unknown {
                    alertController.preferredAction = anyAction
                }
                
                present(alertController, animated: true)
            case 2:
                let alertController = UIAlertController(title: tableView.cellForRow(at: indexPath)?.textLabel?.text, message: nil, preferredStyle: .actionSheet)
                Locale.commonISOLanguageCodes.forEach { (languageCode) in
                    guard let title = Locale.current.localizedString(forLanguageCode: languageCode) else { return }
                    
                    let action = UIAlertAction(title: title, style: .default) { (_) in
                        Settings.preferredSubtitleLanguageCode = languageCode
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    alertController.addAction(action)
                    
                    if Settings.preferredSubtitleLanguageCode == languageCode {
                        alertController.preferredAction = action
                    }
                }
                
                let noneAction = UIAlertAction(title: NSLocalizedString("settings_cell_none_label", comment: "The user has been displayed with a list of options, but has chosen none of them."), style: .default) { (_) in
                    Settings.preferredSubtitleLanguageCode = nil
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                
                alertController.addActions(.cancel, noneAction)
                
                if Settings.preferredSubtitleLanguageCode == nil {
                    alertController.preferredAction = noneAction
                }
                present(alertController, animated: true)
            case 3:
                let alertController = UIAlertController(title: tableView.cellForRow(at: indexPath)?.textLabel?.text, message: nil, preferredStyle: .actionSheet)
                let styles: [UIUserInterfaceStyle] = [.unspecified, .light, .dark]
                styles.forEach { (style) in
                    let title = style.localizedString
                    
                    let action = UIAlertAction(title: title, style: .default) { (_) in
                        Settings.preferredAppearance = style
                        tableView.reloadRows(at: [indexPath], with: .none)
                    }
                    
                    alertController.addAction(action)
                    
                    if Settings.preferredAppearance == style {
                        alertController.preferredAction = action
                    }
                }
                alertController.addAction(.cancel)
                
                present(alertController, animated: true)
            case 4:
                Settings.clearsCacheOnExit = !Settings.clearsCacheOnExit
                tableView.reloadRows(at: [indexPath], with: .none)
            default:
                fatalError()
            }
        case 2:
            switch indexPath.row {
            case 0:
                let contentViewController = UpdateAlertControllerContainerViewController(nibName: "UpdateAlertControllerContainerViewController", bundle: nil)
                
                contentViewController.loadViewIfNeeded()
                
                let alertController = UIAlertController(contentViewController: contentViewController, preferredStyle: .alert)
                
                alertController.addAction(.cancel)
                
                UpdateManager.shared.checkVersion(.immediately) { (updatesAvailable) in
                    guard self.presentedViewController != nil else { return } // Check to see if alert has been cancelled.
                    
                    self.dismiss(animated: true) {
                        if !updatesAvailable {
                            let alert = UIAlertController(title: NSLocalizedString("update_manager_no_update_alert_title", comment: "Tells the user that there are no new versions of Sonix available."), message: NSLocalizedString("update_manager_no_update_alert_message", comment: "Tells the user that that there are no updates available for the app."), preferredStyle: .alert)
                            alert.addAction(.ok)
                            self.present(alert, animated: true)
                        }
                    }
                }
                
                present(alertController, animated: true) {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            default:
                break
            }
        case 3:
            let alertController = UIAlertController(title: NSLocalizedString("settings_sign_out_alert_action_title", comment: "The title of the sign-out alert."), message: NSLocalizedString("settings_sign_out_confirmation_message", comment: "Asks the user if they are sure they would like to sign out of the application."), preferredStyle: .alert)
            
            let signOutAction = UIAlertAction(title: NSLocalizedString("settings_sign_out_alert_action_title", comment: "The title of the button asking the user if they would like to sign out of the application."), style: .destructive) { (_) in
                try! TraktManager.sharedManager.signOutAndRevokeAccessToken()
                Auth.shared().signOutAndRevokeAccessToken().resume()
                
                // Create a SFSafariViewController to sign out and remove cookies so that the user may login with another account if they so please.
                let safariController = TraktLogOutSafariViewController.init() {
                    UIApplication.shared.open(URL(string: "sonix://startOnBoarding")!)
                }
                safariController.preferredControlTintColor = UIColor(named: "traktColor")
                safariController.preferredBarTintColor = UIColor(named: "backgroundColor")
                safariController.modalPresentationStyle = .overCurrentContext
                self.present(safariController, animated: true)
            }
            
            alertController.addActions(signOutAction, .cancel)
            
            present(alertController, animated: true)
        default:
            break
        }
    }
}
