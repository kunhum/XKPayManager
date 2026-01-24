//
//  XKShareManager.swift
//  XKPayManager
//
//  Created by Kenneth Tse on 2026/1/24.
//

import Foundation

public class XKShareManager {
    
    public typealias WechatCallback = (((result: Bool, resp: SendMessageToWXResp?)) -> Void)
    
    public static let shared = XKShareManager()
    
    private var wechatCallback: WechatShareCallback?
    
    private init() {
        XKCommonPayManager.shared
            .shareCallback = {
                [weak self] info in
                self?.wechatCallback?(info)
            }
    }
}

public extension XKShareManager {
    static func shareImage(_ image: UIImage, toTimeline: Bool, complete: WechatShareCallback? = nil) {
        shared.wechatCallback = complete
        let imageObj = WXImageObject()
        if let data = image.jpegData(compressionQuality: 0.9) {
            imageObj.imageData = data
        }
        let message = WXMediaMessage()
        message.mediaObject = imageObj
        // 缩略图必须小，否则可能失败（建议 < 32KB）
        let thumb = image.resize(to: CGSize(width: 150, height: 150))
        message.setThumbImage(thumb)
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = Int32(toTimeline ? WXSceneTimeline.rawValue : WXSceneSession.rawValue)
        WXApi.send(req)
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        draw(in: CGRect(origin: .zero, size: size))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? self
    }
}
