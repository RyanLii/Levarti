//
//  PhototsViewModel.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import RxSwift
import  RxRelay

protocol PhotosViewModelType {
    var sections: Observable<[PhotoSectionModel]> { get }
    func fetch()
    func query(query: String)
    func deleteItem(at indexPath: IndexPath)
}
class PhotosViewModel: PhotosViewModelType{

    let api: APIService

    private var _sections = BehaviorRelay<[PhotoSectionModel]>(value: [])
    lazy var sections: Observable<[PhotoSectionModel]>  = _sections.asObservable()

    let disposeBag = DisposeBag()
    init(api: APIService = APIService.default) {
        self.api = api
    }

    func fetch() {
        request(params: ["_start": "0", "_limit": "100"])
    }

    func query(query: String) {
        query.isEmpty ? fetch() : request(params: ["id": query])
    }

    func deleteItem(at indexPath: IndexPath) {
         var sections =  _sections.value
         var currentSection = sections[indexPath.section]
         currentSection.items.remove(at: indexPath.row)
         sections[indexPath.section] = currentSection
        self._sections.accept(sections)

        // todo: we need api support to delete the item in database
        /*
        api.request(endpoint: .delete, params: ["id": String(item.id)]) { (result: Result<[Photo], APIService.APIError>)  in
            switch result {
            case .success(let photos):
                self._sections.accept([PhotoSectionModel(items: photos)])
            case .failure(let error):
                print(error)
            }
        }
         */
    }

    private func request(params: [String: String]) {
        api.request(endpoint: .fetch, params: params) { (result: Result<[Photo], APIService.APIError>)  in
            switch result {
            case .success(let photos):
                self._sections.accept([PhotoSectionModel(items: photos)])
            case .failure(let error):
                print(error)
            }
        }
    }
}
