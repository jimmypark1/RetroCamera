import UIKit
import SnapKit
import GoogleMobileAds

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, GADBannerViewDelegate {

    let pages = ["intro0_title".localized, "intro1_title".localized ,"intro2_title".localized,"intro3_title".localized, "intro4_title".localized, "intro5_title".localized]
    let descs = [
        "intro0".localized,
        "intro1".localized,
        "intro2".localized,
        "intro3".localized,
        "intro4".localized,
        "intro5".localized]
 
    var pageControl = UIPageControl()
    var pageViewControllers: [UIViewController] = []
    var bannerView: GADBannerView!
    var imgView:UIImageView!
    
    var imageNames: [String] = [] // 애니메이션 이미지 이름 배열
    var imageNames2: [String] = [] // 애니메이션 이미지 이름 배열
    var imageNames3: [String] = [] // 애니메이션 이미지 이름 배열
    var animationTimer: Timer?    // 타이머를 사용하여 이미지 애니메이션 처리
    var curIndex = 0
    var nextBt:UIButton!
    var prevBt:UIButton!
    var titleLabel:UILabel!
//    private let gradientLayer = CAGradientLayer()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        self.delegate = self
        self.navigationController?.isNavigationBarHidden = true
 
        // 각 페이지를 위한 뷰 컨트롤러 생성
        for (index, pageText) in pages.enumerated() {
            let pageVC = createContentViewController(with: pageText, index: index, isLastPage: index == pages.count - 1)
            pageViewControllers.append(pageVC)
        }

        // 첫 번째 페이지로 설정
        if let firstVC = pageViewControllers.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        nextBt = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        nextBt.setImage(UIImage(systemName: "chevron.right.circle"), for: .normal)
        nextBt.tintColor = Constants.onBoardingLabel
        nextBt.addTarget(self, action: #selector(nextPage), for: .touchUpInside)

        prevBt = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        prevBt.setImage(UIImage(systemName: "chevron.left.circle"), for: .normal)
        prevBt.tintColor = Constants.onBoardingLabel
        prevBt.addTarget(self, action: #selector(prevPage), for: .touchUpInside)
//        prev.layer.zPosition = 1000
//        prev.layer.cornerRadius = 10
        self.view.addSubview(prevBt)
        self.view.addSubview(nextBt)
        
        prevBt.alpha = 0
       
        nextBt.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(60)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
        prevBt.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().offset(60)
            make.width.equalTo(40)
            make.height.equalTo(40)
        }
     
        self.isPagingEnabled = false
 
        setupAdBanner() // AdMob 배너 설정
 
        setupPageControl()
    }

    // SnapKit을 사용한 PageControl 설정
    func setupPageControl() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.backgroundColor = Constants.onBoardingBackground//.white
        pageControl.tintColor = .black
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged) // 터치 이벤트 처리 추가
        self.view.addSubview(pageControl)

        
        pageControl.snp.makeConstraints { make in
            make.bottom.equalTo(bannerView.snp.top).offset(0) // AdMob 배너를 위한 여백
            make.height.equalTo(50)
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.centerX.equalToSuperview()
        }
    }

    // 페이지 컨트롤 터치 시 페이지 전환 처리
    @objc func pageControlTapped(_ sender: UIPageControl) {
        let currentIndex = pageControl.currentPage
        guard let visibleVC = viewControllers?.first,
              let visibleIndex = pageViewControllers.firstIndex(of: visibleVC) else { return }
        
        let direction: UIPageViewController.NavigationDirection = currentIndex > visibleIndex ? .forward : .reverse
        let nextVC = pageViewControllers[currentIndex]
        setViewControllers([nextVC], direction: direction, animated: true, completion: nil)
    }

    // AdMob 배너 설정
    func setupAdBanner() {
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = "ca-app-pub-7915959670508279/4342550205" // 실제 AdMob 광고 ID 사용
        bannerView.rootViewController = self
        bannerView.delegate = self
        self.view.addSubview(bannerView)

        bannerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
//            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview()
       
            make.height.equalTo(50) // AdMob 배너 기본 높이
        }

        bannerView.load(GADRequest())
    }
    func createPlanButton(title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }

    // 각 페이지를 위한 Content View Controller 생성
    func createContentViewController(with text: String, index: Int, isLastPage: Bool) -> UIViewController {
        let gradientLayer = CAGradientLayer()
       
        var contentVC = UIViewController()
        contentVC.view.backgroundColor = Constants.onBoardingBackground//.white//UIColor.systemTeal
        if(index == 0 ){
            contentVC.view.backgroundColor = Constants.onBoardingBackground//.white//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
          

        }
//        else if(index == 1 ){
//            contentVC = DemoViewController()
//            (contentVC as! DemoViewController).type = 0
//            contentVC.view.backgroundColor = Constants.onBoardingBackground//.white//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
//        }
//        else if(index == 2 ){
//            contentVC = DemoViewController()
//            (contentVC as! DemoViewController).type = 1
//            contentVC.view.backgroundColor = Constants.onBoardingBackground//.white//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
//        }
//        else if(index == 3 ){
//            contentVC = DemoViewController()
//            (contentVC as! DemoViewController).type = 2
//            contentVC.view.backgroundColor = Constants.onBoardingBackground//.white//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
//        }
        else{
            contentVC.view.backgroundColor = Constants.onBoardingBackground//.white//UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)
           
     

        }

        imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        contentVC.view.addSubview(imgView)

        if(index != 1 && index != 2 && index != 3){
            var colors = [CGColor]()
         
            colors.append(UIColor.clear.cgColor)
            colors.append(UIColor.black.cgColor)
         
            gradientLayer.colors = colors
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 하단
            gradientLayer.locations = [0.7]
            gradientLayer.frame = CGRectMake(0, 100 , UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.width)//headerImageView.bounds
     
            contentVC.view.layer.insertSublayer(gradientLayer, at: 3)
     
        }

        
//        let title = UILabel()
//        title.text = text
//        title.textAlignment = .center
//        title.textColor = .label//.white
//        title.font = UIFont(name: "Helvetica-SemiBold", size: 20)
//        title.numberOfLines = 0
  

        titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.textAlignment = .center
        titleLabel.textColor = Constants.onBoardingLabel//.white
        titleLabel.font = UIFont(name: "Helvetica-SemiBold", size: 20)
        titleLabel.numberOfLines = 0
        
        
        let desc = UILabel()
        desc.text = descs[index]
        desc.textColor = Constants.onBoardingLabel//.secondaryLabel//.white
        desc.font = UIFont(name: "Helvetica", size: 16)
        desc.numberOfLines = 0
    
        contentVC.view.addSubview(titleLabel)
        contentVC.view.addSubview(desc)

        imgView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(100)
//            make.height.equalTo(contentVC.view.snp.height).multipliedBy(0.5)
            make.height.equalTo(UIScreen.main.bounds.size.width)
        }
        
       
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(65)
         
