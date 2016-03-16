//
//  NewListingTypeVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 15/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingTypeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SuccessDelegate, UITextFieldDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var navBar: UIView!
    @IBOutlet var titleLabel: UILabel!
    
    var model:Model?
    var image:UIImage?
    var parentVC:UIViewController?
    var searchBar:SearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        navBar.backgroundColor = kCOLOR_ONE
        titleLabel.textColor = .whiteColor()
        cancelButton.setTitleColor(.whiteColor(), forState: .Normal)
        
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        
        view.backgroundColor = kCOLOR_THREE
        collectionView?.backgroundColor = .clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
        searchBar?.becomeFirstResponder()
    }

    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default: return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SearchBarCell", forIndexPath: indexPath) as? SearchBarCollectionViewCell else { return UICollectionViewCell() }
            cell.questionLabel.text = "What are you listing?"
            searchBar = cell.searchBar
            searchBar?.delegate = self
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemTypeCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
            cell.nameLabel.text = "Sport Skis"
            cell.backgroundColor = .whiteColor()
            return cell
        default:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemTypeCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
            cell.nameLabel.text = ""
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 1 {
            // TODO: If no delivery address exists: ask for it
            performSegueWithIdentifier("SuccessSegue", sender: nil)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchBar?.resignFirstResponder()
        return true
    }
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        searchBar?.resignFirstResponder()
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SuccessSegue" {
            guard let destVC = segue.destinationViewController as? SuccessVC else { return }
            destVC.delegate = self
//            guard let destVC = segue.destinationViewController as? SuccessVC else { return }
//            destVC.titleLabel.text = "Success! Success! Your listing was created."
        } else if segue.identifier == "HomeAddressSegue" {
            
        }
    }
    
    // MARK: - Success Delegate 
    func doneButtonTapped() {
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - UICollectionViewDelegate
extension NewListingTypeVC : UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        case 0: return CGSizeMake(view.bounds.width-16.0, 120.0)
        case 1: return CGSizeMake((view.bounds.width/2.0)-13.0, (view.bounds.width/2.0)+24.0)
        default: return CGSizeMake(0, 0)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch section {
        case 0: return UIEdgeInsetsMake(0.0, 8.0, 0.0, 8.0)
        case 1: return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        default: return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        }
    }
}