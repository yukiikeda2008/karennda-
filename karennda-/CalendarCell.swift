//
//  CalenderCell.swift
//  karennda-
//
//  Created by 池田友希 on 2025/02/19.
//

import UIKit

class CalendarCell: UICollectionViewCell {
    
    var textLabel: UILabel!
    
    
    override init (frame: CGRect) {
        super . init(frame: frame)
    setupTextLabel()
    }
    
    required init?(coder: NSCoder) {
        super . init(coder: coder)
        setupTextLabel()
    }
    
        //UILabelを作成
    private func setupTextLabel() {
        textLabel = UILabel(frame: CGRect(x: 0, y: 0 , width: self.frame.width, height: self.frame.height))
//        textLabel.font = UIFount(name: "HiraKakuProN-W3" , size: 12)
        textLabel.textAlignment = .center
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textLabel)
        
    }
}
