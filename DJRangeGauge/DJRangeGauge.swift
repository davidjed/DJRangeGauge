//
//  DJRangeGauge.swift
//  DJRangeGauge
//
//  Created by David Jedeikin on 6/18/17.
//  Copyright © 2017 David Jedeikin. All rights reserved.
//

import UIKit

@IBDesignable class DJRangeGauge: UIView {
    
    static let DarkGreen: UIColor = UIColor(red: 76/255.0, green: 177/255.0, blue: 88/255.0, alpha: 1)
    static let LightGreen: UIColor = UIColor(red: 162/255.0, green: 235/255.0, blue: 176/255.0, alpha: 1)
    static let MediumGray: UIColor = UIColor(red: 211/255.0, green: 211/255.0, blue: 211/255.0, alpha: 1)

    @IBInspectable var needleRadius: CGFloat = 10
    override var center: CGPoint {
        get {
            return CGPoint(x: self.centerX, y: self.centerY)

        }
        set(value) {}
    }
    var needleCenter: CGPoint {
        get {
            return CGPoint(x: self.centerX, y: self.centerY - needleRadius)
            
        }
    }
    var centerX: CGFloat {
        return self.bounds.size.width/2
    }
    
    //centerY is really bottom center, the base of the gauge
    var centerY: CGFloat {
        return self.bounds.size.height
    }
    @IBInspectable var lowerNeedleColor: UIColor = DJRangeGauge.DarkGreen
    @IBInspectable var upperNeedleColor: UIColor = DJRangeGauge.LightGreen
    @IBInspectable var bgColor: UIColor = DJRangeGauge.MediumGray
    @IBInspectable var maxLevel: UInt = 10
    @IBInspectable var minLevel: UInt = 0
    var bgRadius: CGFloat = 0
    var scale: UInt {
        get {
            return self.maxLevel - self.minLevel
        }
    }
    var currentLowerRadian: CGFloat = 0.0
    var currentUpperRadian: CGFloat = 0.0
    
    //publicly visible levels
    var lowerNeedleLevel: NSInteger = 0
    var upperNeedleLevel: NSInteger = 0
    @IBInspectable weak var delegate: DJRangeGaugeDelegate?

    
    //MARK: - init
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    override func awakeFromNib() {
        self.setup()
    }
    
