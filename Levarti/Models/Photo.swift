//
//  Photo.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import Foundation
import RxDataSources

struct Photo: Codable {
    let albumId: Int
    let id: Int
    let title: String
    let url: String
    let thumbnailUrl: String
}

struct PhotoSectionModel {
    var items: [Photo]
}

extension PhotoSectionModel: SectionModelType {
    typealias Item = Photo

    init(original: PhotoSectionModel, items: [PhotoSectionModel.Item]) {
        self = original
        self.items = items
    }
}
