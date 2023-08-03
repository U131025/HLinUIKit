//
//  RxBaseTableViewController.swift
//  VGCLIP
//
//  Created by mac on 2019/9/9.
//  Copyright © 2019 Mojy. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa

open class HLTableViewController: HLViewController, UITableViewDelegate {

    public var style: HLTableViewStyle = .normal
    
    fileprivate var itemSelectedBlock: HLItemSelectedBlock?
    fileprivate var itemSelectedIndexPathBlock: HLItemSelectedIndexPathBlock?
    fileprivate var itemDeselectedBlock: HLItemSelectedBlock?
    fileprivate var itemDeselectedIndexPathBlock: HLItemSelectedIndexPathBlock?

    lazy public var listView = HLTableView()
        .setStyle(self.style)
        .setTableViewConfig(config: {[weak self](tableView) in
            self?.setTableViewConfig(tableView)
        })
        .setCellConfig(config: {[weak self](cell, indexPath) in
            self?.cellConfig(cell, indexPath)
        })
        .selectedAction(action: {[weak self](type) in
            self?.itemSelected(type)
        })
        .selectedIndexPathAction(action: {[weak self](indexPath) in
            self?.itemSelected(indexPath: indexPath)
        })
        .setCalculateCellHeight({[weak self] (ip) -> CGFloat? in
            return self?.calculateCellHeight(ip)
        })
        .deselectedAction(action: {[weak self] (type) in
            self?.itemDeselected(type)
        })
        .deselectedIndexPathAction(action: {[weak self] (indexPath) in
            self?.itemDeselected(indexPath: indexPath)
        })
        .build()

    required public init(style: HLTableViewStyle = .normal) {
        self.style = style
        super.init()
    }

    required public init?(coder aDecoder: NSCoder) {

        self.style = .normal
        super.init(coder: aDecoder)        
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.listView)
        self.listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    override open var viewModel: HLViewModel? {
        didSet {
            self.viewModel?.viewController = self
            self.setupViewModel()
            self.initNoDataView()
            self.viewModel?.refresh()
        }
    }
    
    public var vmDisposeBag = DisposeBag()
    open func setupViewModel() {
        if let viewModel = self.viewModel {
           
            bindConfig()

            vmDisposeBag = DisposeBag()
            cellEvent
                .bind(to: viewModel.event)
                .disposed(by: vmDisposeBag)

            listView.cellEvent
                .bind(to: viewModel.event)
                .disposed(by: vmDisposeBag)

            viewModel.items
                .subscribe(onNext: {[weak self] (sections) in
                    _ = self?.listView.setSections(sections: sections)
                })
                .disposed(by: vmDisposeBag)
        }
    }
    
    open func calculateCellHeight(_ indexPath: IndexPath) -> CGFloat? {
        if let height = viewModel?.calculateCellHeight(indexPath) {
            return height
        }
        
        return nil
    }

    // MARK: 扩展
    /// collectionView 设置扩展
    open func setTableViewConfig(_ tableView: UITableView) {

    }

    /// cell内部控件绑定扩展
    open func cellConfig(_ cell: HLTableViewCell, _ indexPath: IndexPath) {
        self.viewModel?.cellConfig(cell, indexPath)
    }

    /// 选中事件
    open func itemSelected(_ type: HLCellType) {
        self.viewModel?.itemSelected(type)
        self.itemSelectedBlock?(type)
    }

    open func itemSelected(indexPath: IndexPath) {
        self.viewModel?.itemSelected(indexPath: indexPath)
        self.itemSelectedIndexPathBlock?(indexPath)
    }
    
    open func itemDeselected(_ type: HLCellType) {
        self.viewModel?.itemDeselected(type: type)
        self.itemDeselectedBlock?(type)
    }

    open func itemDeselected(indexPath: IndexPath) {
        self.viewModel?.itemDeselected(indexPath: indexPath)
        self.itemDeselectedIndexPathBlock?(indexPath)
    }

    /// 无数据界面，需要添加到ViewModel初始化后
    var _emptyView: UIView?
    open var noDataView: UIView? {
        set {
            _emptyView?.removeFromSuperview()
            _emptyView = newValue
            initNoDataView()
        }
        get {
            return _emptyView
        }
    }
    
    public lazy var emptyInset: UIEdgeInsets = .zero {
        didSet {
            let view = noDataView
            self.noDataView = view
        }
    }

    public func setNoDataView(_ view: UIView?) -> Self {
        self.noDataView = view
        return self
    }
    var emptyViewDisposable: Disposable?
    open func initNoDataView() {

        _emptyView?.removeFromSuperview()
        guard let emptyView = _emptyView else { return }
        guard let viewModel = viewModel else {
            return
        }

        emptyViewDisposable?.dispose()
        emptyViewDisposable = viewModel
            .items
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (sections) in
                
                emptyView.removeFromSuperview()
                if sections.count == 0 || (sections.count == 1 && sections[0].items.count == 0) {
    
                    self.view.insertSubview(emptyView, aboveSubview: self.listView)
                    emptyView.snp.remakeConstraints { (make) in
                        make.edges.equalTo(self.listView).inset(emptyInset)
                    }
                }
            })
    }
    // 添加刷新
    public func addRefresh(isFooterEnable: Bool = true) {
        _ = listView.setRefreshHeader(block: {[weak self] in
            self?.viewModel?.refresh(type: .reload)
        })
        
        if isFooterEnable {
            _ = listView.setLoardMoreFooter(block: { [weak self] in
                self?.viewModel?.refresh(type: .loadMore)
            })
        }
    }
}

extension HLTableViewController {

    public func setItems(_ datas: [HLCellType]) -> Self {
        _ = listView.setItems(datas)
        return self
    }

    public func selectedAction(_ block: HLItemSelectedBlock?) -> Self {
        self.itemSelectedBlock = block
        return self
    }

    public func selectedIndexPathAction(_ block: HLItemSelectedIndexPathBlock?) -> Self {
        self.itemSelectedIndexPathBlock = block
        return self
    }
}
