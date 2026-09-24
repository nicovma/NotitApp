//
//  Category.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var color: String
    
    @Relationship(deleteRule: .cascade, inverse: \Note.category)
    var notes: [Note] = []
    
    init(_ name: String, color: String, id: UUID = UUID()) {
        self.name = name
        self.color = color
        self.id = id
    }
}
