//
//  Item.swift
//  GreenMind
//
//  Created by JJ Sudusinghe on 2026-10-24.
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
