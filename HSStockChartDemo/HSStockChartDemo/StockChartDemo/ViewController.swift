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
    var segmentMenu: SegmentMenu!
    var viewForChart: UIView!
    var stockBriefView: HSStockBriefView?
    var kLineBriefView: HSKLineBriefView?
    var currentShowingChartVC: UIViewController?

    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        segmentMenu = SegmentMenu(frame: CGRect(x: 0, y: headerStockInfoView.frame.maxY, width: ScreenWidth, height: 40))
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K"]
        segmentMenu.delegate = self
        
        viewForChart = UIView(frame: CGRect(x: 0, y: segmentMenu.frame.maxY, width: ScreenWidth, height: 300))
        
        stockBriefView = HSStockBriefView(frame: CGRect(x: 0, y: headerStockInfoView.frame.maxY, width: self.view.frame.width, height: 40))
        stockBriefView?.isHidden = true
        
        kLineBriefView = HSKLineBriefView(frame: CGRect(x: 0, y: headerStockInfoView.frame.maxY, width: self.view.frame.width, height: 40))
        kLineBriefView?.isHidden = true
        
        self.view.addSubview(segmentMenu)
        self.view.addSubview(viewForChart)
        self.view.addSubview(stockBriefView!)
        self.view.addSubview(kLineBriefView!)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLongPressView), name: NSNotification.Name(rawValue: TimeLineLongpress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnLongPressView), name: NSNotification.Name(rawValue: TimeLineUnLongpress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartLongPressView), name: NSNotification.Name(rawValue: KLineChartLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartUnLongPressView), name: NSNotification.Name(rawValue: KLineChartUnLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLandScapeChartView), name: NSNotification.Name(rawValue: KLineUperChartDidTap), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLandScapeChartView), name: NSNotification.Name(rawValue: TimeLineChartDidTap), object: nil)
        
        setUpControllerView()
        
        segmentMenu.setSelectButton(index: 0) // 默认初始选中第一个
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    //MARK: - 确保从横屏展示切换回来，布局仍以竖屏模式展示
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    
    //MARK: - 添加图表的 viewcontroller
    
    func setUpControllerView() {
        var controllerArray : [UIViewController] = []
        // 分时线
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        controllerArray.append(timeViewcontroller)
        self.addChildViewController(timeViewcontroller)
        
        // 五日分时线
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        controllerArray.append(fiveDayTimeViewController)
        self.addChildViewController(fiveDayTimeViewController)
        
        // 日 K 线
        /*这是和周 K 线和月 K 线一样的实现方法
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        controllerArray.append(kLineViewController)
        self.addChildViewController(kLineViewController)*/
        
        // 这是另外一种通过 scrollview 实现的方法，可以实现很顺畅的水平滑动
        let kLineViewController = DayKLineViewController()
        controllerArray.append(kLineViewController)
        self.addChildViewController(kLineViewController)
        
        // 周 K 线
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        controllerArray.append(weeklyKLineViewController)
        self.addChildViewController(weeklyKLineViewController)
        
        // 月 K 线
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        controllerArray.append(monthlyKLineViewController)
        self.addChildViewController(monthlyKLineViewController)
    }

    @IBAction func showStockMarketData(_ sender: AnyObject) {
        let stockMarketViewController = StockMarketDataViewController(nibName: "StockMarketDataViewController", bundle: nil)
        stockMarketViewController.modalPresentationStyle = .overCurrentContext
        self.present(stockMarketViewController, animated: false, completion: nil)
    }
    
    
    //MARK: - 长按分时线图，显示摘要信息
    
    func showLongPressView(_ notification: Notification) {
        let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
        let timeLineEntity = dataDictionary["timeLineEntity"] as! HSTimeLineModel
        stockBriefView?.isHidden = false
        stockBriefView?.configureView(timeLineEntity)
    }
    
    func showUnLongPressView(_ notification: Notification) {
        stockBriefView?.isHidden = true
    }
    
    
    //MARK: - 长按 K线图，显示摘要信息
    
    func showKLineChartLongPressView(_ notification: Notification) {
        let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
        let preClose = dataDictionary["preClose"] as! CGFloat
        let klineModel = dataDictionary["kLineEntity"] as! HSKLineModel
        kLineBriefView?.configureView(preClose, kLineModel: klineModel)
        kLineBriefView?.isHidden = false
    }
    
    func showKLineChartUnLongPressView(_ notification: Notification) {
        kLineBriefView?.isHidden = true
    }
    
    
    //MARK: - 跳转到横屏页面展示
    
    func showLandScapeChartView(_ notification: Notification) {
        let index = notification.object as! Int
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController {
            vc.modalTransitionStyle = .crossDissolve
            vc.viewindex = index
            self.present(vc, animated: true, completion: nil)
        }
    }

}


// MARK: - SegmentMenuDelegate

extension ViewController: SegmentMenuDelegate {
    
    func menuButtonDidClick(index: Int) {
        currentShowingChartVC?.view.removeFromSuperview()
        
        let selectedVC = self.childViewControllers[index]
        
        selectedVC.view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300)
        
        if (selectedVC.view.superview == nil){
            viewForChart.addSubview(selectedVC.view)
        }
        currentShowingChartVC = selectedVC
    }
}


