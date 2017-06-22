//
//  ViewController.swift
//  DJRangeGauge
//
//  Created by David Jedeikin on 6/18/17.
//  Copyright © 2017 David Jedeikin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DJRangeGaugeDelegate {
    
    @IBOutlet var rangeGauge: DJRangeGauge!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.rangeGauge.needleRadius = 10.0
        self.rangeGauge.maxlevel = 10
        self.rangeGauge.minlevel = 1
        self.rangeGauge.setCurrentLowerLevel(2)
        self.rangeGauge.setCurrentUpperLevel(7)
        self.rangeGauge.layer.borderWidth = 1.0
        self.rangeGauge.layer.borderColor = UIColor.blue.cgColor
        self.rangeGauge.delegate = self
    }

    func rangeGauge(_ gauge: DJRangeGauge, didChangeLowerLevel level: Int) {
        print("Current Level is \(level)")
    }
    
    func rangeGauge(_ gauge: DJRangeGauge, didChangeUpperLevel level: Int) {
        print("Current Level is \(level)")
    }
}

