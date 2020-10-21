//
//  SearchResultsController.swift
//  FlickerBrowser
//
//  Created by abuzeid on 20.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import RxSwift
import UIKit

final class SearchResultsController: UITableViewController {
    let viewModel = SearchResultsViewModel()
    private let disposeBag = DisposeBag()
    private var items: [String] { return viewModel.dataList }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
        viewModel.reloadFields
            .asDriver(onErrorJustReturn: .all)
            .drive(onNext: { [unowned self] _ in self.tableView.reloadData() })
            .disposed(by: disposeBag)
    }

    private func setupTable() {
        view.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear
        view.backgroundColor = .clear
        tableView.alwaysBounceVertical = false
        tableView.register(SearchResultTableCell.self)
    }
}

// MARK: - Table view data source

extension SearchResultsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultTableCell.identifier, for: indexPath) as! SearchResultTableCell
        cell.set(title: items[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.onSelectedItem.onNext(items[indexPath.row])
    }
}
