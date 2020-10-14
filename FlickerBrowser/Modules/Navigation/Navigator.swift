//
//  Navigator.swift
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import UIKit

final class AppNavigator {
    static let shared = AppNavigator()
    private static var homeNavigationController: UINavigationController!

    private init() {}

    func set(window: UIWindow) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            let splitViewController = UISplitViewController()
            let masterNavigationController = UINavigationController(rootViewController: Destination.contactsList.controller)
            let detailsNavigationController = UINavigationController(rootViewController: Destination.contactDetails(of: nil).controller)
            splitViewController.viewControllers = [masterNavigationController, detailsNavigationController]
            splitViewController.preferredDisplayMode = .allVisible
            AppNavigator.homeNavigationController = masterNavigationController
            window.rootViewController = splitViewController

        } else {
            AppNavigator.homeNavigationController = UINavigationController(rootViewController: Destination.contactsList.controller)
            window.rootViewController = AppNavigator.homeNavigationController
        }
        window.makeKeyAndVisible()
    }

    func push(_ dest: Destination) {
        AppNavigator.homeNavigationController.pushViewController(dest.controller, animated: true)
    }
}
