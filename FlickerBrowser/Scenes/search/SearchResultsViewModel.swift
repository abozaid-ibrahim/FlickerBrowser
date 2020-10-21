//
//  SearchResultsViewModel.swift
//  FlickerBrowser
//
//  Created by abuzeid on 20.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import RxSwift

protocol SearchResultsViewModelType {
    var dataList: [String] { get }
    var reloadFields: PublishSubject<CollectionReload> { get }
    var getItemsBeginsWith: PublishSubject<String> { get }
    var onSelectedItem: PublishSubject<String> { get }
    var saveNewSearchItem: PublishSubject<String> { get }
}

final class SearchResultsViewModel: SearchResultsViewModelType {
    let getItemsBeginsWith = PublishSubject<String>()
    let onSelectedItem = PublishSubject<String>()
    let saveNewSearchItem = PublishSubject<String>()
    private(set) var dataList: [String] = []
    private(set) var reloadFields = PublishSubject<CollectionReload>()
    private let disposeBag = DisposeBag()
    private let repo: SearchRepositoryType

    init(repo: SearchRepositoryType = SearchRepository()) {
        self.repo = repo
        getItemsBeginsWith
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.dataList = self.repo.getAll(start: text)
                self.reloadFields.onNext(.all)
            }).disposed(by: disposeBag)

        saveNewSearchItem
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.repo.insert(search: text)
            }).disposed(by: disposeBag)
    }
}
