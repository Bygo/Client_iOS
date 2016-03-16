//
//  NewListingRentalRatesVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingRentalRatesVC: UIViewController {
    
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var headerView: UIView!
    
    @IBOutlet var dailyRateLabel:UILabel!
    @IBOutlet var weeklyRateLabel:UILabel!
    @IBOutlet var semesterRateLabel:UILabel!
    
    @IBOutlet var dailyRateCurrencyLabel:UILabel!
    @IBOutlet var weeklyRateCurrencyLabel:UILabel!
    @IBOutlet var semesterRateCurrencyLabel:UILabel!
    
    @IBOutlet var dailyRateTextField:UITextField!
    @IBOutlet var weeklyRateTextField:UITextField!
    @IBOutlet var semesterRateTextField:UITextField!
    
    @IBOutlet var dailyRateView:UIView!
    @IBOutlet var weeklyRateView:UIView!
    @IBOutlet var semesterRateView:UIView!
    
    @IBOutlet var nextButton: UIBarButtonItem!
    @IBOutlet var resetButton:UIButton!
    
    var model:Model?
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    var listingImages:[UIImage] = []
    var listingValue:Double?
    
    var suggestedDailyRate:Double?
    var suggestedWeeklyRate:Double?
    var suggestedSemesterRate:Double?
    
    var kORIGINAL_OFFSET:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        kORIGINAL_OFFSET = self.view.frame.origin.y
        
        // TODO: Send request to server to get the suggested rates for the itemValue
        
        instructionLabel.text = "6. Feel free to adjust any of the rental rates below."
        detailLabel.text = "The suggested rental rates are calculated to get you earning the most amount of cash as fast as possible."
        
        dailyRateView.backgroundColor = .whiteColor()
        weeklyRateView.backgroundColor = .whiteColor()
        semesterRateView.backgroundColor = .whiteColor()
        view.backgroundColor = kCOLOR_THREE
        
        suggestedDailyRate = 12.50
        suggestedWeeklyRate = 35.00
        suggestedSemesterRate = 2.40
        
        dailyRateTextField.text         = String(format: "%.2f", suggestedDailyRate!)
        weeklyRateTextField.text        = String(format: "%.2f", suggestedWeeklyRate!)
        semesterRateTextField.text        = String(format: "%.2f", suggestedSemesterRate!)
        
        dailyRateTextField.placeholder  = String(format: "%.2f (suggested)", suggestedDailyRate!)
        weeklyRateTextField.placeholder = String(format: "%.2f (suggested)", suggestedWeeklyRate!)
        semesterRateTextField.placeholder = String(format: "%.2f (suggested)", suggestedSemesterRate!)
        
        resetButton.enabled = false
        nextButton.enabled = isDataValid()
        
        dailyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        weeklyRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        semesterRateTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
        resetButton.backgroundColor = kCOLOR_FIVE
        resetButton.alpha = 0.0
        resetButton.enabled = false
        
    }
    
    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func disableResetButtonIfNeeded() {
        if !areRatesTheSuggestedRates() {
            resetButton.enabled = true
            UIView.animateWithDuration(0.25, animations: {
                self.resetButton.alpha = 1.0
            })
        } else {
            resetButton.enabled = false
            UIView.animateWithDuration(0.25, animations: {
                self.resetButton.alpha = 0.0
            })
        }
    }
    
    // MARK: - Data
    func isDataValid() -> Bool {
        let isDailyRateValid    = dailyRateTextField.text?.characters.count > 0
        let isWeeklyRateValid   = weeklyRateTextField.text?.characters.count > 0
        let isSemesterRateValid   = semesterRateTextField.text?.characters.count > 0
        
        return isSemesterRateValid && isDailyRateValid && isWeeklyRateValid
    }
    
    func areRatesTheSuggestedRates() -> Bool {
        let dailyRate   = NSString(string: dailyRateTextField.text!).doubleValue
        let weeklyRate  = NSString(string: weeklyRateTextField.text!).doubleValue
        let semesterRate  = NSString(string: semesterRateTextField.text!).doubleValue
        
        let isDailyRateSuggested    = dailyRate == suggestedDailyRate
        let isWeeklyRateSuggested   = weeklyRate == suggestedWeeklyRate
        let isSemesterRateSuggested   = semesterRate == suggestedSemesterRate
        return isSemesterRateSuggested && isDailyRateSuggested && isWeeklyRateSuggested
    }
    
    // MARK: - Keyboard
    func keyboardWillShow(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let navBarHeight = navigationController?.navigationBar.bounds.height {
                let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
                self.view.frame.origin.y = (navBarHeight + statusBarHeight) - headerView.bounds.height
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let _ = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            if let navBarHeight = navigationController?.navigationBar.bounds.height {
                let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.height
                self.view.frame.origin.y = navBarHeight + statusBarHeight
            }
        }
    }
    
    
    // MARK: - TextField Delegate
    // MARK: - TextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if textField == dailyRateTextField || textField == weeklyRateTextField || textField == semesterRateTextField {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                
                let components = newString.componentsSeparatedByString(".")
                
                // If the user is adding an extra decimal point, don't allow the change
                if components.count > 2 {
                    return false
                }
                
                // If the user is trying to specify a monetary value with greater than one cent precision, don't allow their text to be entered
                if components.count == 2 {
                    let cents = components[1]
                    if cents.characters.count > 2 {
                        return false
                    }
                }
                
                // If the value will be greater than 1000, don't allow the user to enter in a value
                let v = NSString(string: newString).doubleValue
                if v > 1000 { return false }
            }
        }
        return true
    }

    
    func textFieldDidChange(sender:AnyObject) {
        nextButton.enabled = isDataValid()
        disableResetButtonIfNeeded()
    }
    
    
    // MARK: - UIActions
    @IBAction func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if abs(translation.y) > abs(translation.x) && translation.y > 0.0 {
            dailyRateTextField.resignFirstResponder()
            weeklyRateTextField.resignFirstResponder()
            semesterRateTextField.resignFirstResponder()
        }
    }
    
    @IBAction func nextButtonTapped(sender:AnyObject) {
        if isDataValid() {
            performSegueWithIdentifier("ShowGiveDescription", sender: nil)
        }
    }
    
    @IBAction func resetButtonTapped(sender:AnyObject) {
        guard let suggestedSemesterRate   = suggestedSemesterRate else { return }
        guard let suggestedDailyRate    = suggestedDailyRate else { return }
        guard let suggestedWeeklyRate   = suggestedWeeklyRate else { return }
        
        dailyRateTextField.text     = String(format: "%.2f", suggestedDailyRate)
        weeklyRateTextField.text    = String(format: "%.2f", suggestedWeeklyRate)
        semesterRateTextField.text    = String(format: "%.2f", suggestedSemesterRate)
        
        disableResetButtonIfNeeded()
    }
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowGiveDescription" {
            guard let destVC = segue.destinationViewController as? NewListingDescriptionVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
            destVC.listingCategory      = listingCategory
            destVC.listingImages        = listingImages
            destVC.listingValue         = listingValue
            destVC.listingHourlyRate    = Double(NSString(string: semesterRateTextField.text!).floatValue)
            destVC.listingDailyRate     = Double(NSString(string: dailyRateTextField.text!).floatValue)
            destVC.listingWeeklyRate    = Double(NSString(string: weeklyRateTextField.text!).floatValue)
        }
    }
}
