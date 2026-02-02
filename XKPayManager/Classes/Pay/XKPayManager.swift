//
//  XKPayManager.swift
//  XKPayManager
//
//  Created by Kenneth Tse on 2026/1/21.
//

import Foundation
import AlipaySDK

public struct WeChatPayParams {
    /** 商家向财付通申请的商家id */
    public var partnerId: String
    /** 预支付订单 */
    public var prepayId: String
    /** 随机串，防重发 */
    public var nonceStr: String
    /** 时间戳，防重发 */
    public var timeStamp: UInt32
    /** 商家根据财付通文档填写的数据和签名 */
    public var package: String
    /** 商家根据微信开放平台文档对数据做的签名 */
    public var sign: String
    
    public init(partnerId: String, prepayId: String, nonceStr: String, timeStamp: UInt32, package: String, sign: String) {
        self.partnerId = partnerId
        self.prepayId = prepayId
        self.nonceStr = nonceStr
        self.timeStamp = timeStamp
        self.package = package
        self.sign = sign
    }
}

public class XKPayManager {
    
    public static let shared = XKPayManager()
    
    private var aliAppScheme: String = ""
    
    private var wechatCallback: WechatPayCallback?
    
    private init() {
        XKCommonPayManager.shared
            .payCallback = {
                [weak self] info in
                self?.wechatCallback?(info)
            }
    }
}

// MARK: - wechat
public extension XKPayManager {
    
    static func wechatPay(params: WeChatPayParams, complete: @escaping WechatPayCallback) {
        shared.wechatCallback = complete
        let req = PayReq()
        req.partnerId = params.partnerId
        req.prepayId = params.prepayId
        req.nonceStr = params.nonceStr
        req.timeStamp = params.timeStamp
        req.package = params.package
        req.sign = params.sign
        WXApi.send(req)
    }
    
}

// MARK: - alipay
public extension XKPayManager {
    /// can call in scene(_ scene: UIScene,openURLContexts URLContexts: Set<UIOpenURLContext>)
    static func processOrder(url: URL) {
        AlipaySDK
            .defaultService()
            .processAuthResult(url) { result in
                debugPrint(result)
            }
    }
    
    static func setup(appScheme: String) {
        shared.aliAppScheme = appScheme
        XKCommonPayManager.shared.alipayScheme = appScheme
    }
    
    static func alipay(orderString: String, callback: (((result: Bool, status: Int, data: [AnyHashable: Any]?)) -> Void)? = nil) {
        AlipaySDK
            .defaultService()
            .payOrder(orderString,
                      fromScheme: shared.aliAppScheme) { resp in
                /*
                 result 中关键字段：
                 resultStatus:
                   9000 = 成功
                   6001 = 用户取消
                   4000 = 失败
                 */
                
                let status = (resp?["resultStatus"] as? Int) ?? 4000
                callback?((status == 9000, status, resp))
            }
    }
    
}
