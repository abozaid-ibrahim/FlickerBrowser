//
//  SearchRepository.swift
//  FlickerBrowser
//
//  Created by abuzeid on 20.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
protocol SearchRepositoryType {
    func insert(search: String)
    func getAll() -> [String]
    func getAll(start with: String) -> [String]
    func clear()
}

final class SearchRepository: SearchRepositoryType {
    func insert(search: String) {
        var cach = getAll()
        if cach.contains(search) {
            return
        }
        cach.append(search)
        UserDefaults.standard.setValue(cach, forKey: CachingKeys.search.rawValue)
        UserDefaults.standard.synchronize()
    }

    func getAll() -> [String] {
        guard let object = UserDefaults.standard.value(forKey: CachingKeys.search.rawValue),
            let searchItems = object as? [String] else { return [] }
        return searchItems
    }

    func getAll(start with: String) -> [String] {
        return getAll().filter { $0.starts(with: with) }.sorted()
    }

    func clear() {
        UserDefaults.standard.setValue([], forKey: CachingKeys.search.rawValue)
        UserDefaults.standard.synchronize()
    }
}

enum CachingKeys: String {
    case search
}
