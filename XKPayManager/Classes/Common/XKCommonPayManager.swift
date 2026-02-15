//
//  XKCommonPayManager.swift
//  XKPayManager
//
//  Created by Kenneth Tse on 2026/1/24.
//

import UIKit
import AlipaySDK

public typealias WechatPayCallback = (((result: Bool, resp: PayResp?)) -> Void)
public typealias WechatShareCallback = (((result: Bool, resp: SendMessageToWXResp?)) -> Void)
public typealias WechatAuthCallback = (((result: Bool, authCode: String?)) -> Void)
public typealias WechatConfirmationCallback = ((Bool) -> Void)

public class XKCommonPayManager: NSObject {
    
    public static let alipaySimpleAuthHost = "apmqpdispatch"
    public static let alipayHost = "safepay"
    
    public static let shared = XKCommonPayManager()
    
    public var shareCallback: WechatShareCallback?
    public var payCallback: WechatPayCallback?
    public var wechatAuthCallback: WechatAuthCallback?
    public var wechatConfirmationCallback: WechatConfirmationCallback?
    public var alipayScheme: String = ""
    
    private var wechatId = ""
    private var wechatMchId = ""
    
    public override init() {
        super.init()
        
        SharedDelegate.shared()
            .respCallback = {
                [weak self] resp in
                self?.onResp(resp)
            }
    }
}

public extension XKCommonPayManager {
    
    static var wechatIsInstalled: Bool {
        WXApi.isWXAppInstalled()
    }
    static func registerWechat(appId: String, universalLink: String, mchId: String = "") {
//        WXApi.startLog(by: .detail) { text in
//            debugPrint("---weapi----")
//            debugPrint(text)
//        }
        shared.wechatId = appId
        shared.wechatMchId = mchId
        let result = WXApi.registerApp(appId, universalLink: universalLink)
        debugPrint("wxapi: \(result)")
    }
    
    static func wechatOpen(userActivity: NSUserActivity) {
        _ = WXApi.handleOpenUniversalLink(userActivity, delegate: SharedDelegate.shared())
    }
    
    static func wechatOpen(url: URL) {
        _ = WXApi.handleOpen(url, delegate: SharedDelegate.shared())
    }
    
    static func alipaySimpleAuthOpenUrl(_ url: URL) {
        AFServiceCenter.handleResponseURL(url) { _ in }
    }
    
    static func alipayHandle(url: URL) {
        AlipaySDK
            .defaultService()
            .processAuthResult(url) { _ in }
    }
    
    static func bindAlipay(appId: String, complete: (((result: Bool, authCode: String?)) -> Void)?) {
        let alipayScheme = shared.alipayScheme
        guard alipayScheme.isEmpty == false else { return }
        let text = "simpleAuth".data(using: .utf8)?.base64EncodedString()
        let url = "https://authweb.alipay.com/auth?auth_type=PURE_OAUTH_SDK&app_id=\(appId)&scope=auth_user&state=\(text ?? "")"
        let params = [
            kAFServiceOptionBizParams: [
                kAFServiceBizParamsKeyUrl: url
            ],
            kAFServiceOptionCallbackScheme: alipayScheme
        ] as [String : Any]
        AFServiceCenter.call(.auth,
                             withParams: params) { resp in
            guard resp?.responseCode == .success,
                  let authCode = resp?.result?["auth_code"] as? String else {
                complete?((false, nil))
                return
            }
            complete?((true, authCode))
        }
    }
    
    static func bindWechat(complete: WechatAuthCallback?) {
        shared.wechatAuthCallback = complete
        let req = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "bind_wechat"
        WXApi.send(req)
    }
    
    static func confirmWXTransfer(package: String, complete: @escaping WechatConfirmationCallback) {
        guard shared.wechatId.isEmpty == false else {
            complete(false)
            return
        }
        shared.wechatConfirmationCallback = complete
        let req = WXOpenBusinessViewReq.object()
        req.businessType = "requestMerchantTransfer"
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "mchId", value: shared.wechatMchId),
            URLQueryItem(name: "appId", value: shared.wechatId),
            URLQueryItem(name: "package", value: package)
        ]
        req.query =  components.percentEncodedQuery
        debugPrint("confirmation query:\(req.query)")
        WXApi.send(req)
    }
}

extension XKCommonPayManager {
    func onResp(_ resp: BaseResp) {
        let isSuccess = resp.errCode == WXSuccess.rawValue
        if let resp = resp as? PayResp {
            payCallback?((isSuccess, resp))
            return
        }
        
        if let resp = resp as? SendMessageToWXResp {
            shareCallback?((isSuccess, resp))
            return
        }
        
        if let resp = resp as? SendAuthResp {
            wechatAuthCallback?((isSuccess, resp.code))
            return
        }
        
        if let resp = resp as? WXOpenBusinessViewResp {
            let result = resp.extMsg?.contains("success") ?? false
            wechatConfirmationCallback?(result)
        }
    }
}
