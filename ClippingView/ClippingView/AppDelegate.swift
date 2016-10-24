//
//  AppDelegate.swift
//  ClipView
//
//  Created by skyline on 16/6/14.
//  Copyright © 2016年 skyline. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootController = ClippingViewDemo()
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        
        return true
    }


}

