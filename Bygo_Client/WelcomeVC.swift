//
//  WelcomeVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 25/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController, UIGestureRecognizerDelegate {

    var model:Model?
    var delegate:LoginDelegate?
    
    @IBOutlet var greenBackground: UIImageView!
    @IBOutlet var blueBackground: UIImageView!
    
    @IBOutlet var bygoLogoImageView: UIImageView!
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    
    var logoCenterPoint: CGPoint!
//    @IBOutlet var centerLogoHorizontalConstraint: NSLayoutConstraint!
//    @IBOutlet var centerLogoVerticalConstraint: NSLayoutConstraint!
    
    @IBOutlet var buttonsBottomOffset: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        cancelButton.setImage(UIImage(named: "Back")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        cancelButton.tintColor = .whiteColor()
        // cancelButton.hidden = true
        cancelButton.transform = CGAffineTransformMakeRotation(CGFloat((270.0*M_PI)/180.0));
        bygoLogoImageView.alpha = 0.0
        bygoLogoImageView.layer.shadowColor = UIColor.blackColor().CGColor
        bygoLogoImageView.layer.shadowOpacity = 0.5
        bygoLogoImageView.layer.shadowOffset = CGSizeMake(1.0, 1.0)
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "panGestureRecognized:")
        panGestureRecognizer.delegate = self
        panGestureRecognizer.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGestureRecognizer)
        
        signInButton.alpha      = 0.0
        registerButton.alpha    = 0.0
        buttonsBottomOffset.constant = -(8.0+55.0+8.0)
        view.layoutIfNeeded()
        
        logoCenterPoint = bygoLogoImageView.center
        view.bringSubviewToFront(bygoLogoImageView)
    }
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidAppear(animated: Bool) {
        buttonsBottomOffset.constant = 8.0
        UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.bygoLogoImageView.alpha    = 1.0
                self.signInButton.alpha     = 1.0
                self.registerButton.alpha   = 1.0
                self.view.layoutIfNeeded()
            }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        /*
        switch recognizer.state {
        case .Began, .Changed:
            let location = recognizer.locationInView(view)
            if bygoLogoImageView.frame.contains(location) {
                let translation = recognizer.translationInView(view)
                
                bygoLogoImageView.center = CGPointMake(bygoLogoImageView.center.x+(translation.x/2.0), bygoLogoImageView.center.y + (translation.y/2.0))
                recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                
                let centerPoint = bygoLogoImageView.center
                let xDist   = fabs(centerPoint.x - logoCenterPoint.x)
                let yDist   = fabs(centerPoint.y - logoCenterPoint.y)
                let dist    = sqrt((xDist*xDist) + (yDist*yDist))
                
                let kDISTANCE_NEEDED_TO_DISMISS_VC:CGFloat = 100.0
                if dist > kDISTANCE_NEEDED_TO_DISMISS_VC {
                    navigationController?.dismissViewControllerAnimated(true, completion: nil)
                }
                
                let alpha = 1.0 - (dist/kDISTANCE_NEEDED_TO_DISMISS_VC)
                self.registerButton.alpha = alpha
                self.signInButton.alpha = alpha
            }
            
        case .Ended:
            UIView.animateWithDuration(0.5, animations: {
                self.bygoLogoImageView.center = self.logoCenterPoint
                self.registerButton.alpha = 1.0
                self.signInButton.alpha = 1.0
            })
            
        default:
            break
        }
        */
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func registerButtonTapped(sender: AnyObject) {

    }

    @IBAction func signInButtonTapped(sender: AnyObject) {

    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CreateAccountSegue" {
            guard let destVC = segue.destinationViewController as? CreateAccountVC else { return }
            destVC.model = model
            destVC.delegate = delegate
        } else if segue.identifier == "LoginSegue" {
            guard let destVC = segue.destinationViewController as? LoginVC else { return }
            destVC.model = model
            destVC.delegate = delegate
        }
    }
}

protocol LoginDelegate {
    func userDidLogin(shouldDismissLogin:Bool)
    func phoneNumberDidVerify(shouldDidmissLogin:Bool)
}
