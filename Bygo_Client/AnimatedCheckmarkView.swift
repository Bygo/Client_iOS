//
//  AnimatedCheckmarkView.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 15/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class AnimatedCheckmarkView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet var circleView:UIView! = UIView()
    @IBOutlet var partialCheck1:UIView! = UIView()
    @IBOutlet var partialCheck2:UIView! = UIView()
    
    private var partialCheck1Center: CGPoint = CGPointZero
    private var partialCheck2Center: CGPoint = CGPointZero
    private var radius: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    

    func configureAnimation() {
        clipsToBounds = true
        backgroundColor = .clearColor()
        
        layoutIfNeeded()
        
        addSubview(circleView)
        
        circleView.frame = CGRectMake(0, (bounds.height/2.0)-(bounds.width/2.0), bounds.width, bounds.width)
        circleView.layer.cornerRadius = bounds.width/2.0
        circleView.backgroundColor = kCOLOR_ONE // kCOLOR_SIX
        partialCheck1.backgroundColor = kCOLOR_THREE
        partialCheck2.backgroundColor = kCOLOR_THREE
        
        let sine45 = sin(45.0/180.0 * CGFloat(M_PI))
        let r:CGFloat = bounds.width/2.0
        radius = r
        let partialCheck1Length = sine45 * (r/2.0)
        let partialCheck2Length = sine45 * (1.5*r)
        
        let checkLineWidth:CGFloat = 16.0
        
        let partialCheck2Height = partialCheck2Length * sine45
        
        let meetingPointX = (2.2*r)/3.0
        let meetingPointY = (bounds.height/1.9)+(partialCheck2Height/2.0)
        
        let t = (checkLineWidth/2.0)*sine45
        let t1 = (partialCheck1Length/2.0)*sine45
        let t2 = (partialCheck2Length/2.0)*sine45
        
        let partialCheck1CenterX = (meetingPointX + t) - t1
        let partialCheck1CenterY = (meetingPointY - t) - t1
        
        let partialCheck2CenterX = (meetingPointX - t) + t2
        let partialCheck2CenterY = (meetingPointY - t) - t2

        partialCheck1Center = CGPointMake(partialCheck1CenterX, partialCheck1CenterY)
        partialCheck2Center = CGPointMake(partialCheck2CenterX, partialCheck2CenterY)
        
        partialCheck1.frame = CGRectMake(50.0, 50.0, partialCheck1Length, checkLineWidth)
        partialCheck1.center = CGPointMake(-30, 60)
        partialCheck2.frame = CGRectMake(50.0, bounds.height-30.0, partialCheck2Length, checkLineWidth)
        partialCheck2.center = CGPointMake(0, bounds.height+40.0)
        
        let radians1 = 45.0 / 180.0 * CGFloat(M_PI)
        let rotation1 = CGAffineTransformRotate(partialCheck1.transform, radians1)
        partialCheck1.transform = rotation1
        
        let radians2 = -45.0 / 180.0 * CGFloat(M_PI)
        let rotation2 = CGAffineTransformRotate(partialCheck2.transform, radians2)
        partialCheck2.transform = rotation2
        
        addSubview(partialCheck1)
        addSubview(partialCheck2)
        
        let initialCenter1 = CGPointMake(partialCheck1CenterX-(1.25*r), partialCheck1CenterY-(1.25*r))
        let initialCenter2 = CGPointMake(partialCheck2CenterX-(1.25*r), partialCheck2CenterY+(1.25*r))
        
        self.partialCheck1.center = initialCenter1
        self.partialCheck2.center = initialCenter2
    }
    
    func beginAnimation(completion:()->()) {
        UIView.animateWithDuration(0.35, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.partialCheck1.center = self.partialCheck1Center
            self.partialCheck2.center = self.partialCheck2Center

            }, completion: {
                (success:Bool) in
                if success {
                    self.clipsToBounds = false
                    let r = self.radius
                    
                    UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        self.circleView.frame = CGRectMake(-2.0*r, -2.0*r, 6.0*r, 6.0*r)
                        }, completion: {
                            (success:Bool) in
                            if success {
                                completion()
                            }
                    })
                }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
