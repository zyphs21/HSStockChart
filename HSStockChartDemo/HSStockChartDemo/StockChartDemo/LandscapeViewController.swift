//
//  LandscapeViewController.swift
//  HSStockChartDemo
//
//  Created by Hanson on 16/9/1.
//  Copyright © 2016年 hanson. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {

    var segmentMenu: SegmentMenu!
    var viewForChart: UIView!
    var currentShowingChartVC: UIViewController?
    var stockBriefView: HSStockBriefView?
    var kLineBriefView: HSKLineBriefView?
    var viewindex: Int = 0
    
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(ScreenWidth) " + "\(ScreenHeight)")
        NotificationCenter.default.addObserver(self, selector: #selector(showLongPressView), name: NSNotification.Name(rawValue: "TimeLineLongpress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnLongPressView), name: NSNotification.Name(rawValue: "TimeLineUnLongpress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartLongPressView), name: NSNotification.Name(rawValue: KLineChartLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartUnLongPressView), name: NSNotification.Name(rawValue: KLineChartUnLongPress), object: nil)
        
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        self.addChildViewController(timeViewcontroller)
        
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        self.addChildViewController(fiveDayTimeViewController)
        
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        self.addChildViewController(kLineViewController)
        
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        self.addChildViewController(weeklyKLineViewController)
        
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        self.addChildViewController(monthlyKLineViewController)
        
        let oneMonthViewController = UIViewController()
        self.addChildViewController(oneMonthViewController)
        
        let sixMonthViewController = UIViewController()
        self.addChildViewController(sixMonthViewController)
        
        let threeYearViewController = UIViewController()
        self.addChildViewController(threeYearViewController)
        
        let  allViewController = UIViewController()
        self.addChildViewController(allViewController)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 横屏切换时，frame 的 width 和 Height 在 viewDidLayoutSubviews 中才变化，但是该方法会调用多次
        //setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        setUpView()
        print("\(ScreenWidth) " + "\(ScreenHeight)")
        segmentMenu.setSelectButton(index: self.viewindex)
    }
    
    override var shouldAutorotate : Bool {
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.landscapeRight
    }
    
    @IBAction func backButtonDidClick(_ sender: AnyObject) {
        self.modalTransitionStyle = .crossDissolve
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func setUpView() {
        
        print("\(ScreenWidth) " + "\(ScreenHeight)")
        segmentMenu = SegmentMenu(frame: CGRect(x: 0, y: 30, width: 736, height: 40))
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K", "一月", "六月", "三年", "全部"]
        segmentMenu.delegate = self
        viewForChart = UIView(frame: CGRect(x: 0, y: segmentMenu.frame.maxY, width: ScreenWidth, height: 300))
        stockBriefView = HSStockBriefView(frame: CGRect(x: 0, y: 30, width: self.view.frame.width, height: 40))
        stockBriefView?.isHidden = true
        
        kLineBriefView = HSKLineBriefView(frame: CGRect(x: 0, y: 30, width: self.view.frame.width, height: 40))
        kLineBriefView?.isHidden = true
        
        self.view.addSubview(segmentMenu)
        self.view.addSubview(viewForChart)
        self.view.addSubview(stockBriefView!)
        self.view.addSubview(kLineBriefView!)

    }
    
    func showLongPressView(_ notification: Notification) {
        let dataDictionary = (notification as NSNotification).userInfo as! [String: AnyObject]
        let timeLineEntity = dataDictionary["timeLineEntity"] as! TimeLineEntity
        stockBriefView?.isHidden = false
        stockBriefView?.configureView(timeLineEntity)
    }
    
    func showUnLongPressView() {
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
}



// MARK: - SegmentMenuDelegate

extension LandscapeViewController: SegmentMenuDelegate {
    
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
