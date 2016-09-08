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
    var stockBriefView: HSStockBriefView?

    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllerView()
        
    }

    override func viewDidAppear(animated: Bool) {
        print("viewcontroller UIDevice.orientation isPortrait " + "\(UIDevice.currentDevice().orientation.isPortrait)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    
    
    //MARK: - Function
    
    func setUpControllerView() {
        
        var controllerArray : [UIViewController] = []
        
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        timeViewcontroller.title = "分时"
        timeViewcontroller.delegate = self
        controllerArray.append(timeViewcontroller)
        
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        fiveDayTimeViewController.title = "五日"
        fiveDayTimeViewController.delegate = self
        controllerArray.append(fiveDayTimeViewController)
        
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        kLineViewController.title = "日K"
        kLineViewController.delegate = self
        controllerArray.append(kLineViewController)
        
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        weeklyKLineViewController.title = "周K"
        weeklyKLineViewController.delegate = self
        controllerArray.append(weeklyKLineViewController)
        
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        monthlyKLineViewController.title = "月K"
        monthlyKLineViewController.delegate = self
        controllerArray.append(monthlyKLineViewController)
        
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

        stockBriefView = HSStockBriefView(frame: CGRectMake(0, headerStockInfoView.frame.height + 20, self.view.frame.width, 34))
        stockBriefView?.hidden = true
        
        self.view.addSubview(pageMenu!.view)
        self.view.addSubview(stockBriefView!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLongPressView), name: TimeLineLongpress, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showUnLongPressView), name: TimeLineUnLongpress, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(showLandScapeChartView), name: KLineUperChartDidTap, object: nil)
        
    }

    @IBAction func showStockMarketData(sender: AnyObject) {
        
        let stockMarketViewController = StockMarketDataViewController(nibName: "StockMarketDataViewController", bundle: nil)
        stockMarketViewController.modalPresentationStyle = .OverCurrentContext
        self.presentViewController(stockMarketViewController, animated: false, completion: nil)
    }
    
    func showLongPressView(note: NSNotification) {
        let timeLineEntity = note.object as! TimeLineEntity
        stockBriefView?.hidden = false
        stockBriefView?.priceLabel.text = timeLineEntity.price.toStringWithFormat("%.2f")
        stockBriefView?.ratioLabel.text = timeLineEntity.rate.toStringWithFormat("%.2f") + "%"
        stockBriefView?.timeLabel.text = timeLineEntity.currtTime
        stockBriefView?.volumeLabel.text = timeLineEntity.volume.toStringWithFormat("%.2f")
    }
    
    func showUnLongPressView(note: NSNotification) {
        stockBriefView?.hidden = true
    }
    
    func showLandScapeChartView(note: NSNotification) {
        let index = note.object as! Int
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController {
            vc.modalTransitionStyle = .CrossDissolve
            vc.viewindex = index
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }

}


extension ViewController: ChartViewControllerDelegate {
    func showLandscapeChartView(index: Int) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LandscapeViewController") as? LandscapeViewController {
            vc.modalTransitionStyle = .CrossDissolve
            vc.viewindex = index
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}

