//
//  ADacNativeAdManager.swift
//  APaiAphroAI
//
//  Created by HONGJUNWANG on 2024/7/12.
//


import UIKit
import Moya
import Alamofire
import MoyaSugar
import SwiftyJSON
import Network
import Security
import CoreTelephony
import GoogleMobileAds
import UserMessagingPlatform
import FirebaseCore
import FirebaseAnalytics
import DeviceKit
import CoreTelephony
import AdSupport
import FBSDKCoreKit

 

class ADHomePageViewController: UIViewController {
    
    let contentV = UIView()
    var nativeAdBgV: UIView?
    var autorefreshAction: (()->Void)?
    var reloadNativeAdAction: ((Bool, Bool)->Void)?
    let nativeAdPosition: AdTypePostionId = .nativeHome
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //MARK: 刷新广告
        loadNaitveAd()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        ADacNativeAdManager.shared.stopShouldShowNativeAd()
    }
    
    func loadNaitveAd() {
        //TODO: Subscription
        if ADacNativeAdManager.shared.isLimitOrNotAd(position: .nativeHome) {
            self.setupNativeAd(isShowNative: false)
        } else {
            self.setupNativeAd(isShowNative: true)
        }
    }
    
    func setupNativeAd(isShowNative: Bool) {
        
        if isShowNative {
            if (nativeAdBgV == nil) {
                let nativeAdBgV = UIView()
                self.nativeAdBgV = nativeAdBgV
                view.addSubview(nativeAdBgV)
                
            }
            
            reloadNativeAdAction = {success, failedShoulContinueCheck in
                if success {
                    ADacNativeAdManager.shared.showNativeAd(position: self.nativeAdPosition, adBgView: self.nativeAdBgV, reloadCompletion: self.reloadNativeAdAction, autoRefreshBlock: self.autorefreshAction)
                    //
                    self.layoutNativeFrame(showNative: true)
                } else {
                    self.layoutNativeFrame(showNative: false)
                    if failedShoulContinueCheck {
                        ADacNativeAdManager.shared.showNativeAd(position: self.nativeAdPosition, adBgView: self.nativeAdBgV, reloadCompletion: self.reloadNativeAdAction, autoRefreshBlock: self.autorefreshAction)
                    }
                }
            }
            
            autorefreshAction = {
                ADacNativeAdManager.shared.showNativeAd(position: self.nativeAdPosition, adBgView: self.nativeAdBgV, reloadCompletion: self.reloadNativeAdAction, autoRefreshBlock: self.autorefreshAction)
            }
            
            if let nativeAdItem = ADacNativeAdManager.shared.currentAdAvailable(), let nativeAd = nativeAdItem.ad {
                printLog(type: .ad, msg: "这里加广告判断是为了提前布局是否显示广告的frame")
                layoutNativeFrame(showNative: true)
                
            } else {
                layoutNativeFrame(showNative: false)
                
            }
            ADacNativeAdManager.shared.showNativeAd(position: nativeAdPosition, adBgView: nativeAdBgV) { success, failedShoulContinueCheck in
                printLog(type: .ad, msg: "原生广告 调用reloadCompletion  load原生广告成功状态：\(success)")
                DispatchQueue.main.async {
                    self.reloadNativeAdAction?(success, failedShoulContinueCheck)
                }
            } autoRefreshBlock: {
                printLog(type: .ad, msg: "原生广告 autoRefreshBlock success 回调 autoRefreshBlock = \(self.autorefreshAction != nil)")
                DispatchQueue.main.async {
                    self.autorefreshAction?()
                }
            }
        } else {
            layoutNativeFrame(showNative: false)
            
            nativeAdBgV?.removeSubviews()
            nativeAdBgV?.removeFromSuperview()
            nativeAdBgV = nil
            autorefreshAction = nil
            
            ADacNativeAdManager.shared.stopShouldShowNativeAd()
        }
    }
    
    func layoutNativeFrame(showNative: Bool) {
        if showNative {
            contentV.snp.remakeConstraints ({
                $0.left.right.equalToSuperview()
                if UIScreen.isDevice8SEPaid() || UIScreen.isDevice8Plus() {
                    $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120 - 20 - 15)
                } else {
                    $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-120 - 15)
                }

                $0.top.equalToSuperview()
            })
            nativeAdBgV?.snp.remakeConstraints {
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-12)
                $0.height.equalTo(120)
            }
           
        } else {
            contentV.snp.remakeConstraints ({
                $0.left.right.equalToSuperview()
                $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(0)
                $0.top.equalTo(settingBtn.snp.bottom).offset(4)
            })
        }
        
        nativeAdBgV?.isHidden = !showNative
    }
}


class ADLoadNativeAdItem: NSObject {
    var position: AdTypePostionId
    var adConfig: ADAdInfoConfig
    var hasShow: Bool
    
    var ad: GADNativeAd? = nil {
        didSet {
            requestAdTime = Date()
        }
    }
    var adLoader: GADAdLoader? = nil
    
    var requestAdTime: Date?
    
    init(position: AdTypePostionId, adConfig: ADAdInfoConfig) {
        self.position = position
        self.adConfig = adConfig
        self.hasShow = false
    }
}

class ADacNativeAdManager: NSObject, GADNativeAdLoaderDelegate {
    static let shared = ADacNativeAdManager()
//    var adLoader: GADAdLoader?
//    var nativeAd: GADNativeAd?
    
    
    var cacheAdItemList: [ADLoadNativeAdItem] = []
    var currentShowAdPosition: AdTypePostionId?
//    var currentAdItem: ADLoadNativeAdItem?
    var nativeAdView: ADNativeAdView?
//    var loadingFishView: UIView?
    
    var isLoadingAd = false
    var isShowingAd = false
    let testid = "ca-app-pub-3940256099942544/3986624511"
    var currentLoadAdCompletionBlock: ((Bool, Bool)->Void)?
    var currentSecond: Int = 0
    var currentAdBgView: UIView?
    var timer: Timer?
    
    func loadAd(position: AdTypePostionId, completion: ((_ success: Bool, _ failedShoulContinueCheck: Bool)->Void)? = nil) {
        printLog(type: .ad, msg: "原生广告请求调用开始...position: \(position) LoadAdCompletionBlock回调 = \(completion != nil)")
        self.currentLoadAdCompletionBlock = completion
        
        if isLoadingAd {
            printLog(type: .ad, msg: "原生广告isLoadingAd = \(isLoadingAd) (currentAdAvailable() != nil) = \((currentAdAvailable() != nil))..本次加载无效")
            completion?(false, false)
            return
        }
        
        if (currentAdAvailable() != nil) {
            completion?(true, false)
            return
        }
        
        //--
        guard let adConfig = ADacManager.default.findAd(positionId: position) else {
            completion?(false, false)
            return
        }
        //--
        #if DEBUG
//        let aditem = ADAdInfoConfig(json: JSON(parseJSON: ""))
//        aditem.adsId = testid
        #endif
        
        var united = adConfig.adsId
        #if DEBUG
        united = testid
        #endif
        
        let item = ADLoadNativeAdItem(position: position, adConfig: adConfig)
        self.cacheAdItemList.append(item)
        
        printLog(type: .ad, msg: "原生广告加载-开始 - \(position.rawValue)\n united = \(united)\npage = \(ADacManager.default.page(positionId:position.rawValue))")
        
        let adLoader = GADAdLoader(adUnitID: united, rootViewController: nil, adTypes: [.native], options: nil)
        adLoader.delegate = self
        adLoader.load(GADRequest())
        item.adLoader = adLoader
        self.isLoadingAd = true
    }
    
