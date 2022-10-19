//
//  File.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2022/7/18.
//

import Foundation
import RxSwift
import RxCocoa

open class HLObject: NSObject {
    
    public var disposable: Disposable?
    public var disposeBag = DisposeBag()
    
    public override init() {
        super.init()
        self.initConfig()
        self.bindConfig()
    }
    
    open func initConfig() {
        
    }
    
    open func bindConfig() {
        disposeBag = DisposeBag()
    }
}
