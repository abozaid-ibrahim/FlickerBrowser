//
//  PhotosViewModel.swift
//  FlickerBrowser
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

enum CollectionReload: Equatable {
    case all
    case insertIndexPaths([IndexPath])
}

protocol PhotosViewModelType {
    var dataList: [Photo] { get }
    var error: PublishSubject<String> { get }
    var searchFor: PublishSubject<String> { get }
    var isDataLoading: PublishSubject<Bool> { get }
    var isSearchLoading: PublishSubject<Bool> { get }
    var reloadFields: PublishSubject<CollectionReload> { get }
    func searchCanceled()
    func loadData(for text: String?)
    func prefetchItemsAt(prefetch: Bool, indexPaths: [IndexPath])
}

final class PhotosViewModel: PhotosViewModelType {
    let error = PublishSubject<String>()
    let searchFor = PublishSubject<String>()
    let isDataLoading = PublishSubject<Bool>()
    let isSearchLoading = PublishSubject<Bool>()
    private let disposeBag = DisposeBag()
    private let apiClient: ApiClient
    private var page = Page()
    private var searchText = "Tree" // Default search keyword
    private(set) var reloadFields = PublishSubject<CollectionReload>()

    init(apiClient: ApiClient = HTTPClient()) {
        self.apiClient = apiClient
        bindForSearch()
    }

    var dataList: [Photo] = []

    func searchCanceled() {
        reloadFields.onNext(.all)
    }

    func loadData(for text: String? = nil) {
        guard page.shouldLoadMore else {
            return
        }
        page.isFetchingData = true
        isDataLoading.onNext(true)
        apiClient.getData(of: PhotosAPI.search(for: text ?? searchText, page: page.currentPage)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(data):
                if let response: PhotosResponse? = data.parse() {
                    self.updateUI(with: response?.photos?.photo ?? [])
                    self.page.newPage(fetched: self.dataList.count, total: response?.photos?.pages ?? 0)
                } else {
                    self.error.onNext(NetworkError.failedToParseData.localizedDescription)
                }
            case let .failure(error):
                self.error.onNext(error.localizedDescription)
            }
            self.isDataLoading.onNext(false)
        }
    }

    func prefetchItemsAt(prefetch: Bool, indexPaths: [IndexPath]) {
        guard let max = indexPaths.map({ $0.row }).max() else { return }
        if page.fetchedItemsCount <= (max + 1) {
            prefetch ? loadData() : ()
        }
    }
}

// MARK: private

private extension PhotosViewModel {
    func updateUI(with photos: [Photo]) {
        isDataLoading.onNext(false)
        let startRange = dataList.count
        dataList.append(contentsOf: photos)
        if page.isFirstPage {
            reloadFields.onNext(.all)
        } else {
            let rows = (startRange ... dataList.count - 1).map { IndexPath(row: $0, section: 0) }
            reloadFields.onNext(.insertIndexPaths(rows))
        }
    }

    func bindForSearch() {
        searchFor.distinctUntilChanged()
            .debounce(.milliseconds(300), scheduler: SharingScheduler.make())
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                self.reset()
                self.loadData(for: text)
            }).disposed(by: disposeBag)
    }

    func reset() {
        page.reset()
        dataList.removeAll()
        reloadFields.onNext(.all)
    }
}
