//
//  Collection+SafeSubscript.swift
//  Sonix
//
//  Created by Nikita Kukushkin on 2/5/15.
//  Copyright © 2018 Nikita Kukushkin. All rights reserved.
//

import Foundation

extension Collection {
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
