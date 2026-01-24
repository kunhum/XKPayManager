//
//  XKCommonPayManager.swift
//  XKPayManager
//
//  Created by Kenneth Tse on 2026/1/24.
//

import UIKit

public typealias WechatPayCallback = (((result: Bool, resp: PayResp?)) -> Void)
public typealias WechatShareCallback = (((result: Bool, resp: SendMessageToWXResp?)) -> Void)

public class XKCommonPayManager: NSObject {
    
    public static let shared = XKCommonPayManager()
    
    public var shareCallback: WechatShareCallback?
    public var payCallback: WechatPayCallback?
    
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
    static func registerWechat(appId: String, universalLink: String) {
//        WXApi.startLog(by: .detail) { text in
//            debugPrint("---weapi----")
//            debugPrint(text)
//        }
        let result = WXApi.registerApp(appId, universalLink: universalLink)
        debugPrint("wxapi: \(result)")
    }
    
    func wechatOpen(userActivity: NSUserActivity) {
        _ = WXApi.handleOpenUniversalLink(userActivity, delegate: SharedDelegate.shared())
    }
    
    func wechatOpen(url: URL) {
        _ = WXApi.handleOpen(url, delegate: SharedDelegate.shared())
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
    }
}
