//
//  PhotosViewModel.swift
//  FlickerBrowser
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import RxSwift

enum CollectionReload {
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
    func loadData()
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
    private var isSearchingMode = false
    private var sessionsList: [Photo] = []
    private var searchResultList: [Photo] = []

    private(set) var reloadFields = PublishSubject<CollectionReload>()

    init(apiClient: ApiClient = HTTPClient()) {
        self.apiClient = apiClient
        bindForSearch()
    }

    var dataList: [Photo] {
        isSearchingMode ? searchResultList : sessionsList
    }

    func searchCanceled() {
        isSearchingMode = false
        reloadFields.onNext(.all)
    }

    func loadData() {
        guard page.shouldLoadMore else {
            return
        }
        page.isFetchingData = true
        isDataLoading.onNext(true)
//        let api: Observable<PhotosResponse?> = apiClient.getData(of: PhotosAPI.search(""))
//        let concurrentScheduler = ConcurrentDispatchQueueScheduler(qos: .background)
//        api.subscribeOn(concurrentScheduler)
//            .delay(DispatchTimeInterval.seconds(0), scheduler: concurrentScheduler)
//            .subscribe(onNext: { [weak self] response in
//                self?.updateUI(with: response?.pho.sessions ?? [])
//            }, onError: { [weak self] err in
//                self?.error.onNext(err.localizedDescription)
//                self?.isDataLoading.onNext(false)
//            }).disposed(by: disposeBag)
//
//
        apiClient.getData(of: PhotosAPI.search("car")) { [weak self] result in
            switch result {
            case let .success(data):
                if let response: PhotosResponse? = data.parse() {
                    self?.updateUI(with: response?.photos?.photo ?? [])
                } else {
                    self?.error.onNext(NetworkError.failedToParseData.localizedDescription)
                }
            case let .failure(error):
                self?.error.onNext(error.localizedDescription)
            }
            self?.isDataLoading.onNext(false)
        }
    }

    func prefetchItemsAt(prefetch: Bool, indexPaths: [IndexPath]) {
        guard let max = indexPaths.map({ $0.row }).max(), !isSearchingMode else { return }
        if page.fetchedItemsCount <= (max + 1) {
            prefetch ? loadData() : ()
        }
    }
}

// MARK: private

private extension PhotosViewModel {
    func updateUI(with sessions: [Photo]) {
        isDataLoading.onNext(false)
        let startRange = sessionsList.count
        sessionsList.append(contentsOf: sessions)
        if page.currentPage == 0 {
            reloadFields.onNext(.all)
        } else {
            let rows = (startRange ... sessionsList.count - 1).map { IndexPath(row: $0, section: 0) }
            reloadFields.onNext(.insertIndexPaths(rows))
        }
        updatePage(with: sessionsList.count)
    }

    func bindForSearch() {
//        searchFor.distinctUntilChanged()
//            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
//            .subscribe(onNext: { [unowned self] text in
//                self.isSearchLoading.onNext(true)
//                let endpoint: Observable<AlbumsResponse?> = self.apiClient.getData(of: AlbumsApi.search(text))
//                endpoint.subscribe(onNext: { [weak self] value in
//                    guard let self = self else{return}
//                    self.isSearchingMode = true
//                    self.searchResultList = value?.data.sessions ?? []
//                    self.reloadFields.onNext(.all)
//                    self.isSearchLoading.onNext(false)
//                }, onError: { [unowned self] err in
//                    self.error.onNext(err.localizedDescription)
//                    self.isSearchLoading.onNext(false)
//                }).disposed(by: self.disposeBag)
//            }).disposed(by: disposeBag)
    }

    func updatePage(with count: Int) {
        page.isFetchingData = false
        page.currentPage += 1
        page.fetchedItemsCount = count
    }
}
