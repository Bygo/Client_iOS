//
//  SuccessVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 15/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class SuccessVC: UIViewController {

    @IBOutlet var titleLabel:UILabel!
    @IBOutlet var detailLabel:UILabel!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var checkmarkView:AnimatedCheckmarkView!
    
    var delegate:SuccessDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = kCOLOR_THREE
        UIApplication.sharedApplication().statusBarHidden = true
        
        titleLabel.textColor = kCOLOR_THREE
        detailLabel.textColor = kCOLOR_THREE
        titleLabel.alpha = 0.0
        detailLabel.alpha = 0.0
        
        doneButton.backgroundColor = kCOLOR_THREE
        doneButton.setTitleColor(kCOLOR_SIX, forState: .Normal)
        doneButton.alpha = 0.0

        checkmarkView.layoutIfNeeded()
        checkmarkView.configureAnimation()
        
        view.bringSubviewToFront(titleLabel)
        view.bringSubviewToFront(detailLabel)
    }
    
    override func viewDidAppear(animated: Bool) {
        checkmarkView.beginAnimation({
            UIView.animateWithDuration(1.0, animations: {
                self.titleLabel.alpha = 1.0
                self.detailLabel.alpha = 1.0
                self.doneButton.alpha = 1.0
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(sender:AnyObject) {
        self.delegate?.doneButtonTapped()
//        print(parentViewController)
//        .parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol SuccessDelegate {
    func doneButtonTapped()
}
