//
//  ViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/15.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var headerStockInfoView: UIView!
    var pageMenu: CAPSPageMenu?
    var longPressToShowView = UIView()
    var currentPriceLabel = UILabel()    
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        setUpControllerView()
        
    }

    override func viewDidAppear(animated: Bool) {
        print("UIDevice.orientation isPortrait " + "\(UIDevice.currentDevice().orientation.isPortrait)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - Function
    
    func setUpControllerView() {
        
        var controllerArray : [UIViewController] = []
        
        let timeViewcontroller = TimeViewController(frame: CGRectMake(0.0, 20, self.view.frame.width, self.view.frame.height))
        timeViewcontroller.title = "分时"
        timeViewcontroller.delegate = self
        controllerArray.append(timeViewcontroller)
        
        let fiveDayTimeViewController = FiveDayTimeViewController()
        fiveDayTimeViewController.title = "五日"
        controllerArray.append(fiveDayTimeViewController)
        
        let kLineViewController = KLineViewController()
        kLineViewController.title = "日K"
        controllerArray.append(kLineViewController)
        
        let weeklyKLineViewController : UIViewController = WeeklyKLineViewController()
        weeklyKLineViewController.title = "周K"
        controllerArray.append(weeklyKLineViewController)
        
        let monthlyKLineViewController : UIViewController = MonthlyKLineViewController()
        monthlyKLineViewController.title = "月K"
        controllerArray.append(monthlyKLineViewController)
        
        // Customize page menu to your liking (optional) or use default settings by sending nil for 'options' in the init
        let parameters: [CAPSPageMenuOption] = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .UnselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .SelectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .MenuItemSeparatorHidden(true),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorPercentageHeight(0.1),
            .TitleTextSizeBasedOnMenuItemWidth(true)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, headerStockInfoView.frame.height + 20, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        longPressToShowView.frame = CGRectMake(0, 150, self.view.frame.width, 30)
        longPressToShowView.backgroundColor = UIColor.whiteColor()
        currentPriceLabel.frame = CGRectMake(0, 0, self.view.frame.width, 25)
        longPressToShowView.addSubview(currentPriceLabel)
        longPressToShowView.hidden = true
        
        self.view.addSubview(pageMenu!.view)
        self.view.addSubview(longPressToShowView)        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLongPressView), name: "TimeLineLongpress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showUnLongPressView), name: "TimeLineUnLongpress", object: nil)
        
    }

    @IBAction func showStockMarketData(sender: AnyObject) {
        
        let stockMarketViewController = StockMarketDataViewController(nibName: "StockMarketDataViewController", bundle: nil)
        stockMarketViewController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(stockMarketViewController, animated: false, completion: nil)
    }
    
    func showLongPressView(note: NSNotification) {
        let timeLineEntity = note.object as! TimeLineEntity
        longPressToShowView.hidden = false
        currentPriceLabel.text = timeLineEntity.price.toStringWithFormat("%.2f")
        print("当前价格" + "\(timeLineEntity.price)")
    }
    
    func showUnLongPressView() {
        longPressToShowView.hidden = true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    
//    override func viewDidLayoutSubviews() {
//        self.view.layoutSubviews()
//    }

}

extension ViewController: TimeViewControllerDelegate {
    func showLandscapeView() {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController {
            self.presentViewController(vc, animated: true, completion: nil)
        }
//        let test = TestViewController()
//        self.presentViewController(test, animated: true, completion: nil)
    }
}

