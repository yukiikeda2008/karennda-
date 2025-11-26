//
//  IntakeLogStore.swift
//  karennda-
//
//  Created by 池田友希 on 2025/10/22.
//

import Foundation

struct IntakeLogKey: Hashable, Codable {
    let dayKey: String           // "yyyy-MM-dd"
    let medicationID: UUID
    let scheduleID: UUID
}

struct IntakeLogStore {
    private static let key = "intakeLogs"

    // 辞書全体のロード／セーブ
    static func loadAll() -> [IntakeLogKey: IntakeLog] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [:] }
        return (try? JSONDecoder().decode([IntakeLogKey: IntakeLog].self, from: data)) ?? [:]
    }

    static func saveAll(_ dict: [IntakeLogKey: IntakeLog]) {
        let data = try? JSONEncoder().encode(dict)
        UserDefaults.standard.set(data, forKey: key)
    }

    // 追加 or 更新
    static func upsert(_ log: IntakeLog) {
        var dict = loadAll()
        let k = IntakeLogKey(dayKey: log.dayKey, medicationID: log.medicationID, scheduleID: log.scheduleID)
        dict[k] = log
        saveAll(dict)
    }

    // その日の全記録を取得
    static func fetch(dayKey: String) -> [IntakeLog] {
        loadAll()
            .filter { $0.key.dayKey == dayKey }
            .map { $0.value }
    }

    // その日 & 特定スケジュールの記録を取得（UIに既存チェック反映する時など）
    static func fetch(dayKey: String, medicationID: UUID, scheduleID: UUID) -> IntakeLog? {
        let dict = loadAll()
        let k = IntakeLogKey(dayKey: dayKey, medicationID: medicationID, scheduleID: scheduleID)
        return dict[k]
    }

    // 削除（例えば間違えて付けたチェックを消すなど）
    static func delete(dayKey: String, medicationID: UUID, scheduleID: UUID) {
        var dict = loadAll()
        let k = IntakeLogKey(dayKey: dayKey, medicationID: medicationID, scheduleID: scheduleID)
        dict.removeValue(forKey: k)
        saveAll(dict)
    }
}
