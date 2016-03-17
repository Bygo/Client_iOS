//
//  OrderVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 16/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class OrderVC: UIViewController, UITextFieldDelegate, SuccessDelegate {

    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var sendButton: UIBarButtonItem!
    @IBOutlet var promptLabel: UILabel!
    @IBOutlet var rentalDurationTextField: UITextField!
    @IBOutlet var rentalValueTextField: UITextField!
    @IBOutlet var rentalDurationLabel: UILabel!
    @IBOutlet var rentalValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        cancelButton.tintColor = .whiteColor()
        sendButton.tintColor = .whiteColor()
        
        view.backgroundColor = kCOLOR_THREE
        
        // Do any additional setup after loading the view.
        rentalValueTextField.userInteractionEnabled = false
        
        rentalDurationTextField.addTarget(self, action: "rentalDurationTextFieldDidChange:", forControlEvents: .EditingChanged)
        rentalDurationTextField.tintColor = kCOLOR_ONE
        rentalDurationTextField.text = ""
        sendButton.enabled = isDataValid()
        rentalDurationTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func isDataValid() -> Bool {
        guard let text = rentalDurationTextField.text else { return false }
        let data = NSString(string: text).integerValue
        return data > 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == rentalDurationTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                let duration = NSString(string: newString).integerValue
                return duration < 366
            }
        }
        return true
    }
    
    @IBAction func rentalDurationTextFieldDidChange(sender: AnyObject) {
        guard let text = rentalDurationTextField.text else {
            rentalValueTextField.text = "$5"
            sendButton.enabled = isDataValid()
            return
        }
        
        let duration = NSString(string: text).integerValue
        if duration < 1 {
            rentalValueTextField.text = "$5"
            sendButton.enabled = isDataValid()
            return
        }
        
        let deliveryRate = 5.0
        let rentalRate = 4.0
        let rentalValue = deliveryRate + (Double(duration)*rentalRate)
        rentalValueTextField.text = "$\(Int(rentalValue))"
        
        sendButton.enabled = isDataValid()
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        rentalDurationTextField.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        rentalDurationTextField.resignFirstResponder()
        performSegueWithIdentifier("SentSegue", sender: nil)
    }
    
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            rentalDurationTextField.resignFirstResponder()
        }
    }
    
    func doneButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SentSegue" {
            guard let destVC = segue.destinationViewController as? SuccessVC else { return }
            
            destVC.delegate = self
            destVC.titleString = "Order Sent!"
            destVC.detailString = "We'll notify you when we find an Acoustic Guitar to fill your order."
        }
    }
}
