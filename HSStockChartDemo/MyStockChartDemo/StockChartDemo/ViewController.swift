//
//  ViewController.swift
//  MyStockChartDemo
//
//  Created by Hanson on 16/8/15.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var pageMenu : CAPSPageMenu?

    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllerView()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    //MARK: - Function
    
    func setUpControllerView() {
        
        var controllerArray : [UIViewController] = []
        
        let timeViewcontroller : UIViewController = TimeViewController()
        timeViewcontroller.title = "分时"
        controllerArray.append(timeViewcontroller)
        
        let fiveDayTimeViewController : UIViewController = FiveDayTimeViewController()
        fiveDayTimeViewController.title = "五日"
        controllerArray.append(fiveDayTimeViewController)
        
        let kLineViewController : UIViewController = KLineViewController()
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
            .MenuItemSeparatorWidth(4.3),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorPercentageHeight(0.1)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 20, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        self.view.addSubview(pageMenu!.view)
    }

}

