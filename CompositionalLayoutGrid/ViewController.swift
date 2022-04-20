//
//  ViewController.swift
//  CompositionalLayoutGrid
//
//  Created by Kevin Hoàng on 19.04.22.
//

import UIKit

class ViewController: UIViewController {
    
    enum Section: CaseIterable {
        case colors
    }
    
    var viewModel: ViewModel!
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, CellContent>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        navigationItem.title = "Compositional Layout"
        
        viewModel = ViewModel()
        viewModel.delegate = self
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.reuseIdentifier)
        
        collectionView.prefetchDataSource = self
        
        createDataSource()
    }
    
    private func configure<T: ImageCell>(with cellContent: CellContent, for indexPath: IndexPath) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Unable to dequeue \(ImageCell.self)")
        }
        
        cell.configure(with: cellContent)
        return cell
    }
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, CellContent>(collectionView: collectionView, cellProvider: { collectionView, indexPath, cellContent in
            return self.configure(with: cellContent, for: indexPath)
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, CellContent>()
        snapshot.appendSections(Section.allCases)
        
        for section in Section.allCases {
            snapshot.appendItems(viewModel.contents, toSection: section)
        }
        
        dataSource?.apply(snapshot)
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let insets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        let topGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
        
        let topSmallItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        let topLargeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1))
        
        let topSmallItem = NSCollectionLayoutItem(layoutSize: topSmallItemSize)
        topSmallItem.contentInsets = insets
        
        let topLargeItem = NSCollectionLayoutItem(layoutSize: topLargeItemSize)
        topLargeItem.contentInsets = insets
        
        let topGroup = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize, subitems: [topSmallItem, topLargeItem])
        
        let midLargeItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1))
        let midSmallItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2))
        
        let midLargeItem = NSCollectionLayoutItem(layoutSize: midLargeItemSize)
        midLargeItem.contentInsets = insets
        let midSmallItem = NSCollectionLayoutItem(layoutSize: midSmallItemSize)
        midSmallItem.contentInsets = insets
        
        let midNestedGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1))
        
        let midNestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: midNestedGroupSize, subitems: [midSmallItem])
        
        let midGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/2))
        
        let midGroup = NSCollectionLayoutGroup.horizontal(layoutSize: midGroupSize, subitems: [midLargeItem, midNestedGroup])
        
        let bottomItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1/4))
        
        let bottomItem = NSCollectionLayoutItem(layoutSize: bottomItemSize)
        bottomItem.contentInsets = insets
        
        
        // reversed
        let topGroup2 = NSCollectionLayoutGroup.horizontal(layoutSize: topGroupSize, subitems: [topLargeItem, topSmallItem])
        let midGroup2 = NSCollectionLayoutGroup.horizontal(layoutSize: midGroupSize, subitems: [midNestedGroup, midLargeItem])
        
        let fullGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(650))
        let fullGroup = NSCollectionLayoutGroup.vertical(layoutSize: fullGroupSize, subitems: [topGroup, midGroup, bottomItem, topGroup2, midGroup2, bottomItem])
        
        let section = NSCollectionLayoutSection(group: fullGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
}

extension ViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        // no ideal solution but it works
        for _ in 0..<indexPaths.count {
            viewModel.getImage()
        }
    }
}

extension ViewController: ViewModelDelegate {
    func didLoad() {
        reloadData()
    }
}
