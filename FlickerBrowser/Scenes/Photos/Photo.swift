//
//  Albums.swift
//  FlickerBrowser
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
struct PhotosResponse: Codable {
    let photos: Photos?
    let stat: String?
}

struct Photos: Codable {
    let page, pages, perpage: Int?
    let total: String?
    let photo: [Photo]?
}

struct Photo: Codable {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    let owner: String?
    let title: String?
}
