//
//  HomeViewController.swift
//  RetroCamera
//
//  Created by Junsung Park on 2022/04/19.
//

import UIKit
import GoogleMobileAds
import SnapKit
import Siren
//import FirebaseMessaging

class HomeViewController: UIViewController,GADFullScreenContentDelegate, UIScrollViewDelegate, GADBannerViewDelegate{
    
    @IBOutlet weak var ivSlideshow:UIImageView!
    
    @IBOutlet weak var cameraBt:UIImageView!
    @IBOutlet weak var profileBt:UIImageView!
    
    @IBOutlet weak var collectionView:UICollectionView!
    
    @IBOutlet weak var more0:UILabel!
    @IBOutlet weak var more1:UILabel!
    @IBOutlet weak var more2:UILabel!
    
    @IBOutlet weak var stickerFrame:UIView!
    @IBOutlet weak var swapFrame:UIView!
    
    var tapView0:UIView = UIView()
    var tapView1:UIView!
    var tapView2:UIView!

//    @IBOutlet weak var bannerHeight:NSLayoutConstraint!
    
    
    @IBOutlet weak var desc0:UILabel!
    @IBOutlet weak var desc1:UILabel!
    @IBOutlet weak var desc2:UILabel!
    //    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var title0:UILabel!
    @IBOutlet weak var title1:UILabel!
    @IBOutlet weak var title2:UILabel!
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        view.addSubview(scrollView)
        return scrollView
    }()
    let imgView = UIImageView()
    let imgView2 = UIImageView()
  
    var imagesArraySlideshow : [UIImage] = []
    var slideShowIndex:NSInteger = 0
    
    var slideShowMax:NSInteger = 0
    var end:Bool!
    
    let filterSource:FilterDemoDataSource = FilterDemoDataSource()
    let contentView = UIView()

    var datas:Array<String> = Array<String>()
    @IBOutlet weak var  bannerView: GADBannerView!
    private var interstitial: GADInterstitialAd?
    let topView = UIView()
    
    var  bannerView0: GADBannerView!
    var isCamera:Bool = false
    let label = UILabel()
    
    var bannerHeight:CGFloat = 50
    var collectionView0:UICollectionView!
   
