//
//  ViewController.swift
//  HSStockChart-Demo
//
//  Created by Hanson on 2017/10/12.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import UIKit
import HSStockChart

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height
public let TimeLineLongpress = "TimeLineLongpress"
public let TimeLineUnLongpress = "TimeLineUnLongpress"
public let TimeLineChartDidTap = "TimeLineChartDidTap"
public let KLineChartLongPress = "kLineChartLongPress"
public let KLineChartUnLongPress = "kLineChartUnLongPress"
public let KLineUperChartDidTap = "KLineUperChartDidTap"


class ViewController: UIViewController {

    var segmentMenu: SegmentMenu!
    var currentShowingChartVC: UIViewController?
    var controllerArray : [UIViewController] = []
    
    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        addNoticficationObserve()
        addChartController()
        segmentMenu.setSelectButton(index: 0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var shouldAutorotate : Bool {
        // 确保从横屏展示切换回来，布局仍以竖屏模式展示
        return false
    }
    
    override var preferredInterfaceOrientationForPresentation : UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }
    
    
    // MARK: - Functioin
    
    func setUpView() {
        segmentMenu = SegmentMenu(frame: CGRect(x: 0, y: 88, width: ScreenWidth, height: 40))
        segmentMenu.menuTitleArray = ["分时", "五日", "日K", "周K", "月K"]
        segmentMenu.delegate = self
        self.view.addSubview(segmentMenu)
    }
    
    func addNoticficationObserve() {
        NotificationCenter.default.addObserver(self, selector: #selector(showLongPressView), name: NSNotification.Name(rawValue: TimeLineLongpress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnLongPressView), name: NSNotification.Name(rawValue: TimeLineUnLongpress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartLongPressView), name: NSNotification.Name(rawValue: KLineChartLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showKLineChartUnLongPressView), name: NSNotification.Name(rawValue: KLineChartUnLongPress), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLandScapeChartView), name: NSNotification.Name(rawValue: KLineUperChartDidTap), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLandScapeChartView), name: NSNotification.Name(rawValue: TimeLineChartDidTap), object: nil)
    }
    
    func addChartController() {
        // 分时线
        let timeViewcontroller = ChartViewController()
        timeViewcontroller.chartType = HSChartType.timeLineForDay
        controllerArray.append(timeViewcontroller)
        
        // 五日分时线
        let fiveDayTimeViewController = ChartViewController()
        fiveDayTimeViewController.chartType = HSChartType.timeLineForFiveday
        controllerArray.append(fiveDayTimeViewController)
        
        // 日 K 线
        let kLineViewController = ChartViewController()
        kLineViewController.chartType = HSChartType.kLineForDay
        controllerArray.append(kLineViewController)
        
        // 周 K 线
        let weeklyKLineViewController = ChartViewController()
        weeklyKLineViewController.chartType = HSChartType.kLineForWeek
        controllerArray.append(weeklyKLineViewController)
        
        // 月 K 线
        let monthlyKLineViewController = ChartViewController()
        monthlyKLineViewController.chartType = HSChartType.kLineForMonth
        controllerArray.append(monthlyKLineViewController)
    }
    
    // 长按分时线图，显示摘要信息
    @objc func showLongPressView(_ notification: Notification) {
    }
    
    @objc func showUnLongPressView(_ notification: Notification) {
    }
    
    // 长按 K线图，显示摘要信息
    @objc func showKLineChartLongPressView(_ notification: Notification) {
    }
    
    @objc func showKLineChartUnLongPressView(_ notification: Notification) {
    }
    
    // 跳转到横屏页面展示
    @objc func showLandScapeChartView(_ notification: Notification) {
    }
}


// MARK: - SegmentMenuDelegate

extension ViewController: SegmentMenuDelegate {
    
    func menuButtonDidClick(index: Int) {
        currentShowingChartVC?.willMove(toParent: nil)
        currentShowingChartVC?.view.removeFromSuperview()
        currentShowingChartVC?.removeFromParent()
        
        let selectedVC = self.controllerArray[index] as! ChartViewController
        selectedVC.chartRect = CGRect(x: 0, y: 0, width: ScreenWidth, height: 300)
        selectedVC.view.frame = CGRect(x: 0, y: segmentMenu.frame.maxY, width: ScreenWidth, height: 300)
        
        addChild(selectedVC)
        if (selectedVC.view.superview == nil){
            view.addSubview(selectedVC.view)
        }
        selectedVC.didMove(toParent: self)
        
        currentShowingChartVC = selectedVC
    }
}

