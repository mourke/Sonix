//
//  Cinema.swift
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
import MapKit
import Contacts

struct Cinema: Decodable {
    
    let name: String
    let phoneNumber: String
    let location: (latitude: CLLocationDegrees, longitude: CLLocationDegrees, distance: CLLocationDistance)
    let address: CNPostalAddress
    var screenings: [Screening] = []
    
    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "callablePhone"
        case address
    }
    
    enum AddressKeys: String, CodingKey {
        case street
        case city
        case state
        case zip
        case longitude
        case latitude
        case distance
    }
    
    func openInMaps() -> Bool {
        let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: location.distance, longitudinalMeters: location.distance)
        
        let options = [MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                       MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)]
        let placemark = MKPlacemark(coordinate: coordinates, postalAddress: address)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        
        return mapItem.openInMaps(launchOptions: options)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        
        let addressContainer = try container.nestedContainer(keyedBy: AddressKeys.self, forKey: .address)
        let latitude = try addressContainer.decode(CLLocationDegrees.self, forKey: .latitude)
        let longitude = try addressContainer.decode(CLLocationDegrees.self, forKey: .longitude)
        let distance = try addressContainer.decode(CLLocationDistance.self, forKey: .distance)
        location = (latitude, longitude, distance)
        
        address = try {
            let address = CNMutablePostalAddress()
            address.city = try addressContainer.decode(String.self, forKey: .city)
            address.street = try addressContainer.decode(String.self, forKey: .street)
            address.postalCode = try addressContainer.decode(String.self, forKey: .zip)
            address.state = try addressContainer.decode(String.self, forKey: .state)
            return address
        }()
    }
}
