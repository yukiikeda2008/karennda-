//
//  Medication.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//
import Foundation

struct Medication: Codable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var note: String?

    var startDate: Date
    var endDate: Date?

    var dosesPerDay: Int       // 1日の服用回数
    var dosePerIntake: Double  // 1回の服用量

    var schedules: [DoseSchedule]

    var dailyConsumption: Double { Double(dosesPerDay) * dosePerIntake }
}