//            make.top.equalTo(imgView.snp.bottom).offset(20)
//            make.height.equalTo(30)

        }
        desc.snp.makeConstraints { make in
            make.leading.equalTo(24)
            make.trailing.equalTo(-24)
            make.top.equalTo(imgView.snp.bottom).offset(10)
            make.height.equalTo(100)
       
        }
        if index == 0 {
            imageNames.removeAll()
         
            imageNames = ["p0","p1","p2","p3","p4","p5","p6", "p7", "p8", "p9"]
            imgView.image = UIImage(named: imageNames[0])
            startImageAnimation(for: imgView)
        }
        else if(index == 4){
            imageNames2.removeAll()
            imageNames2 = ["f0", "f1", "f2", "f3", "f4","f5","f6","f7","f8","f9","f10","f11","f12","f13","f14","f15","f16","f17","f18","f19","f20","f21","f22","f23","f24","f25","f26","f27","f28","f29"]
            imgView.image = UIImage(named: imageNames2[0])
            startImageAnimation2(for: imgView)
        }
        else if(index == 5) {
//            imgView.image = UIImage(named: "intro\(index)")
            imageNames3.removeAll()
            imageNames3 = ["i2_0", "i2_1","i2_1_1", "i2_2", "i2_3","i2_4","i2_5","i2_6"]
            imgView.image = UIImage(named: imageNames3[0])
            startImageAnimation3(for: imgView)

        }
