//
//  LoadingScreen.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class LoadingScreen: UIView {

    @IBOutlet var loadingIcon: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let kLOADING_ICON_SIZE: CGFloat = 64.0
        alpha = 0.0
        backgroundColor = kCOLOR_THREE
        loadingIcon = UIImageView(frame: CGRectMake(0, 0, kLOADING_ICON_SIZE, kLOADING_ICON_SIZE))
        loadingIcon.center = center
        loadingIcon.center.y -= 32.0
        loadingIcon.image = UIImage(named: "loadingIcon")?.imageWithRenderingMode(.AlwaysTemplate)
        loadingIcon.tintColor = kCOLOR_ONE
        addSubview(loadingIcon)
    }
    
    func beginAnimation() {
        UIView.animateWithDuration(0.25, animations: {
            self.alpha = 1.0
            }, completion: {
                (complete:Bool) in
                if complete {
                    
                    /*
 
                     CABasicAnimation* rotationAnimation;
                     rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
                     rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
                     rotationAnimation.duration = duration;
                     rotationAnimation.cumulative = YES;
                     rotationAnimation.repeatCount = repeat;
                     
                     [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
                     
                    */
                    
                    let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                    rotationAnimation.toValue = M_PI * 2.0
                    rotationAnimation.duration = 1.5
                    rotationAnimation.cumulative = true
                    rotationAnimation.repeatCount = Float(Int.max)
                    self.loadingIcon.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
                    
                }
        })
    }
    
    func endAnimation() {
        UIView.animateWithDuration(0.25, animations: {
            self.alpha = 0.0
            }, completion: {
                (complete:Bool) in
                if complete {
                    self.removeFromSuperview()
                }
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}
