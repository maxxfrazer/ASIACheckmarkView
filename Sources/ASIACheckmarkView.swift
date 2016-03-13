//
//  ASIACheckmarkView.swift
//  ASIACheckmarkView
//
//  Created by Andrzej Michnia on 13.03.2016.
//  Copyright © 2016 Andrzej Michnia Usługi Programistyczne. All rights reserved.
//

import UIKit

@IBDesignable
class ASIACheckmarkView: UIButton {
    
    // MARK: - Inspectable Configuration
    @IBInspectable var lineColorForTrue : UIColor = UIColor.greenColor()
    @IBInspectable var lineColorForFalse : UIColor = UIColor.redColor()
    @IBInspectable var lineWidth : CGFloat = 1
    /// CHeckmark fill, where 0 is no checkmark, and 1 is checkmark connected with surrounding circle
    @IBInspectable var checkmarkFill : CGFloat = 0.8
    /// Fill of rect for false value - 0 means no rect, 1 means cross out of circle bounds
    @IBInspectable var crossFill : CGFloat = 0.4
    /// Fill of the whole button rect - if 1, will try to cover whole area (cropped to center square).
    @IBInspectable var rectFill : CGFloat = 0.5
    
    @IBInspectable var isGood : Bool = true
    
    /// Determines if animation should pause and wait on "spinning" state
    @IBInspectable var isSpinning : Bool = false
    
    /// How much circle percentage should spinner take in <0:1>
    @IBInspectable var spinnerPercentage : CGFloat = 0.25
    
    @IBInspectable var animationTotalTime : NSTimeInterval = 0.5
    @IBInspectable var spinningFullDuration : CFTimeInterval = 0.8
    
    // MARK: - Public properties
    var boolValue : Bool { return self.isGood }
    var isAnimating : Bool { return self.animating }
    
    typealias ASIACompletion = ()->()
    
    // MARK: - Private properties
    var endAnimationCLosure : ASIACompletion?
    
    private var checkmarkGoodLayer : CAShapeLayer?
    private var checkmarkBadLayers = [CAShapeLayer]()
    private var checkmarkCircleLayer : CAShapeLayer?
    
    private var animating : Bool = false
    private let checkmarkEnd : CGFloat = 0.265
    private let startAngle : CGFloat = CGFloat(-M_PI_2)/CGFloat(2)
    
    private var animationFirstStep : NSTimeInterval {
        return self.animationTotalTime * NSTimeInterval(self.checkmarkEnd)
    }
    private var animationSeccondStep : NSTimeInterval {
        return self.animationTotalTime - self.animationFirstStep
    }
    
    // MARK: - Action
    
    /**
    Changes desired state (boolValue) to given state. If checkmark is not spinning - animates to spinner, and then to final state (only if state changed). If you set isSpinning, after calling this method, checkmark will wait on spinning state, until you set isSpinning to false.
    
    - parameter value:      New state
    - parameter completion: Called after whole animation is finished - new state is determined
    */
    func animateTo(value: Bool, withCompletion completion:ASIACompletion? = nil){
        animateMarkGood(value, completion: completion)
    }
    
    private func animateMarkGood(good: Bool, completion:ASIACompletion? = nil) {
        let oldValue = self.isGood
        self.isGood = good
        
        if oldValue && !self.isGood && !self.isSpinning && !self.animating{
            self.animating = true
            self.endAnimationCLosure = {
                self.animating = false
                completion?()
            }
            self.animateGoodIntoSpinner(){
                self.startSpinning()
            }
        }
        else if !oldValue && self.isGood && !self.isSpinning && !self.animating{
            self.animating = true
            self.endAnimationCLosure = {
                self.animating = false
                completion?()
            }
            self.animateBadIntoSpinner(){
                self.startSpinning()
            }
        }
    }
    
    // MARK: - Animations
    
