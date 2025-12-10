//
//  DayCell.swift
//  karennda-
//
//  Created by Honoka Nishiyama on 2025/12/10.
//

import UIKit

final class DayCell: UICollectionViewCell {
    static let reuseIdentifier = "DayCell"

    let dayLabel = UILabel()
    private let todayCircleView = UIView()   // ← 追加

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        // 先に丸を追加（ラベルの「後ろ」にしたいので）
        contentView.addSubview(todayCircleView)
        contentView.addSubview(dayLabel)

        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        dayLabel.font = .systemFont(ofSize: 16, weight: .regular)
        dayLabel.textAlignment = .center

        // 今日マーク（丸）の見た目
        todayCircleView.translatesAutoresizingMaskIntoConstraints = false
        todayCircleView.backgroundColor = UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0)
        todayCircleView.layer.cornerRadius = 12                 // 半径 = サイズの半分
        todayCircleView.isHidden = true                         // デフォルトは非表示

        NSLayoutConstraint.activate([
            // ラベルは上寄せ＋中央
            dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),

            // 丸はラベルの中心に合わせて、少し大きめ
            todayCircleView.centerXAnchor.constraint(equalTo: dayLabel.centerXAnchor),
            todayCircleView.centerYAnchor.constraint(equalTo: dayLabel.centerYAnchor),
            todayCircleView.widthAnchor.constraint(equalToConstant: 24),
            todayCircleView.heightAnchor.constraint(equalToConstant: 24)
        ])

        // 枠線はそのまま
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
    }

    override var isSelected: Bool {
        didSet {
            contentView.backgroundColor = isSelected
            ? UIColor(red: 132/255, green: 147/255, blue: 132/255, alpha: 1.0).withAlphaComponent(0.2)
            : .clear
        }
    }

    // 今日かどうかを設定する用のメソッドを追加
    func configureToday(isToday: Bool, baseTextColor: UIColor) {
        todayCircleView.isHidden = !isToday
        dayLabel.textColor = isToday ? .white : baseTextColor
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        todayCircleView.isHidden = true
    }
}

