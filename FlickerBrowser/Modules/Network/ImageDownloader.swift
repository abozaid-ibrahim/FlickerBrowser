//
//  ImageDownloader.swift
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import Foundation
import UIKit
typealias DownloadImageCompletion = (UIImage?) -> Void
protocol ImageDownloaderType {
    func downloadImageWith(url: URL, completion: DownloadImageCompletion?) -> Disposable?
}

public protocol Disposable {
    func dispose()
}

extension URLSessionDataTask: Disposable {
    public func dispose() {
        cancel()
    }
}

public final class ImageDownloader: ImageDownloaderType {
    func downloadImageWith(url: URL, completion: DownloadImageCompletion? = nil) -> Disposable? {
        let dataTask = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                let image = UIImage(data: data) else {
                completion?(nil)
                return
            }
            completion?(image)
        }
        dataTask.resume()
        return dataTask
    }
}

extension UIImageView {
    @discardableResult
    func setImage(of photo:Photo) -> Disposable? {
        guard let url = URL(string: "http://farm\(photo.farm).static.flickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg") else { return nil }
        print(url.absoluteString)
        return ImageDownloader().downloadImageWith(url: url, completion: { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image
            }
        })
    }
}
