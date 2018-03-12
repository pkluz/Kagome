//
//  AppDelegate.swift
//  KagomeDemo
//
//  Created by Philip Kluz on 2018-03-11.
//  Copyright © 2018 Philip Kluz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.backgroundColor = .black
        window?.rootViewController = UINavigationController(rootViewController: ViewController())
        window?.rootViewController?.view.backgroundColor = .white
        window?.makeKeyAndVisible()
        
        return true
    }
}
