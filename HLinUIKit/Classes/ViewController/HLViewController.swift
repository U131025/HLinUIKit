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
    
    public let scrollView = UIScrollView()
    open override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenW)
            make.height.greaterThanOrEqualTo(scrollView).offset(1)
        }
    }
}
