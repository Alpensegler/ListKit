//
//  AppDelegate.swift
//  ListKitExample
//
//  Created by Frain on 2020/4/23.
//

import ListKit
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ListKit.Log.logger = { print($0) }

        window = UIWindow()
        window?.rootViewController = UINavigationController(rootViewController: ContentsViewController())
        window?.makeKeyAndVisible()
        return true
    }
}
