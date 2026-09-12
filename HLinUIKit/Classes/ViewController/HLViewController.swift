//
//  BaseViewController.swift
//  BluetoothTest
//
//  Created by mojingyu on 2019/3/20.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import MJRefresh

open class HLViewController: UIViewController {
    public var eventDisposeBag = DisposeBag()
    public var disposeBag = DisposeBag()
    public var cellEvent = PublishSubject<(tag: Int, value: Any?)>()

    public var viewModel: HLViewModel? {
        didSet {
            viewModel?.viewController = self
            bindConfig()
        }
    }
    
    deinit {
        viewModel?.release()
        viewModel = nil
    }
    
    public var barStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return barStyle
    }

//    open var statusBarStyle: UIBarStyle {
//        return .default
//    }

    public init() {
        super.init(nibName: nil, bundle: nil)
        initConfig()
        bindConfig()
        layoutConfig()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        initConfig()
        bindConfig()
        layoutConfig()
    }

    open func initConfig() {

    }

    open func bindConfig() {
        disposeBag = DisposeBag()
    }

    open func layoutConfig() {

    }

    open func reloadData() {

    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

    }
}

extension HLViewController {

    public func setViewModel(_ viewModel: HLViewModel) -> Self {
        self.viewModel = viewModel
        self.viewModel?.viewController = self
        return self
    }

    public func setTitle(_ title: String) -> Self {
        self.title = title
        return self
    }

    public func setPopAction(to aClassList: [AnyClass], _ backImage: UIImage? = "back".image) -> Self {

        _ = setBackButton(backImage)
            .take(until:self.rx.deallocated)
            .subscribe(onNext: { (_) in
                self.pop(to: aClassList)
            })

        return self
    }

    public func setPopAction(isToRoot: Bool = false, _ backImage: UIImage? = "back".image) -> Self {

        _ = setBackButton(backImage)
            .take(until:self.rx.deallocated)
            .subscribe(onNext: { (_) in
                self.pop(isToRoot)
            })

        return self
    }
}

open class HLScrollViewController: HLViewController {
    
    public var isUsedStackView: Bool = false {
        didSet {
            if isUsedStackView == true, hl_stackView.superview == nil {
                scrollView.addSubview(hl_stackView)
                hl_stackView.snp.makeConstraints { make in
                    make.left.right.top.bottom.equalToSuperview()
                    make.width.equalToSuperview()
                }
            } else if hl_stackView.superview != nil {
                hl_stackView.removeFromSuperview()
            }
        }
    }
    public lazy var hl_stackView = UIStackView().then { view in
        view.axis = .vertical
        view.spacing = 0
        view.distribution = .fillProportionally
        view.alignment = .leading
    }
        
    public let scrollView = UIScrollView()
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.contentSize = CGSize(width: kScreenW, height:kScreenH)
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.isScrollEnabled = true
    }
    
    public var backgroundColor: UIColor? {
        didSet {
            view.backgroundColor = backgroundColor
            scrollView.backgroundColor = backgroundColor
        }
    }
    
    public func addRefresh(isFooterEnable: Bool = true) {
        _ = scrollView.setRefreshHeader(block: {[weak self] in
            self?.viewModel?.refresh(type: .reload)
        })
        
        if isFooterEnable {
            _ = scrollView.setLoardMoreFooter(block: { [weak self] in
                self?.viewModel?.refresh(type: .loadMore)
            })
        }
    }
    
    open func setupItems(_ items: [HLCellType], config:((UIView, Int, HLCellType) -> Void)? = nil, width: CGFloat = kScreenW) {
        
        for view in hl_stackView.subviews {
            hl_stackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }
        
        for (index, item) in items.enumerated() {
           
            if let c = item as? HLCustomTableViewConfig, let view = c.customView {
                
                hl_stackView.addArrangedSubview(view)
                view.snp.makeConstraints { make in
                    make.width.equalTo(c.cellSize.width)
                    make.height.equalTo(c.cellSize.height)
                }
                config?(view, index, item)
                
            } else if let view = item.createView() {
                hl_stackView.addArrangedSubview(view)
                view.snp.makeConstraints { make in
                    make.height.equalTo(item.cellHeight)
                }
                config?(view, index, item)
            }
        }
    }
}
