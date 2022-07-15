//
//  HorListTableViewCell.swift
//  Community
//
//  Created by mac on 2019/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class HLHorListTableViewCell: HLCollectionsTableViewCell {

    public var minimumLineSpacing: CGFloat = 15 {
        didSet {
            
            if oldValue == minimumLineSpacing {
                return
            }
            
            if let flowLayout = generateFlowLayout() {
                DispatchQueue.main.async {
                    self.listView.collectionView.setCollectionViewLayout(flowLayout, animated: false)
                }
            }
        }
    }
    
    /// 布局
    override open func generateFlowLayout() -> UICollectionViewLayout? {
        return UICollectionViewFlowLayout().then { (layout) in
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = minimumLineSpacing
//            layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        }
    }

    override open func initConfig() {
        super.initConfig()

        listView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15))
        }
    }
}