    func showNativeAd(position: AdTypePostionId, adBgView: UIView?, reloadCompletion: ((_ success: Bool, _ failedShoulContinueCheck: Bool)->Void)?, autoRefreshBlock: (()->Void)?) {
        
        currentShowAdPosition = position
        
        if isenterBackground {
            printLog(type: .ad, msg: "进入后台，原生广告不展示，不加载，跳过本次调用")
            reloadCompletion?(false, false)
            return
        }
        //--
//        guard let aditem = ADacManager.default.findAd(positionId: position) else {
//            reloadCompletion?(false, false)
//            return
//        }
        
        //
        printLog(type: .ad, msg: "原生广告 - 展示")
        printLog(type: .ad, msg: "清除一下已经展示过的的原生广告")
        printLog(type: .ad, msg: "50分钟过期时间，如果过期了，移除掉这个广告，本次不展示广告，重新请求放到缓存中")
        cacheAdItemList.removeAll {
            if $0.hasShow {
                return true
            }
            if let requestDate = $0.requestAdTime, Date().timeIntervalSince(requestDate) >= 50 * 60 {
                return true
            }
            return false
        }
        
        currentAdBgView = adBgView
        timer?.invalidate()
        if let time = timer {
            ADacManager.default.removeInvaliDateTimer(timer: time)
        }
        if currentAdBgView == nil {
            printLog(type: .ad, msg: "原生广告 - 展示，已经不是当前需要展示广告页面 刷新计时停止")
            
            return;
        }
        
        if let nativeAdItem = self.currentAdAvailable(), let nativeAd = nativeAdItem.ad {
            
            if self.nativeAdView == nil {
                printLog(type: .ad, msg: "原生广告 - 展示，新建 NativeAdView")
                currentAdBgView?.removeSubviews()
                let x: CGFloat = 12
                let y: CGFloat = 0
                let adW: CGFloat = UIScreen.main.bounds.size.width - 12 * 2
                var adH: CGFloat = 120
                if position == .nativeSetting {
                    if UIScreen.isDevice8SEPaid() || UIScreen.isDevice8Plus() {
                        let nativeAdFrame = CGRect(x: x, y: y, width: adW, height: adH)
                        self.nativeAdView = ADSmallNativeAdView(frame: nativeAdFrame)
//                        self.loadingFishView = ADSmallNativeLoadingFishView(frame: nativeAdFrame)
                    } else {
                        adH = 240
                        let nativeAdFrame = CGRect(x: x, y: y, width: adW, height: adH)
                        self.nativeAdView = ADBigNativeAdView(frame: nativeAdFrame)
//                        self.loadingFishView = ADBigNativeLoadingFishView(frame: nativeAdFrame)
                    }
                    
                } else {
                    let nativeAdFrame = CGRect(x: x, y: y, width: adW, height: adH)
                    self.nativeAdView = ADSmallNativeAdView(frame: nativeAdFrame)
//                    self.loadingFishView = ADSmallNativeLoadingFishView(frame: nativeAdFrame)
                }
                
//                currentAdBgView?.addSubview(loadingFishView!)
                currentAdBgView?.addSubview(nativeAdView!)
                
            } else {
                currentAdBgView?.removeSubviews()
                currentAdBgView?.addSubview(nativeAdView!)
            }
            
//            nativeAdView?.isHidden = true
//            loadingFishView?.isHidden = false
//            loadingFishView?.tab_startAnimation(configBlock: { tabAnimated in
//                tabAnimated.superAnimationType = .shimmer
//            }, adjust: { manager in
//
//            }, completion: nil)
//
//            //
//            loadingFishView?.tab_endAnimation()
//            loadingFishView?.isHidden = true
//            self.nativeAdView?.isHidden = false
            //
            
            printLog(type: .ad, msg: "原生广告展示 成功 计数+1")
            nativeAdItem.hasShow = true
            nativeAd.delegate = self
            //
            nativeAdView?.nativeAd = nativeAd
            (nativeAdView?.headlineView as? UILabel)?.text = nativeAd.headline
            (nativeAdView?.bodyView as? UILabel)?.text = nativeAd.body
            (nativeAdView?.callToActionView as? UILabel)?.text = nativeAd.callToAction
            (nativeAdView?.iconView as? UIImageView)?.image = nativeAd.icon?.image
            if nativeAdItem.position == .nativeSetting {
                (nativeAdView?.mediaView)?.mediaContent = nativeAd.mediaContent
            }
            //
            ADacManager.default.saveADShowCount(positionId: position)
            nativeAd.paidEventHandler = { value in
                printLog(type: .ad, msg: "原生广告展示 广告价值 value.precision - \(value.precision), value.currencyCode - \(value.currencyCode), value.value - \(value.value)")
                ADacManager.default.heheLog(event: .adEvent(adConfig: nativeAdItem.adConfig, adValue: value, status: .Impression, errorInfo: nil))
            }
            
            //
            printLog(type: .ad, msg: "原生广告展示中，并开始请求缓存下一条广告")
            loadAd(position: position)
            //
            printLog(type: .ad, msg: "原生广告刷新倒计时开始 - 全局控制刷新时长：\(ADacManager.default.adGlobalConfig.bannerRefreshTime)")
            currentSecond = 0
            let time = Timer.every(1.seconds, {[weak self] timer in
                guard let `self` = self else {return}
                if self.currentSecond < ADacManager.default.adGlobalConfig.bannerRefreshTime {
                    self.currentSecond += 1
                    printLog(type: .ad, msg: "原生广告刷新倒计时 - \(self.currentSecond)")
                } else {
                    printLog(type: .ad, msg: "原生广告刷新倒计时结束 - 调用autoRefreshBlock-\(autoRefreshBlock != nil)")
                    timer.invalidate()
                    ADacManager.default.removeInvaliDateTimer(timer: timer)
                    autoRefreshBlock?()
                }
            })
            self.timer = time
            ADacManager.default.addNewAdCountTimer(timer: time)
        } else {
            printLog(type: .ad, msg: "无缓存原生广告 重新加载")
            loadAd(position: position, completion: reloadCompletion)
        }
    }
    
    //判断广告是否被限制，或者没有广告
    func isLimitOrNotAd(position: AdTypePostionId) -> Bool {
        #if DEBUG
//        return false
        #endif
        let adConfig = ADacManager.default.findAd(positionId: position)
        if adConfig == nil {
            printLog(type: .ad, msg: "原生广告到达上限或者没有找到对应的广告ID")
            return true
        }
        printLog(type: .ad, msg: "原生广告没有到达上限")
        return false
    }
    
    func stopShouldShowNativeAd() {
        printLog(type: .ad, msg: "原生广告 已经不是当前需要展示广告页面 或者已经订阅 刷新计时停止")
        currentAdBgView = nil
        nativeAdView = nil
        timer?.invalidate()
        if let time = timer {
            ADacManager.default.removeInvaliDateTimer(timer: time)
        }
    }
    
    func currentAdAvailable() -> ADLoadNativeAdItem? {
        let item = self.cacheAdItemList.first {
            !$0.hasShow && $0.ad != nil
        }
        printLog(type: .ad, msg: "原生广告 是否可用 \(item != nil)")
        return item
    }
    
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        printLog(type: .ad, msg: "加载原生广告 成功 - self.currentLoadAdCompletionBlock = \(self.currentLoadAdCompletionBlock)")
        
        isLoadingAd = false
        
        guard let lastAdItem = self.cacheAdItemList.last else {
            printLog(type: .ad, msg: "出错了，缓存里没有 lastAdItem")
            self.currentLoadAdCompletionBlock?(false, true)
            return
        }
        lastAdItem.ad = nativeAd
        
        self.currentLoadAdCompletionBlock?(true, false)
    }
    
    public func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: any Error) {
        
        printLog(type: .ad, msg: "加载原生广告 失败  \(error.localizedDescription)")
        isLoadingAd = false
        if let loadCompletion = currentLoadAdCompletionBlock {
            // 说明展示广告的时候没有广告，所以进行了reloading，有个reloading的block，这时并没有计时器，所以需要添加广告刷新的计时器，各一段时间后再请求广告
            loadCompletion(false, false)
            
            //
            if let tim = self.timer {
                tim.invalidate()
                ADacManager.default.removeInvaliDateTimer(timer: tim)
            }
            //
            printLog(type: .ad, msg: "load原生广告失败，重新开始原生广告刷新倒计时开始 - 全局控制刷新时长：\(ADacManager.default.adGlobalConfig.bannerRefreshTime)")
            currentSecond = 0
            let time = Timer.every(1.seconds, {[weak self] timer in
                guard let `self` = self else {return}
                if self.currentSecond < ADacManager.default.adGlobalConfig.bannerRefreshTime {
                    self.currentSecond += 1
                    printLog(type: .ad, msg: "原生广告刷新倒计时 - \(self.currentSecond)")
                } else {
                    printLog(type: .ad, msg: "原生广告刷新倒计时结束 - 调用autoRefreshBlock-\(loadCompletion != nil)")
                    timer.invalidate()
                    ADacManager.default.removeInvaliDateTimer(timer: timer)
                    loadCompletion(false, true)
                }
            })
            self.timer = time
            ADacManager.default.addNewAdCountTimer(timer: time)
        } else {
            // 没有block说明展示广告的时候是有广告的，计时器正在运行，是缓存广告的时候走的这个代理
        }

    }
    
    func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
        printLog(type: .ad, msg: "加载原生广告 结束")
        
    }
}

