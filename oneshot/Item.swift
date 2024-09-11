//
//  Item.swift
//  oneshot
//
//  Created by Oliver Lowe on 11/9/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
