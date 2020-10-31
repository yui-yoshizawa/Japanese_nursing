//
//  AppDelegate.swift
//  tvOS
//
//  Created by Merrick Sapsford on 10/10/2020.
//  Copyright © 2020 UI At Six. All rights reserved.
//

import UIKit
import Pageboy

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let gradientColors: [UIColor] = [.pageboyPrimary, .pageboySecondary]
        
        let pageViewController = PageViewController()
        addStatusView(to: pageViewController)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = GradientBackgroundViewController(embedding: pageViewController, colors: gradientColors)
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
}

extension AppDelegate {
    
    private func addStatusView(to viewController: PageboyViewController) {
        
        let statusView = PageboyStatusView()
        viewController.delegate = statusView
        
        viewController.view.addSubview(statusView)
        statusView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(tvOS 11, *) {
            NSLayoutConstraint.activate([
                statusView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 32.0),
                viewController.view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 8.0)
            ])
        } else {
            NSLayoutConstraint.activate([
                statusView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 32.0),
                viewController.view.bottomAnchor.constraint(equalTo: statusView.bottomAnchor, constant: 8.0)
            ])
        }
    }
}