extension ADacNativeAdManager: GADNativeAdDelegate {
    func nativeAdDidRecordImpression(_ nativeAd: GADNativeAd) {
        // The native ad was shown. 展示不在这里 在广告赋值那段代码里
        
    }
    
    func nativeAdDidRecordClick(_ nativeAd: GADNativeAd) {
        // The native ad was clicked on.
        
        if let nativeAdItem = self.currentAdAvailable() {
            printLog(type: .ad, msg: "原生广告点击 成功 计数+1")
            ADacManager.default.saveADClickCount(positionId: nativeAdItem.position)
            ADacManager.default.heheLog(event: .adEvent(adConfig: nativeAdItem.adConfig, adValue: nil, status: .Click, errorInfo: nil))
        }
    }
    
    func nativeAdWillPresentScreen(_ nativeAd: GADNativeAd) {
        // The native ad will present a full screen view.
    }
    
    func nativeAdWillDismissScreen(_ nativeAd: GADNativeAd) {
        // The native ad will dismiss a full screen view.
    }
    
    func nativeAdDidDismissScreen(_ nativeAd: GADNativeAd) {
        // The native ad did dismiss a full screen view.
    }
    
    func nativeAdWillLeaveApplication(_ nativeAd: GADNativeAd) {
        // The native ad will cause the app to become inactive and
        // open a new app.
    }
}



class ADNativeAdView: GADNativeAdView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ADSmallNativeAdView: ADNativeAdView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor(UIColor(hexString: "#FFFFFF")!.withAlphaComponent(1))
        borderColor(UIColor(hexString: "#B1B1B1")!.withAlphaComponent(1), width: 0.6)
        cornerRadius(8)
        
        self.headlineView = UILabel()
            .adhere(toSuperview: self, {
                $0.top.equalToSuperview().offset(8)
                $0.left.equalToSuperview().offset(66)
                $0.width.lessThanOrEqualTo(260)
                $0.height.equalTo(22)
            })
            .color(.black.withAlphaComponent(0.8))
            .font(UIFont.FontName_AvenirMedium, 18)
            .textAlignment(.left)
        
        self.iconView = UIImageView()
            .adhere(toSuperview: self, {
                $0.left.equalToSuperview().offset(10)
                $0.top.equalToSuperview().offset(10)
                $0.width.height.equalTo(50)
            })
            .contentMode(.scaleAspectFit)
        
        self.bodyView = UILabel()
            .adhere(toSuperview: self, {
                $0.top.equalTo(self.headlineView?.snp.bottom ?? self).offset(0)
                $0.left.equalTo(self.headlineView?.snp.left ?? self)
                $0.right.equalToSuperview().offset(-20)
                $0.height.equalTo(35)
            })
            .color(.black.withAlphaComponent(0.8))
            .font(UIFont.FontName_AvenirMedium, 15)
            .textAlignment(.left)
            .adjustsFontSizeToFitWidth()
            .numberOfLines(0)
        
        self.callToActionView = UILabel()
            .adhere(toSuperview: self, {
                $0.left.equalToSuperview().offset(25)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-10)
                $0.height.equalTo(40)
            })
            .backgroundColor(UIColor(hexString: "#ADE92D")!)
            .text("Install")
            .color(UIColor(hexString: "#232323")!)
            .font(UIFont.FontName_AvenirMedium, 15)
            .cornerRadius(20)
            .textAlignment(.center)
        
        //
        let adtagV = UILabel()
            .adhere(toSuperview: self, {
                $0.left.equalTo(self.headlineView?.snp.right ?? self).offset(4)
                $0.centerY.equalTo(self.headlineView?.snp.centerY ?? self)
                $0.width.equalTo(28)
                $0.height.equalTo(15)
            })
            .backgroundColor(UIColor(hexString: "#FFFFFF")!)
            .text("AD")
            .color(UIColor(hexString: "#333333")!)
            .font(UIFont.FontName_AvenirMedium, 10)
            .cornerRadius(2)
            .textAlignment(.center)
            .borderColor(UIColor(hexString: "#B1B1B1")!, width: 0.6)
    }
}


class ADBigNativeAdView: ADNativeAdView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        backgroundColor(UIColor(hexString: "#FFFFFF")!)
        borderColor(UIColor(hexString: "#B1B1B1")!.withAlphaComponent(1), width: 0.6)
        cornerRadius(8)
        
        self.mediaView = GADMediaView()
            .adhere(toSuperview: self, {
                $0.left.right.top.equalToSuperview()
                $0.bottom.equalTo(self.snp.centerY)
            })
            .clipsToBounds(true)
        //
        self.headlineView = UILabel()
            .adhere(toSuperview: self, {
                $0.top.equalTo(self.snp.centerY).offset(5)
                $0.left.equalToSuperview().offset(66)
                $0.width.lessThanOrEqualTo(260)
                $0.height.equalTo(22)
            })
            .color(.black.withAlphaComponent(0.8))
            .font(UIFont.FontName_AvenirMedium, 18)
            .textAlignment(.left)
        
        self.iconView = UIImageView()
            .adhere(toSuperview: self, {
                $0.left.equalToSuperview().offset(10)
                $0.top.equalTo(self.snp.centerY).offset(10)
                $0.width.height.equalTo(50)
            })
            .contentMode(.scaleAspectFit)
        
        self.bodyView = UILabel()
            .adhere(toSuperview: self, {
                $0.top.equalTo(self.headlineView?.snp.bottom ?? self).offset(0)
                $0.left.equalTo(self.headlineView?.snp.left ?? self)
                $0.right.equalToSuperview().offset(-20)
                $0.height.equalTo(35)
            })
            .color(.black.withAlphaComponent(0.8))
            .font(UIFont.FontName_AvenirMedium, 15)
            .textAlignment(.left)
            .adjustsFontSizeToFitWidth()
            .numberOfLines(0)
        
        self.callToActionView = UILabel()
            .adhere(toSuperview: self, {
                $0.left.equalToSuperview().offset(25)
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-10)
                $0.height.equalTo(40)
            })
            .backgroundColor(UIColor(hexString: "#ADE92D")!)
            .text("Install")
            .color(UIColor(hexString: "#232323")!)
            .font(UIFont.FontName_AvenirMedium, 15)
            .cornerRadius(20)
            .textAlignment(.center)
        
        //
        let adtagV = UILabel()
            .adhere(toSuperview: self, {
                $0.left.equalTo(self.headlineView?.snp.right ?? self).offset(4)
                $0.centerY.equalTo(self.headlineView?.snp.centerY ?? self)
                $0.width.equalTo(28)
                $0.height.equalTo(15)
            })
            .backgroundColor(UIColor(hexString: "#FFFFFF")!)
            .text("AD")
            .color(UIColor(hexString: "#333333")!)
            .font(UIFont.FontName_AvenirMedium, 10)
            .cornerRadius(2)
            .textAlignment(.center)
            .borderColor(UIColor(hexString: "#B1B1B1")!, width: 0.6)
    }
}
 
 
 

