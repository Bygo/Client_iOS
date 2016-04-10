//
//  DemoHomeVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 10/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class WaitlistHomeVC: UIViewController {
    @IBOutlet var circleView:UIView! = UIView()
    @IBOutlet var bygoView0: UIImageView!
    @IBOutlet var bygoView1: UIImageView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    
    @IBOutlet var view0: UIView!
    @IBOutlet var view1: UIView!
    
    @IBOutlet var titleLabel0: UILabel!
    @IBOutlet var titleLabel1: UILabel!
    @IBOutlet var titleLabel2: UILabel!
    @IBOutlet var titleLabel3: UILabel!
    
    @IBOutlet var detailLabel0: UILabel!
    @IBOutlet var detailLabel1: UILabel!
    @IBOutlet var detailLabel2: UILabel!
    @IBOutlet var detailLabel3: UILabel!
    
    let kNUMBER_OF_PAGES:Int = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        
        // Do any additional setup after loading the view.
        view.backgroundColor = kCOLOR_THREE
        
        view.addSubview(circleView)
        circleView.frame = CGRectMake(0, (view.bounds.height/2.0)-(view.bounds.width/2.0), view.bounds.width/2.0, view.bounds.width/2.0)
        circleView.center = CGPointMake(view.center.x, view.center.y - 48.0)
        circleView.layer.cornerRadius = (circleView.bounds.width/2.0) - 1.0
        circleView.backgroundColor = kCOLOR_ONE
        
        bygoView0 = UIImageView(image: UIImage(named: "Bygo")?.imageWithRenderingMode(.AlwaysTemplate))
        bygoView0.tintColor = kCOLOR_THREE
        bygoView0.center = circleView.center
        scrollView.addSubview(bygoView0)
        
        bygoView1 = UIImageView(image: UIImage(named: "Bygo")?.imageWithRenderingMode(.AlwaysTemplate))
        bygoView1.tintColor = kCOLOR_THREE
        bygoView1.center = circleView.center
        bygoView1.alpha = 0.0
        view.addSubview(bygoView1)
        view.sendSubviewToBack(bygoView1)
        view.sendSubviewToBack(circleView)
        
        //        let k = (circleView.center.x+(circleView.bounds.height/2.0/2.0)) - circleView.center.x + (circleView.bounds.height/6.0)
        let k = circleView.bounds.height/8.0
        view0 = UIView(frame: CGRectMake(0, 0, circleView.bounds.width+(2.0*k), circleView.bounds.width+(2.0*k)))
        let circle0 = UIView(frame: CGRectMake(0, view0.bounds.height-circleView.bounds.height/2.0, circleView.bounds.height/2.0, circleView.bounds.height/2.0))
        circle0.backgroundColor = kCOLOR_ONE
        circle0.layer.cornerRadius = (circle0.bounds.width/2.0) - 1.0
        view0.addSubview(circle0)
        view0.center.x = (circleView.center.x) + k + (circleView.bounds.height/4.0)
        view0.center.y = (circleView.center.y) - k - (circleView.bounds.height/4.0)
        view.addSubview(view0)
        view.sendSubviewToBack(view0)
        
        view1 = UIView(frame: CGRectMake(0, 0, circleView.bounds.height/2.0, circleView.bounds.height/2.0))
        view1.center = circleView.center
        view1.backgroundColor = kCOLOR_ONE
        view1.layer.cornerRadius = circle0.layer.cornerRadius
        view.addSubview(view1)
        view.sendSubviewToBack(view1)
        
        
        scrollView.backgroundColor = .clearColor()
        pageControl.numberOfPages = kNUMBER_OF_PAGES
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = kCOLOR_ONE
        pageControl.pageIndicatorTintColor = UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 0.25)
        
        doneButton = UIButton()
        doneButton.setTitle("Get on the waitlist!", forState: .Normal)
        doneButton.backgroundColor = .whiteColor()
        doneButton.titleLabel?.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        doneButton.setTitleColor(kCOLOR_ONE, forState: .Normal)
        doneButton.setTitleColor(UIColor(red: 44.0/255.0, green: 62.0/255.0, blue: 80.0/255.0, alpha: 0.75), forState: .Highlighted)
        doneButton.frame = CGRectMake(0, view.bounds.height - 24.0 - 56.0, view.bounds.width, 56.0)
        doneButton.alpha = 0.0
        doneButton.enabled = false
        doneButton.addTarget(self, action: #selector(HowDoesBygoWorkVC.doneButtonTapped(_:)), forControlEvents: .TouchUpInside)
        view.addSubview(doneButton)
        
        
        scrollView.layoutIfNeeded()
        
        scrollView.contentSize = CGSizeMake(CGFloat(kNUMBER_OF_PAGES)*view.bounds.width, view.bounds.height)
        
        scrollView.layoutIfNeeded()
        
        configurePage0()
        configurePage1()
        configurePage2()
        configurePage3()
    }
    
    
    private func configurePage0() {
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(24.0)
        titleLabel.textColor = kCOLOR_ONE
        titleLabel.text = "Welcome to Bygo!"
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        let kTITLE_OFFSET: CGFloat = circleView.frame.origin.y/2.0 - (titleLabel.bounds.height/2.0)
        titleLabel.frame = CGRectMake(0, kTITLE_OFFSET, scrollView.bounds.width, titleLabel.bounds.height)
        scrollView.addSubview(titleLabel)
        titleLabel0 = titleLabel
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        detailLabel.textColor = kCOLOR_ONE
        detailLabel.numberOfLines = 0
        detailLabel.text = "Swipe to get started"
        detailLabel.alpha = 0.75
        detailLabel.textAlignment = .Center
        detailLabel.sizeToFit()
        detailLabel.frame = CGRectMake(0, pageControl.frame.origin.y - 24.0 - (detailLabel.bounds.height/2.0), scrollView.bounds.width, detailLabel.bounds.height)
        scrollView.addSubview(detailLabel)
        detailLabel0 = detailLabel
    }
    
    private func configurePage1() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(24.0)
        titleLabel.textColor = kCOLOR_ONE
        titleLabel.text = "You Order"
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        let kTITLE_OFFSET: CGFloat = circleView.frame.origin.y/2.0 - (titleLabel.bounds.height/2.0)
        titleLabel.frame = CGRectMake(scrollView.bounds.width, kTITLE_OFFSET, scrollView.bounds.width, titleLabel.bounds.height)
        scrollView.addSubview(titleLabel)
        titleLabel1 = titleLabel
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        detailLabel.textColor = kCOLOR_ONE
        detailLabel.numberOfLines = 0
        detailLabel.text = "When you order an item,\npeople in your area will\nrespond with offers."
        detailLabel.alpha = 0.75
        detailLabel.textAlignment = .Center
        detailLabel.sizeToFit()
        detailLabel.frame = CGRectMake(scrollView.bounds.width+24.0, pageControl.frame.origin.y - 24.0-(detailLabel.bounds.height/2.0), scrollView.bounds.width-48.0, detailLabel.bounds.height)
        scrollView.addSubview(detailLabel)
        detailLabel1 = detailLabel
        
        let order = UIImageView(image: UIImage(named: "Order")?.imageWithRenderingMode(.AlwaysTemplate))
        order.tintColor = kCOLOR_THREE
        order.center = circleView.center
        order.center.x += view.bounds.width
        scrollView.addSubview(order)
        
        let distRange = (circleView.bounds.height/8.0) + (circleView.bounds.height/4.0)
        let person = UIImageView(image: UIImage(named: "Male")?.imageWithRenderingMode(.AlwaysTemplate))
        person.tintColor = kCOLOR_THREE
        person.center = circleView.center
        person.center.x += view.bounds.width - distRange
        person.center.y += distRange
        scrollView.addSubview(person)
    }
    
    private func configurePage2() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(24.0)
        titleLabel.textColor = kCOLOR_ONE
        titleLabel.text = "We Deliver"
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        let kTITLE_OFFSET: CGFloat = circleView.frame.origin.y/2.0 - (titleLabel.bounds.height/2.0)
        titleLabel.frame = CGRectMake(2.0*scrollView.bounds.width, kTITLE_OFFSET, scrollView.bounds.width, titleLabel.bounds.height)
        scrollView.addSubview(titleLabel)
        titleLabel2 = titleLabel
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        detailLabel.textColor = kCOLOR_ONE
        detailLabel.numberOfLines = 0
        detailLabel.text = "Once you accept an offer,\nwe'll pick up the item\nand bring it to you."
        detailLabel.alpha = 0.75
        detailLabel.textAlignment = .Center
        detailLabel.sizeToFit()
        detailLabel.frame = CGRectMake((2.0*scrollView.bounds.width)+24.0, pageControl.frame.origin.y - 24.0-(detailLabel.bounds.height/2.0), scrollView.bounds.width-48.0, detailLabel.bounds.height)
        scrollView.addSubview(detailLabel)
        detailLabel2 = detailLabel
        
        
        let deliveryTruck = UIImageView(image: UIImage(named: "DeliveryTruck")?.imageWithRenderingMode(.AlwaysTemplate))
        deliveryTruck.tintColor = kCOLOR_THREE
        deliveryTruck.center = circleView.center
        deliveryTruck.center.x += view.bounds.width*2.0
        scrollView.addSubview(deliveryTruck)
        
        
        let distRange = sqrt(2.0)*((circleView.bounds.height/8.0) + (circleView.bounds.height/4.0))
        let pointA = UIImageView(image: UIImage(named: "Marker")?.imageWithRenderingMode(.AlwaysTemplate))
        pointA.tintColor = kCOLOR_THREE
        pointA.center = circleView.center
        pointA.center.x += (view.bounds.width*2.0) - distRange
        scrollView.addSubview(pointA)
        
        let pointB = UIImageView(image: UIImage(named: "Marker")?.imageWithRenderingMode(.AlwaysTemplate))
        pointB.tintColor = kCOLOR_THREE
        pointB.center = circleView.center
        pointB.center.x += (view.bounds.width*2.0) + distRange
        scrollView.addSubview(pointB)
    }
    
    private func configurePage3() {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFontOfSize(24.0)
        titleLabel.textColor = kCOLOR_ONE
        titleLabel.text = "You Earn Money"
        titleLabel.textAlignment = .Center
        titleLabel.sizeToFit()
        let kTITLE_OFFSET: CGFloat = circleView.frame.origin.y/2.0 - (titleLabel.bounds.height/2.0)
        titleLabel.frame = CGRectMake(3.0*scrollView.bounds.width, kTITLE_OFFSET, scrollView.bounds.width, titleLabel.bounds.height)
        scrollView.addSubview(titleLabel)
        titleLabel3 = titleLabel
        
        let detailLabel = UILabel()
        detailLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        detailLabel.textColor = kCOLOR_ONE
        detailLabel.numberOfLines = 0
        detailLabel.text = "You earn extra cash,\nby listing items you own\nand responding to orders."
        detailLabel.alpha = 0.75
        detailLabel.textAlignment = .Center
        detailLabel.sizeToFit()
        detailLabel.frame = CGRectMake((3.0*scrollView.bounds.width)+24.0, pageControl.frame.origin.y - 24.0-(detailLabel.bounds.height/2.0), scrollView.bounds.width-48.0, detailLabel.bounds.height)
        scrollView.addSubview(detailLabel)
        detailLabel3 = detailLabel
        
        
        let banknotes = UIImageView(image: UIImage(named: "Banknotes")?.imageWithRenderingMode(.AlwaysTemplate))
        banknotes.tintColor = kCOLOR_THREE
        banknotes.center = circleView.center
        banknotes.center.x += view.bounds.width*3.0
        scrollView.addSubview(banknotes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func enableDoneButton() {
        doneButton.enabled = true
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: true)
        UIView.animateWithDuration(1.0, animations: {
            self.bygoView1.alpha = 1.0
            self.doneButton.alpha = 1.0
        })
    }
    
    @IBAction func doneButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - ScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        if scrollView == scrollView {
            // Set page control
            let pageWidth = scrollView.bounds.size.width
            let fractionalPage = scrollView.contentOffset.x / pageWidth
            let page = lround(Double(fractionalPage))
            pageControl.currentPage = page
            
            if page == pageControl.numberOfPages-1 {
                scrollView.scrollEnabled = false
                enableDoneButton()
            }
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == scrollView {
            
            detailLabel0.frame.origin.x = 0 - scrollView.contentOffset.x
            detailLabel1.frame.origin.x = view.bounds.width - (scrollView.contentOffset.x - (view.bounds.width)) + 24.0
            detailLabel2.frame.origin.x = (2.0*view.bounds.width) - (scrollView.contentOffset.x - (2.0*view.bounds.width)) + 24.0
            detailLabel3.frame.origin.x = (3.0*view.bounds.width) - (scrollView.contentOffset.x - (3.0*view.bounds.width)) + 24.0
            
            if scrollView.contentOffset.x < scrollView.bounds.width {
                // let k = (circleView.center.x+(circleView.bounds.height/2.0/2.0)) - circleView.center.x + (circleView.bounds.height/6.0)
                // let distRange = (circleView.center.x+(circleView.bounds.height/2.0/2.0)) - circleView.center.x + (circleView.bounds.height/6.0)
                let distRange = (circleView.bounds.height/8.0) + (circleView.bounds.height/4.0)
                let offsetRange = scrollView.bounds.width
                let offsetPosition = scrollView.bounds.width - scrollView.contentOffset.x
                let progress = (offsetRange-offsetPosition)/offsetRange
                let distPostion_x = (circleView.center.x + distRange) - progress*distRange
                let distPostion_y = (circleView.center.y - distRange) + progress*distRange
                view0.center = CGPointMake(distPostion_x, distPostion_y)
            }
            
            
            if scrollView.contentOffset.x > scrollView.bounds.width && scrollView.contentOffset.x < (2.0*scrollView.bounds.width) {
                let kMIN_DEGREE: CGFloat = 0.0
                let kMAX_DEGREE: CGFloat = -45.0
                let kDEGREE_RANGE = kMAX_DEGREE - kMIN_DEGREE
                let kOFFSET_RANGE = scrollView.bounds.width
                let kOFFSET_POSITION = scrollView.bounds.width - scrollView.contentOffset.x
                let progress = kOFFSET_POSITION / kOFFSET_RANGE
                let rotation = kDEGREE_RANGE*progress
                let rotation_radians = (rotation*CGFloat(M_PI))/180.0
                view0.transform = CGAffineTransformMakeRotation(rotation_radians)
                
                let distRange = (circleView.bounds.height/8.0) + (circleView.bounds.height/4.0)
                let distPosition_x = (circleView.center.x) - (sqrt(2.0)*distRange)*progress
                view1.center.x = distPosition_x
            }
            
            if scrollView.contentOffset.x > (2.0*scrollView.bounds.width) && scrollView.contentOffset.x < (3.0*scrollView.bounds.width) {
                let distRange = (circleView.bounds.height/8.0) + (circleView.bounds.height/4.0)
                let offsetRange = scrollView.bounds.width
                let offsetPosition = (scrollView.bounds.width*3.0) - scrollView.contentOffset.x
                let progress = (offsetRange-offsetPosition)/offsetRange
                let distPosition_x0 = (circleView.center.x) + progress*(sqrt(2.0)*distRange)
                view0.center.x = distPosition_x0
                
                let distPosition_x1 = (circleView.center.x+(sqrt(2.0)*distRange)) - progress*(sqrt(2.0)*distRange)
                view1.center.x = distPosition_x1
            }
            
            if scrollView.contentOffset.x > scrollView.bounds.width*CGFloat(kNUMBER_OF_PAGES-2) {
                let kMAX_HEIGHT = (view.bounds.height*1.1)+(2.0*48.0)
                let kMIN_HEIGHT = view.bounds.width/2.0
                let kMAX_OFFSET = scrollView.bounds.width*CGFloat(kNUMBER_OF_PAGES-1)
                let kMIN_OFFSET = scrollView.bounds.width*CGFloat(kNUMBER_OF_PAGES-2)
                let progress = (scrollView.contentOffset.x-kMIN_OFFSET) / (kMAX_OFFSET-kMIN_OFFSET)
                let newSize = kMIN_HEIGHT + (progress*(kMAX_HEIGHT-kMIN_HEIGHT))
                circleView.frame.size = CGSizeMake(newSize, newSize)
                circleView.center = CGPointMake(view.center.x, view.center.y - 48.0)
            } else {
                circleView.frame.size = CGSizeMake(view.bounds.width/2.0, view.bounds.width/2.0)
                circleView.center = CGPointMake(view.center.x, view.center.y - 48.0)
            }
        }
    }
}
