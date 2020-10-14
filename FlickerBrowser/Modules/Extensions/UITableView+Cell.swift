//
//  UITableView+Cell.swift
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import UIKit

public extension UITableViewCell {
    static var identifier: String {
        return String(describing: self)
    }
}

public extension UITableView {
    /// WARNING: you must set the reuse identifier as same as the nib file name.
    func register<T: UITableViewCell>(_: T.Type) {
        let nib = UINib(nibName: T.identifier, bundle: Bundle(for: T.self))
        register(nib, forCellReuseIdentifier: T.identifier)
    }
}