class ADacManager: NSObject {
    static let `default` = ADacManager()
    let adAppID = "30244825"
    let adAppName = "Glam AI - iOS"
    let adAesKey = "3NYAR0YODYAZPPD0"
    let adBaseUrl = "https://ai.glamcamaiface.com"
    let adConfigRoute = "/shard/bench/pak/v1-3/getAdvs"
    let adStrategyRoute = "/center/flat/component/eda/anScheme/hope"
    let adLogingTracking = "/saas/chop/appPlug/v1-1/logInfo/push"
    
    
    let appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"]  as? String ?? "1.0.0"
    var gadMobileAdsVersion: String = ""
    var adUserIPInfo: ADUserIPInfo?
    var adInfoItemsList: [ADAdInfoConfig] = []
    var adGlobalConfig: ADPubGlobalConfig = ADPubGlobalConfig()
    var adIsLimitAdTracking: Bool = false
    
    let k_userIpInfo = "k_userIpInfo"
    let k_globalConfig = "k_globalConfig"
    let k_adInfoItemsConfig = "k_adInfoItemsConfig"
    let k_genrateClickCount = "k_genrateClickCount"
    let k_tabbtnClickCount = "k_tabbtnClickCount"
    let k_adShowCount = "k_adShowCount"
    let k_adClickCount = "k_adClickCount"
    let k_lastDate = "k_lastDate"
    let k_isFirstLaunch = "k_isFirstLaunch"
    
    static let debugUUID = "00008110-00042C411160401E"
    
    private var isMobileAdsStartCalled = false
    let globalGroup = DispatchGroup()
    var currentActiveTimer: [Timer?] = []
    
    
    let hhk_event_id = "hohchsab"
    let hhk_page = "gitoqaxj"
    let hhk_v_fail_cause = "krssuyfk"
    let hhk_args = "irrkcdfmenl"
    let hhk_ad_id = "nipems"
    let hhk_ad_unit = "mittwe"
    let hhk_ad_source = "ntgcwjduudth"
    let hhk_ad_format = "xzrksearrtk"
    let hhk_ad_type = "mebvkpamdkq"
    let hhk_ad_ad_gma_sdk = "tyezeu"
    let hhk_ad_value = "eizqdhueoo"
    let hhk_ad_action = "dzexifird"
    let hhk_ad_currency = "putvkjxbhvuk"
    let hhk_ad_position = "gwvidaoafyl"
    let hhk_ad_fail_cause = "gpwlywm"
    let hhk_ad_drop_type = "qufkjwzwdysh"
    let hhk_ad_start_mode = "yrwgfb"
    let hhk_ad_precision_type = "sumuic"
    let hhk_ad_fail_cause_code = "arehbuvwsbmdo"
    let hhk_app_id = "yyonyiee"
    let hhk_app_name = "hcvgvhtsjkn"
    let hhk_app_version = "rlswzwzhqfmg"
    let hhk_device_id = "pdvajkbolzi"
    let hhk_brand = "nmmlddwb"
    let hhk_device_model = "sedcarckr"
    let hhk_resolution = "prfoztcsasid"
    let hhk_os = "pmifjuqcva"
    let hhk_os_version = "sppuudi"
    let hhk_carrier = "ggufcidmaehv"
    let hhk_access = "ygbbvnwbkkyu"
    let hhk_access_subtype = "vpwdpvifyl"
    let hhk_client_ip = "ziwrliqnbsayb"
    let hhk_local_time = "kxplpprydnjt"
    let hhk_local_timestamp = "ovqdxgapvq"
    let hhk_is_limit_ad_tracking = "zqxuiokeimv"
    let hhk_install_referrer = "aoffxqbga"
    let hhk_country = "vffgfseizdzua"
    let hhk_session_id = "sukutspgn"
    let hhk_network_type = "sboybfjwg"
    let hhk_utm_source = "uhrlvy"
    let hhk_utm_medium = "nqblmoz"
    let hhk_utm_campaign = "fhijjjim"
    
    func zhongtaiRequstChain(json: JSON, itemKey: String) -> JSON {
        let j = json["zlpmrelddv"][0]["wrntzcslmd"][0]["hgjhspwg"][0]["xkvgbnrw"][itemKey]
        return j
    }
    
    func requestAdGlobalConfig(completion: (()->Void)? = nil) {
        var hashistory = false
        if let json = self.loadAdJson(keyStr: k_globalConfig) {
            hashistory = true
            self.configAdGlobalConfig(json: json)
            printLog(type: .ad, msg: "加载缓存的广告全局配置")
            completion?()
        }
        APaiNetworkManager.default.adapiRequest(target: .fetchStrategy) {[weak self] json, statusCode in
            guard let `self` = self else {return}
            
            let successStatus = self.zhongtaiRequstChain(json: json, itemKey: "pptkdnt").intValue == 200
            if successStatus {
                self.configAdGlobalConfig(json: json)
                self.saveAd(json: json, keyStr: k_globalConfig)
            }
            printLog(type: .ad, msg: "加载中台线上的广告全局配置 - 是否成功 - \(successStatus)")
            if !hashistory {
                completion?()
            }
        }
    }
    
    func requestAdInfoItemsList(completion: (()->Void)? = nil) {
        var hashistory = false
        if let json = self.loadAdJson(keyStr: k_adInfoItemsConfig) {
            hashistory = true
            self.configAdInfoItems(json: json)
            printLog(type: .ad, msg: "加载缓存的广告Item配置")
            completion?()
        }
        APaiNetworkManager.default.adapiRequest(target: .fetchAdConfig) {[weak self] json, statusCode in
            guard let `self` = self else {return}
            
            let successStatus = self.zhongtaiRequstChain(json: json, itemKey: "yszthcwbznu").intValue == 200
            if successStatus {
                self.configAdInfoItems(json: json)
                self.saveAd(json: json, keyStr: k_adInfoItemsConfig)
            }
            printLog(type: .ad, msg: "加载中台线上的广告Item配置 - 是否成功 - \(successStatus)")
            if !hashistory {
                completion?()
            }
        }
    }
    
    func requestUserIpInfo() {
        var hashistory = false
        if let json = self.loadAdJson(keyStr: k_userIpInfo) {
            hashistory = true
            self.configUserIpInfo(json: json)
            printLog(type: .ad, msg: "加载缓存的用户IP信息")
        }
        APaiNetworkManager.default.adapiRequest(target: .userIP) { json, statusCode in
            self.configUserIpInfo(json: json)
            self.saveAd(json: json, keyStr: self.k_userIpInfo)
            printLog(type: .ad, msg: "加载线上接口的用户IP信息ip json = \(json)")
        }
    }
    
    func findAd(positionId: AdTypePostionId) -> ADAdInfoConfig? {
        printLog(type: .ad, msg: "开始查询广告Item - 广告位置 - \(page(positionId: positionId.rawValue))")
        //检查是否达到中台控制总量
        if !ADacManager.default.isCanLoadAdInGlobalConfigLimit() {
            return nil
        }
        //检查是否到达各自的展示次数
        if let adconfig = findAdConfig(positionId: positionId), ADacManager.default.isCanLoadAdInAdItemConfigLimit(adConfig: adconfig, positionId: positionId) {
            return adconfig
        }
        //
        
        return nil
    }
    
    private func findAdConfig(positionId: AdTypePostionId) -> ADAdInfoConfig? {
        //
        let item = self.adInfoItemsList.first {
            $0.advertiseId == positionId
        }
        if item?.status == "0" {
            printLog(type: .ad, msg: "广告源状态可用 - 广告位置 - \(page(positionId: positionId.rawValue))")
            return item
        } else {
            printLog(type: .ad, msg: "无广告或者广告源关闭 - 广告位置 - \(page(positionId: positionId.rawValue))")
            return nil
        }
    }
    
    func saveAd(json: JSON, keyStr: String) {
        if let rawjsonStr = json.rawString(), rawjsonStr != "" {
            UserDefaults.standard.setValue(rawjsonStr, forKey: keyStr)
            UserDefaults.standard.synchronize()
        }
    }
    
    func loadAdJson(keyStr: String) -> JSON? {
        if let str = UserDefaults.standard.value(forKey: keyStr) as? String, str != "" {
            let json = JSON(parseJSON: str)
            return json
        }
        return nil
    }
    
