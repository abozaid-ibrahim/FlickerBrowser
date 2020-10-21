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
    var searchItems: PublishSubject<[String]> { get }
    var getItemsBeginsWith: PublishSubject<String> { get }
    var onSelectedItem: PublishSubject<String> { get }
    var saveNewSearchItem: PublishSubject<String> { get }
}

final class SearchResultsViewModel: SearchResultsViewModelType {
    let searchItems = PublishSubject<[String]>()
    let getItemsBeginsWith = PublishSubject<String>()
    let onSelectedItem = PublishSubject<String>()
    let saveNewSearchItem = PublishSubject<String>()

    private let disposeBag = DisposeBag()
    private let repo: SearchRepositoryType

    init(repo: SearchRepositoryType = SearchRepository()) {
        self.repo = repo
        getItemsBeginsWith.distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.searchItems.onNext(self.repo.getAll(start: text))
            }).disposed(by: disposeBag)

        saveNewSearchItem.distinctUntilChanged()
            .subscribe(onNext: { [weak self] text in
                self?.repo.insert(search: text)
            }).disposed(by: disposeBag)
    }
}
