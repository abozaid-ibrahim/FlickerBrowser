//
//  Data+Codable.swift
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation

public extension Data {
    func parse<T: Decodable>() -> T? {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: self)
        } catch let error {
            print(error)
        }
        return nil
    }
}
