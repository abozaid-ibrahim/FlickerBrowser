//
//  SearchRepoTests.swift
//  FlickerBrowserTests
//
//  Created by abuzeid on 20.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

@testable import FlickerBrowser
import XCTest

final class SearchRepoTests: XCTestCase {
    func testAddDeleteSearchItems() throws {
        let repo = SearchRepository()
        repo.clear()
        XCTAssertTrue(repo.getAll().isEmpty)
        repo.insert(search: "Hello")
        repo.insert(search: "Hello")
        XCTAssertEqual(repo.getAll().count, 1)
        repo.insert(search: "He")
        repo.insert(search: "Ha")
        XCTAssertEqual(repo.getAll(start: "He").first, "He")
        XCTAssertEqual(repo.getAll(start: "He").count, 2)
    }
}
