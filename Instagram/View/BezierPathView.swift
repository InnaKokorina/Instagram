//
//  BezierPathView.swift
//  Instagram
//
//  Created by Inna Kokorina on 30.03.2022.
//

import UIKit

class BezierPathView: UIView {

    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    func getHearts()  {
        path = UIBezierPath()
        path.move(to: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height))
        path.addCurve(to: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/4), controlPoint1: CGPoint(x: 0.0, y: self.frame.size.height/1.3), controlPoint2: CGPoint(x: 0.0, y: 0.0 - self.frame.size.height/4))
        path.addCurve(to: CGPoint(x: self.frame.size.width/2, y: self.frame.size.height), controlPoint1: CGPoint(x: self.frame.size.width, y: 0.0 - self.frame.size.height/4), controlPoint2: CGPoint(x: self.frame.size.width, y: self.frame.size.height/1.3))
        path.close()
    }
    
    override func draw(_ rect: CGRect) {
        getHearts()
        UIColor.systemPink.setFill()
            path.fill()
    }
}
