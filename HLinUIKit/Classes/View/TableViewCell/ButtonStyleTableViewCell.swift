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
    public var alignment: NSTextAlignment = .center
    public var backgroundColor: UIColor?
    public var backgroundImage: UIImage?
    public var cornerRate: CGFloat? = 4
    public var icon: UIImage?
    public var iconLayoutType: UPButtonEdgeInsetsStyle = .left
    public var isEnable: Bool = true
    
    public var font: UIFont = .pingfang(ofSize: 15)
    public var borderColor: UIColor = .clear
    public var tag: Int = 0
    
    public var height: CGFloat = 44
    public var width: CGFloat?
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
    public var customView: UIView?
    public var marginValue: CGFloat = 30 {
        didSet {
            commitButton.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.left.equalTo(marginValue)
                make.right.equalTo(-marginValue)
                make.height.equalToSuperview()
            }
        }
    }

    public let commitButton = UIButton().then { (button) in
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
    }

    open override func initConfig() {
        super.initConfig()

        backgroundColor = .clear

        contentView.addSubview(commitButton)
        commitButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalTo(marginValue)
            make.right.equalTo(-marginValue)
            make.height.equalToSuperview()
        }
    }

    open override func updateData() {

        if let config = data as? HLButtonCellConfig {

            tag = config.tag

            if let color = config.backgroundColor {
                _ = commitButton.setBackgroundImage(color.image, .normal)
            }
            
            commitButton.isEnabled = config.isEnable

            _ = commitButton
                .setTitle(config.title)
                .setTitleColor(config.titleColor)
                .setFont(config.font)
            
            let width = config.width ?? kScreenW - HLTableViewCell.defaultCellMarginValue*2
            if let width = config.width {
                commitButton.snp.remakeConstraints { (make) in
                    make.centerY.equalToSuperview()
                    
                    switch config.alignment {
                    case .left:
                        make.left.equalToSuperview().offset(marginValue)
                    case .right:
                        make.right.equalToSuperview().offset(-marginValue)
                    default:
                        make.centerX.equalToSuperview()
                    }
                    
                    make.width.equalTo(width)
                    make.height.equalToSuperview()
                }
            }

            if let image = config.icon {
                commitButton.frame = CGRect(origin: .zero, size: CGSize(width: width, height: 44))
                commitButton.setImage(image).layoutButton(with: config.iconLayoutType, imageTitleSpace: 10)
            } else {
                commitButton.setImage(nil).layoutButton(with: config.iconLayoutType, imageTitleSpace: 10)
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
        }
    }

    open override func bindConfig() {
        super.bindConfig()

        commitButton.rx.tap.subscribe(onNext: {[unowned self] (_) in
            self.cellEvent.onNext((tag: self.tag, value: self.data))
        }).disposed(by: disposeBag)
    }
}