//        prevBt.alpha = 0

        if isLastPage {
            let nextButton = createPlanButton(title: "start_beautycamera".localized)//UIButton(type: .system)
//            nextButton.setTitle("Start to Beauty Camera", for: .normal)
//            nextButton.setTitleColor(.white, for: .normal)
//            nextButton.backgroundColor = UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
//            nextButton.layer.cornerRadius = 25
//            nextButton.layer.masksToBounds = true
//            nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            
            // Adding shadow effect
//            nextButton.layer.shadowColor = UIColor.black.cgColor
//            nextButton.layer.shadowOpacity = 0.3
//            nextButton.layer.shadowOffset = CGSize(width: 0, height: 4)
//            nextButton.layer.shadowRadius = 10

            nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
            contentVC.view.addSubview(nextButton)

            nextButton.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(desc.snp.bottom).offset(10)
//                make.width.equalTo(300)
                make.leading.trailing.equalToSuperview().inset(16)
        
                make.height.equalTo(60)
            }
        }

        return contentVC
    }

    func processTopButton(_ index:Int){
        if(index == pages.count - 1){
            nextBt.alpha = 0
            prevBt.alpha = 1

        }
        else if index == 0{
            nextBt.alpha = 1
            prevBt.alpha = 0

        }
        else if index > 0{
            nextBt.alpha = 1
            prevBt.alpha = 1


        }
//        else{
//            nextBt.isHidden = false
//            prevBt.isHidden = false
//
//
//        }
    }
    
    @objc func nextPage(){
        if curIndex < pageViewControllers.count - 1{
            curIndex += 1
            processTopButton(curIndex)
            pageControl.currentPage = curIndex
            let nextVC = pageViewControllers[curIndex]
            setViewControllers([nextVC], direction: .forward, animated: true, completion: nil)
            
            UIView.animate(withDuration: 0.5) {
                self.titleLabel.alpha = 0
            
            } completion: { _ in
                self.titleLabel.alpha = 1
            
            }
        }
       
    }
    @objc func prevPage(){
        if curIndex > 0 {
            curIndex -= 1
            pageControl.currentPage = curIndex
    
            processTopButton(curIndex)
            
//            if(curIndex == pages.count - 1){
//                nextBt.isHidden = true
//                prevBt.isHidden = false
//
//            }
//            else if curIndex == 0{
//                nextBt.isHidden = false
//                prevBt.isHidden = true
//
//            }
//            else if curIndex > 0{
//                nextBt.isHidden = false
//                prevBt.isHidden = false
//
//            }
//            else{
//                nextBt.isHidden = false
//                prevBt.isHidden = false
//
//
//            }
            let nextVC = pageViewControllers[curIndex]
            setViewControllers([nextVC], direction: .reverse, animated: true, completion: nil)
            UIView.animate(withDuration: 0.5) {
                self.titleLabel.alpha = 0
            
            } completion: { _ in
                self.titleLabel.alpha = 1
            
            }
        }
       
    }
    func startImageAnimation(for imageView: UIImageView) {
        var currentImageIndex = 0

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            currentImageIndex = (currentImageIndex + 1) % self.imageNames.count
//            imageView.image = UIImage(named: self.imageNames[currentImageIndex])
            UIView.transition(with: imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                imageView.image = UIImage(named: self.imageNames[currentImageIndex])
            }, completion: nil)
          
        }
       
    }
    func startImageAnimation2(for imageView: UIImageView) {
        var currentImageIndex = 0

        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: true) { timer in
            currentImageIndex = (currentImageIndex + 1) % self.imageNames2.count
//            imageView.image = UIImage(named: self.imageNames2[currentImageIndex])
            UIView.transition(with: imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                imageView.image = UIImage(named: self.imageNames2[currentImageIndex])
            }, completion: nil)
          
        }
    }
    func startImageAnimation3(for imageView: UIImageView) {
        var currentImageIndex = 0

        animationTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            currentImageIndex = (currentImageIndex + 1) % self.imageNames3.count
//            imageView.image = UIImage(named: self.imageNames3[currentImageIndex])
            UIView.transition(with: imageView, duration: 1, options: .transitionCrossDissolve, animations: {
                imageView.image = UIImage(named: self.imageNames3[currentImageIndex])
            }, completion: nil)
          
        }
    }

    @objc func nextTapped() {
        animationTimer?.invalidate()
        let subscribeVC = SubscribeViewController()
        subscribeVC.modalPresentationStyle = .fullScreen
        subscribeVC.modalTransitionStyle = .crossDissolve
        subscribeVC.onSubscribeViewClosed = { [weak self] in
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            self?.navigateToHome()
        }
        self.present(subscribeVC, animated: true, completion: nil)
    }

    func navigateToHome() {
        let homeVC = HomeViewController()
        let navigationController = UINavigationController(rootViewController: homeVC)
        navigationController.modalPresentationStyle = .fullScreen

        if let window = UIApplication.shared.windows.first {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }

    // UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pageViewControllers.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return pageViewControllers[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = pageViewControllers.firstIndex(of: viewController), currentIndex < pageViewControllers.count - 1 else {
            return nil
        }
        return pageViewControllers[currentIndex + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = viewControllers?.first, let currentIndex = pageViewControllers.firstIndex(of: currentVC) {
            pageControl.currentPage = currentIndex
            processTopButton(currentIndex)

 
//            if(currentIndex == pages.count - 1){
//                nextBt.isHidden = true
//                prevBt.isHidden = false
//
//            }
//            else if currentIndex == 0{
//                nextBt.isHidden = false
//                prevBt.isHidden = true
//
//            }
//            else if currentIndex > 0{
//                nextBt.isHidden = false
//                prevBt.isHidden = false
//
//            }
//            else{
//                nextBt.isHidden = false
//                prevBt.isHidden = false
//
//
//            }
        }
    }
}

extension UIPageViewController {
    var isPagingEnabled: Bool {
        get {
            scrollView?.isScrollEnabled ?? false
        }
        set {
            scrollView?.isScrollEnabled = newValue
        }
    }

    var scrollView: UIScrollView? {
        view.subviews.first { $0 is UIScrollView } as? UIScrollView
    }
}
