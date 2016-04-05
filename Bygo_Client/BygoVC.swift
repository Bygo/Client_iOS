//
//  BygoVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 5/3/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class BygoVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SuccessDelegate, DiscoveryDelegate, UITextFieldDelegate {
    
    @IBOutlet var searchBar: SearchBar!
    @IBOutlet var searchBarVerticalOffset: NSLayoutConstraint!
    @IBOutlet var promptLabel: UILabel!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var createListingButton: UIButton!
    @IBOutlet var createListingButtonBottomOffset: NSLayoutConstraint!
    @IBOutlet var refreshControl: UIRefreshControl!
    @IBOutlet var menuButton: UIBarButtonItem!
    
    @IBOutlet var tapRecognizer: UITapGestureRecognizer!
    
    var delegate:HomeDelegate?
    var model:Model?
    var selectedTypeID: String?
    
    private var layoutData: AnyObject? = nil
    
    let promptOptions = ["What are you looking for?", "Try something new this weekend.", "Need a basketball?", "Throwing a party?", "What are your plans for tonight?", "Want to practice guitar?"]
    var promptIdx: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(BygoVC.tapGestureRecognized(_:)))
        
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        view.backgroundColor = kCOLOR_THREE
        
        menuButton.tintColor = .whiteColor()
        
        view.backgroundColor = kCOLOR_THREE
        collectionView?.backgroundColor = .clearColor()
        
        title = "Discover"
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(BygoVC.refresh), forControlEvents: .ValueChanged)
        collectionView.addSubview(refreshControl)
        
        refresh()
    }
    
    override func viewDidAppear(animated: Bool) {
        refreshControl.endRefreshing()
    }
    
    func configureCreateListingButton() {
        createListingButton.backgroundColor = kCOLOR_TWO
        createListingButton.setTitleColor(.whiteColor(), forState: .Normal)
        createListingButton.titleLabel?.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        createListingButton.setTitle("Create a Listing", forState: .Normal)
        
        //        createListingButton.layer.shadowColor = UIColor.blackColor().CGColor
        //        createListingButton.layer.shadowOpacity = 0.5
        //        createListingButton.layer.shadowOffset = CGSizeMake(1.0, 1.0)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        UIApplication.sharedApplication().statusBarHidden = false
        // UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Slide)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func changePrompt() {
        if layoutData != nil {
            UIView.animateWithDuration(0.3, animations: {
                self.promptLabel.alpha = 0.0
                }, completion: {
                    (complete:Bool) in
                    if complete {
                        self.promptIdx = self.promptIdx+1
                        if self.promptIdx >= self.promptOptions.count {
                            self.promptIdx = 0
                        }
                        
                        self.promptLabel.text = self.promptOptions[self.promptIdx]
                        UIView.animateWithDuration(0.3, animations: {
                            self.promptLabel.alpha = 1.0
                        })
                    }
            })
        }
    }
    
    func userDidLogin() {

    }
    
    func userDidLogout() {

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    
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
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == searchBar {
            delegate?.didMoveOneLevelIntoNavigation()
            view.addGestureRecognizer(tapRecognizer)
        }
    }
    
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        self.layoutData = []
        self.collectionView.reloadSections(NSIndexSet(index: 1))
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField == searchBar {
            if textField.text?.characters.count < 1 {
                refresh()
            }
            
            view.removeGestureRecognizer(tapRecognizer)
            delegate?.didReturnToBaseLevelOfNavigation()
        }
    }
    
    // MARK: UICollectionViewDataSource

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 3
    }


    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            guard let layoutData = layoutData else { return 0 }
            return layoutData.count
        case 2:
            return 1
        default :
            return 0
        }
    }
    
    private let kGALLERY_WITH_TITLE_CELL = 0
    private let kITEM_TYPE_CELL = 1
    private let kCREATE_NEW_LISTING_CELL = 2
    private let kHOW_DOES_BYGO_WORK_CELL = 3

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SearchBarCell", forIndexPath: indexPath) as? SearchBarCollectionViewCell else { return UICollectionViewCell() }
            cell.questionLabel.text = nil
            cell.clipsToBounds = false
            searchBar = cell.searchBar
            searchBarVerticalOffset = searchBar.centerYAnchor.constraintEqualToAnchor(cell.centerYAnchor, constant: 0)
            searchBarVerticalOffset.active = true
            cell.searchBar.delegate = self
            return cell
            
        case 1:
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return collectionView.dequeueReusableCellWithReuseIdentifier("BufferCell", forIndexPath: indexPath) }
            let data = layoutData[indexPath.row]
            guard let type = data["type"] as? Int else { return collectionView.dequeueReusableCellWithReuseIdentifier("BufferCell", forIndexPath: indexPath) }
            switch type {
            case kGALLERY_WITH_TITLE_CELL:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Discovery_0_Cell", forIndexPath: indexPath) as? Discovery_0_CollectionViewCell else { return UICollectionViewCell() }
                let title = data["title"] as? String
                cell.titleLabel.text = title
                cell.delegate = self
                cell.model = model
                cell.backgroundColor = .clearColor()
                cell.collectionView.backgroundColor = .clearColor()
                cell.collectionView.delegate = cell
                cell.collectionView.dataSource = cell
                
                guard let itemTypeIDs = data["item_type_ids"] as? [String] else { return cell }
                cell.itemTypeIDs = itemTypeIDs
                cell.collectionView.reloadData()
                return cell
                
            case kITEM_TYPE_CELL:
                
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
                            cell.imageView.alpha = 0.0
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
                
            case kCREATE_NEW_LISTING_CELL:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiscoveryInfoCell", forIndexPath: indexPath) as? DiscoveryInfoCollectionViewCell else { return UICollectionViewCell() }
                cell.backgroundColor = kCOLOR_FIVE
                cell.titleLabel.textColor = .whiteColor()
                cell.detailLabel.textColor = .whiteColor()
                cell.detailLabel.alpha = 0.75
                cell.titleLabel.text = "Got a Guitar?"
                cell.detailLabel.text = "Tap here to list it now and earn some cash"
                return cell
                
            case kHOW_DOES_BYGO_WORK_CELL:
                guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("DiscoveryInfoCell", forIndexPath: indexPath) as? DiscoveryInfoCollectionViewCell else { return UICollectionViewCell() }
                cell.backgroundColor = kCOLOR_FIVE
                cell.titleLabel.textColor = .whiteColor()
                cell.detailLabel.textColor = .whiteColor()
                cell.detailLabel.alpha = 0.75
                cell.titleLabel.text = "How does bygo work?"
                cell.detailLabel.text = "Tap here to find out how you can save and earn money"
                return cell

            default:
                return collectionView.dequeueReusableCellWithReuseIdentifier("BufferCell", forIndexPath: indexPath)
            }
            
        case 2:
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("BufferCell", forIndexPath: indexPath)
            cell.backgroundColor = .clearColor()
            return cell
            
        default:
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("QuickRequestCell", forIndexPath: indexPath) as? ItemTypeCollectionViewCell else { return UICollectionViewCell() }
            cell.nameLabel.text = nil
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            searchBar.becomeFirstResponder()
            
        case 1:
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return }
            let data = layoutData[indexPath.row]
            guard let type = data["type"] as? Int else { return }
            switch type {
            case kITEM_TYPE_CELL:
                guard let id = data["id"] as? String else { return }
                didSelectItemType(id)
                
            case kCREATE_NEW_LISTING_CELL:
                performSegueWithIdentifier("CreateNewListing", sender: nil)
                
            case kHOW_DOES_BYGO_WORK_CELL:
                let loginSB = UIStoryboard(name: "HowDoesBygoWork", bundle: NSBundle.mainBundle())
                let howDoesBygoWorkVC = loginSB.instantiateInitialViewController() as? UINavigationController
                presentViewController(howDoesBygoWorkVC!, animated: true, completion: nil)

            default: return
            }
        default: return
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        print(indexPath)
        switch indexPath.section {
        case 1:
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return false }
            if layoutData.count == 0 { return false }
            let data = layoutData[indexPath.row]
            guard let type = data["type"] as? Int else { return false }
            switch type {
            case kITEM_TYPE_CELL: return true
            case kCREATE_NEW_LISTING_CELL: return true
            case kHOW_DOES_BYGO_WORK_CELL: return true
            default: return false
            }
        default: return false
        }
    }
    

    
    private var previousScrollViewOffset:CGFloat = 0.0
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == collectionView {
            if scrollView.contentOffset.y <= 0 {
                guard let searchBarVerticalOffset = searchBarVerticalOffset else { return }
                searchBarVerticalOffset.constant = scrollView.contentOffset.y / 2.0
            } else {
                guard let searchBarVerticalOffset = searchBarVerticalOffset else { return }
                searchBarVerticalOffset.constant = 0.0
            }
        }
    }
    
    
    // MARK: - UI Action
    @IBAction func menuButtonTapped(sender: AnyObject) {
        delegate?.openMenu()
        if searchBar != nil {
            searchBar.resignFirstResponder()
        }
    }
    
    @IBAction func tapGestureRecognized(recognizer: UITapGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "CreateNewListing" { 
            guard let destVC = segue.destinationViewController as? NewListingImageVC else { return }
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                destVC.sourceType     = .Camera
                destVC.cameraDevice   = UIImagePickerControllerCameraDevice.Rear
                destVC.cameraCaptureMode = UIImagePickerControllerCameraCaptureMode.Photo
                destVC.allowsEditing  = true
                destVC.showsCameraControls = true
                destVC.model = model
                
            } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
                destVC.sourceType     = .PhotoLibrary
                destVC.allowsEditing  = false
            }
            
        } else if segue.identifier == "OrderSegue" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? OrderVC else { return }
            destVC.typeID = selectedTypeID
            destVC.model = model
            
        }
    }
    
    // MARK: - Refresh
    func refresh() {
        self.model?.discoveryServiceProvider.fetchDefaultHomePageData({ (data:AnyObject?) in
            if data != nil {
                self.layoutData = data
                if self.searchBar != nil {
                    self.searchBar.text = nil
                }
                
                if self.collectionView.numberOfSections() > 1 {
                    self.collectionView.performBatchUpdates({
                        self.collectionView.reloadSections(NSIndexSet(index: 1))
                        }, completion: nil)
                } else {
                    self.collectionView.reloadData()
                }
                
            } else {
                // TODO: Present some error message to the user that the homepage data could not be loaded
            }
            
            self.refreshControl.endRefreshing()
        })
    }


    
    // MARK: - DiscoveryDelegate
    func didSelectItemType(typeID: String?) {
        searchBar.resignFirstResponder()
        selectedTypeID = typeID
        performSegueWithIdentifier("OrderSegue", sender: nil)
    }
    
    // MARK: - Success Delegate
    func doneButtonTapped() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegate
