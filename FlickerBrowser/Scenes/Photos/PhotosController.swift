//
//  CollectionViewController.swift
//  FlickerBrowser
//
//  Created by abuzeid on 14.10.20.
//  Copyright © 2020 abuzeid. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

final class PhotosController: UICollectionViewController {
    private let viewModel: PhotosViewModelType
    private let disposeBag = DisposeBag()
    private var albums: [Photo] { viewModel.dataList }
    private let resultsController = SearchResultsController()

    init(viewModel: PhotosViewModelType) {
        self.viewModel = viewModel
        self.viewModel.loadPreviousSearches
            .bind(to: resultsController.viewModel.getItemsBeginsWith)
            .disposed(by: disposeBag)
        viewModel.searchFor
            .bind(to: resultsController.viewModel.saveNewSearchItem)
            .disposed(by: disposeBag)
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Unsupported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollection()
        bindToViewModel()
    }
}

// MARK: - setup

private extension PhotosController {
    func collection(reload: CollectionReload) {
        switch reload {
        case .all: collectionView.reloadData()
        case let .insertIndexPaths(paths): collectionView.insertItems(at: paths)
        }
    }

    func bindToViewModel() {
        viewModel.reloadFields
            .asDriver(onErrorJustReturn: .all)
            .drive(onNext: collection(reload:))
            .disposed(by: disposeBag)
        viewModel.isDataLoading
            .map { $0 ? CGFloat(50) : CGFloat(0) }
            .asDriver(onErrorJustReturn: 0)
            .drive(onNext: collectionView.updateFooterHeight(height:))
            .disposed(by: disposeBag)

        viewModel.error
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: show(error:))
            .disposed(by: disposeBag)
        viewModel.searchFor
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] _ in self?.resultsController.dismiss(animated: true, completion: nil) })
            .disposed(by: disposeBag)

        viewModel.loadData(for: .none)
    }

    func setupCollection() {
        title = Str.albumsTitle
        collectionView.register(PhotoCollectionCell.self)
        collectionView.register(ActivityIndicatorFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ActivityIndicatorFooterView.id)
        collectionView.setCell(type: .twoColumn)
        collectionView.prefetchDataSource = self
    }

    func setupSearchBar() {
        resultsController.viewModel.onSelectedItem.bind(to: viewModel.searchFor).disposed(by: disposeBag)
        let searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = Str.search
        viewModel.isSearchLoading
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak searchController] in
                searchController?.searchBar.isLoading = $0
            }).disposed(by: disposeBag)
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
}

// MARK: - UISearchResultsUpdating

extension PhotosController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        guard searchController.isActive else {
            viewModel.searchCanceled()
            return
        }
        guard let text = searchController.searchBar.text else { return }
        viewModel.loadPreviousSearches.onNext(text)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchFor.onNext(searchBar.text ?? "")
    }
}

// MARK: - UICollectionViewDataSource

extension PhotosController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath) as! PhotoCollectionCell
        cell.setData(with: albums[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: ActivityIndicatorFooterView.id,
                                                                   for: indexPath)

        default:
            fatalError("Unexpected element kind")
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension PhotosController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItemsAt(prefetch: true, indexPaths: indexPaths)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        viewModel.prefetchItemsAt(prefetch: false, indexPaths: indexPaths)
    }
}
