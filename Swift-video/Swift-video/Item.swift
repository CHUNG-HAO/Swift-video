//
//  Item.swift
//  Swift-video
//
//  Created by 鍾弘浩 on 2024/3/18.
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
