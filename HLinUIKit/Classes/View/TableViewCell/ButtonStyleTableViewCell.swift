//
//  ButtonStyleTableViewCell.swift
//  JingPeng
//
//  Created by 屋联-神兽 on 2020/10/15.
//

import UIKit

public class HLButtonCellConfig: NSObject {
    public var title: String?
    public var titleColor: UIColor = .white
    public var title_disable: String?
    public var titleColor_disable: UIColor?
    
    public var alignment: NSTextAlignment = .center
    public var backgroundColor: UIColor?
    public var backgroundImage: UIImage?
    public var cornerRate: CGFloat? = 4
    public var icon: UIImage?
    public var iconLayoutType: UPButtonEdgeInsetsStyle = .left
    public var isEnable: Bool = true
    public var showLoading: Bool?
    
    public var font: UIFont = .pingfang(ofSize: 15, .medium)
    public var borderColor: UIColor = .clear
    public var tag: Int = 0
    
    public var height: CGFloat = 44
    public var width: CGFloat?
    public var marginValue: CGFloat = 16
    
//    public init() {
//    }
}

extension HLButtonCellConfig: HLCellType {
    public var cellClass: AnyClass {
        return ButtonStyleTableViewCell.self
    }
    
    public var cellHeight: CGFloat {
        return height
    }
}

open class ButtonStyleTableViewCell: HLTableViewCell {
    
    public lazy var loadingView = UIActivityIndicatorView().then { view in
        view.hidesWhenStopped = true
    }
        
    public var customView: UIView?
    public var marginValue: CGFloat = 16 {
        didSet {
            DispatchQueue.main.async {
                self.commitButton.snp.remakeConstraints { (make) in
                    make.center.equalToSuperview()
                    make.left.right.equalToSuperview().inset(self.marginValue)
                    make.height.equalToSuperview()
                }
            }
            
        }
    }

    public var commitButton = UIButton().then { (button) in
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
    }

    open override func initConfig() {
        super.initConfig()

        backgroundColor = .clear
         
        bodyView.addSubview(commitButton)
        commitButton.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }

    open override func updateData() {

        if let config = data as? HLButtonCellConfig {

            tag = config.tag

            if let color = config.backgroundColor {
                commitButton.backgroundColor = color
            }
            
            commitButton.isEnabled = config.isEnable

            _ = commitButton
                .setTitle(config.title)
                .setTitleColor(config.titleColor)
                .setTitle(config.title_disable, .disabled)
                .setFont(config.font)
            
            let width = config.width ?? kScreenW - HLTableViewCell.defaultCellMarginValue*2
            if let width = config.width {
                commitButton.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    
                    switch config.alignment {
                    case .left:
                        make.left.equalToSuperview().offset(config.marginValue)
                    case .right:
                        make.right.equalToSuperview().offset(-config.marginValue)
                    default:
                        make.centerX.equalToSuperview()
                    }
                    
                    make.width.equalTo(width)
                    make.height.equalToSuperview()
                }
            } else {
                commitButton.snp.remakeConstraints { (make) in
                    make.left.right.equalToSuperview().inset(config.marginValue)
                    make.top.bottom.equalToSuperview()
                }
            }

            if let image = config.icon {
                commitButton.frame = CGRect(origin: .zero, size: CGSize(width: width, height: 44))
                commitButton.setImage(image).layoutButton(with: config.iconLayoutType, imageTitleSpace: 4)
            } else {
                commitButton.setImage(nil).layoutButton(with: config.iconLayoutType, imageTitleSpace: 4)
            }
            
            if let bgImage = config.backgroundImage {
                _ = commitButton.setBackgroundImage(bgImage)
            }
            
            if let corner = config.cornerRate {
                commitButton.layer.cornerRadius = corner
                commitButton.layer.masksToBounds = true
            }
            
            commitButton.layer.borderColor = config.borderColor.cgColor
            commitButton.layer.borderWidth = 1
            
            loadingView.removeFromSuperview()
            if let isShow = config.showLoading {
                loadingView.isHidden = false
                
                loadingView.color = config.titleColor
                if isShow == false {
                    loadingView.stopAnimating()
                } else {
                    loadingView.startAnimating()
                }
                
                let textSize = commitButton.sizeThatFits(CGSize(width: kScreenW, height: 50))
                let offset = textSize.width / 2 + 10
                contentView.addSubview(loadingView)
                loadingView.snp.makeConstraints { make in
                    make.right.equalTo(commitButton.snp.centerX).offset(-offset)
                    make.centerY.equalTo(commitButton)
                    make.width.height.equalTo(20)
                }
                                
            } else {
                loadingView.isHidden = true
            }
        }
    }

    open override func bindConfig() {
        super.bindConfig()

        commitButton.rx.tap.subscribe(onNext: {[unowned self] (_) in
            self.cellEvent.onNext((tag: self.tag, value: self.data))
        }).disposed(by: disposeBag)
    }
}