    func setup() {
        self.bgRadius = self.bounds.size.height
        
        self.isOpaque = false
        self.contentMode = UIViewContentMode.redraw
        
        self.currentLowerRadian = 0;
        self.addGestureRecognizer(UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(gesture:))))
    }
    
    //MARK: - drawing
    
    override func draw(_ rect: CGRect) {
        self.drawBackground()
        self.drawNeedle(self.currentLowerRadian, needleColor: self.lowerNeedleColor)
        self.drawNeedle(self.currentUpperRadian, needleColor: self.upperNeedleColor)
    }
    
    func drawBackground() {
        //multipliers are needed to convert from needle angle range space (which is smaller by the radius
        //of the needle, converted via sin & cos to radians on the circle) to background range space
        //(which is the full 180 degrees)
        //need this to make the "fill area" between the needles match the needles themselves
        let needleSin = (self.needleRadius * 2) / self.bounds.size.height
        let needleCos = cos(asin(needleSin))
        let needleATan = atan2(needleSin, needleCos)
        let lowerNeedleATanMultiplier = needleATan + ((self.currentLowerRadian * needleATan) / CGFloat(Double.pi * 0.75))
        let upperNeedleATanMultiplier = needleATan + ((self.currentUpperRadian * needleATan) / CGFloat(Double.pi * 0.75))
        let lowerInsetRadians: CGFloat = needleATan - lowerNeedleATanMultiplier
        let upperInsetRadians: CGFloat = needleATan + upperNeedleATanMultiplier
        let starttime: CGFloat = CGFloat(Double.pi)
        let endtime: CGFloat = 2 * CGFloat(Double.pi)
        let bgStartRadian: CGFloat = self.currentLowerRadian + lowerInsetRadians
        let bgEndRadian: CGFloat = self.currentUpperRadian - upperInsetRadians
        
        let bgPath2: UIBezierPath = UIBezierPath()
        bgPath2.move(to: self.center)
        bgPath2.addArc(withCenter: self.center,
                       radius: self.bgRadius,
                       startAngle: starttime,
                       endAngle: endtime,
                       clockwise: true)
        self.lighterColor(forColor: self.bgColor).set()
        bgPath2.fill()
        
        //shaded area between needles
        //a bit of angle trickery to get it just right
        let bgPath: UIBezierPath = UIBezierPath()
        bgPath.move(to: self.center)
        bgPath.addArc(withCenter: self.center,
                      radius: self.bgRadius,
                      startAngle: bgStartRadian - CGFloat(Double.pi/2),
                      endAngle: bgEndRadian - CGFloat(Double.pi * 0.35),
                      clockwise: true)
        bgPath.addLine(to: self.center)
        self.bgColor.set()
        bgPath.fill()
        
        let bgPathInner: UIBezierPath = UIBezierPath()
        bgPathInner.move(to: self.center)
        
        let innerRadius: CGFloat = self.bgRadius - (self.bgRadius * 0.4)
        bgPathInner.addArc(withCenter: self.center, radius: innerRadius, startAngle: starttime, endAngle: endtime, clockwise: true)
        bgPathInner.addLine(to: self.center)
        
        if self.backgroundColor != nil {
            self.backgroundColor?.set()
        }
        else {
            UIColor.white.set()
        }
        
        bgPathInner.stroke()
        bgPathInner.fill()
    }

    func lighterColor(forColor c: UIColor) -> UIColor {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        c.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return UIColor(red: min(1.0, red + 0.1), green: min(1.0, green + 0.1), blue: min(1.0, blue + 0.1), alpha: alpha)
    }

    func drawNeedle(_ radian: CGFloat, needleColor: UIColor) {
        let distance = self.bgRadius - self.needleRadius
        let starttime: CGFloat = 0
        let endtime: CGFloat = CGFloat(Double.pi)
        let topSpace: CGFloat = (distance * 0.1)/6
        
        let topPoint: CGPoint = CGPoint(x: self.needleCenter.x, y: self.needleCenter.y - distance)
        let topPoint1: CGPoint = CGPoint(x: self.needleCenter.x - topSpace, y: self.needleCenter.y - distance + (distance * 0.1))
        let topPoint2: CGPoint = CGPoint(x: self.needleCenter.x + topSpace, y: self.needleCenter.y - distance + (distance * 0.1))
        let finishPoint: CGPoint = CGPoint(x: self.needleCenter.x + self.needleRadius, y: self.needleCenter.y)
        
        let needlePath: UIBezierPath = UIBezierPath()
        needlePath.move(to: self.needleCenter)
        let nextX: CGFloat = self.needleCenter.x + self.needleRadius * cos(starttime)
        let nextY: CGFloat = self.needleCenter.y + self.needleRadius * sin(starttime)
        let next: CGPoint = CGPoint(x: nextX, y: nextY)
        
        needlePath.addLine(to: next)
        needlePath.addArc(withCenter: self.needleCenter,
                          radius: self.needleRadius,
                          startAngle: starttime,
                          endAngle: endtime,
                          clockwise: true)
        needlePath.addLine(to: topPoint1)
        needlePath.addQuadCurve(to: topPoint2, controlPoint: topPoint)
        needlePath.addLine(to: finishPoint)
        
        var translate: CGAffineTransform = CGAffineTransform(translationX: -1 * (self.bounds.origin.x + self.needleCenter.x),
                                                             y: -1 * (self.bounds.origin.y + self.needleCenter.y))
        needlePath.apply(translate)
        
        let rotate: CGAffineTransform = CGAffineTransform(rotationAngle: radian)
        needlePath.apply(rotate)
        
        translate = CGAffineTransform(translationX: self.bounds.origin.x + self.needleCenter.x,
                                      y: self.bounds.origin.y + self.needleCenter.y)
        needlePath.apply(translate)
        
        needleColor.set()
        needlePath.fill()
    }

    func handlePan(gesture: UIPanGestureRecognizer) {
        let currentPosition = gesture.location(in: self)
        
        if gesture.state == UIGestureRecognizerState.changed {
            let newRadian = self.calculateRadian(pos: currentPosition)
            
            //adjust whichever radian is closer, which is the same as moving the closer
            //needle radian to the newRadian
            let lowerDistance = abs(newRadian - self.currentLowerRadian)
            let upperDistance = abs(newRadian - self.currentUpperRadian)
            
            //make sure this doesn't cause upper to be lower than lower
            if(lowerDistance < upperDistance && newRadian < self.currentUpperRadian) {
                self.currentLowerRadian = newRadian
            }
            else if newRadian > self.currentLowerRadian {
                self.currentUpperRadian = newRadian
            }
            
            
            self.setNeedsDisplay()
            self.updateCurrentLowerLevel()
            self.updateCurrentUpperLevel()
        }
    }
    
    func calculateRadian(pos: CGPoint) -> CGFloat {
        let tmpPoint: CGPoint = CGPoint(x: pos.x, y: self.center.y)
        
        //needle in center
        if pos.x == self.center.x {
            return 0
        }
        
        if pos.y > self.center.y {
            if pos.x < self.center.x {
                return self.currentLowerRadian
            }
            else {
                return self.currentUpperRadian
            }
        }
        
        // calculate distance between pos and center
        let p12: CGFloat = self.calculateDistance(from: pos, to: self.center)
        
        // calculate distance between pos and tmpPoint
        let p23: CGFloat = self.calculateDistance(from: pos, to: tmpPoint)

        // calculate distance between tmpPoint and center
        let p13: CGFloat = self.calculateDistance(from: tmpPoint, to: self.center)
        
        var result: CGFloat = CGFloat(Double.pi/2) - acos(((p12 * p12) + (p13 * p13) - (p23 * p23))/(2 * p12 * p13))
        
        if pos.x <= self.center.x {
            result = -result
        }
    
        if result > CGFloat(Double.pi/2) {
            return CGFloat(Double.pi/2)
        }
    
        if result < -CGFloat(Double.pi/2) {
            return -CGFloat(Double.pi/2)
        }

        return result
    }

    func calculateDistance(from p1: CGPoint, to p2: CGPoint) -> CGFloat {
        let dx: CGFloat = p2.x - p1.x
        let dy: CGFloat = p2.y - p1.y
        let distance: CGFloat = sqrt(dx*dx + dy*dy)
        return distance
    }
    
    //update of currentLevel in response to user pan
    func updateCurrentLowerLevel() {
        let oldLowerLevel = self.lowerNeedleLevel
        self.lowerNeedleLevel = self.updateCurrentLevel(currentRadian: self.currentLowerRadian)//level
        if self.lowerNeedleLevel != oldLowerLevel && self.delegate != nil {
            self.delegate!.rangeGauge(self, didChangeLowerLevel: self.lowerNeedleLevel)
        }
    }
    
    //update of currentLevel in response to user pan
    func updateCurrentUpperLevel() {
        let oldUpperLevel = self.upperNeedleLevel
        self.upperNeedleLevel = self.updateCurrentLevel(currentRadian: self.currentUpperRadian)//level
        if self.upperNeedleLevel != oldUpperLevel && self.delegate != nil {
            self.delegate!.rangeGauge(self, didChangeUpperLevel: self.upperNeedleLevel)
        }
    }
    
    //update of currentLevel in response to user pan
    func updateCurrentLevel(currentRadian: CGFloat) -> Int {
        var level: Int = -1
        
        let levelSection: CGFloat = CGFloat(Double.pi) / CGFloat(self.scale)
        var currentSection: CGFloat = -CGFloat(Double.pi/2)
        
        let localScale = self.scale
        for index: UInt in 1 ..< localScale + 1 {
            if currentRadian >= currentSection && currentRadian < (currentSection + levelSection) {
                level = Int(index)
                break
            }
            currentSection += levelSection;
        }
        
        if (currentRadian >= CGFloat(Double.pi/2)) {
            level = Int(self.scale + 1)
        }
        
        level = level + Int(self.minLevel - 1)
        
        return level
    }
    
    func setCurrentLowerLevel(_ level: Int) {
        if level >= Int(self.minLevel) && level <= Int(self.maxLevel) {
            self.lowerNeedleLevel = level
            self.currentLowerRadian = self.radianFromLevel(level)
            self.setNeedsDisplay()
        }
    }

    
    func setCurrentUpperLevel(_ level: Int) {
        if level >= Int(self.minLevel) && level <= Int(self.maxLevel) {
            self.upperNeedleLevel = level
            self.currentUpperRadian = self.radianFromLevel(level)
            self.setNeedsDisplay()
        }
    }
    
    func radianFromLevel(_ level: Int) -> CGFloat {
        let range = CGFloat(Double.pi)
        if (CGFloat(level) != CGFloat(self.scale/2)) {
            
            return (CGFloat(level) * range)/CGFloat(self.scale) - (range/2)
        }
        else {
            return 0.0
        }
    }
}

protocol DJRangeGaugeDelegate: class {
    func rangeGauge(_ gauge: DJRangeGauge, didChangeLowerLevel level: Int)
    func rangeGauge(_ gauge: DJRangeGauge, didChangeUpperLevel level: Int)
}
