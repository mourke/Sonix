//
//  WelcomeOnBoardingViewController.swift
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

class WelcomeOnBoardingViewController: OnBoardingViewController {
    
    override var cellType: WelcomeCollectionViewCell.Type {
        return SummaryWelcomeCollectionViewCell.self
    }
    
    class func `init`(from storyboard: UIStoryboard) -> WelcomeOnBoardingViewController {
        let `self` = storyboard.instantiateViewController(withIdentifier: "OnBoardingViewController") as! OnBoardingViewController
        
        object_setClass(self, WelcomeOnBoardingViewController.self)
        self.view.tintColor = UIColor(named: "accentColor")
        
        return self as! WelcomeOnBoardingViewController
    }
    
    override func bigButtonPressed() {
        guard let storyboard = storyboard else { return }
        let nextViewController = TraktOnBoardingViewController.init(from: storyboard)
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bigButton?.setTitle(NSLocalizedString("welcome_onboarding_button_title_label", comment: "The title of the button allowing the user to proceed with set-up."), for: .normal)
        bigButton?.backgroundColor = UIColor(named: "accentColor")
    }
    
    override func configure<C: WelcomeCollectionViewCell>(_ cell: C, at indexPath: IndexPath, on rail: Int) {
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = NSLocalizedString("welcome_onboarding_speed_title_label", comment: "The title describing Sonix's quick downloads.")
            cell.detailTextLabel?.text = NSLocalizedString("welcome_onboarding_speed_description_label", comment: "A more detailed description of Sonix's quick downloads.")
            cell.imageView?.image = UIImage(named: "Lightning")
        case 1:
            cell.textLabel?.text = NSLocalizedString("welcome_onboarding_recommendations_title_label", comment: "The title describing Sonix's recommendations.")
            cell.detailTextLabel?.text = NSLocalizedString("welcome_onboarding_recommendations_description_label", comment: "A more detailed description of Sonix's recommendations.")
            cell.imageView?.image = UIImage(named: "Recommendations")
        case 2:
            cell.textLabel?.text = NSLocalizedString("welcome_onboarding_times_title_label", comment: "The title describing Sonix's cinema-time capabilities.")
            cell.detailTextLabel?.text = NSLocalizedString("welcome_onboarding_times_description_label", comment: "A more detailed description of Sonix's cinema-time capabilities.")
            cell.imageView?.image = UIImage(named: "Cinema Times")
        default:
            fatalError()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! SummaryWelcomeCollectionViewCell
        let rail = collectionView.tag
        
        configure(cell, at: indexPath, on: rail)
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { fatalError() }
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        let textLabel = header.viewWithTag(1) as? UILabel
        
        
        let appName = "Sonix"
        let string = String(format: NSLocalizedString("welcome_onboarding_title_label_format", comment: "Format for onboarding title: Welcome to {App's Name}."), appName)
        
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [.font: UIFont.systemFont(ofSize: 37, weight: .heavy),
                                                                      .foregroundColor: UIColor(named: "labelColor")!])
        attributedString.addAttribute(.foregroundColor, value: UIColor(named: "accentColor")!, range: (string as NSString).range(of: appName))
        
        textLabel?.attributedText = attributedString
        
        return header
    }

}