    func configAdGlobalConfig(json: JSON) {
        
        let infoJson = zhongtaiRequstChain(json: json, itemKey: "qunxewfambtk")
        let config = ADPubGlobalConfig(json: infoJson)
        ADacManager.default.adGlobalConfig = config
        
        printLog(type: .ad, msg: "获得全局广告配置 - 日最大展示：\(config.userDailyMaxShowNum)- 日最大点击：\(config.userDailyMaxClickNum)- 刷新时长：\(config.bannerRefreshTime)")
        
        let params = infoJson["heprdmnnxrnpo"].arrayValue
        params.forEach { json1 in
            let keystr = "mwqozatrjwblx"
            let valuestr = "xbivpkkuf"
            let k = json1[keystr].stringValue
            if k == "facechaintokey" {
                APaiNetworkManager.default.aliAccessTokey = json1[valuestr].stringValue
                printLog(type: .ad, msg: "获得ali token key - \(APaiNetworkManager.default.aliAccessTokey)")
            } else if k == "previewinsert" {
                ADacInterstitialAdManager.shared.config_previewClickCountDuration = json1[valuestr].intValue
                printLog(type: .ad, msg: "获得 首页点击预览的广告控制次数 - \(ADacInterstitialAdManager.shared.config_previewClickCountDuration)")
            } else if k == "settinginsert" {
                ADacInterstitialAdManager.shared.config_settingClickCountDuration = json1[valuestr].intValue
                printLog(type: .ad, msg: "获得 首页点击设置的广告控制次数 - \(ADacInterstitialAdManager.shared.config_settingClickCountDuration)")
            }
        }
    }
    
    func configAdInfoItems(json: JSON) {
        
        let adListJson = zhongtaiRequstChain(json: json, itemKey: "xygeutxgvehcg").arrayValue
        
        for jsModel in adListJson {
            let adInfo = ADAdInfoConfig(json: jsModel)
            let currentItem = ADacManager.default.adInfoItemsList.first {
                $0.advertiseId == adInfo.advertiseId
            }
            if let currentItem_m = currentItem {
                currentItem_m.updateInfo(fromItem: adInfo)
            } else {
                ADacManager.default.adInfoItemsList.append(adInfo)
            }
            printLog(type: .ad, msg: "获得独立广告配置 page: \(page(positionId:adInfo.advertiseId.rawValue))- 日最大展示：\(adInfo.frequencyUnitCount)- 日最大点击：\(adInfo.clickUnitCount)- 广告源状态：\(adInfo.status)-广告类型：\(adInfo.adsType)-广告ID：\(adInfo.adsId)")
        }
        printLog(type: .ad, msg: "获取广告配置信息 - \(ADacManager.default.adInfoItemsList.count)个广告")
        
    }
    
    func configUserIpInfo(json: JSON) {
        ADacManager.default.adUserIPInfo = ADUserIPInfo(json: json)
    }
}

extension ADacManager {
    func isFirstInstallApp() -> Bool {
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: k_isFirstLaunch)
        UserDefaults.standard.set(true, forKey: k_isFirstLaunch)
        UserDefaults.standard.synchronize()
        printLog(type: .ad, msg: "是否首次安装app - \(isFirstLaunch)")
        return isFirstLaunch
    }
    
    func checkIsNewAdDayAndClearStatus() {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let lastDateString = UserDefaults.standard.string(forKey: k_lastDate) ?? ""
        if lastDateString != formatter.string(from: currentDate) {
            UserDefaults.standard.set(formatter.string(from: currentDate), forKey: k_lastDate)
            printLog(type: .ad, msg: "是新一天,需要清除广告计数")
            resetupAdConfigCount()
            
        } else {
            printLog(type: .ad, msg: "是同一天,不需要清除广告计数")
        }
    }
    
    func resetupAdConfigCount() {
        UserDefaults.standard.setValue(0, forKey: k_genrateClickCount)
        UserDefaults.standard.setValue(0, forKey: k_tabbtnClickCount)
        UserDefaults.standard.setValue(0, forKey: k_adShowCount)
        UserDefaults.standard.setValue(0, forKey: k_adClickCount)
        //
        let positionList: [AdTypePostionId] = [
            .openScreenCold,
            .openScreenHot,
            .interstitialSubscribeClose,
            .interstitialSetting,
            .interstitialPreview,
            .interstitialGenerate,
            .interstitialReGenerate,
            .nativeHome,
            .nativeSetting,
            .nativeGenerating,
            .nativeGenerate,
            .nativeMyspace,
        ]
        //
        for positionId in positionList {
            let kShow = "\(k_adShowCount)\(positionId.rawValue)"
            let kClick = "\(k_adClickCount)\(positionId.rawValue)"
            UserDefaults.standard.setValue(0, forKey: kShow)
            UserDefaults.standard.setValue(0, forKey: kClick)
        }
        
        UserDefaults.standard.synchronize()
        printLog(type: .ad, msg: "重制广告计数")
    }
    
    func saveGenerateBtnClickCount() {
        let count = UserDefaults.standard.value(forKey: k_genrateClickCount) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k_genrateClickCount)
        UserDefaults.standard.synchronize()
        printLog(type: .ad, msg: "生成按钮点击数+1 = \(count + 1)")
    }
    
    func currentGenrateBtnClickCount() -> Int {
        let count = UserDefaults.standard.value(forKey: k_genrateClickCount) as? Int ?? 0
        printLog(type: .ad, msg: "当前生成按钮点击数 = \(count)")
        return count
    }
    
    func saveADShowCount(positionId: AdTypePostionId) {
        let count = UserDefaults.standard.value(forKey: k_adShowCount) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k_adShowCount)
        UserDefaults.standard.synchronize()
        
        printLog(type: .ad, msg: "广告展示page:\(page(positionId:positionId.rawValue)) +1 当前总数 = \(count + 1)")
        saveADItemPositionShowCount(positionId: positionId)
        
        checkIsNewAdDayAndClearStatus()
    }
    
    func saveADClickCount(positionId: AdTypePostionId) {
        let count = UserDefaults.standard.value(forKey: k_adClickCount) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k_adClickCount)
        
        printLog(type: .ad, msg: "广告点击 +1 当前总数 = \(count + 1)")
        saveADItemPositionClickCount(positionId: positionId)
        
        checkIsNewAdDayAndClearStatus()
    }
    
    func isCurrentADShowCountMax() -> Bool {
        let count = UserDefaults.standard.value(forKey: k_adShowCount) as? Int ?? 0
        if count < ADacManager.default.adGlobalConfig.userDailyMaxShowNum {
            printLog(type: .ad, msg: "广告总展示数 - \(count) 是否达到全局日上限\(ADacManager.default.adGlobalConfig.userDailyMaxShowNum) - \(false)")
            return false
        } else {
            printLog(type: .ad, msg: "广告总展示数 - \(count) 是否达到全局日上限\(ADacManager.default.adGlobalConfig.userDailyMaxShowNum) - \(true)")
            return true
        }
    }
    
    func isCurrentADClickCountMax() -> Bool {
        let count = UserDefaults.standard.value(forKey: k_adClickCount) as? Int ?? 0
        if count < ADacManager.default.adGlobalConfig.userDailyMaxClickNum {
            printLog(type: .ad, msg: "广告总点击数 - \(count) 是否达到全局日上限\(ADacManager.default.adGlobalConfig.userDailyMaxClickNum) - \(false)")
            return false
        } else {
            printLog(type: .ad, msg: "广告总点击数 - \(count) 是否达到全局日上限\(ADacManager.default.adGlobalConfig.userDailyMaxClickNum) - \(true)")
            return true
        }
    }
    
    func isCanLoadAdInGlobalConfigLimit() -> Bool {
        if isCurrentADShowCountMax() || isCurrentADClickCountMax() {
            printLog(type: .ad, msg: "超限度,不展示广告")
            return false
        } else {
            printLog(type: .ad, msg: "未超限度,可以展示广告")
            return true
        }
    }
}

