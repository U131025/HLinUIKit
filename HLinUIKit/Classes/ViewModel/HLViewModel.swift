//
//  BaseViewModel.swift
//  Exchange
//
//  Created by mac on 2018/12/25.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import RxDataSources
import RxCocoa
import RxSwift
import SnapKit

/// 刷新类型
public enum HLRefreshType {
    case reload
    case loadMore
}
/// ViewModel基类
open class HLViewModel {
    /// 刷新类型
    public var refreshType = HLRefreshType.reload {
        didSet {
            if refreshType == .reload {
                self.page = 1
            } else {
                self.page += 1
            }
        }
    }
    /// 页面和页面大小
    public var page: Int = 1
    public var pageSize: Int = 20

    public var disposeBag = DisposeBag()
    public var disposable: Disposable?

    /// 数据源
    public var items = BehaviorRelay<[SectionModel<String, HLCellType>]>(value: [])

    public weak var viewController: HLViewController?

    /// 初始化
    public init(_ viewController: HLViewController? = nil) {
        self.viewController = viewController

        initConfig()
        bindConfig()
    }

    open func initConfig() {

    }
    
    open func release() {
        disposeBag = DisposeBag()
        self.viewController = nil
    }

    /// 释放
    deinit {
        self.release()
    }

    /// 自定义事件绑定
    public var event: Binder<(tag: Int, value: Any?)> {
        return Binder(self) { base, event in
            base.handleEvent(event: event)
        }
    }
    /// 自定义事件处理
    open func handleEvent(event: (tag: Int, value: Any?)) {

    }

    /// 选中处理
    open func itemSelected(_ type: HLCellType) {

    }    
   
    /// 序列
    open func itemSelected(indexPath: IndexPath) {

    }
    
    open func itemDeselected(type: HLCellType) {

    }
    
    open func itemDeselected(indexPath: IndexPath) {

    }
    
//    public func setSelectedCell(_ ip: IndexPath) {
//        guard let vc = viewController as? HLTableViewController else {
//            return
//        }
//
//        DispatchQueue.main.async {
//            vc.listView.selectRow(at: ip, animated: false, scrollPosition: .none)
//        }
//    }

    /// 刷新
    public let refreshEvent = PublishSubject<HLRefreshType>()
    open func refresh() {
        
        refresh(type: .reload)
        HLTableViewCell.defaultCellMarginValue = 16
    }

    open func refresh(type: HLRefreshType) {
        self.refreshType = type
        self.refreshEvent.onNext(type)
    }
    // 新增防抖
    open func refreshAction(type: HLRefreshType) {
        
    }
    
    public func endEditing(_ force: Bool = true) {
        DispatchQueue.main.async {
            self.viewController?.view.endEditing(force)
        }        
    }
    
    public func beginRefreshing() {
        if let vc = viewController as? HLTableViewController, vc.listView.mj_header?.isRefreshing == false {
            
            vc.listView.mj_header?.beginRefreshing()
        }
    }
    
    public func endRefreshing() {
        if let vc = viewController as? HLTableViewController {
            
            vc.listView.mj_header?.endRefreshing()
            vc.listView.mj_footer?.endRefreshing()
        }
    }
    