//    @objc func openCart() {
//        let cartVC = SubscribeViewController()
//        //        let cartVC = PaywallViewController()
//        cartVC.modalPresentationStyle = .fullScreen  // 전체 화면으로 설정
//        cartVC.modalTransitionStyle = .crossDissolve  // 슬라이드로 올라오는 애니메이션 설정
//        self.present(cartVC, animated: true, completion: nil)
//    }
    @objc func showStore()
    {
//        performSegue(withIdentifier: "exec_store", sender: 0)
        let cartVC = StoreViewController()
        cartVC.type = 0
        //        let cartVC = PaywallViewController()
        cartVC.modalPresentationStyle = .fullScreen  // 전체 화면으로 설정
        cartVC.modalTransitionStyle = .crossDissolve  // 슬라이드로 올라오는 애니메이션 설정
        self.present(cartVC, animated: true, completion: nil)
//        self.navigationController?.isNavigationBarHidden = false
//        navigationController?.pushViewController(cartVC, animated: true)
    }
    @objc func showStore2()
    {
//        performSegue(withIdentifier: "exec_store", sender: 1)
        //        performSegue(withIdentifier: "exec_store", sender: 0)
        let cartVC = StoreViewController()
        cartVC.type = 1
        //        let cartVC = PaywallViewController()
        cartVC.modalPresentationStyle = .fullScreen  // 전체 화면으로 설정
        cartVC.modalTransitionStyle = .crossDissolve  // 슬라이드로 올라오는 애니메이션 설정
        self.present(cartVC, animated: true, completion: nil)
//        self.navigationController?.isNavigationBarHidden = false
//        navigationController?.pushViewController(cartVC, animated: true)

    }
    @objc func showStore3()
    {
//        performSegue(withIdentifier: "exec_store", sender: 2)
        //        performSegue(withIdentifier: "exec_store", sender: 0)
        let cartVC = StoreViewController()
        cartVC.type = 2
        //        let cartVC = PaywallViewController()
        cartVC.modalPresentationStyle = .fullScreen  // 전체 화면으로 설정
        cartVC.modalTransitionStyle = .crossDissolve  // 슬라이드로 올라오는 애니메이션 설정
        self.present(cartVC, animated: true, completion: nil)
//        self.navigationController?.isNavigationBarHidden = false
//        navigationController?.pushViewController(cartVC, animated: true)

    }
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        
    }
    func setupAdBanner() {
        var bBuyVIP:Bool = UserDefaults.standard.bool(forKey: "BUY_VIP")
        
//        bBuyVIP = true
        if(bBuyVIP == false)
        {
            if bannerView0 !=  nil{
                bannerView0.removeFromSuperview()
            }
            bannerView0 = GADBannerView(adSize: GADAdSizeBanner) // 배너 광고 사이즈 설정
            bannerView0.adUnitID = "ca-app-pub-7915959670508279/8457567696" // 실제 배너 광고 유닛 ID로 변경
            bannerView0.rootViewController = self
            bannerView0.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(UIScreen.main.bounds.size.width)

            let extras = GADExtras()
              extras.additionalParameters = ["collapsible" : "bottom"]
            let request = GADRequest()
              
//            request.register(extras)

            bannerView0.delegate = self
            contentView.addSubview(bannerView0)
            
            bannerHeight = 50

            // 배너 레이아웃 설정 (높이 100으로 고정)
            bannerView0.snp.makeConstraints { make in
//                make.top.equalTo(imageView.snp.top)
                make.top.equalToSuperview()
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(bannerHeight) // 배너 높이를 100으로 고정
            }
            
            bannerView0.load(request)
        }
        else{
            if(bannerView0 != nil){
                bannerView0.removeFromSuperview()
            }
            bannerHeight = 0
//            bannerView0.snp.makeConstraints { make in
////                make.top.equalTo(imageView.snp.top)
//                make.top.equalToSuperview()
//              
//                make.leading.trailing.equalToSuperview()
//                make.height.equalTo(bannerHeight) // 배너 높이를 100으로 고정
//            }
        }
//        bannerView0.layoutIfNeeded()
        
    }
    func checkUpdate() {
           let siren = Siren.shared
           siren.rulesManager = RulesManager(globalRules: .critical,
                                             showAlertAfterCurrentVersionHasBeenReleasedForDays: 0)

           siren.wail { results in
               switch results {
               case .success(let updateResults):
                   print("AlertAction ", updateResults.alertAction)
                   print("Localization ", updateResults.localization)
                   print("Model ", updateResults.model)
                   print("UpdateType ", updateResults.updateType)
               case .failure(let error):
                   print(error.localizedDescription)
               }
           }
       }
    func initUI()
    {
        setupAdBanner()
        self.view.backgroundColor = Constants.topBar1//.white//Constants.mainColor
        
        topView.backgroundColor = Constants.topBar1//.white
        
        
        self.view.addSubview(topView)
        topView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)//.offset(50)
            
            make.height.equalTo(64)
        }
        
        let titleView = UILabel()
        titleView.text = "Retro Camera"
        titleView.textColor = Constants.titleColor
        titleView.font = UIFont(name: "Helvetica", size: 18)
        titleView.textAlignment = .center
        //        titleView.backgroundColor = .systemBlue
        topView.addSubview(titleView)
        titleView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
        
        let subscribeBt = UIButton()
        
        subscribeBt.setImage(UIImage(systemName: "cart.fill")?.withRenderingMode(.alwaysTemplate), for: .normal)
        subscribeBt.addTarget(self, action: #selector(openCart), for: .touchUpInside)
        subscribeBt.tintColor = .white
//        UIImage(systemName: "cart.fill")
        topView.addSubview(subscribeBt)
        
        subscribeBt.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(30)
      
        }
        
        scrollView.backgroundColor = Constants.bottomBarColor
        
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        scrollView.addSubview(contentView)
        
        contentView.backgroundColor = Constants.bottomBarColor//Constants.mediumBlue
        //        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview() // 스크롤뷰의 모든 가장자리에 연결
            make.width.equalTo(scrollView.snp.width) // 스크롤뷰의 너비를 맞춤 (가로 스크롤 방지)
        }
        setupContent()

    }
    @objc func closeTapped(){
        dismiss(animated: false)
    }
    func setupContent() {
        
        label.text = "Face AI Sticker Filter".localized
        label.font = UIFont(name: "Helvetica", size: 18)
        label.textAlignment = .center
        label.textColor = Constants.labelTitleColor
        contentView.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(30 + bannerHeight)
            make.leading.equalToSuperview().inset(16)
        }
        imgView.contentMode = .scaleAspectFill
        imgView.image = UIImage(named: "d0")
        imgView.layer.cornerRadius = 10
        imgView.clipsToBounds = true
        let height = (UIScreen.main.bounds.size.width - 32) * 0.75
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(label.snp.bottom).offset(10)
            make.height.equalTo(height)
          
        }
        
        
