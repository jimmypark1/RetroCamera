import GoogleMobileAds
import UIKit

class AdMobOpenAdManager: NSObject {
    
    @objc static let shared = AdMobOpenAdManager()
    private var appOpenAd: GADAppOpenAd?
    private var isShowingAd = false
    private let adUnitID = "ca-app-pub-7915959670508279/3886916299" // AdMob 광고 단위 ID
    var isClose = false

    var rootViewController:UIViewController?
    // 광고 로드 함수
    func loadAd() {
        guard shouldShowAd() else {
            print("하루 1회 광고 제한 - 광고 표시 안 함")
//            CMNotificationCenter.default().postNotificationName("CMAppOpeningADShowNotification", object: nil)
//            return
            return
        }
        if isClose{
            return
        }
        GADAppOpenAd.load(
            withAdUnitID: adUnitID,
            request: GADRequest()
         ) {[weak self]  (ad: GADAppOpenAd?, error: Error?) in
             if let error = error {
                 print("앱 오픈 광고 로드 실패: \(error.localizedDescription)")
                 return
             }
             self?.appOpenAd = ad
             self?.show()
        }
//        GADAppOpenAd.load(
//            withAdUnitID: adUnitID,
//            request: GADRequest(),
//            orientation: UIInterfaceOrientation.portrait
//        ) { [weak self] (ad, error) in
//            if let error = error {
//                print("앱 오픈 광고 로드 실패: \(error.localizedDescription)")
//                return
//            }
//            self?.appOpenAd = ad
//            self?.show()
        
//        }
    }
    @objc func firstInstall(){
        UserDefaults.standard.set(true, forKey: "FIRST_INSTALL")
        UserDefaults.standard.synchronize()
     
    }
    func show()
    {
//        guard shouldShowAd() else {
//            print("하루 1회 광고 제한 - 광고 표시 안 함")
//            CMNotificationCenter.default().postNotificationName("CMAppOpeningADShowNotification", object: nil)
//
//            return
//        }

        if let ad = appOpenAd, !isShowingAd
        {
            isClose = true
            if self.rootViewController != nil{
                DispatchQueue.main.async { [weak self] in
                    self?.isShowingAd = true
                    ad.present(fromRootViewController: (self?.rootViewController)!)
                    
                     // 광고 표시 후 다시 로드
                    print("앱 오픈 광고 ad.present")
                 
                    ad.fullScreenContentDelegate = self
                    self?.saveLastAdDate()
                }
               
            }
            else{
                DispatchQueue.main.async { [weak self] in
                    self?.isShowingAd = true
                    ad.present(fromRootViewController: (UIApplication.shared.keyWindow?.rootViewController)!)
                    
                    // 광고 표시 후 다시 로드
                    print("앱 오픈 광고2 ad.present")
                 
                    ad.fullScreenContentDelegate = self
                    self?.saveLastAdDate()
                }
            }
           
        }
    }
    // 광고 표시 함수
    @objc func showAdIfAvailable(viewController: UIViewController) {
        self.rootViewController = viewController
        loadAd()
    }
   
    // 광고 본 날짜 저장
    private func saveLastAdDate() {
        UserDefaults.standard.set(Date(), forKey: "LastAdDate")
    }

    // 하루가 지났는지 확인
    
    @objc public func shouldShowAd() -> Bool
    {
        let lastAdDate = UserDefaults.standard.object(forKey: "LastAdDate") as? Date ?? Date.distantPast
        let calendar = Calendar.current
        let lastAdDay = calendar.startOfDay(for: lastAdDate)
        let today = calendar.startOfDay(for: Date())

        return today > lastAdDay
    }
}

// 광고 닫힘 이벤트 처리
extension AdMobOpenAdManager: GADFullScreenContentDelegate {
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("앱 오픈 광고 닫힘")
        isShowingAd = false
        isClose = false
    
//        CMNotificationCenter.default().postNotificationName("CMAppOpeningADShowNotification", object: nil)
    }
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
       print("App open ad will be presented.")
     }

    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content: \(error.localizedDescription)")
    }
}
