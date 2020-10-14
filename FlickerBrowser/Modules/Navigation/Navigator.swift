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
    private static var rootController: UINavigationController!

    private init() {}

    func set(window: UIWindow) {
        AppNavigator.rootController = UINavigationController(rootViewController: Destination.photos.controller)
        window.rootViewController = AppNavigator.rootController
        window.makeKeyAndVisible()
    }
}
