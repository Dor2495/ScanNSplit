//
//  Person.swift
//  ScanNSplit
//
//  Created by Dor Mizrachi on 14/05/2025.
//

import SwiftUI
import SwiftData

@Model
class Person {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var color: String = "#00ff22"
    
    init(id: String = UUID().uuidString, name: String, color: String = "#00ff22") {
        self.id = id
        self.name = name
        self.color = color
    }
}


