//
//  IntakeLog.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//
import Foundation

struct IntakeLog: Codable, Identifiable, Equatable {
    let id: UUID
    var medicationID: UUID
    var scheduleID: UUID
    var dayKey: String   // "yyyy-MM-dd"
    var taken: Bool
    var takenAt: Date?
}
