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
    
    @IBOutlet var bygoLogoImageView: UIImageView!
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var cancelButton: UIBarButtonItem!
    
    var logoCenterPoint: CGPoint!
    
    @IBOutlet var buttonsBottomOffset: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
//        cancelButton.setImage(UIImage(named: "Back")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: .Normal)
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        cancelButton.tintColor = .whiteColor()
        
        registerButton.backgroundColor = kCOLOR_ONE
        registerButton.setTitleColor(.whiteColor(), forState: .Normal)
        signInButton.backgroundColor = .clearColor()
        signInButton.setTitleColor(kCOLOR_ONE, forState: .Normal)
        
        
        view.backgroundColor = kCOLOR_THREE
        
        // cancelButton.hidden = true
//        cancelButton.transform = CGAffineTransformMakeRotation(CGFloat((270.0*M_PI)/180.0));
        
        bygoLogoImageView.alpha = 0.0
        bygoLogoImageView.image = UIImage(named: "Bygo")?.imageWithRenderingMode(.AlwaysTemplate)
        bygoLogoImageView.tintColor = kCOLOR_ONE
        
//        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(WelcomeVC.panGestureRecognized(_:)))
//        panGestureRecognizer.delegate = self
//        panGestureRecognizer.maximumNumberOfTouches = 1
//        view.addGestureRecognizer(panGestureRecognizer)
//
        
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
        UIView.animateWithDuration(0.75, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
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

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
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