//        tapView0 = UIView()
        tapView0.backgroundColor = .clear
        self.view.addSubview(tapView0)
        tapView0.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(label.snp.bottom).offset(10)
            make.height.equalTo(height)
          
        }
        let descLabel0 = UILabel()
        descLabel0.textColor = Constants.mainTitleColor
        descLabel0.numberOfLines = 0
        descLabel0.font = UIFont(name: "Helvetica", size: 14)
       
        descLabel0.text = "How are you feeling today?\nUpgrade your mood with cute and fun sticker lenses. We look forward to seeing you again.".localized
        contentView.addSubview(descLabel0)
        
        descLabel0.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imgView.snp.bottom).offset(10)
        }
        
        let label1 = UILabel()
        label1.text = "Color Lookup Filter".localized
        label1.font = UIFont(name: "Helvetica", size: 18)
        label1.textAlignment = .left
        label1.textColor = Constants.labelTitleColor
        contentView.addSubview(label1)
        label1.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(descLabel0.snp.bottom).offset(16)
        }
        
        datas.removeAll()
        datas.append("p0")
        datas.append("p9")
        datas.append("p2")
        datas.append("p8")
        datas.append("p1")
        datas.append("p5")
        datas.append("p6")
        datas.append("p7")
        datas.append("p4")
        datas.append("p2")

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0

        //56 + 18 + 8
        let width = UIScreen.main.bounds.size.width
        layout.itemSize = CGSize(width: 120,height: 120)

        filterSource.parentCon = self
        filterSource.initData(data: datas)
        
        collectionView0 = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView0.register(FilterCell.self, forCellWithReuseIdentifier: "FilterCell")
      
        collectionView0.dataSource = filterSource
        collectionView0.delegate = filterSource
        
        let tapGesture5 = UITapGestureRecognizer(target: self, action: #selector(showStore2))
        collectionView0.isUserInteractionEnabled = true
        collectionView0.addGestureRecognizer(tapGesture5)
//        collectionView0.setCollectionViewLayout(layout, animated: false)
//        
//        collectionView0.setCollectionViewLayout(layout, animated: false)

        contentView.addSubview(collectionView0)
      
        collectionView0.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(label1.snp.bottom).offset(10)
            make.height.equalTo(120)
   
        }
        collectionView0.isUserInteractionEnabled = true
      
        collectionView0.reloadData()
        
        let descLabel1 = UILabel()
        descLabel1.textColor = Constants.mainTitleColor
        descLabel1.numberOfLines = 0
        descLabel1.font = UIFont(name: "Helvetica", size: 14)
       
        descLabel1.text = "Retro Camera captures you beautifully, lovingly, warmly, and sometimes vintage. check it out now".localized
        contentView.addSubview(descLabel1)
        
        descLabel1.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(collectionView0.snp.bottom).offset(10)
        }
        
        let label2 = UILabel()
        label2.text = "Face Swap Filter".localized
        label2.font = UIFont(name: "Helvetica", size: 18)
        label2.textAlignment = .left
        label2.textColor = Constants.labelTitleColor
        contentView.addSubview(label2)
        label2.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(descLabel1.snp.bottom).offset(16)
        }
        imgView2.contentMode = .scaleAspectFill
        imgView2.image = UIImage(named: "face_swap")
        imgView2.layer.cornerRadius = 10
        imgView2.clipsToBounds = true
        let height0 = (UIScreen.main.bounds.size.width - 32) * 0.75
        contentView.addSubview(imgView2)
        imgView2.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(label2.snp.bottom).offset(10)
            make.height.equalTo(height)
          
        }
        
        let descLabel2 = UILabel()
        descLabel2.textColor = Constants.mainTitleColor
        descLabel2.numberOfLines = 0
        descLabel2.font = UIFont(name: "Helvetica", size: 14)
       
        descLabel2.text = "Find another face of yours!\nSometimes handsome and beautiful...\nSometimes it's fun!!!".localized
        contentView.addSubview(descLabel2)
        
        descLabel2.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(imgView2.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-20)
        
        }
        
        
        let cpatureBack = UIImageView()
        cpatureBack.image = UIImage(named: "capture_rev")
        cpatureBack.layer.cornerRadius = 60
        cpatureBack.clipsToBounds = true
        self.view.addSubview(cpatureBack)
        cpatureBack.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
            make.width.equalTo(120)
            make.bottom.equalToSuperview().offset(-100)
          
        }
        
        let cameraBt0 = UIButton()
