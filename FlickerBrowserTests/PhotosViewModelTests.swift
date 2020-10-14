//
//  FlickerBrowserTests.swift
//  FlickerBrowserTests
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

@testable import FlickerBrowser
import RxCocoa
import RxSwift
import RxTest
import XCTest

final class FlickerBrowserTests: XCTestCase {
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        disposeBag = nil
    }

//    func testLoadingFromAPIClient() throws {
//    let         viewModel = PhotosViewModel(apiClient: MockedSuccessAPIClient())

//        let schedular = TestScheduler(initialClock: 0)
//        let reloadObserver = schedular.createObserver(CollectionReload.self)
//        viewModel.reloadFields.bind(to: reloadObserver).disposed(by: disposeBag)
//
//        schedular.scheduleAt(0, action: { self.viewModel.loadData(for: "Car") })
//        schedular.start()
//
//        XCTAssertEqual(reloadObserver.events, [.next(0, .all)])
//        XCTAssertEqual(viewModel.dataList.count, 3)
//    }

    func testLoadingMultiplePages() throws {
        let schedular = TestScheduler(initialClock: 0, resolution: 0.001)
//        SharingScheduler.mock(scheduler: schedular) {
            let viewModel = PhotosViewModel(apiClient: MockedSuccessAPIClient())
            let reloadObserver = schedular.createObserver(CollectionReload.self)
            viewModel.reloadFields.bind(to: reloadObserver).disposed(by: disposeBag)
            
        schedular.scheduleAt(0, action: { viewModel.searchFor.onNext("Cat") })
            schedular.scheduleAt(400, action: { prefetch(row: 2) })
            schedular.scheduleAt(500, action: { prefetch(row: 5) })
            schedular.scheduleAt(600, action: { prefetch(row: 5) })
            let secondPage = [3, 4, 5].map { IndexPath(row: $0, section: 0) }
            let thirdPage = [6, 7, 8].map { IndexPath(row: $0, section: 0) }
            schedular.start()

            XCTAssertEqual(reloadObserver.events, [.next(300, .all),
                                                   .next(400, .insertIndexPaths(secondPage)),
                                                   .next(500, .insertIndexPaths(thirdPage))])
            func prefetch(row: Int) {
                viewModel.prefetchItemsAt(prefetch: true, indexPaths: [.init(row: row, section: 0)])
            }
//        }
    }

//    func testAPIFailure() throws {
//        let schedular = TestScheduler(initialClock: 0)
//        let errorObserver = schedular.createObserver(String.self)
//        let viewModel = PhotosViewModel(apiClient: MockedFailureApi())
//        viewModel.error.bind(to: errorObserver).disposed(by: disposeBag)
//
//        schedular.scheduleAt(1, action: { viewModel.loadData() })
//        schedular.start()
//
//        XCTAssertEqual(errorObserver.events, [.next(1, NetworkError.failedToParseData.localizedDescription)])
//    }
}

final class MockedFailureApi: ApiClient {
    func getData(of request: RequestBuilder, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let data = "{photos:1}".data(using: .utf8)
        completion(.success(try! JSONEncoder().encode(data)))
    }
}

final class MockedSuccessAPIClient: ApiClient {
    func getData(of request: RequestBuilder, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        let data = """
        {
                "photos": {
                "pages": 3,
                "photo": [
                {
                "id": "1",
                "secret": "aff287813e",
                "server": "65535",
                "farm": 66,
                "title": "Monica On Weather Station ♣"
                },{
               "id": "2",
               "secret": "aff287813e",
               "server": "65535",
               "farm": 66,
               "title": "Monica On Weather Station ♣"
               },{
               "id": "3",
               "secret": "aff287813e",
               "server": "65535",
               "farm": 66,
               "title": "Monica On Weather Station ♣"
               }]}}
        """.data(using: .utf8)!
        completion(.success(data))
    }
}
