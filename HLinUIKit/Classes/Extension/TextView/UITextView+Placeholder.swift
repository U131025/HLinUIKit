//
//  UITextView+Placeholder.swift
//  IM_XMPP
//
//  Created by apple on 2018/9/22.
//  Copyright © 2018年 mac. All rights reserved.
//
// swiftlint:disable identifier_name

import Foundation
import RxCocoa
import RxSwift

var placeholderLabelKey = 101
var wordLimitLabelKey   = 102
var placeholderKey      = 103
var placeholderColorKey = 104
var wordLimitKey        = 105
var disposeBagKey       = 106

extension UITextView {

    open override func layoutSubviews() {
        super.layoutSubviews()
        setupPlacehoderViews()
    }
    
    public func setupPlacehoderViews() {
        let placeholderSize = self.placeholderLabel?.sizeThatFits(CGSize(width: self.bounds.width - 10, height: 0))
        self.placeholderLabel?.frame = CGRect(x: 5, y: 8, width: bounds.width - 5, height: (placeholderSize?.height) ?? 0)
        
//        self.placeholderLabel?.snp.remakeConstraints({ make in
//            make.left.equalTo(0)
//            make.right.equalToSuperview()
//            make.top.equalTo(8)
//            make.height.equalTo(placeholderSize?.height ?? 0)
//        })

        self.wordLimitLabel?.bounds = CGRect(x: 0, y: 0, width: self.bounds.width - 10, height: (placeholderSize?.height) ?? 0)
        self.wordLimitLabel?.left = 5
        self.wordLimitLabel?.bottom = self.bounds.height - 5

        if self.wordLimit != nil && self.wordLimit! > 1 {

            self.wordLimitLabel?.isHidden = false
            self.wordLimitLabel?.text = "0/\(self.wordLimit!)"

        } else {

            self.wordLimitLabel?.isHidden = false
        }

        self.placeholderLabel?.isHidden = text.count > 0 ? true : false

        self.inputDisposeBag = DisposeBag()
        self.rx.text.orEmpty.asObservable().subscribe(onNext: { [weak self](text) in

            self?.placeholderLabel?.isHidden = text.count > 0 ? true : false

            if self?.wordLimit != nil && (self?.wordLimit)! > 1 {

                self?.wordLimitLabel?.text = "\(text.count)/\((self?.wordLimit)!)"

            }

        })
        .disposed(by: self.inputDisposeBag!)
    }

    // MARK: getter and setter
    fileprivate var inputDisposeBag: DisposeBag? {
        set {
            objc_setAssociatedObject(self, &disposeBagKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {

            if let rs = objc_getAssociatedObject(self, &disposeBagKey) as? DisposeBag {

                return rs
            }

            let rs = DisposeBag()
            objc_setAssociatedObject(self, &disposeBagKey, rs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return rs
        }
    }

    public var wordLimit: Int? {
        set {
            objc_setAssociatedObject(self, &wordLimitKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {

            return objc_getAssociatedObject(self, &wordLimitKey) as? Int
        }
    }

    public var hl_placeholder: String? {
        set {
            objc_setAssociatedObject(self, &placeholderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.placeholderLabel?.text = newValue
            self.setNeedsLayout()

        }

        get {

            return objc_getAssociatedObject(self, &placeholderKey) as? String
        }
    }

    public var hl_placeholderColor: UIColor? {
        set {
            objc_setAssociatedObject(self, &placeholderColorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.placeholderLabel?.textColor = newValue
            self.setNeedsLayout()

        }

        get {

            return objc_getAssociatedObject(self, &placeholderColorKey) as? UIColor
        }
    }

    fileprivate var placeholderLabel: UILabel? {
        set {
            objc_setAssociatedObject(self, &placeholderLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {

            if let rs = objc_getAssociatedObject(self, &placeholderLabelKey) as? UILabel {

                return rs
            }

            let rs = UILabel()
            rs.frame = bounds
            rs.font = font ?? UIFont.systemFont(ofSize: 15.0)
            rs.textAlignment =  textAlignment
            rs.textColor = UIColor.lightGray
            rs.numberOfLines = 0
            self.addSubview(rs)

            objc_setAssociatedObject(self, &placeholderLabelKey, rs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return rs
        }
    }

    fileprivate var wordLimitLabel: UILabel? {
        set {
            objc_setAssociatedObject(self, &wordLimitLabelKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

        get {

            if let rs = objc_getAssociatedObject(self, &wordLimitLabelKey) as? UILabel {

                return rs
            }

            let rs = UILabel()
            rs.font = UIFont.systemFont(ofSize: 15.0)
            rs.textColor = UIColor.lightGray
            rs.textAlignment = .right
            self.addSubview(rs)

            objc_setAssociatedObject(self, &wordLimitLabelKey, rs, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            return rs
        }
    }
}
