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

// MARK: - Photos

struct Photos: Codable {
    let page, pages, perpage: Int?
    let total: String?
    let photo: [Photo]?
}

// MARK: - Photo

struct Photo: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String?
    let ispublic, isfriend, isfamily: Int?
}