//        cameraBt0.backgroundColor = .white
//        cameraBt0.clipsToBounds = true
//        cameraBt0.layer.cornerRadius = 40
//        cameraBt0.contentMode = .scaleAspectFit
        cameraBt0.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        cameraBt0.setImage(UIImage(named: "camera"), for: .normal)
        self.view.addSubview(cameraBt0)
        
        cameraBt0.snp.makeConstraints { make in
            make.centerY.equalTo(cpatureBack.snp.centerY)
            make.centerX.equalTo(cpatureBack.snp.centerX)
   
            make.height.equalTo(60)
            make.width.equalTo(60)
          
        }

        }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
  
        buildImagesArraySlideshow()
        initGesture()
        initUI()
        
        //
        //  bannerHeight.constant = 0
//        bannerView.adUnitID = "ca-app-pub-7915959670508279/8457567696"
//        bannerView.rootViewController = self
//        bannerView.load(GADRequest())
        
//        setupAdBanner()
    }
    
    

    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        var vip0 = UserDefaults.standard.bool(forKey: "BUY_VIP0")
        var vip1 = UserDefaults.standard.bool(forKey: "BUY_VIP1")
        var vip2 = UserDefaults.standard.bool(forKey: "BUY_VIP2")
        
        
        if(vip0 == false)
        {
            showStore()
        }
        else if(vip1 == false)
        {
            showStore2()
        }
        else if(vip2 == false)
        {
            showStore3()
        }
    }
    func showFullAd()
    {
        //
        let request = GADRequest()
        
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-7915959670508279/7706758658",
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
            if interstitial != nil {
                interstitial!.present(fromRootViewController: (self))
            } else {
                print("Ad wasn't ready")
            }
            
        }
                               
        )
        
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // login check
        self.navigationController?.isNavigationBarHidden = true
  
//        let appearance = UINavigationBarAppearance()
//        //        appearance.configureWithOpaqueBackground()
//        appearance.backgroundColor = Constants.mainColor//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0) // 투명 배경
//        appearance.titleTextAttributes = [.foregroundColor: UIColor.white] // 타이틀 텍스트 색상
//        appearance.shadowImage = UIImage()
//        //        appearance.shadowColor = .black
//        
//        
//        self.navigationController?.navigationBar.standardAppearance = appearance
//        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
//        showSlide()
        self.end = false
        showSlide(imgView: imgView)
        var vip0 = UserDefaults.standard.bool(forKey: "BUY_VIP0")
        var vip1 = UserDefaults.standard.bool(forKey: "BUY_VIP1")
        var vip2 = UserDefaults.standard.bool(forKey: "BUY_VIP2")
        
//        vip0 = true
        if( vip0 == true || vip1 == true || vip2 == true)
        {
//            bannerHeight.constant = 0
            bannerHeight = 0
        }
        if( vip0 == true && vip1 == true && vip2 == true)
        {
            
        }
        else
        {
            if(JunSoftUtil.shared.isDetail == true)
            {
                JunSoftUtil.shared.isDetail = false
                showFullAd()
            }
            
        }
        
        checkUpdate()
        
        
    }
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    override func viewDidAppear(_ animated: Bool) {
        let userId = UserDefaults.standard.string(forKey: "USER_ID")
        let isIntro = UserDefaults.standard.bool(forKey: "INTRO_LOAD")
        let isInit = UserDefaults.standard.bool(forKey: "INIT_APP")
        
//        if( isInit == false)
//        {
//            UserDefaults.standard.set(true, forKey: "INIT_APP")
//            UserDefaults.standard.synchronize()
//            CameraAPI.shared.initCameraSession(front: true)
//            
//            performSegue(withIdentifier: "exec_store", sender: 0)
//            
//        }
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.end = true
        
        isCamera = false
    }
    func buildImagesArraySlideshow(){
        // example: localImageFilePath:URL = *URLs FOR SOME LOCAL IMAGE FILES*
        
        imagesArraySlideshow.append(UIImage(named: "d0")!)
        imagesArraySlideshow.append(UIImage(named: "d2")!)
        
        imagesArraySlideshow.append(UIImage(named: "d3")!)
        imagesArraySlideshow.append(UIImage(named: "d4")!)
        
        imagesArraySlideshow.append(UIImage(named: "d5")!)
        
    }
