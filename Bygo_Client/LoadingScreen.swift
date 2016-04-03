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
    @IBOutlet var messageLabel: UILabel!
    
    init(frame: CGRect, message:String?) {
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
        
        let messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        messageLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        messageLabel.textColor = kCOLOR_ONE
        messageLabel.alpha = 0.75
        messageLabel.textAlignment = .Center
        messageLabel.text = message
        messageLabel.centerXAnchor.constraintEqualToAnchor(centerXAnchor).active = true
        messageLabel.leadingAnchor.constraintEqualToAnchor(leadingAnchor, constant: 24.0).active = true
        messageLabel.topAnchor.constraintEqualToAnchor(loadingIcon.bottomAnchor, constant: 24.0).active = true
        
        messageLabel.layoutIfNeeded()
    }
    
    func beginAnimation() {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = M_PI * 2.0
        rotationAnimation.duration = 1.5
        rotationAnimation.cumulative = true
        rotationAnimation.repeatCount = Float(Int.max)
        self.loadingIcon.layer.addAnimation(rotationAnimation, forKey: "rotationAnimation")
        
        UIView.animateWithDuration(0.25, animations: {
            self.alpha = 1.0
        }, completion: nil)
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
