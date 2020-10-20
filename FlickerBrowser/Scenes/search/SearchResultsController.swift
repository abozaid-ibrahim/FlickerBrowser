//
//  SearchResultsController.swift
//  FlickerBrowser
//
//  Created by abuzeid on 20.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import UIKit

final class SearchResultsController: UIViewController, UITableViewDataSource {
    private var tableView = SelfSizedTableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.setConstrainsEqualToParentEdges()
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell() // tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = "Helo"
        return cell
    }
   
}

final class SelfSizedTableView: UITableView {
    var maxHeight: CGFloat = UIScreen.main.bounds.size.height-100

    override func reloadData() {
        super.reloadData()
        invalidateIntrinsicContentSize()
        layoutIfNeeded()
    }

    override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, maxHeight)
        return CGSize(width: contentSize.width, height: height)
    }
}
