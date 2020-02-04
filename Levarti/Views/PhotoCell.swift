//
//  PhotoCell.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import UIKit
import Kingfisher
class PhotoCell: UITableViewCell {

    static let identifier = "PhotoCell"
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarView: UIImageView!

    func configureCell(photo: Photo) {
        titleLabel.text = photo.title
        avatarView.kf.setImage(with: URL(string: photo.thumbnailUrl))
    }
}
