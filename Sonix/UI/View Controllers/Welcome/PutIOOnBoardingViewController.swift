//
//  PutIOOnBoardingViewController.swift
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
import PutKit.PIOAuth
import class SafariServices.SFSafariViewController

class PutIOOnBoardingViewController: OnBoardingViewController, AuthenticatorDelegate {
    
    override var cellType: WelcomeCollectionViewCell.Type {
        return ServiceWelcomeCollectionViewCell.self
    }
    
    class func `init`(from storyboard: UIStoryboard) -> PutIOOnBoardingViewController {
        let `self` = storyboard.instantiateViewController(withIdentifier: "OnBoardingViewController") as! OnBoardingViewController
        
        object_setClass(self, PutIOOnBoardingViewController.self)
        self.view.tintColor = UIColor(named: "putioColor")
        
        return self as! PutIOOnBoardingViewController
    }
    
    func authenticationDidFinishWithError(_ error: Error?) {
        let completion: () -> Void
        
        Auth.shared().removeListener(self)
        
        if let error = error {
            completion = {
                self.present(UIAlertController(error: error), animated: true)
            }
        } else {
            completion = {
                let keyWindow = UIApplication.shared.keyWindow
                keyWindow?.rootViewController?.dismiss(animated: true) {
                    keyWindow?.rootViewController = self.storyboard?.instantiateInitialViewController()
                }
            }
        }
        
        if presentedViewController != nil {
            dismiss(animated: true, completion: completion)
        } else {
            completion()
        }
    }
    
    override func bigButtonPressed() {
        Auth.shared().addListener(self)
        
        let safariController = SFSafariViewController(url: Auth.shared().signInURL)
        let navigationController = UINavigationController(rootViewController: safariController)
        navigationController.modalPresentationStyle = .overCurrentContext
        
        safariController.preferredControlTintColor = UIColor(named: "putioColor")
        safariController.preferredBarTintColor = UIColor(named: "backgroundColor")
        navigationController.setNavigationBarHidden(true, animated: false)
        
        present(navigationController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigButton?.setTitle(NSLocalizedString("connect_onboarding_button_title_label", comment: "The title of the button allowing the user to connect to one of Sonix's services, e.g. Trakt or Put.io."), for: .normal)
        bigButton?.backgroundColor = UIColor(named: "putioColor")
    }
    
    override func configure<C: WelcomeCollectionViewCell>(_ cell: C, at indexPath: IndexPath, on rail: Int) {
        cell.textLabel?.text = NSLocalizedString("put_io_onboarding_title_label", comment: "The title describing Sonix's Put.io integrations.")
        cell.detailTextLabel?.text = NSLocalizedString("put_io_onboarding_description_label", comment: "A more detailed description of Sonix's Put.io integrations.")
        cell.imageView?.tintColor = UIColor(named: "putioColor")
        cell.imageView?.image = UIImage(named: "Put.io Logo")
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
        
        
        let serviceName = "Put.io"
        let string = String(format: NSLocalizedString("connect_onboarding_title_label_format", comment: "Format for onboarding connect title: Connect to {Service's Name}."), serviceName)
        
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 37, weight: .heavy),
                                                                      .foregroundColor: UIColor(named: "labelColor")!])
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "putioColor")!, range: (string as NSString).range(of: serviceName))
        
        textLabel?.attributedText = attributedString
        
        return header
    }

}
