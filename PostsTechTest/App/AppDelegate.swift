//
//  AppDelegate.swift
//  PostsTechTest
//
//  Created by Dimitris Chatzieleftheriou on 23/03/2019.
//  Copyright © 2019 Decimal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        AppController(window: window).start()
        self.window = window
        return true
    }

}