extension ADacManager {
    func isCanLoadAdInAdItemConfigLimit(adConfig: ADAdInfoConfig , positionId: AdTypePostionId) -> Bool {
        
        if isCurrentADItemPositionShowCountMax(adConfig: adConfig, positionId: positionId) || isCurrentADItemPositionClickCountMax(positionId: positionId) {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数超过限度,不能继续加载广告")
            return false
        } else {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 未超限度,可以继续加载广告")
            return true
        }
    }
    
    func saveADItemPositionShowCount(positionId: AdTypePostionId) {
        let k = "\(k_adShowCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k)
        UserDefaults.standard.synchronize()
        printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数+1 = \(count + 1)")
    }
    
    func saveADItemPositionClickCount(positionId: AdTypePostionId) {
        let k = "\(k_adClickCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k)
        printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 点击数 = \(count + 1)")
    }
    
    func isCurrentADItemPositionShowCountMax(adConfig: ADAdInfoConfig, positionId: AdTypePostionId) -> Bool {
        let k = "\(k_adShowCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
//        guard let item = findAdConfig(positionId: positionId) else { return true }
        if count < adConfig.frequencyUnitCount {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数 - \(count)\n是否达到上限\(adConfig.frequencyUnitCount) - false")
            return false
        } else {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数 - \(count)\n是否达到上限\(adConfig.frequencyUnitCount) - true")
            return true
        }
    }
    
    func isCurrentADItemPositionClickCountMax(positionId: AdTypePostionId) -> Bool {
        let k = "\(k_adClickCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
        guard let item = findAdConfig(positionId: positionId) else { return false }
        if count < item.clickUnitCount {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 点击数 - \(count)\n是否达到上限\(item.clickUnitCount) - false")
            return false
        } else {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 点击数 - \(count)\n是否达到上限\(item.clickUnitCount) - true")
            return true
        }
    }
}

extension ADacManager {
    func saveTabBtnClickCount() {
        let count = UserDefaults.standard.value(forKey: k_tabbtnClickCount) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k_tabbtnClickCount)
        UserDefaults.standard.synchronize()
        printLog(type: .ad, msg: "保存首页Tab按钮点击数 - \(count + 1)")
    }
    
    func currentTabBtnClickCount() -> Int {
        let count = UserDefaults.standard.value(forKey: k_tabbtnClickCount) as? Int ?? 0
        printLog(type: .ad, msg: "首页Tab按钮点击数 - \(count)")
        return count
    }
    
    func checkTabBtnShouldAdStatus() -> Bool {
        saveTabBtnClickCount()
        if currentTabBtnClickCount() % 2 == 0 {
            printLog(type: .ad, msg: "首页Tab按钮点击数除2余数是否为0 - true")
            return true
        }
        printLog(type: .ad, msg: "首页Tab按钮点击数除2余数是否为0 - false")
        return false
    }
}

extension ADacManager {
    func beginCheckNetAndPrepare(in splashVC: UIViewController, prepareAdCompletion: @escaping (()->Void)) {
        //检查自然天是否归零广告计数数据
        checkIsNewAdDayAndClearStatus()
        //开始检查网络，请求中台广告信息，请求冷启动开屏广告，请求插屏广告
        if APaiNetworkManager.default.networkReachable() {
            printLog(type: .ad, msg: "网络可用")
            startPrepare(in: splashVC, prepareAdCompletion: prepareAdCompletion)
        } else {
            printLog(type: .ad, msg: "网络未知/不可用")
            APaiNetworkManager.default.loadNetRequest { reachable in
                printLog(type: .ad, msg: "网络 load reachable状态 - \(reachable)")
                if reachable {
                    self.startPrepare(in: splashVC, prepareAdCompletion: prepareAdCompletion)
                }
            }
        }
    }
    
    func startPrepare(in splashVC: UIViewController, prepareAdCompletion: @escaping (()->Void)) {
        
        printLog(type: .ad, msg: "开始准备 1.加载中台广告控制 2.加载中台配置的广告列表 3.请求用户IP 4.初始化Admob")
        self.globalGroup.enter()
        self.globalGroup.enter()
        self.globalGroup.enter()
        self.requestAdGlobalConfig {
            self.globalGroup.leave()
        }
        self.requestAdInfoItemsList {
            self.globalGroup.leave()
        }
        self.requestUserIpInfo()
        self.prepareAdmobAd(in: splashVC)
        self.globalGroup.notify(queue: DispatchQueue.main) {
            printLog(type: .ad, msg: "中台配置以及Admob都已完成。开始请求广告")
            prepareAdCompletion()
        }
        
        //MARK: - 定时20分钟刷新
        let timer = Timer.every(20 * 60) {
            self.requestAdGlobalConfig()
        }
        
        
    }
    
    func prepareAdmobAd(in splashVC: UIViewController) {
        if ADacManager.default.isEuropeanUser() {
            // Request an update for the consent information.
            if UMPConsentInformation.sharedInstance.canRequestAds {
                startGoogleMobileAdsSDK()
            } else {
                UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(with: nil) {
                    [weak self] requestConsentError in
                    guard let self else { return }
                    
                    if let consentError = requestConsentError {
                        // Consent gathering failed.
                        self.startGoogleMobileAdsSDK()
                        return //debugPrint("Error: \(consentError.localizedDescription)")
                    }
                    UMPConsentForm.loadAndPresentIfRequired(from: splashVC) {
                        [weak self] loadAndPresentError in
                        guard let self else { return }
                        if let consentError = loadAndPresentError {
                            // Consent gathering failed.
                            self.startGoogleMobileAdsSDK()
                            return //debugPrint("Error: \(consentError.localizedDescription)")
                        }
                        // Consent has been gathered.
                        if UMPConsentInformation.sharedInstance.canRequestAds {
                            self.startGoogleMobileAdsSDK()
                        } else {
                            self.startGoogleMobileAdsSDK()
                        }
                    }
                }
            }
        } else {
            startGoogleMobileAdsSDK()
        }
    }
    
    private func startGoogleMobileAdsSDK() {
        guard !self.isMobileAdsStartCalled else { return }
        self.isMobileAdsStartCalled = true
        // Initialize the Google Mobile Ads SDK.
        printLog(type: .ad, msg: "谷歌广告SDK初始化")
        GADMobileAds.sharedInstance().start {_ in
            self.globalGroup.leave()
        }
        gadMobileAdsVersion = "iOS \(GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber))"
    }

}

extension ADacManager {
    func isEuropeanUser() -> Bool {
        // 获取移动网络信息
        let networkInfo = CTTelephonyNetworkInfo()
        guard let carrier = networkInfo.subscriberCellularProvider else {
            return false
        }
        // 获取移动网络运营商的国家代码
        let countryCodeFromCarrier = carrier.isoCountryCode
        // 获取当前设备的国家代码
        let countryCodeFromLocale = Locale.current.regionCode?.lowercased()
        // 定义欧洲国家的ISO代码数组
        let europeanCountries: Set<String> = ["AT", "BE", "BG", "CY", "HR", "CZ", "DK", "EE", "FI", "FR", "DE", "EL", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE", "GR"]
        // 检查两个来源的国家代码是否属于欧洲国家
        let isEuropean = (countryCodeFromCarrier?.uppercased() ?? "").lowercased() == countryCodeFromLocale &&
        europeanCountries.contains(countryCodeFromLocale ?? "")
        printLog(type: .ad, msg: "欧洲国家判断 - \(isEuropean)")
        
        return isEuropean
    }
}

extension ADacManager {
    
    static func getUUID() -> String {
        #if DEBUG
        return ADacManager.debugUUID
        #endif
        
        let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecAttrAccount as String: bundleID,
            kSecAttrService as String: "Sparkle_UUID"
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        var uid = ""
        if status == errSecSuccess {
            if let data = dataTypeRef as? Data {
                uid = String(data: data, encoding: .utf8) ?? ""
            }
        }
        if uid.isEmpty {
            uid = addUUID(UUID().uuidString)
        }
        return uid
    }
    
