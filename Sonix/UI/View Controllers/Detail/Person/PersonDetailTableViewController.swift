//
//  PersonDetailTableViewController.swift
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
import struct TMDBKit.DetailPerson

class PersonDetailTableViewController: DetailTableViewController {
    
    var person: DetailPerson!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = person.name
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPersonInfoDetail",
            let destination = segue.destination as? InfoDetailViewController {
            destination.loadViewIfNeeded()
            destination.view.translatesAutoresizingMaskIntoConstraints = false
            
            if let date = person.birthDate, let place = person.birthPlace {
                destination.detailLabel?.text = String(format: NSLocalizedString("detail_person_date_and_place_of_birth_format", comment: "The format string for the date and location of a person: Born {Date of birth e.g. 21st June 1999} in {Place of birth e.g. Virginia, Minnesota}."), DateFormatter.localizedString(from: date, dateStyle: .long, timeStyle: .none), place)
            } else {
                destination.detailLabel?.text = nil
            }
            
            destination.titleLabel?.text = person.name
            destination.socialIds = Dictionary(uniqueKeysWithValues: person.ids.compactMap { (network, id) in
                switch network {
                case .imdb:
                    return (network, URL(string: "https://www.imdb.com/name/\(id)")!)
                case .tvdb:
                    return nil
                case .tmdb:
                    return (network, URL(string: "https://www.themoviedb.org/person/\(id)")!)
                case .twitter:
                    return (network, URL(string: "https://twitter.com/\(id)")!)
                case .facebook:
                    return (network, URL(string: "https://facebook.com/\(id)")!)
                case .instagram:
                    return (network, URL(string: "https://instagram.com/\(id)")!)
                }
            })
            destination.textView?.text = person.biography
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        let url = traitCollection.horizontalSizeClass == .compact ? person.headshot(for: .original) : person.backdrop(for: .original)
        backgroundImageView.kf.setImage(with: url, placeholder: UIImage(named: "PreloadAsset_Generic"))
    }
}
