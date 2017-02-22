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
    var controllerArray : [UIViewController] = []
    var stockBriefView: HSStockBriefView?
    var kLineBriefView: HSKLineBriefView?
    var viewindex: Int = 0
    
    
    //MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("\(self.view.frame)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(showLongPressView), name: NSNotification.Name(rawValue: "TimeLineLongpress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnLongPressView), name: NSNotification.Name(rawValue: "TimeLineUnLongpress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartLongPressView), name: NSNotification.Name(rawValue: KLineChartLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartUnLongPressView), name: NSNotification.Name(rawValue: KLineChartUnLongPress), object: nil)
        
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        controllerArray.append(timeViewcontroller)
        
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        controllerArray.append(fiveDayTimeViewController)
        
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        controllerArray.append(kLineViewController)
        
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        controllerArray.append(weeklyKLineViewController)
        
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        controllerArray.append(monthlyKLineViewController)
        
        let oneMonthViewController = UIViewController()
        controllerArray.append(oneMonthViewController)
        
        let sixMonthViewController = UIViewController()
        controllerArray.append(sixMonthViewController)
        
        let threeYearViewController = UIViewController()
        controllerArray.append(threeYearViewController)
        
        let  allViewController = UIViewController()
        controllerArray.append(allViewController)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 横屏切换时，frame 的 width 和 Height 在 viewDidLayoutSubviews 中才变化，但是该方法会调用多次
        //setUpView()
        print("\(self.view.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("\(self.view.frame)")
        setUpView()
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
        
        segmentMenu = SegmentMenu(frame: CGRect(x: 0, y: 30, width: 736, height: 40))
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K", "一月", "六月", "三年", "全部"]
        segmentMenu.delegate = self
        viewForChart = UIView(frame: CGRect(x: 0, y: segmentMenu.frame.maxY, width: self.view.frame.width, height: self.view.frame.height - 90))
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
        let timeLineEntity = dataDictionary["timeLineEntity"] as! HSTimeLineModel
        stockBriefView?.isHidden = false
        stockBriefView?.configureView(timeLineEntity)
    }
    
    func showUnLongPressView() {
        stockBriefView?.isHidden = true
    }
    
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
}



// MARK: - SegmentMenuDelegate

extension LandscapeViewController: SegmentMenuDelegate {
    
    func menuButtonDidClick(index: Int) {
//        currentShowingChartVC?.view.removeFromSuperview()
//        
//        let selectedVC = self.childViewControllers[index]
//        
////        selectedVC.view.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300)
//        
//        if (selectedVC.view.superview == nil){
//            viewForChart.addSubview(selectedVC.view)
//        }
//        currentShowingChartVC = selectedVC
        
        
        currentShowingChartVC?.willMove(toParentViewController: nil)
        currentShowingChartVC?.view.removeFromSuperview()
        currentShowingChartVC?.removeFromParentViewController()
        
        let selectedVC: UIViewController = self.controllerArray[index]
        
        addChildViewController(selectedVC)
        
        selectedVC.view.frame = viewForChart.bounds
        if (selectedVC.view.superview == nil) {
            viewForChart.addSubview(selectedVC.view)
        }
        selectedVC.didMove(toParentViewController: self)
        currentShowingChartVC = selectedVC
    }
}