    static func addUUID(_ uuid: String) -> String {
        let bundleID = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String ?? ""
        let query: [String: Any] = [
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
            kSecClass as String: kSecClassGenericPassword,
            kSecValueData as String: uuid.data(using: .utf8)!,
            kSecAttrAccount as String: bundleID,
            kSecAttrService as String: "Sparkle_UUID"
        ]
        
        var result: AnyObject?
        let status = SecItemAdd(query as CFDictionary, &result)
        if status == errSecSuccess {
            return uuid
        }
        
        return ""
    }
}

//MARK: 日志上传相关参数
extension ADacManager {
    func baseUploadDict() -> [String: Any] {
        
        var dict: [String: String] = [:]
        dict[hhk_app_id] = adAppID // (string)中台产品id app_id
        dict[hhk_app_name] = adAppName // (string)中台产品名称 app_name
        dict[hhk_app_version] = appVersion // (string)应用版本号 app_version
        dict[hhk_device_id] = ADacManager.getUUID() // (string)设备唯一标识符 device_id
        dict[hhk_brand] = "Apple" // (string)用户手机品牌。如：xiaomi brand
        dict[hhk_device_model] = Device.current.description // (string)用户手机型号 如：xiaomi14 device_model
        dict[hhk_resolution] = "\(UIScreen.main.bounds.size.width)*\(UIScreen.main.bounds.size.height)" // (string)(string)手机或终端的屏幕分辨率 resolution
        dict[hhk_os] = "iOS" // (string)操作系统，如：Android、iOS os
        dict[hhk_os_version] = systemVersion() // (string)操作系统的版本。如：Android 11 os_version
        dict[hhk_carrier] = carrier() // (string)运营商，如：ChinaUnion,ChinaNet carrier
        let (netName, netType) = NetworkMonitor.shared.getNetworkConnectionType()
        dict[hhk_access] = netName // (string)连接的网络，如：2G、3G、4G、5G、Wi-Fi access
        dict[hhk_access_subtype] = netType // (string)网络类型，如：HSPA、EVDO、EDGE、GPRS等 access_subtype
        dict[hhk_client_ip] = ADacManager.default.adUserIPInfo?.ip ?? "" // (string)用户真实ip client_ip
        dict[hhk_local_time] = localTime() // (string)终端时间（格式为yyyy-mm-dd hh24:mi:ss） local_time
        dict[hhk_local_timestamp] = CLongLong(round(Date().unixTimestamp*1000)).string // (string)终端时间（格式为数字型的unix 时间,精确到毫秒,可通过from_unixtime函数转换成日期） local_timestamp
        dict[hhk_is_limit_ad_tracking] = adIsLimitAdTracking.string // (string)用户是否启用了限制广告跟踪 is_limit_ad_tracking
        dict[hhk_install_referrer] = "app store" // (string)安装来源 install_referrer
        dict[hhk_country] = ADacManager.default.adUserIPInfo?.countryCode ?? "" // (string)用户国家 --- （作为子参数传到 args 参数中) country
        
        dict[hhk_session_id] = "" // (string)用户的一次会话id session_id
        dict[hhk_network_type] = "" // (string)根据access,access_subtype转化后的网络类型 -- (获取不到忽略该字段) network_type
        dict[hhk_utm_source] = "" // (string)广告来源，搜索引擎、渠道名称或其他来源。 utm_source
        dict[hhk_utm_medium] = "" // (string)广告媒介，媒介， 具体形式等，比如放在Banner上还是放在文字超链接里。 utm_medium
        dict[hhk_utm_campaign] = "" // (string)广告名称，这次活动、内容的名称。 utm_campaign
        
        return dict
    }
    
    func heheLog(event: HElogEvent) {
#if DEBUG
return
#endif
        switch event {
        case .firstInstall:
            var dict = baseUploadDict()
            let event_id = "10003"
            dict[hhk_event_id] = event_id
            APaiNetworkManager.default.adapiRequest(target: .logingTracking(event: dict)) { json, code in
                printLog(type: .logUpload, msg: "首次安装")
            }
        case .applogEvent(let eventName, let params):
            var dict = baseUploadDict()
            let event_id = "10004"
            dict[hhk_event_id] = event_id
            dict[hhk_page] = eventName
            if let failresone = params {
                var args: [String: String] = [:]
                args[hhk_v_fail_cause] = failresone
                dict[hhk_args] = args
            }
            
            APaiNetworkManager.default.adapiRequest(target: .logingTracking(event: dict)) { json, code in
                printLog(type: .logUpload, msg: "App事件记录\(eventName)")
            }
        case .adEvent(let adInfo, let adValue, let status, let errorInfo):
            
            var dict = baseUploadDict()
            var args: [String: String] = [:]
            var presition = ""
            switch adValue?.precision {
            case .estimated:
                presition = "estimated"
            case .precise:
                presition = "precise"
            case .publisherProvided:
                presition = "publisherProvided"
            case .unknown:
                presition = "unknown"
            default:
                presition = "unknown"
            }
            
            let event_id = "10001"
            dict[hhk_event_id] = event_id // (string)埋点的事件ID，事件ID为1000，page是表示当前页面，arg1表示上一个页面；事件ID为9999，page是默认page_extend,可埋点重写，arg1表示自定义事件名称 event_id
            dict[hhk_page] = page(positionId: adInfo?.advertiseId.rawValue ?? "") // (string)页面，如果有设置过页面名称，为设置的页面名称；如果未设置页面名称时，安卓默认取Activity的名称，Ios默认取ViewController的名称 page
            
            dict[hhk_ad_id] = getIDFA() ?? "" // (string)广告ID (GAID / IDFA) ad_id
            dict[hhk_ad_unit] = adInfo?.adsId ?? "" // (string)广告单元ID （作为子参数传到 args 参数中) ad_unit
            dict[hhk_ad_source] = adInfo?.adsPlatform ?? "" // (string)按广告来源查看效果。AdMob、Facebook、Pangle。 （作为子参数传到 args 参数中) ad_source
            args[hhk_ad_format] = adInfo?.adsType ?? "" // (string)按广告格式查看效果（横幅广告、原生广告、原生高级广告、插页式广告、插页式激励广告、激励广告、开屏广告）Banner, Native,Nativeadvanced, Interstitial, Rewarded interstitial, Rewarded, Appopen。（作为子参数传到 args 参数中) ad_format
            args[hhk_ad_type] = "" // (string)按广告类型（文字、图片、视频、Flash、动画图片、富媒体等）查看效果。可用枚举：Text, Pictures, Video,Flash,Animated Pictures, Rich Media。（作为子参数传到 args 参数中) ad_type
            args[hhk_ad_ad_gma_sdk] = gadMobileAdsVersion // (string)GMA SDK，集成到应用中的 Google 移动广告 SDK 版本查看效果。（iOS x.x.x orAndroidx.x.x）（作为子参数传到 args 参数中) ad_gma_sdk
            args[hhk_ad_value] = adValue?.value.stringValue ?? "" // (string)广告产生的价值。（作为子参数传到 args 参数中) ad_value
            args[hhk_ad_action] = status.rawValue // (string)广告的行为：发起请求、匹配、无匹配、展示、点击。（Request、Matched、Unmatched、Show、Click）（作为子参数传到args 参数中) ad_action
            args[hhk_ad_currency] = adValue?.currencyCode ?? "" // (string)广告的币种（ARS,USD,EUR）.etc （作为子参数传到 args 参数中) ad_currency
            
            args[hhk_ad_position] = adInfo?.advertiseId.rawValue ?? "" // (string)广告标识（HEHE中台广告位值） （作为子参数传到 args 参数中) ad_position
            args[hhk_ad_fail_cause] = errorInfo?.errorInfoStr ?? "" // (string)广告失败原因（待定，尽量别传堆栈信息） -- （作为子参数传到 args 参数中) ad_fail_cause
            args[hhk_ad_drop_type] = "Norm" // (string)Norm、Partners ---（作为子参数传到 args 参数中) ad_drop_type
            args[hhk_ad_start_mode] = "Cold" // (string)启动方式。（冷启动、热启动）- （Cold,Warm）---（作为子参数传到 args 参数中) ad_start_mode
            args[hhk_ad_precision_type] = presition // (string)精度类型。---（作为子参数传到 args 参数中) ad_precision_type
            args[hhk_ad_fail_cause_code] = errorInfo?.errorCode ?? "" // (string)广告失败原因自定义code，每款产品自定义code，用来统计具体广告失败原因的次数 ad_fail_cause_code
            dict[hhk_args] = args // (string)事件参数，调接口setProperty()等埋点的KV属性串 args
            
            APaiNetworkManager.default.adapiRequest(target: .logingTracking(event: dict)) { json, code in
                printLog(type: .logUpload, msg: "page = \(self.page(positionId: adInfo?.advertiseId.rawValue ?? ""))\nad_unit = \(adInfo?.adsId ?? "")\nad_position = \(adInfo?.advertiseId.rawValue ?? "")\nstatus.rawValue = \(status.rawValue)")
            }
            
            // facebook log event
            if let advalue_m = adValue {
                AppEvents.shared.logPurchase(amount: advalue_m.value.doubleValue, currency: advalue_m.currencyCode)
            }
            
        }
    }
    
