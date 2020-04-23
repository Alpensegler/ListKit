//
//  AppDelegate.swift
//  ListKitExample
//
//  Created by Frain on 2020/4/23.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: ContentsViewController())
        window?.makeKeyAndVisible()
        return true
    }
}

