//
//  NewListingTypeVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 15/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class NewListingTypeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, SuccessDelegate, UITextFieldDelegate, HomeAddressDelegate, LoginDelegate, ErrorMessageDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var navBar: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var searchBar:SearchBar!
    @IBOutlet var loginContainer:UINavigationController?
    
    var model:Model?
    var image:UIImage?
    var parentVC:UIViewController?
    
    
    private var targetIndexPath: NSIndexPath?
    private var layoutData: AnyObject? = nil
    
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
    
    // MARK: - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == searchBar {
            if let text = textField.text {
                let newString = (text as NSString).stringByReplacingCharactersInRange(range, withString: string)
                model?.discoveryServiceProvider.search(newString, completionHanlder: {
                    (data: AnyObject?) in
                    
                    self.layoutData = data
                    if self.layoutData != nil {
                        self.collectionView.reloadSections(NSIndexSet(index: 1))
                    }
                })
            }
            return true
        }
        return false
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchBar?.resignFirstResponder()
        return true
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        self.layoutData = []
        self.collectionView.reloadSections(NSIndexSet(index: 1))
        return true
    }
    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1:
            guard let layoutData = layoutData else { return 0 }
            return layoutData.count
        default: return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SearchBarCell", forIndexPath: indexPath) as? SearchBarCollectionViewCell else { return UICollectionViewCell() }
            cell.questionLabel.text = nil //"What are you listing?"
            searchBar = cell.searchBar
            searchBar?.placeholder = "What are you listing?"
            searchBar?.delegate = self
            return cell
            
        case 1:
            
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return UICollectionViewCell() }
            let data = layoutData[indexPath.row]
            guard let type = data["type"] as? Int else { return UICollectionViewCell() }
            switch type {
            case 1:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemTypeCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
                cell.backgroundColor = .whiteColor()
                cell.imageView.backgroundColor = .clearColor()
                cell.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                cell.imageView.clipsToBounds = true
                
                guard let typeID = data["id"] as? String else { return cell }
                guard let model = model else { return cell }
                model.itemTypeServiceProvider.fetchItemType(typeID, completionHandler: {
                    (success:Bool) in
                    
                    if success {
                        let realm = try! Realm()
                        let itemType = realm.objects(ItemType).filter("typeID == \"\(typeID)\"")[0]
                        let name = itemType.name
                        let mediaLink = NSURL(string: itemType.imageLinks[0].value!)!
                        dispatch_async(GlobalMainQueue, {
                            cell.nameLabel.text = name
                            cell.imageView.hnk_setImageFromURL(mediaLink, placeholder: nil, format: nil, failure: nil, success: {
                                (image: UIImage) in
                                dispatch_async(GlobalMainQueue, {
                                    cell.imageView.image = image
                                    UIView.animateWithDuration(0.2, animations: {
                                        cell.imageView.alpha = 1.0
                                    })
                                })
                            })
                        })
                    }
                })
                return cell
                
            default:
                return collectionView.dequeueReusableCellWithReuseIdentifier("BufferCell", forIndexPath: indexPath)
            }
            
        default:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ItemTypeCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
            cell.nameLabel.text = ""
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            searchBar.becomeFirstResponder()
            
        case 1:
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return }
            let data = layoutData[indexPath.row]
            guard let type = data["type"] as? Int else { return }
            
            switch type {
            case 1:
                targetIndexPath = indexPath
                createListing()
            default:
                return
            }
        default:
            return
        }
    }
    
    private func createListing() {
        
        searchBar?.resignFirstResponder()
        
        guard let layoutData = layoutData as? [[String:AnyObject]] else { return }
        guard let targetIndexPath = targetIndexPath else { return }
        
        let data = layoutData[targetIndexPath.row]
        guard let id = data["id"] as? String else { return }
        
        
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else {
            let window = UIApplication.sharedApplication().keyWindow!
            var e: ErrorMessage?
            e = ErrorMessage(frame: window.bounds, title: "Login Required", detail: "Tap \"Okay\" to login", error: .UserNotFound, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
            if let e = e {
                e.delegate = self
                window.addSubview(e)
                e.show()
            }
            return
        }
        
        guard let image = image else { return }
        
        let l = LoadingScreen(frame: view.bounds, message: "Creating Listing")
        view.addSubview(l)
        l.beginAnimation()
        
        model?.listingServiceProvider.createNewListing(userID, typeID: id, image: image, completionHandler: {
            (success:Bool, error: BygoError?) in
            dispatch_async(GlobalMainQueue, {
                if success {
                    self.performSegueWithIdentifier("SuccessSegue", sender: nil)
                } else {
                    l.endAnimation()
                    let window = UIApplication.sharedApplication().keyWindow!
                    var e: ErrorMessage?
                    
                    guard let error = error else {
                        e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong while trying to create your listing", error: .Unknown, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Retry])
                        if let e = e {
                            e.delegate = self
                            window.addSubview(e)
                            e.show()
                        }
                        return
                    }
                    
                    switch error {
                    case .PhoneNumberNotFound:
                        e = ErrorMessage(frame: window.bounds, title: "Mobile Number Required", detail: "Tap \"Okay\" to verify the mobile number associated with this account", error: error, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
                        
                    case .PhoneNumberNotVerified:
                        e = ErrorMessage(frame: window.bounds, title: "Verify Mobile Number", detail: "Tap \"Okay\" to verify the mobile number associated with this account", error: error, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
                        
                    case .HomeAddressNotFound:
                        e = ErrorMessage(frame: window.bounds, title: "Address Required", detail: "Tap \"Okay\" to list the address where we can pickup this item when someone orders it", error: error, priority: .Low, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Okay])
                        
                    default:
                        e = ErrorMessage(frame: window.bounds, title: "Uh oh!", detail: "Something went wrong while trying to create your listing", error: error, priority: .High, options: [ErrorMessageOptions.Cancel, ErrorMessageOptions.Retry])
                    }
                    
                    if let e = e {
                        e.delegate = self
                        window.addSubview(e)
                        e.show()
                    }
                }
            })
        })
    }

    @IBAction func cancelButtonTapped(sender: AnyObject) {
        searchBar?.resignFirstResponder()
        parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ErrorMessageDelegate
    func okayButtonTapped(error: BygoError) {
        switch error {
        case .HomeAddressNotFound:
            self.performSegueWithIdentifier("HomeAddress", sender: nil)
            
        case .PhoneNumberNotVerified:
            self.performSegueWithIdentifier("VerifyMobile", sender: nil)
            
        case .PhoneNumberNotFound:
            self.performSegueWithIdentifier("PhoneNumber", sender: nil)
            
        case .UserNotFound:
            showLoginMenu()
            
        default:
            return
        }
    }
    
    func retryButtonTapped(error: BygoError) {
        print("\n\nRETRY!!")
        self.createListing()
    }


    // MARK: - Login 
    func showLoginMenu() {
        let loginSB = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        loginContainer = loginSB.instantiateInitialViewController() as? UINavigationController
        (loginContainer?.topViewController as? WelcomeVC)?.model = model
        (loginContainer?.topViewController as? WelcomeVC)?.delegate = self
        presentViewController(loginContainer!, animated: true, completion: nil)
    }
    
    
    // MARK: - HomeAddress Delegate
    func didUpdateHomeAddress() {
        self.createListing()
    }
    
    // MARK: - LoginDelegate
    func userDidLogin(shouldDismissLogin: Bool) {
        NSNotificationCenter.defaultCenter().postNotificationName("UserDidLogin", object: false)
        dispatch_async(GlobalMainQueue, {
            if shouldDismissLogin {
                self.loginContainer?.dismissViewControllerAnimated(true, completion: {
                    self.loginContainer = nil
                    self.createListing()
                })
            }
        })
    }
    
    func phoneNumberDidVerify(shouldDismissLogin: Bool) {
        dispatch_async(GlobalMainQueue, {
            if shouldDismissLogin {
                self.dismissViewControllerAnimated(true, completion: {
                        self.createListing()
                })
            }
        })
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SuccessSegue" {
            guard let destVC = segue.destinationViewController as? SuccessVC else { return }
            destVC.delegate = self
            destVC.titleString = "Success!"
            destVC.detailString = "Your listing was created."

        } else if segue.identifier == "HomeAddress" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? HomeAddressVC else { return }
            destVC.model = model
            destVC.delegate = self
            
        } else if segue.identifier == "PhoneNumber" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? PhoneNumberVC else { return }
            destVC.model = model
            destVC.isModalPresentation = true
            destVC.delegate = self
            
        } else if segue.identifier == "VerifyMobile" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? VerifyPhoneNumberVC else { return }
            destVC.model = model
            destVC.isModalPresentation = true
            destVC.delegate = self
            
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