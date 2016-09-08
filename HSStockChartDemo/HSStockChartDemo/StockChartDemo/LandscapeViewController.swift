//
//  LandscapeViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/1.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    var pageMenu : CAPSPageMenu?
    var stockBriefView: HSStockBriefView?
    var controllerArray: [UIViewController] = []
    var parameters: [CAPSPageMenuOption] = []
    var viewindex: Int = 0
    
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLongPressView), name: "TimeLineLongpress", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showUnLongPressView), name: "TimeLineUnLongpress", object: nil)
        
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        timeViewcontroller.title = "分时"
        controllerArray.append(timeViewcontroller)
        
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        fiveDayTimeViewController.title = "五日"
        controllerArray.append(fiveDayTimeViewController)
        
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        kLineViewController.title = "日K"
        controllerArray.append(kLineViewController)
        
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        weeklyKLineViewController.title = "周K"
        controllerArray.append(weeklyKLineViewController)
        
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        monthlyKLineViewController.title = "月K"
        controllerArray.append(monthlyKLineViewController)
        
        let oneMonthViewController = UIViewController()
        oneMonthViewController.title = "1月"
        controllerArray.append(oneMonthViewController)
        
        let sixMonthViewController = UIViewController()
        sixMonthViewController.title = "6月"
        controllerArray.append(sixMonthViewController)
        
        let threeYearViewController = UIViewController()
        threeYearViewController.title = "3年"
        controllerArray.append(threeYearViewController)
        
        let  allViewController = UIViewController()
        allViewController.title = "全部"
        controllerArray.append(allViewController)
        
        parameters = [
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .SelectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .UnselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .SelectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .MenuItemSeparatorHidden(true),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorPercentageHeight(0.1),
            .TitleTextSizeBasedOnMenuItemWidth(true)
        ]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 横屏切换时，frame 的 width 和 Height 在 viewDidLayoutSubviews 中才变化，但是该方法会调用多次
        //setUpControllerView()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        setUpControllerView()
        
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.LandscapeRight
    }
    
    @IBAction func backButtonDidClick(sender: AnyObject) {
        self.modalTransitionStyle = .CrossDissolve
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Function
    
    func setUpControllerView() {
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 30, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        pageMenu?.moveToPage(self.viewindex)
        
        stockBriefView = HSStockBriefView(frame: CGRectMake(0, 30, self.view.frame.width, 34))
        stockBriefView?.hidden = true
        
        self.view.addSubview(pageMenu!.view)
        self.view.addSubview(stockBriefView!)

    }
    
    
    // MARK: - Handle Notification function
    
    func showLongPressView(note: NSNotification) {
        let timeLineEntity = note.object as! TimeLineEntity
        stockBriefView?.hidden = false
        stockBriefView?.configureView(timeLineEntity)
    }
    
    func showUnLongPressView() {
        stockBriefView?.hidden = true
    }
    
    
}