    private func animateGoodIntoSpinner(completion: ASIACompletion?) {
        self.checkmarkGoodLayer?.strokeStart = 1
        self.checkmarkGoodLayer?.strokeEnd = 1
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.animateCircleIntoSpinner(self.animationSeccondStep, completion: completion)
        }
        
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = self.animationFirstStep
        animation.timingFunction = CAMediaTimingFunction(name: "easeIn")
        
        let animation2 = CABasicAnimation(keyPath: "strokeEnd")
        animation2.fromValue = self.checkmarkFill
        animation2.toValue = 1
        animation2.duration = self.animationFirstStep * 0.5
        animation2.timingFunction = CAMediaTimingFunction(name: "easeIn")
        
        self.checkmarkGoodLayer?.addAnimation(animation, forKey: animation.keyPath)
        self.checkmarkGoodLayer?.addAnimation(animation2, forKey: animation2.keyPath)
        
        CATransaction.commit()
    }
    
    private func animateSpinnerIntoGood(completion: ASIACompletion?) {
        self.animateSpinnerIntoCircle(self.animationSeccondStep){
            self.checkmarkGoodLayer?.strokeStart = 0
            self.checkmarkGoodLayer?.strokeEnd = self.checkmarkFill
            
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                completion?()
                self.endAnimationCLosure = nil
            }
            
            let animation = CABasicAnimation(keyPath: "strokeStart")
            animation.fromValue = 1
            animation.toValue = 0
            animation.duration = self.animationFirstStep
            animation.timingFunction = CAMediaTimingFunction(name: "easeOut")
            
            let animation2 = CABasicAnimation(keyPath: "strokeEnd")
            animation2.fromValue = 1
            animation2.toValue = self.checkmarkFill
            animation2.duration = self.animationFirstStep
            animation2.timingFunction = CAMediaTimingFunction(name: "easeOut")
            
            self.checkmarkGoodLayer?.addAnimation(animation, forKey: animation.keyPath)
            self.checkmarkGoodLayer?.addAnimation(animation2, forKey: animation2.keyPath)
            
            CATransaction.commit()
        }
    }
    
    private func animateCircleIntoSpinner(duration: NSTimeInterval, completion: ASIACompletion?) {
        self.checkmarkCircleLayer?.strokeStart = 1 - self.spinnerPercentage
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            completion?()
        }
        
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = 0
        animation.toValue = 1 - self.spinnerPercentage
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: "linear")
        
        self.checkmarkCircleLayer?.addAnimation(animation, forKey: animation.keyPath)
        
        CATransaction.commit()
    }
    
    private func animateBadIntoSpinner(completion: ASIACompletion?) {
        // Setup
        for checkmark in self.checkmarkBadLayers {
            checkmark.strokeEnd = 0
        }
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            self.animateCircleIntoSpinner(self.animationSeccondStep, completion: completion)
        }
        
        for i in 0..<self.checkmarkBadLayers.count {
            self.animateCheckmarkBadLayer(i, from: 1, to: 0, duration: self.animationFirstStep)
        }
        
        CATransaction.commit()
    }
    
    private func animateSpinnerIntoBad(completion: ASIACompletion?) {
        self.animateSpinnerIntoCircle(self.animationSeccondStep){
            // Setup
            for checkmark in self.checkmarkBadLayers {
                checkmark.strokeEnd = 1
            }
            
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                completion?()
                self.endAnimationCLosure = nil
            }
            
            for i in 0..<self.checkmarkBadLayers.count {
                self.animateCheckmarkBadLayer(i, from: 0, to: 1, duration: self.animationFirstStep)
            }
            
            CATransaction.commit()
        }
    }
    
    private func startSpinning(){
        if self.isSpinning {
            CATransaction.begin()
            CATransaction.setCompletionBlock { () -> Void in
                self.startSpinning()
            }
            
            let animation = CABasicAnimation(keyPath: "transform.rotation.z")
            animation.toValue = 2 * M_PI
            animation.duration = self.spinningFullDuration
            animation.cumulative = true
            animation.removedOnCompletion = false
            animation.timingFunction = CAMediaTimingFunction(name: "linear")
            
            self.checkmarkCircleLayer?.addAnimation(animation, forKey: animation.keyPath)
            
            CATransaction.commit()
        }
        else {
            self.endSpinning()
        }
    }
    
    private func endSpinning(){
        if self.isGood {
            self.animateSpinnerIntoGood(self.endAnimationCLosure)
        }
        else {
            self.animateSpinnerIntoBad(self.endAnimationCLosure)
        }
    }
    
    private func animateSpinnerIntoCircle(duration: NSTimeInterval, completion: ASIACompletion?) {
        
        self.checkmarkCircleLayer?.strokeStart = 0
        
        let fromColor = self.checkmarkCircleLayer?.strokeColor
        let toColor = self.isGood ? self.lineColorForTrue.CGColor : self.lineColorForFalse.CGColor
        self.checkmarkCircleLayer?.strokeColor = toColor
        
        CATransaction.begin()
        CATransaction.setCompletionBlock { () -> Void in
            completion?()
        }
        
        let rotation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = 2 * M_PI
        rotation.duration = duration
        rotation.cumulative = true
        rotation.removedOnCompletion = false
        rotation.timingFunction = CAMediaTimingFunction(name: "linear")
        
        let animation = CABasicAnimation(keyPath: "strokeStart")
        animation.fromValue = 1 - self.spinnerPercentage
        animation.toValue = 0
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: "linear")
        
        let color = CABasicAnimation(keyPath: "strokeColor")
        color.fromValue = fromColor
        color.toValue = toColor
        color.duration = duration
        color.timingFunction = CAMediaTimingFunction(name: "linear")
        
        self.checkmarkCircleLayer?.addAnimation(animation, forKey: animation.keyPath)
        self.checkmarkCircleLayer?.addAnimation(rotation, forKey: rotation.keyPath)
        self.checkmarkCircleLayer?.addAnimation(color, forKey: color.keyPath)
        
        CATransaction.commit()
    }
    
    private func animateCheckmarkBadLayer(index: Int, from: CGFloat, to: CGFloat, duration: NSTimeInterval) {
        let anim = CABasicAnimation(keyPath: "strokeEnd")
        anim.fromValue = from
        anim.toValue = to
        anim.duration = duration
        self.checkmarkBadLayers[index].addAnimation(anim, forKey: anim.keyPath)
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.addLayersIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addLayersIfNeeded()
    }
    
    // MARK: - Configuration
    
    private func addMarkGoodShapeLayer() {
        self.checkmarkGoodLayer?.removeFromSuperlayer()
        self.checkmarkGoodLayer = CAShapeLayer()
        self.checkmarkGoodLayer?.frame = self.bounds
        let pathFrame = CGRectInset(self.bounds, self.lineWidth, self.lineWidth)
        
        let radius = (min(pathFrame.width,pathFrame.height) / 2) * self.rectFill
        
        let path = UIBezierPath()
        var startPoint = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        startPoint.x -= radius / 1.5
        var midPoint = CGPoint(x: self.bounds.width/2 - radius/6, y: self.bounds.height/2)
        midPoint.y += radius / 2
        path.moveToPoint(startPoint)
        path.addLineToPoint(midPoint)
        
        let halCircle : CGFloat = CGFloat(0)
        
        path.addArcWithCenter(CGPoint(x: self.bounds.width/2, y: self.bounds.height/2), radius: radius, startAngle: startAngle, endAngle: startAngle + halCircle, clockwise: true)
        
        self.checkmarkGoodLayer?.path = path.CGPath
        self.checkmarkGoodLayer?.lineWidth = self.lineWidth
        self.checkmarkGoodLayer?.strokeColor = self.lineColorForTrue.CGColor
        self.checkmarkGoodLayer?.backgroundColor = UIColor.clearColor().CGColor
        self.checkmarkGoodLayer?.fillColor = UIColor.clearColor().CGColor
        self.checkmarkGoodLayer?.lineCap = kCALineCapRound
        self.checkmarkGoodLayer?.strokeEnd = self.checkmarkFill
        
        self.layer.addSublayer(self.checkmarkGoodLayer!)
    }
    
    private func addCheckmarkBadLayer(x x: CGFloat, y: CGFloat) {
        
        let badShapeLayer = CAShapeLayer()
        badShapeLayer.frame = self.bounds
        let pathFrame = CGRectInset(self.bounds, self.lineWidth, self.lineWidth)
        
        let radius = (min(pathFrame.width,pathFrame.height) / 2 ) * self.crossFill * self.rectFill
        
        let path = UIBezierPath()
        
        let startPoint = CGPoint(x: self.bounds.width/2, y: self.bounds.height/2)
        path.moveToPoint(startPoint)
        path.addLineToPoint(CGPoint(x: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2).x + radius * x, y: CGPoint(x: self.bounds.width/2, y: self.bounds.height/2).y + radius * y))
        
        badShapeLayer.path = path.CGPath
        badShapeLayer.lineWidth = self.lineWidth
        badShapeLayer.strokeColor = self.lineColorForFalse.CGColor
        badShapeLayer.backgroundColor = UIColor.clearColor().CGColor
        badShapeLayer.fillColor = UIColor.clearColor().CGColor
        
        badShapeLayer.strokeStart = 0
        badShapeLayer.strokeEnd = 1
        badShapeLayer.lineCap = kCALineCapRound
        
        self.layer.addSublayer(badShapeLayer)
        self.checkmarkBadLayers.append(badShapeLayer)
    }
    
    private func addCheckmarkCircleLayer() {
        
        self.checkmarkCircleLayer?.removeFromSuperlayer()
        self.checkmarkCircleLayer = CAShapeLayer()
        self.checkmarkCircleLayer?.frame = self.bounds
        let pathFrame = CGRectInset(self.bounds, self.lineWidth, self.lineWidth)
        
        let radius = min(pathFrame.width,pathFrame.height) / 2 * self.rectFill
        let path = UIBezierPath()
        
        let halCircle : CGFloat = CGFloat(M_PI)
        path.addArcWithCenter(CGPoint(x: self.bounds.width/2, y: self.bounds.height/2), radius: radius, startAngle: startAngle, endAngle: startAngle + halCircle, clockwise: true)
        path.addArcWithCenter(CGPoint(x: self.bounds.width/2, y: self.bounds.height/2), radius: radius, startAngle: startAngle + halCircle, endAngle: startAngle, clockwise: true)
        
        self.checkmarkCircleLayer?.path = path.CGPath
        self.checkmarkCircleLayer?.lineWidth = self.lineWidth
        self.checkmarkCircleLayer?.strokeColor = self.lineColorForFalse.CGColor
        self.checkmarkCircleLayer?.backgroundColor = UIColor.clearColor().CGColor
        self.checkmarkCircleLayer?.fillColor = UIColor.clearColor().CGColor
        self.checkmarkCircleLayer?.lineCap = kCALineCapRound
        
        self.layer.addSublayer(self.checkmarkCircleLayer!)
    }
    
    private func addLayersIfNeeded(){
        if self.checkmarkGoodLayer == nil {
            self.addMarkGoodShapeLayer()
            self.checkmarkGoodLayer?.strokeStart = self.isGood ? 0 : 1
        }
        if self.checkmarkBadLayers.isEmpty {
            self.addCheckmarkBadLayer(x: -1,y: -1)
            self.addCheckmarkBadLayer(x: -1,y:  1)
            self.addCheckmarkBadLayer(x:  1,y: -1)
            self.addCheckmarkBadLayer(x:  1,y:  1)
            
            for layer in self.checkmarkBadLayers {
                layer.strokeEnd = self.isGood ? 0 : 1
            }
        }
        if self.checkmarkCircleLayer == nil {
            self.addCheckmarkCircleLayer()
            self.checkmarkCircleLayer?.strokeColor = self.isGood ? self.lineColorForTrue.CGColor : self.lineColorForFalse.CGColor
        }
    }
    
    // MARK: - Custom drawing
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.addLayersIfNeeded()
    }
    
}
