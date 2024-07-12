//
//  ADacNativeAdManager.swift
//  APaiAphroAI
//
//  Created by HONGJUNWANG on 2024/7/12.
//


import UIKit
import GoogleMobileAds
import SwiftyTimer
import TABAnimated
import SwiftyJSON


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

class ADHomePageViewController: UIViewController {
    
    var nativeAdBgV: UIView?
    var autorefreshAction: (()->Void)?
    var reloadNativeAdAction: ((Bool, Bool)->Void)?
    
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

                $0.top.equalTo(settingBtn.snp.bottom).offset(4)
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
 

enum ADEventStatus: String {
    case request = "Request"
    case requestSuccess = "Matched"
    case requestFail = "Unmatched"
    case Impression = "Show"
    case Click = "Click"
}

struct ADRequestError {
    var errorInfoStr: String
    var errorCode: String
}
enum HElogEvent {
    case firstInstall
    case adEvent(adConfig: ADAdInfoConfig?, adValue: GADAdValue?, status: ADEventStatus, errorInfo: ADRequestError? = nil)
    case applogEvent(eventName: String, params: String?)
}

class ADacManager: NSObject {
    static let `default` = ADacManager()
    var adInfoItemsList: [ADAdInfoConfig] = []
    let k_adShowCount = "k_adShowCount"
    let k_adClickCount = "k_adClickCount"
    var adGlobalConfig: ADPubGlobalConfig = ADPubGlobalConfig()
    func heheLog(event: HElogEvent) {
        
    }
    func findAd(positionId: AdTypePostionId) -> ADAdInfoConfig? {
        
        //检查是否达到中台控制总量
        if !ADacManager.default.isCanLoadAdInGlobalConfigLimit() {
            return nil
        }
        //检查是否到达各自的展示次数
        if !ADacManager.default.isCanLoadAdInAdItemConfigLimit(positionId: positionId) {
            return nil
        }
        //
        
        return findAdConfig(positionId: positionId)
    }
    
    func saveADShowCount(positionId: AdTypePostionId) {
        let count = UserDefaults.standard.value(forKey: k_adShowCount) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k_adShowCount)
        UserDefaults.standard.synchronize()
        
        printLog(type: .ad, msg: "广告展示page:\(page(positionId:positionId.rawValue)) +1 当前总数 = \(count + 1)")
        saveADItemPositionShowCount(positionId: positionId)
        
        checkIsNewAdDayAndClearStatus()
    }
    
    func saveADItemPositionShowCount(positionId: AdTypePostionId) {
        let k = "\(k_adShowCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k)
        UserDefaults.standard.synchronize()
        printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数+1 = \(count + 1)")
    }
    func saveADClickCount(positionId: AdTypePostionId) {
        let count = UserDefaults.standard.value(forKey: k_adClickCount) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k_adClickCount)
        
        printLog(type: .ad, msg: "广告点击 +1 当前总数 = \(count + 1)")
        saveADItemPositionClickCount(positionId: positionId)
        
        checkIsNewAdDayAndClearStatus()
    }
    
    
    func saveADItemPositionClickCount(positionId: AdTypePostionId) {
        let k = "\(k_adClickCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
        UserDefaults.standard.setValue(count + 1, forKey: k)
        printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 点击数 = \(count + 1)")
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
    
    func isCanLoadAdInAdItemConfigLimit(positionId: AdTypePostionId) -> Bool {
        guard let item = findAdConfig(positionId: positionId) else {
            return true
        }
        if isCurrentADItemPositionShowCountMax(positionId: positionId) || isCurrentADItemPositionClickCountMax(positionId: positionId) {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数超过限度,不能继续加载广告")
            return false
        } else {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 未超限度,可以继续加载广告")
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
    func isCurrentADItemPositionShowCountMax(positionId: AdTypePostionId) -> Bool {
        let k = "\(k_adShowCount)\(positionId.rawValue)"
        let count = UserDefaults.standard.value(forKey: k) as? Int ?? 0
        guard let item = findAdConfig(positionId: positionId) else { return true }
        if count < item.frequencyUnitCount {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数 - \(count)\n是否达到上限\(item.frequencyUnitCount) - false")
            return false
        } else {
            printLog(type: .ad, msg: "广告位 \(page(positionId:positionId.rawValue)) 展示数 - \(count)\n是否达到上限\(item.frequencyUnitCount) - true")
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
