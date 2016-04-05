//
//  MenuContainerVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MenuContainerVC: UIViewController, MenuDelegate {
    
    @IBOutlet var menuVC: MenuVC?
    @IBOutlet var menuContainer: UIView!
    @IBOutlet var backgroundTintView: UIView!
    @IBOutlet var menuLeadingSpace: NSLayoutConstraint!
    
    var delegate:MenuContainerDelegate?
    
    var model:Model? {
        didSet { menuVC?.model = model }
    }
    
    let MAX_MENU_ANIMATION_DURATION                     = 0.4
    let OPEN_MENU_LEADING_SPACE_TO_CONTAINER:CGFloat    = -UIScreen.mainScreen().bounds.width/3.0
    let CLOSED_MENU_LEADING_SPACE_TO_CONTAINER:CGFloat  = -UIScreen.mainScreen().bounds.width
    let OPEN_MENU_BLACK_TINT_VIEW_ALPHA:CGFloat         = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        menuLeadingSpace.constant   = -view.bounds.width
        backgroundTintView.alpha    = 0.0
        self.view.hidden            = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMenu() {
        self.view.hidden = false
        openMenuAnimationWithVelocity(-1.0)
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        
        guard let delegate = delegate else { return }
        
        if delegate.shouldMenuOpen() {
            
            self.view.hidden = false
            
            // Get data from the gesture recognizer
            let translation = recognizer.translationInView(view)
            let velocity = recognizer.velocityInView(view)
            
            if recognizer.state == UIGestureRecognizerState.Changed {
                
                // Move the menu horizontally with the user's finger while panning
                let targetLeadingSpaceToContainer = max(CLOSED_MENU_LEADING_SPACE_TO_CONTAINER, min(OPEN_MENU_LEADING_SPACE_TO_CONTAINER, menuLeadingSpace.constant + translation.x))
                menuLeadingSpace.constant = targetLeadingSpaceToContainer
                
                // Tint the background UI
                let targetBlackTintViewAlpha = ((CLOSED_MENU_LEADING_SPACE_TO_CONTAINER - targetLeadingSpaceToContainer) / (CLOSED_MENU_LEADING_SPACE_TO_CONTAINER - OPEN_MENU_LEADING_SPACE_TO_CONTAINER)) * OPEN_MENU_BLACK_TINT_VIEW_ALPHA
                backgroundTintView.alpha = targetBlackTintViewAlpha
                
            } else if recognizer.state == UIGestureRecognizerState.Ended {
                
                // Once the pan has ended, animate the menu fully open or close
                if velocity.x >= 0 {
                    
                    // If the user's finger was moving open when the pan stopped, animate open the menu
                    openMenuAnimationWithVelocity(velocity.x)
                    
                } else {
                    
                    // If the user's finger was moving close when the pan stopped, animate close the menu
                    closeMenuAnimationWithVelocity(velocity.x)
                }
            }
            
            // Reset the recognizer's relative translation
            recognizer.setTranslation(CGPointZero, inView: self.view)
        }
    }
    
    private func openMenuAnimationWithVelocity(velocity:CGFloat) {
        
        // Bring the menu to the front of the view hierarchy
        view.layoutIfNeeded()
        
        // Calculate the animation duration
        var animationDuration = min(MAX_MENU_ANIMATION_DURATION, Double((OPEN_MENU_LEADING_SPACE_TO_CONTAINER - menuLeadingSpace.constant)/velocity))
        if velocity <= 0.0 {
            animationDuration = MAX_MENU_ANIMATION_DURATION
        }
        
        // Run the animation
        self.menuLeadingSpace.constant = self.OPEN_MENU_LEADING_SPACE_TO_CONTAINER
        UIView.animateWithDuration(animationDuration,
            animations: {
                self.view.layoutIfNeeded()
                self.backgroundTintView.alpha = self.OPEN_MENU_BLACK_TINT_VIEW_ALPHA
            }, completion: { (complete:Bool) -> Void in
                if complete {
                    self.view.setNeedsLayout()
                }
        })
    }
    
    // Animate close the side menu with a given velocity
    private func closeMenuAnimationWithVelocity(velocity:CGFloat) {
        view.layoutIfNeeded()
        
        // Calculate the animation duration
        var animationDuration = min(MAX_MENU_ANIMATION_DURATION, Double((CLOSED_MENU_LEADING_SPACE_TO_CONTAINER - menuLeadingSpace.constant)/velocity))
        if velocity == 0.0 {
            animationDuration = MAX_MENU_ANIMATION_DURATION
        }
        
        // Run the animation
        menuLeadingSpace.constant = CLOSED_MENU_LEADING_SPACE_TO_CONTAINER
        UIView.animateWithDuration(animationDuration,
            animations: {
                self.setNeedsStatusBarAppearanceUpdate()
                self.view.layoutIfNeeded()
                self.backgroundTintView.alpha = 0.0
            }, completion: { (complete:Bool) -> Void in
                if complete {
                    self.view.hidden = true
                    self.view.setNeedsLayout()
                }
        })
    }
    
    
    func userDidLogin() {
        menuVC?.userDidLogin()
    }
    
    func userDidLogout() {
        menuVC?.userDidLogout()
    }
    
    
    @IBAction func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        closeMenuAnimationWithVelocity(0.0)
    }
    
    // MARK: - MenuDelegate
    func didSelectMenuOption(option: MenuOptions) {
        closeMenuAnimationWithVelocity(0.0)
        delegate?.didSelectMenuOption(option)
    }
    
    func shouldMenuOpen() -> Bool {
        guard let delegate = delegate else { return false }
        return delegate.shouldMenuOpen()
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EmbedSideBarMenu" {
            guard let destVC    = segue.destinationViewController as? MenuVC else { return }
            menuVC              = destVC
            destVC.delegate     = self
            destVC.model        = model
        }
    }
}


protocol MenuContainerDelegate  {
    func didSelectMenuOption(option:MenuOptions)
    func shouldMenuOpen() -> Bool
}
