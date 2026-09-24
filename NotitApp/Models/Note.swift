//
//  Note.swift
//  NotitApp
//
//  Created by Nicolas Valentini on 27/8/2026.
//
import Foundation
import SwiftData

@Model
final class Note {
    var id: UUID
    var title: String
    var value: String
    var category: Category
    var createdAt: Date
    var updatedAt: Date = Date.now

    init(_ title: String, value: String, category: Category, createdAt: Date, updatedAt: Date? = nil, id: UUID = UUID()) {
        self.id = id
        self.title = title
        self.value = value
        self.category = category
        self.createdAt = createdAt
        self.updatedAt = updatedAt ?? createdAt
    }
}
