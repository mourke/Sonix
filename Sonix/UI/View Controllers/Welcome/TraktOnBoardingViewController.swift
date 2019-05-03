//
//  TraktOnBoardingViewController.swift
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
import class SafariServices.SFSafariViewController

class TraktOnBoardingViewController: OnBoardingViewController {
    
    override var cellType: WelcomeCollectionViewCell.Type {
        return ServiceWelcomeCollectionViewCell.self
    }

    class func `init`(from storyboard: UIStoryboard) -> TraktOnBoardingViewController {
        let `self` = storyboard.instantiateViewController(withIdentifier: "OnBoardingViewController") as! OnBoardingViewController
        
        object_setClass(self, TraktOnBoardingViewController.self)
        self.view.tintColor = UIColor(named: "traktColor")
        
        return self as! TraktOnBoardingViewController
    }
    
    override func bigButtonPressed() {
        NotificationCenter.default.addObserver(self, selector: #selector(accountStatusDidChange), name: .TraktAccountStatusDidChange, object: nil)
        
        let safariController = SFSafariViewController(url: TraktManager.sharedManager.oauthURL!)
        let navigationController = UINavigationController(rootViewController: safariController)
        navigationController.modalPresentationStyle = .overCurrentContext
        
        safariController.preferredControlTintColor = UIColor(named: "traktColor")
        safariController.preferredBarTintColor = UIColor(named: "backgroundColor")
        navigationController.setNavigationBarHidden(true, animated: false)
        
        present(navigationController, animated: true)
    }
    
    @objc func accountStatusDidChange() {
        let success = TraktManager.sharedManager.isSignedIn
        NotificationCenter.default.removeObserver(self)
        
        let completion: () -> Void
        
        if success {
            let nextViewController = PutIOOnBoardingViewController.init(from: storyboard!)
            completion = {
                self.navigationController?.pushViewController(nextViewController, animated: true)
            }
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("trakt_error_alert_title", comment: "Tells the user that there has been an error signing in."), message: NSLocalizedString("trakt_error_alert_message", comment: "Tells the user there has been an unknown problem and the only solution is to try again."), preferredStyle: .alert)
            alertController.addAction(UIAlertAction.ok)
            completion = {
                self.present(alertController, animated: true)
            }
        }
        
        if presentedViewController != nil {
            dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigButton?.setTitle(NSLocalizedString("connect_onboarding_button_title_label", comment: "The title of the button allowing the user to connect to one of Sonix's services, e.g. Trakt or Put.io."), for: .normal)
        bigButton?.backgroundColor = UIColor(named: "traktColor")
    }
    
    override func configure<C: WelcomeCollectionViewCell>(_ cell: C, at indexPath: IndexPath, on rail: Int) {
        cell.textLabel?.text = NSLocalizedString("trakt_onboarding_title_label", comment: "The title describing Sonix's Trakt integrations.")
        cell.detailTextLabel?.text = NSLocalizedString("trakt_onboarding_description_label", comment: "A more detailed description of Sonix's Trakt integrations.")
        cell.imageView?.tintColor = UIColor(named: "traktColor")
        cell.imageView?.image = UIImage(named: "Trakt Logo")
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ServiceWelcomeCollectionViewCell
        let rail = collectionView.tag
        
        configure(cell, at: indexPath, on: rail)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { fatalError() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        let textLabel = header.viewWithTag(1) as? UILabel
        
        
        let serviceName = "Trakt"
        let string = String(format: NSLocalizedString("connect_onboarding_title_label_format", comment: "Format for onboarding connect title: Connect to {Service's Name}."), serviceName)
        
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 37, weight: .heavy),
                                                                      .foregroundColor: UIColor(named: "labelColor")!])
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "traktColor")!, range: (string as NSString).range(of: serviceName))
        
        textLabel?.attributedText = attributedString
        
        return header
    }

}
