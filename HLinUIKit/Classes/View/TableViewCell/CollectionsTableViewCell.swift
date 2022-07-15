//
//  CollectionsTableViewCell.swift
//  Apartment
//
//  Created by mac on 2020/6/16.
//  Copyright © 2020 Fd. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class HLCollectionsTableViewCell: HLTableViewCell {
    
    static public var minimumInteritemSpacing: CGFloat = 0
    static public var minimumLineSpacing: CGFloat = 0

    lazy public var listView = HLCollectionView()
        .setFlowLayout(config: {[weak self] () -> (UICollectionViewLayout?) in
            return self?.generateFlowLayout()
        })
        .setCellConfig(config: { (cell, indexPath) in
            self.cellConfigBlock?(cell, indexPath)
            self.cellConfig(cell: cell, indexPath: indexPath)
        })
        .selectedAction(action: {[weak self] (type) in
            self?.itemSelected(type)
            self?.cellEvent.onNext((tag: 0, value: type))
        })
        .build()
    
    public var cellConfigBlock: HLCollectionCellConfigBlock?
    open func cellConfig(cell: HLCollectionViewCell, indexPath: IndexPath) {
        cellConfigBlock?(cell, indexPath)
    }
    
    public let itemSelectedSubject = PublishSubject<HLCellType>()
    open func itemSelected(_ type: HLCellType) {
        self.itemSelectedSubject.onNext(type)
    }

    /// 布局
    open func generateFlowLayout() -> UICollectionViewLayout? {
        return UICollectionViewFlowLayout().then { (layout) in
            layout.scrollDirection = .vertical
//            layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            layout.minimumInteritemSpacing = HLCollectionsTableViewCell.minimumInteritemSpacing
            layout.minimumLineSpacing = HLCollectionsTableViewCell.minimumLineSpacing
        }
    }

    override open func initConfig() {
        super.initConfig()

        contentView.addSubview(listView)
        listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override open func bindConfig() {
        super.bindConfig()

        listView.cellEvent.bind(to: event).disposed(by: disposeBag)
    }

    override open func updateData() {

        if let datas = data as? [HLCellType] {
            _ = listView.setItems(datas)
        }
    }
}