//    func showSlide()
//    {
//        buildImagesArraySlideshow()
//        self.end = false
//        self.slideShowMax = self.imagesArraySlideshow.count
//        // ivSlideshow.contentMode = .scaleToFill
//        DispatchQueue.global(qos: .userInteractive).async (
//            execute: {() -> Void in
//                while self.end == false {
//                    print ("MAX:"+String(self.slideShowMax))
//                    
//                    DispatchQueue.main.async(execute: {() -> Void in
//                        let toImage = self.imagesArraySlideshow[self.slideShowIndex]
//                        print ("index:"+String(self.slideShowIndex))
//                        UIView.transition(
//                            with: self.ivSlideshow,
//                            duration: 0.6,
//                            options: .transitionCrossDissolve,
//                            animations: {self.ivSlideshow.image = toImage},
//                            completion: nil
//                        )
//                    })
//                    self.slideShowIndex += 1
//                    if self.slideShowIndex == self.slideShowMax {
//                        self.slideShowIndex = 0
//                    }
//                    sleep(2)
//                }
//            })
//    }
    func showSlide(imgView:UIImageView)
    {
        buildImagesArraySlideshow()
        self.end = false
        self.slideShowMax = self.imagesArraySlideshow.count
        // ivSlideshow.contentMode = .scaleToFill
        DispatchQueue.global(qos: .userInteractive).async (
            execute: {() -> Void in
                while self.end == false {
                    print ("MAX:"+String(self.slideShowMax))
                    
                    DispatchQueue.main.async(execute: {() -> Void in
                        let toImage = self.imagesArraySlideshow[self.slideShowIndex]
                        print ("index:"+String(self.slideShowIndex))
                        UIView.transition(
                            with: imgView,
                            duration: 0.6,
                            options: .transitionCrossDissolve,
                            animations: {imgView.image = toImage},
                            completion: nil
                        )
                    })
                    self.slideShowIndex += 1
                    if self.slideShowIndex == self.slideShowMax {
                        self.slideShowIndex = 0
                    }
                    sleep(2)
                }
            })
    }
    func initDemoData()
    {
        
//        datas.removeAll()
//        datas.append("p0")
//        datas.append("p9")
//        datas.append("p2")
//        datas.append("p8")
//        datas.append("p1")
//        datas.append("p5")
//        datas.append("p6")
//        datas.append("p7")
//        datas.append("p4")
//        datas.append("p2")
//        
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        layout.minimumLineSpacing = 0
//        
//        //56 + 18 + 8
//        let width = UIScreen.main.bounds.size.width
//        layout.itemSize = CGSize(width: 120,height: 120)
//        
//        filterSource.parentCon = self
//        filterSource.initData(data: datas)
//        collectionView.dataSource = filterSource
//        collectionView.delegate = filterSource
//        collectionView.setCollectionViewLayout(layout, animated: false)
//        
//        collectionView.reloadData()
    }
    @objc func showCamera()
    {
        showCameraView()
    }
    
    func initGesture()
    {
//        let tapGesture0 = UITapGestureRecognizer(target: self, action: #selector(showCamera))
//        cameraBt.isUserInteractionEnabled = true
//        cameraBt.addGestureRecognizer(tapGesture0)
//        
//
//        //ivSlideshow
//        
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(showStore))
        tapView0.isUserInteractionEnabled = true
        tapView0.addGestureRecognizer(tapGesture2)
//
//        
//        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(showStore2))
//        more1.isUserInteractionEnabled = true
//        more1.addGestureRecognizer(tapGesture4)
//        

//        
        let tapGesture6 = UITapGestureRecognizer(target: self, action: #selector(showStore3))
        imgView2.isUserInteractionEnabled = true
        imgView2.addGestureRecognizer(tapGesture6)
    }
    
    @objc func showProfile()
    {
        performSegue(withIdentifier: "exec_profile", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "exec_store"{
            
            let type = sender as! Int
            
            if let detail = segue.destination as? StoreViewController {
                detail.type = type
                if(type == 0)
                {
                    detail.titleStr = "Face AI Sticker Lens"
                    
                }
                if(type == 1)
                {
                    detail.titleStr = "Color Lookup Lens"
                    
                }
                if(type == 2)
                {
                    detail.titleStr = "Face AI Swap Lens"
                    
                }
            }
        }
    }
}

extension UIViewController
{
    
    @objc func openCart() {
        let cartVC = SubscribeViewController()
        //        let cartVC = PaywallViewController()
        cartVC.modalPresentationStyle = .fullScreen  // 전체 화면으로 설정
        cartVC.modalTransitionStyle = .crossDissolve  // 슬라이드로 올라오는 애니메이션 설정
        self.present(cartVC, animated: true, completion: nil)
    }
}
