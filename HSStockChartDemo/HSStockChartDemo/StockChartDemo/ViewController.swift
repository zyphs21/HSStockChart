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
    var kLineBriefView: HSKLineBriefView?

    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpControllerView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
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
            .scrollMenuBackgroundColor(UIColor.white),
            .selectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .unselectedMenuItemLabelColor(UIColor(red: 40.0/255.0, green: 40.0/255.0, blue: 40.0/255.0, alpha: 1.0)),
            .selectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .menuItemSeparatorHidden(true),
            .useMenuLikeSegmentedControl(true),
            .menuItemSeparatorPercentageHeight(0.1),
            .titleTextSizeBasedOnMenuItemWidth(true)
        ]
        
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRect(x: 0.0, y: 120 + 20, width: self.view.frame.width, height: self.view.frame.height), pageMenuOptions: parameters)

        stockBriefView = HSStockBriefView(frame: CGRect(x: 0, y: 120 + 20, width: self.view.frame.width, height: 34))
        stockBriefView?.isHidden = true
        
        kLineBriefView = HSKLineBriefView(frame: CGRect(x: 0, y: 120 + 20, width: self.view.frame.width, height: 34))
        kLineBriefView?.isHidden = true
        
        self.view.addSubview(pageMenu!.view)
        self.view.addSubview(stockBriefView!)
        self.view.addSubview(kLineBriefView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLongPressView), name: NSNotification.Name(rawValue: TimeLineLongpress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnLongPressView), name: NSNotification.Name(rawValue: TimeLineUnLongpress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartLongPressView), name: NSNotification.Name(rawValue: KLineChartLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartUnLongPressView), name: NSNotification.Name(rawValue: KLineChartUnLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLandScapeChartView), name: NSNotification.Name(rawValue: KLineUperChartDidTap), object: nil)
    }

    @IBAction func showStockMarketData(_ sender: AnyObject) {
        
        let stockMarketViewController = StockMarketDataViewController(nibName: "StockMarketDataViewController", bundle: nil)
        stockMarketViewController.modalPresentationStyle = .overCurrentContext
        self.present(stockMarketViewController, animated: false, completion: nil)
    }
    
    func showLongPressView(_ notification: Notification) {
        let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
        let timeLineEntity = dataDictionary["timeLineEntity"] as! TimeLineEntity
        stockBriefView?.isHidden = false
        stockBriefView?.configureView(timeLineEntity)
    }
    
    func showUnLongPressView(_ notification: Notification) {
        stockBriefView?.isHidden = true
    }
    
    func showKLineChartLongPressView(_ notification: Notification) {
        let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
        let preClose = dataDictionary["preClose"] as! CGFloat
        let klineEntity = dataDictionary["kLineEntity"] as! KLineEntity
        kLineBriefView?.configureView(preClose, kLineEntity: klineEntity)
        kLineBriefView?.isHidden = false
    }
    
    func showKLineChartUnLongPressView(_ notification: Notification) {
        kLineBriefView?.isHidden = true
    }
    
    func showLandScapeChartView(_ notification: Notification) {
        let index = notification.object as! Int
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.viewindex = index
            self.present(vc, animated: true, completion: nil)
        }
    }

}


extension ViewController: ChartViewControllerDelegate {
    func showLandscapeChartView(_ index: Int) {
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.viewindex = index
            self.present(vc, animated: true, completion: nil)
        }
    }
}

