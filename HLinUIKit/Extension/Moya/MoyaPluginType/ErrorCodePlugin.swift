//
//  ErrorCodePlugin.swift
//  Community
//
//  Created by mac on 2019/9/29.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import Moya
import Result
import RxSwift

class ErrorCodePlugin: PluginType {

    //收到请求
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {

        // 解析返回
        guard let respond = result.value else {
            return
        }

        if respond.statusCode != 200 { return }

//        let model = respond.mapModel(RespondModel<String>.self, true)
//
//        guard let errorCode = model.code else { return }
//
//        switch errorCode {
//        case 8:
//            // 异地登录, 未登录等状态
//            ConfigManger.shared.setAccount(nil)
//            SVProgressHUD.showInfo(withStatus: "登录过期，请重新登录")
//        default:
//            break
//        }
    }
}
