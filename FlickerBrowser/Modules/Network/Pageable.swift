//
//  APIClient.swift
//  FlickerBrowser
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//
import Foundation

final class Page {
    var currentPage = 1
    var maxPages = 5
    var countPerPage = 100
    var isFetchingData = false
    var fetchedItemsCount = 0
    var shouldLoadMore: Bool {
        (currentPage <= maxPages) && (!isFetchingData)
    }

    var isFirstPage: Bool {
        currentPage == 1
    }

    func reset() {
        isFetchingData = false
        currentPage = 1
        fetchedItemsCount = 0
    }

    func newPage(fetched: Int, total: Int) {
        currentPage += 1
        fetchedItemsCount += fetched
        maxPages = total
    }
}