    public lazy var isLoadFinish: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLoadFinish == true {
                    if let vc = self.viewController as? HLTableViewController {
                        vc.listView.mj_footer?.endRefreshingWithNoMoreData()
                    } else if let vc = self.viewController as? HLCollectionViewController {
                        vc.listView.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                }
            }            
        }
    }
    /// 预加载处理
    open func preload(indexPath: IndexPath) {
        
    }

    /// 绑定处理
    open func bindConfig() {
        disposeBag = DisposeBag()
        
        refreshEvent
            .throttle(.seconds(1), latest: false, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] type in
                self?.refreshAction(type: type)
            }).disposed(by: disposeBag)
    }

    //cell内部控件绑定扩展
    open func cellConfig(_ cell: HLTableViewCell, _ indexPath: IndexPath) {
        if let cell = cell as? HLListTableViewCell {
            _ = cell.listView.selectedAction {[weak self] type in
                self?.itemSelected(type)
            }
            
            cell.listView.cellConfigSubject.subscribe(onNext: {[weak self] c, ip in
                self?.cellConfig(c, ip)
            }).disposed(by: cell.disposeBag)
        }
    }
    
    /// cell内部控件绑定扩展
    open func cellControlBindConfig(_ cell: HLCollectionViewCell, _ indexPath: IndexPath) {

    }
    
    open func calculateCellHeight(_ indexPath: IndexPath) -> CGFloat? {
        return nil
    }
    
    // 针对ScrollView
    lazy var scrollViewItemDisposeBag = DisposeBag()
    open func setupScrollViewItems(_ items: [HLCellType]) {
        
        DispatchQueue.main.async {
            guard let vc = self.viewController as? HLScrollViewController else {
                return
            }
            
            vc.scrollView.subviews.forEach { view in
                if let cell = view as? HLTableViewCell {
                    cell.disposeBag = DisposeBag()
                }
                view.removeFromSuperview()
            }
            self.scrollViewItemDisposeBag = DisposeBag()
                            
            var preView: UIView?
            for (index, item) in items.enumerated() {
                
                let height = item.cellHeight
                if let view = item.createView() {
                                        
                    if let cell = view as? HLTableViewCell {
                        self.cellConfig(cell, IndexPath(row: index, section: 0))
                        cell.cellEvent.bind(to: self.event).disposed(by: cell.disposeBag)
                        
                       
                        if let _ = cell as? HLCollectionsTableViewCell {
                            
                        } else if let _ = cell as? HLListTableViewCell {
                            
                        } else if let _ = cell as? HLCustomTableViewCell {
                            
                        } else if let _ = cell as? HLVerticalViewsCell {
                            
                        } else {
                            view.rx.tapGesture().when(.recognized)
                                .subscribe(onNext: {[weak self] _ in
                                    self?.itemSelected(item)
                                })
                                .disposed(by: cell.disposeBag)
                        }
                                                
                    } else if let cell = view as? HLCollectionViewCell {
                        self.cellControlBindConfig(cell, IndexPath(row: index, section: 0))
                        cell.cellEvent.bind(to: self.event).disposed(by: cell.disposeBag)
                    }
                                                            
                    var offsetY: CGFloat = 0
                    if let preView = preView {
                        offsetY = preView.frame.maxY
                    }

                    view.frame = CGRect(x: 0, y: offsetY, width: kScreenW, height: height)
                    
                    vc.scrollView.addSubview(view)
                    vc.scrollView.contentSize = CGSize(width: kScreenW, height: view.frame.maxY)
                    
//                    view.snp.remakeConstraints { make in
//                        make.left.right.equalToSuperview()
//                        make.width.equalTo(kScreenW)
//                        make.height.equalTo(height)
//                        if let preView = preView {
//                            make.top.equalTo(preView.snp.bottom)
//                        } else {
//                            make.top.equalTo(0)
//                        }
//
//                        if index == (items.count - 1) {
//                            make.bottom.lessThanOrEqualTo(vc.scrollView.snp.bottom).offset(-10)
//                        }
//                    }
                    preView = view
                }
            }
            
            vc.view.layoutIfNeeded()
        }
    }
    
    public func updateScrollViewLayout() {
        
        DispatchQueue.main.async {
            guard let vc = self.viewController as? HLScrollViewController else {
                return
            }
            
            let oldOffset = vc.scrollView.contentOffset
            
            var preView: UIView?
            for view in vc.scrollView.subviews {
                
                guard let cell = view as? HLTableViewCell, let config = cell.cellType else {
                    continue
                }
                
                var offsetY: CGFloat = 0
                if let preView = preView {
                    offsetY = preView.frame.maxY
                }
                
                view.frame = CGRect(x: 0, y: offsetY, width: kScreenW, height: config.cellHeight)
                vc.scrollView.contentSize = CGSize(width: kScreenW, height: view.frame.maxY)
                                    
                preView = view
            }
            vc.scrollView.contentOffset = oldOffset
            vc.view.layoutIfNeeded()
        }
    }
}

extension HLViewModel {
    
    public func getItemValue(with ip: IndexPath) -> HLCellType? {
        return items.value[safe: ip.section]?.items[safe: ip.row]
    }

    public func setItems(_ datas: [HLCellType]) -> Self {
        items.accept([SectionModel(model: "list", items: datas)])
        
        if let _ = self.viewController as? HLScrollViewController {
            setupScrollViewItems(datas)
        }        
        return self
    }

    public func setSections(sections: [SectionModel<String, HLCellType>]) -> Self {
        items.accept(sections)
        return self
    }
    
    public func reloadItemsAtIndexPaths(_ ips: [IndexPath]) {
        
        if let vc = viewController as? HLTableViewController {
            vc.listView.reloadItemsAtIndexPaths(ips, animationStyle: .none)
        }
    }
}
// MARK: 列表选中
extension HLViewModel {

    public func getSelectedItems() -> [HLCellType] {
        if let vc = viewController as? HLTableViewController {
            return vc.listView.getSelectedRows()
        }
        return []
    }
    
    public func setSelectedIndexPath(_ indexPath: IndexPath, isSelected: Bool = true) {
        guard let vc = viewController as? HLTableViewController else {
            return
        }
        DispatchQueue.main.async {
            if isSelected {
                vc.listView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                vc.listView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    public func setSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        for ip in indexPaths {
            setSelectedIndexPath(ip)
        }
    }
    
    public func getSelectedIndexPath() -> IndexPath? {
        guard let vc = viewController as? HLTableViewController else {
            return nil
        }
        
        return vc.listView.indexPathForSelectedRow
    }
    
    public func getIndexPathsForSelectedRows() -> [IndexPath] {
        guard let vc = viewController as? HLTableViewController else {
            return []
        }
        
        return vc.listView.indexPathsForSelectedRows ?? []
    }
    
    public func reloadRows(_ indexPaths: [IndexPath]) {
        guard let vc = viewController as? HLTableViewController else {
            return
        }
        
        DispatchQueue.main.async {
            vc.listView.beginUpdates()
            vc.listView.reloadRows(at: indexPaths, with: .none)
            vc.listView.endUpdates()
        }
    }
}