extension BygoVC : UICollectionViewDelegateFlowLayout{
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        switch indexPath.section {
        case 0: return CGSizeMake(view.bounds.width-16.0, 112.0)
        case 1:
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return CGSizeZero }
            let data = layoutData[indexPath.row]
            guard let type = data["type"] as? Int else { return CGSizeZero }
            switch type {
            case kGALLERY_WITH_TITLE_CELL: return CGSizeMake(view.bounds.width, 336.0)
            case kITEM_TYPE_CELL: return CGSizeMake((view.bounds.width/2.0)-12.0, 252.0)
            case kCREATE_NEW_LISTING_CELL: return CGSizeMake(view.bounds.width-16, 96.0)
            case kHOW_DOES_BYGO_WORK_CELL: return CGSizeMake(view.bounds.width-16, 96.0)
            default: return CGSizeZero
            }
        case 2: return CGSizeMake(view.bounds.width, 48.0)
        default: return CGSizeMake(0.0, 0.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        switch section {
        case 0: return UIEdgeInsetsMake(8.0, 8.0, 0.0, 8.0)
        case 1:
            guard let layoutData = layoutData as? [[String:AnyObject]] else { return UIEdgeInsetsZero }
            if layoutData.count == 0 { return UIEdgeInsetsZero }
            let data = layoutData[0]
            guard let type = data["type"] as? Int else { return UIEdgeInsetsZero }
            switch type {
            case 1: return UIEdgeInsetsMake(0.0, 8.0, 8.0, 8.0)
            default: return UIEdgeInsetsZero
            }
        case 2: return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        default: return UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 8.0
    }
}



public protocol HomeDelegate {
    func openMenu()
    func didMoveOneLevelIntoNavigation()
    func didReturnToBaseLevelOfNavigation()
}