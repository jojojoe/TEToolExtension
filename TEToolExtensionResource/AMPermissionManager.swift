//
//  AMPermissionManager.swift
//  ATaiArtCapture
//
//  Created by wqqqq on 2024/5/15.
//

import Foundation
import AVFoundation
import Photos
import UIKit
import AppTrackingTransparency
import AdSupport

class AMPermissionManager: NSObject {
    static let `default` = AMPermissionManager()
    override init() {
        super.init()
        // frome LBXPermission
    }
    
}

//MARK: Camera Permission
extension AMPermissionManager {
    
    func checkCameraAuthorizationStatus(completion: @escaping ((_ authStatus: AVAuthorizationStatus, _ granted: Bool, _ firstTime: Bool)->Void)) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            debugPrint("Camera is authorized.")
            completion(status, true, false)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completion(status, granted, true)
            }
        case .restricted, .denied:
            completion(status, false, false)
        @unknown default:
            completion(status, false, false)
        }
    }
}

//MARK: Album Permission
extension AMPermissionManager {
    public func requestAlbumPermission(completion: @escaping ((_ authStatus: PHAuthorizationStatus, _ granted: Bool, _ firstTime: Bool)->Void)) {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { requestStatus in
                    if requestStatus == .authorized || requestStatus == .limited {
                        completion(status, true, true)
                    } else {
                        completion(status, false, true)
                    }
                }
            case .restricted, .denied:
                completion(status, false, false)
            case .authorized, .limited:
                completion(status, true, false)
            @unknown default:
                completion(status, false, false)
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        completion(status, true, true)
                    } else {
                        completion(status, false, true)
                    }
                }
            case .restricted, .denied:
                completion(status, false, false)
            case .authorized, .limited:
                completion(status, true, false)
            @unknown default:
                completion(status, false, false)
            }
        }
    }
    
    public func requestAlbumOnlySavePermission(completion: @escaping ((_ authStatus: PHAuthorizationStatus, _ granted: Bool, _ firstTime: Bool)->Void)) {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { requestStatus in
                    if requestStatus == .authorized || requestStatus == .limited {
                        completion(status, true, true)
                    } else {
                        completion(status, false, true)
                    }
                }
            case .restricted, .denied:
                completion(status, false, false)
            case .authorized, .limited:
                completion(status, true, false)
            @unknown default:
                completion(status, false, false)
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        completion(status, true, true)
                    } else {
                        completion(status, false, true)
                    }
                }
            case .restricted, .denied:
                completion(status, false, false)
            case .authorized, .limited:
                completion(status, true, false)
            @unknown default:
                completion(status, false, false)
            }
        }
    }
}


//MARK: ATTrackingManager Permission
extension AMPermissionManager {
    func requestATTrackingPermission(authorized: @escaping (()->Void), denied: @escaping (()->Void)) {
        
        if #available(iOS 14, *) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            switch status {
            case .notDetermined:
                ATTrackingManager.requestTrackingAuthorization { rqstatus in
                    debugPrint("rqstatus = \(rqstatus)")
                    switch rqstatus {
                    case .notDetermined:
                        denied()
                    case .restricted:
                        denied()
                    case .denied:
                        denied()
                    case .authorized:
                        authorized()
                    }
                }
            case .restricted:
                denied()
            case .denied:
                denied()
            case .authorized:
                authorized()
            }
            
        } else {
            //iOS 14以下请求idfa权限
            // 判断在设置-隐私里用户是否打开了广告跟踪
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
                authorized()
            } else {
                denied()
            }
        }
    }
}

//MARK: UNUserNotificationCenter Permission
extension AMPermissionManager: UNUserNotificationCenterDelegate {
    func requestUNUserNotificationPermission(authorized: (()->Void)? = nil, denied: (()->Void)? = nil) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.getNotificationSettings { (setting) in
            if setting.authorizationStatus == .notDetermined {
                center.requestAuthorization(options: [.badge,.sound,.alert]) { (result, error) in
                    if (result) {
                        if !(error != nil) {
                            // 注册成功
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                                authorized?()
                            }
                        }
                    } else {
                        //用户不允许推送
                        denied?()
                    }
                }
            } else if (setting.authorizationStatus == .denied){
                // 申请用户权限被拒
                denied?()
            } else if (setting.authorizationStatus == .authorized){
                // 用户已授权（再次获取dt）
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    authorized?()
                }
            } else {
                // 未知错误
                denied?()
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let body = notification.request.content.body
        let info = notification.request.content.userInfo
        debugPrint(body, info)
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("")
        _ = response.notification.request.content.categoryIdentifier
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        
    }
}

