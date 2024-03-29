//
//  RxBaseCollectionViewController.swift
//  VGCLIP
//
//  Created by mac on 2019/9/9.
//  Copyright © 2019 Mojy. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import MJRefresh

public extension UICollectionView {
    func isValid(indexPath: IndexPath) -> Bool {
        if indexPath.section >= numberOfSections {
          return false
        }
        if indexPath.row >= numberOfItems(inSection: indexPath.section) {
          return false
        }
        return true
    }
}

public extension HLCollectionView {
    func isValid(indexPath: IndexPath) -> Bool {
        return collectionView.isValid(indexPath: indexPath)
    }
}

open class HLCollectionViewController: HLViewController {

    lazy public var listView = HLCollectionView()
        .setFlowLayout(config: {[weak self] () -> (UICollectionViewLayout?) in
            return self?.generateFlowLayout()
        })
        .setCollectionViewConfig(config: {[weak self] (collectionView) in
            self?.setCollectionViewConfig(collectionView)
        })
        .setCellConfig(config: {(cell, indexPath) in
            self.cellControlBindConfig(cell, indexPath)
        })
        .selectedAction(action: {[weak self] (type) in
            self?.itemSelected(type)
        })
        .selectedIndexPathAction(action: {[weak self] (indexPath) in
            self?.itemSelected(indexPath)
        })
        .deselectedIndexPathAction(action: {[weak self] (indexPath) in
            self?.itemDeselected(indexPath)
        })
        .build()
    
    func isValid(indexPath: IndexPath) -> Bool {
        return listView.collectionView.isValid(indexPath: indexPath)
    }

    /// 布局
    open func generateFlowLayout() -> UICollectionViewLayout? {
        return nil
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white

        view.addSubview(listView)
        listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override open var viewModel: HLViewModel? {
        didSet {
            if let viewModel = viewModel {

                _ = cellEvent
                    .take(until:self.rx.deallocated)
                    .bind(to: viewModel.event)

                _ = listView.cellEvent
                    .take(until:self.rx.deallocated)
                    .bind(to: viewModel.event)

                _ = viewModel.items
                    .take(until:self.rx.deallocated)
                    .subscribe(onNext: {[unowned self] (sections) in
                        _ = self.listView.setSections(sections: sections)
                    })

                viewModel.refresh()
                initNoDataView()
            }
        }
    }

    // MARK: 扩展
    /// collectionView 设置扩展
    open func setCollectionViewConfig(_ collectionView: UICollectionView) {

    }

    /// cell内部控件绑定扩展
    open func cellControlBindConfig(_ cell: HLCollectionViewCell, _ indexPath: IndexPath) {
        self.viewModel?.cellControlBindConfig(cell, indexPath)
    }

    /// 选中事件
    open func itemSelected(_ type: HLCellType) {
        self.viewModel?.itemSelected(type)
    }
    
    open func itemSelected(_ indexPath: IndexPath) {
        self.viewModel?.itemSelected(indexPath: indexPath)
    }
    
    open func itemDeselected(_ indexPath: IndexPath) {
        self.viewModel?.itemDeselected(indexPath: indexPath)
    }

    override open func reloadData() {

        DispatchQueue.main.async { [weak self] in
            self?.listView.collectionView.reloadData()
        }
    }

    /// 无数据界面
    open var noDataView: UIView? {
        didSet {
            initNoDataView()
        }
    }

    public func setNoDataView(_ view: UIView?) -> Self {
        self.noDataView = view
        return self
    }

    var noDataViewDis: Disposable?
    open func initNoDataView() {

        noDataView?.removeFromSuperview()
        guard let emptyView = noDataView else { return }

        view.addSubview(emptyView)
        emptyView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        guard let viewModel = viewModel else { return }

        noDataViewDis?.dispose()
        noDataViewDis = viewModel
            .items
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (sections) in

                if sections.count == 0 || (sections.count == 1 && sections[0].items.count == 0) {
                    emptyView.isHidden = false
                    self.view.bringSubviewToFront(emptyView)
                } else {
                    emptyView.isHidden = true
                    self.view.sendSubviewToBack(emptyView)
                }
            })
    }
}

extension HLCollectionViewController {

    public func setItems(_ datas: [HLCellType]) -> Self {
        _ = listView.setItems(datas)
        return self
    }
    
    // 添加刷新
    public func addRefresh(isFooterEnable: Bool = true) {
        _ = listView.collectionView.mj_header = refreshHeader(block: {[weak self] in
            self?.viewModel?.refresh(type: .reload)
        })
        
        if isFooterEnable {
            _ = listView.collectionView.mj_footer = loadMoreFooter(block: {[weak self] in
                self?.viewModel?.refresh(type: .loadMore)
            })
        }
    }
    
    func refreshHeader(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> MJRefreshStateHeader {

        let header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in

            if (self?.listView.collectionView.mj_footer) != nil {
                self?.listView.collectionView.mj_footer?.resetNoMoreData()
            }

            self?.listView.collectionView.mj_footer?.resetNoMoreData()
            block?()

        }).then {

            $0.lastUpdatedTimeLabel?.isHidden = true
            $0.stateLabel?.isHidden = false

            $0.stateLabel?.textColor = config?.textColor ?? UIColor.lightGray
            $0.stateLabel?.font = config?.font ?? .pingfang(ofSize: 13)

//            let images = UIImage.getLoadingImages()
//            $0.setImages(images, duration: 1, for: .refreshing)
//            $0.setImages(images, duration: 1, for: .pulling)
        }

        return header
    }

    func loadMoreFooter(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> MJRefreshAutoFooter {

        return MJRefreshAutoNormalFooter.init(refreshingBlock: {
            block?()
        }).then {

            $0.stateLabel?.textColor = config?.textColor ?? .lightGray
            $0.stateLabel?.font = config?.font ?? .pingfang(ofSize: 13)
            $0.isRefreshingTitleHidden = false
            $0.isAutomaticallyRefresh = false

//            $0.setTitle(LocalizedString(""), for: .idle)
//            $0.setTitle(LocalizedString("释放即可刷新"), for: .pulling)
//            $0.setTitle(LocalizedString("正在加载更多数据"), for: .refreshing)
//            $0.setTitle(LocalizedString("暂无更多数据"), for: .noMoreData)

        }
    }
}
