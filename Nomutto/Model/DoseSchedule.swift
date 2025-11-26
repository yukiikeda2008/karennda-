//
//  DoseSchedule.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//


import Foundation

struct DoseSchedule: Codable, Identifiable, Equatable {
    let id: UUID
    var medicationID: UUID
    var hour: Int
    var minute: Int
    var daysOfWeek: Set<Int>
    var quantity: Double

    init(id: UUID = UUID(), medicationID: UUID, hour: Int, minute: Int,
         daysOfWeek: Set<Int>, quantity: Double) {
        self.id = id; self.medicationID = medicationID; self.hour = hour; self.minute = minute
        self.daysOfWeek = daysOfWeek; self.quantity = quantity
    }
}
