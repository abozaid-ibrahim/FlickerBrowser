//
//  PhotoCollectionCell.swift
//  FlickerBrowser
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import UIKit

final class PhotoCollectionCell: UICollectionViewCell {
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var nameLabel: UILabel!

    private var imageLoader: Disposable?
    func setData(with session: Photo) {
        imageLoader = imageView.setImage(of: session)
        nameLabel.text = session.title
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.cornerRadius = 12
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoader?.dispose()
    }
}
