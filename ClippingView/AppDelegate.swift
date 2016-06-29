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

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        let rootController = ClippingViewDemo()
        window?.rootViewController = rootController
        window?.makeKeyAndVisible()
        
        return true
    }


}

