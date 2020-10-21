//
//  SearchResultTableCell.swift
//  FlickerBrowser
//
//  Created by abuzeid on 21.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import UIKit

final class SearchResultTableCell: UITableViewCell {
    @IBOutlet private var titleLabel: UILabel!
    func set(title: String) {
        titleLabel.text = title
    }
}
