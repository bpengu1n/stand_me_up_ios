//
//  RingsControl.swift
//  StandMeUp_dev2
//
//  Created by Benjamin Yunker on 10/29/17.
//  Copyright © 2017 Benjamin Yunker. All rights reserved.
//

import UIKit
import HealthKitUI

class RingsControl: UIStackView {
    //MARK: Properties
    private var ringButtons = [UIButton]()
    public var rings = [HKActivityRingView]()
    
    
    
    //MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRings()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupRings()
    }

    //MARK: Private Methods
    private func setupRings() {
        for _ in (0..<7) {
            let button = UIButton()
            button.backgroundColor = UIColor.black
            
            
            button.translatesAutoresizingMaskIntoConstraints = false
            
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            
            let ringView = HKActivityRingView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            
            button.addSubview(ringView)
            
            addArrangedSubview(button)
            
            ringButtons.append(button)
            rings.append(ringView)
        }

    }
}
