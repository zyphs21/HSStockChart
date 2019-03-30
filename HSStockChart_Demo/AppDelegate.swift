//
//  AppDelegate.swift
//  HSStockChart-Demo
//
//  Created by Hanson on 2017/10/12.
//  Copyright © 2017年 HansonStudio. All rights reserved.
//

import UIKit
import GDPerformanceView_Swift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        PerformanceMonitor.shared().start()
//        PerformanceMonitor.shared().configure(configuration: { (textLabel) in
//            textLabel?.backgroundColor = .black
//            textLabel?.textColor = .white
//            textLabel?.layer.borderColor = UIColor.black.cgColor
//        })
        
        return true
    }
}

