//
//  AlbumCollectionCell.swift
//  MusicPlayer
//
//  Created by abuzeid on 07.08.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import UIKit

final class AlbumCollectionCell: UICollectionViewCell {
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
