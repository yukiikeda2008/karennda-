//
//  MedicationStore.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import Foundation

struct MedicationStore {
    private static let key = "medications"

    static func load() -> [Medication] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        return (try? JSONDecoder().decode([Medication].self, from: data)) ?? []
    }

    static func save(_ meds: [Medication]) {
        let data = try? JSONEncoder().encode(meds)
        UserDefaults.standard.set(data, forKey: key)
    }

    static func upsert(_ med: Medication) {
        var all = load()
        if let i = all.firstIndex(where: { $0.id == med.id }) {
            all[i] = med
        } else {
            all.append(med)
        }
        save(all)
    }

    static func delete(id: UUID) {
        var all = load()
        all.removeAll { $0.id == id }
        save(all)
    }

    static func get(by id: UUID) -> Medication? {
        load().first { $0.id == id }
    }
}
