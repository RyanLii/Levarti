//
//  RootViewController.swift
//  Levarti
//
//  Created by Lee, Ryan on 2/3/20.
//  Copyright © 2020 Lee, Ryan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
class PhotosViewController: UIViewController {

    @IBOutlet weak var searchField: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let viewModel: PhotosViewModelType = PhotosViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        bindUI()
    }

    func bindUI() {
        // tableView
        let dataSource = PhotosViewController.dataSource()
        dataSource.canEditRowAtIndexPath = { dataSource, indexPath  in
            return true
        }

        viewModel.sections.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        tableView.rx
            .itemDeleted
            .subscribe(onNext: {self.viewModel.deleteItem(at: $0)})
            .disposed(by: disposeBag)

        // search field
        searchField.rx.text
            .orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: {self.viewModel.query(query: $0)})
            .disposed(by: disposeBag)

        // user state
        UserStateManager.shared
            .state
            .asObservable()
            .subscribe(onNext: { state in
                switch state {
                case .active: self.viewModel.fetch()
                case .inActive: self.presentLoginViewController()
                }
            })
            .disposed(by: disposeBag)
    }

    func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "Login")
        navigationController?.present(loginVC, animated: true)
    }
    func configureRefreshControl () {
        // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:
            #selector(handleRefreshControl),
                                            for: .valueChanged)
    }
    @objc func handleRefreshControl() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
            self.viewModel.fetch()
        }
    }
}
extension PhotosViewController {
    static func dataSource() -> RxTableViewSectionedReloadDataSource<PhotoSectionModel> {
        return RxTableViewSectionedReloadDataSource<PhotoSectionModel>(
            configureCell: { _, tableView, indexPath, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.identifier, for: indexPath) as? PhotoCell ?? PhotoCell(style: .default, reuseIdentifier: PhotoCell.identifier)
                cell.configureCell(photo: item)
                return cell
        })
    }
}