    func systemVersion() -> String {
        let systemVersion = ProcessInfo().operatingSystemVersion
        let majorVersion = systemVersion.majorVersion
        let minorVersion = systemVersion.minorVersion
        let patchVersion = systemVersion.patchVersion
        let v = "\(majorVersion).\(minorVersion).\(patchVersion)"
//        debugPrint("操作系统版本: \(v)")
        return v
    }
    
    func localTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = dateFormatter.string(from: currentDate)
        return formattedDate
    }
    
    func carrier() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        // 获取当前运营商的名称
        if let carrier = networkInfo.subscriberCellularProvider?.carrierName {
            return carrier
        } else {
            return ""
        }
    }
    
    func getIDFA() -> String? {
        if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
            // 获取IDFA
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            return idfa
        } else {
            // 如果广告跟踪被禁用，则返回nil
            return nil
        }
    }
    
    func page(positionId: String) -> String {
        let position = AdTypePostionId(rawValue: positionId)
                
        switch position {
        case .openScreenCold:
            return "cold splash"
        case .openScreenHot:
            return "hot splash"
        case .interstitialSubscribeClose:
            return "subscribe close interstitial"
        case .interstitialSetting:
            return "setting interstitial"
        case .interstitialPreview:
            return "preview interstitial"
        case .interstitialGenerate:
            return "generate interstitial"
        case .interstitialReGenerate:
            return "regenerate interstitial"
        case .interstitialSelect4Photos:
            return "select 4photos interstitial"
        case .nativeHome:
            return "home native"
        case .nativeSetting:
            return "setting native"
        case .nativeGenerating:
            return "generating native"
        case .nativeGenerate:
            return "generate native"
        case .nativeMyspace:
            return "myspace native"
        case nil:
            return ""

        }
    }
}

extension ADacManager {
    func removeInvaliDateTimer(timer: Timer) {
        printLog(type: .ad, msg: "数组移除失效的计时器")
        currentActiveTimer.removeAll(timer)
    }
    func addNewAdCountTimer(timer: Timer) {
        printLog(type: .ad, msg: "数组添加计时器")
        if !currentActiveTimer.contains(timer) {
            currentActiveTimer.append(timer)
        }
    }
    func invalidActiveTimer() {
        printLog(type: .ad, msg: "失效当前活跃的计时器 currentActiveTimer count \(currentActiveTimer.count)")
        currentActiveTimer.forEach { time in
            time?.invalidate()
        }
        currentActiveTimer.removeAll()
    }
}

class ADAdInfoConfig {
    var adsId: String // elmjwa
    var adsType: String // sinsvxukmcsl
    var adsPlatform: String // qhcvdh
    var frequencyUnitCount: Int // uhrvoddw // 展示
    var clickUnitCount: Int // xqnzprqb // 点击
    var advertiseId: AdTypePostionId // mtqngwbzn 广告位id
    var status: String // vodehnrpqjt 广告源状态 0：正常 1：停用
//    var nativeADResponseInfoId: String = "" // 这个值不从历史记录中拿 也不存到历史记录中，是从加载出来的原生广告中找到ADResponseInfoId 从而在原生广告点击的时候找到对应的广告信息
    
    init(json: JSON) {
        self.adsId = json["pjduaczhgfh"].stringValue // 数据类型(String) 广告单元id
        self.adsType = json["letdohnzgtkvq"].stringValue // 数据类型(String)广告类型
        self.frequencyUnitCount = json["ikpygdgqzuvkm"].intValue // 数据类型(int32)单位内限制展示次数
        self.adsPlatform = json["ctkyzduk"].stringValue // 数据类型(String)广告平台
        self.clickUnitCount = json["txhcsfp"].intValue // 数据类型(int32)单位内限制点击次数
        self.advertiseId = AdTypePostionId(rawValue: json["zjzftneiid"].stringValue) ?? .openScreenCold // 数据类型(int64) 广告位id
        self.status = json["dtilervnzb"].stringValue // 数据类型(String) 广告源状态 0：正常 1：停用
    }
    
    func updateInfo(fromItem: ADAdInfoConfig) {
        self.adsId = fromItem.adsId
        self.adsType = fromItem.adsType
        self.frequencyUnitCount = fromItem.frequencyUnitCount
        self.adsPlatform = fromItem.adsPlatform
        self.clickUnitCount = fromItem.clickUnitCount
        self.advertiseId = fromItem.advertiseId
        self.status = fromItem.status
    }
}

struct ADPubGlobalConfig {
    var userDailyMaxShowNum: Int // cmwczijtqb
    var userDailyMaxClickNum: Int // nwqukbljtpcrd
    var bannerRefreshTime: Int //clbkkobkueu
    
    init() {
        self.userDailyMaxShowNum = 30
        self.userDailyMaxClickNum = 10
        self.bannerRefreshTime = 10
        
    }
    
    init(json: JSON) {
        self.userDailyMaxShowNum = json["rxsuyhayubhg"].intValue // (int)用户每日最大展示数（上限）
        self.userDailyMaxClickNum = json["nzmohb"].intValue // (int)用户每日最大点击数（上限）
        self.bannerRefreshTime = json["wscmtgivppjxc"].intValue // (int)原生banner刷新时间
    }
}

struct ADUserIPInfo {
    
    var ip: String
    var countryCode: String
    
    init(json: JSON) {
        self.ip = json["ip"].stringValue
        self.countryCode = json["country_code"].stringValue
    }
}

struct ADRequestError {
    var errorInfoStr: String
    var errorCode: String
}

enum AdTypePostionId: String {
    case openScreenCold = "1806608437325991936"
    case openScreenHot = "1806608635141820416"
    
    case interstitialSubscribeClose = "1806608995776860160"
    case interstitialSetting = "1806614387676286976"
    case interstitialPreview = "1806614270840803328"
    case interstitialGenerate = "1806614617334747136"
    case interstitialReGenerate = "1806614742397882368"
    case interstitialSelect4Photos = "1811243726927302656"
    
    case nativeHome = "1806616748101734400"
    case nativeSetting = "1806616882059153408"
    case nativeGenerating = "1806617007585890304"
    case nativeGenerate = "1806617121021628416"
    case nativeMyspace = "1806617251555446784"
    
}

enum GenerateBtnShouldStatus {
    case zero
    case interstitalAd
    case rewardAd
    case subscriptionVC
    case lastRewardAd
}

enum HElogEvent {
    case firstInstall
    case adEvent(adConfig: ADAdInfoConfig?, adValue: GADAdValue?, status: ADEventStatus, errorInfo: ADRequestError? = nil)
    case applogEvent(eventName: String, params: String?)
}

enum ADEventStatus: String {
    case request = "Request"
    case requestSuccess = "Matched"
    case requestFail = "Unmatched"
    case Impression = "Show"
    case Click = "Click"
}

enum PrintLogType: String {
    case logUpload = "日志上传"
    case ad = "广告逻辑"
    case app = "APP逻辑"
}

func printLog(type: PrintLogType, msg: String) {
    #if DEBUG
    print("*****[\(type.rawValue)!!!!!]\n\(msg)\n")
    #endif
}
