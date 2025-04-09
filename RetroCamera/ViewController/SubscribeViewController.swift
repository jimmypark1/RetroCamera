import UIKit
import SnapKit
//import DLRadioButton
import SwiftyStoreKit
import SafariServices
import TTGSnackbar
import FirebaseAnalytics

enum SubscriptionPlan: Int, CaseIterable {
    case basic = 0
    case pro = 1
//    case lifetime = 2
    
    var displayName: String {
        switch self {
        case .basic:
            return "월간 구독 - $4.99"
        case .pro:
            return "연간 구독 - $29.99 (추천)"
//        case .lifetime:
//            return "평생 이용권 - $79.99"
        }
    }
}
class SubscribeViewController: UIViewController {
    
    var onSubscribeViewClosed: (() -> Void)? // 구독 화면 닫힘을 처리하기 위한 클로저
    
    var ivSlideshow: UIImageView!
    var descriptionLabel: UILabel!
    var descriptionLabel0:UILabel!
    var descriptionLabel2:UILabel!
    
    var radioButtonContainerView: UIView!
//    var yearRadioButton: DLRadioButton!
//    var monthRadioButton: DLRadioButton!
//    var weekRadioButton: DLRadioButton!
    var subscribeBt: UIButton!
    var privacyPolicyButton: UIButton!
    var termsOfServiceButton: UIButton!
    var restorePurchaseButton: UIButton!
    var imagesArraySlideshow: [UIImage] = []
    var slideShowIndex: NSInteger = 0
    var slideShowMax: NSInteger = 0
    var end: Bool!
    var animationTimer: Timer?    // 타이머를 사용하여 이미지 애니메이션 처리
    var imageNames: [String] = [] // 애니메이션 이미지 이름 배열
    var descs: [String] = [] // 애니메이션 이미지 이름 배열
    var headerImageView:UIImageView!
    var closeButton:UIButton!
    var yearlyPlanButton:UIButton!
    var benefitStack:UIStackView!
    var titleLabel:UILabel!
    private let gradientLayer = CAGradientLayer()
    let gradientLayer2 = CAGradientLayer()
    
    var yearSubTitle = ""
    
    private var selectedPlan: SubscriptionPlan = .pro
    private let planStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        return stackView
    }()
    lazy var activityIndicator: UIActivityIndicatorView = {
                // Create an indicator.
                let activityIndicator = UIActivityIndicatorView()
                activityIndicator.frame = self.view.frame//CGRect(x: 0, y: 0, width: 50, height: 50)
           activityIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
                activityIndicator.center = self.view.center
           activityIndicator.color = .white//UIColor(red: 255, green: 199, blue: 44, alpha: 1)
                    // Also show the indicator even when the animation is stopped.
                activityIndicator.hidesWhenStopped = true
                activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
                // Start animation.
                activityIndicator.stopAnimating()
                return activityIndicator
        
         }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.view.backgroundColor = UIColor(red: 173/255, green: 216/255, blue: 230/255, alpha: 1.0)//.white
        //        self.view.backgroundColor = .black
        //        self.title = "Beauty Camera VIP"
        
        self.view.addSubview(self.activityIndicator)
        setupCloseButton()
        
        setupUI()
        buildImagesArraySlideshow()
       
        retrieveProductInfo()
        setupLegalLinks()
        showSlide()
        setupGradientBackground()
       
        self.navigationController?.isNavigationBarHidden = false
        
    }
    func setupGradientBackground() {
        
        //        make.top.equalTo(self.closeButton.snp.bottom).offset(10)
        //        make.centerX.trailing.equalToSuperview().inset(16)
        //        make.height.equalTo(UIScreen.main.bounds.size.width - 32)
        
        setupBenefitLabel()
        gradientLayer.frame = CGRectMake(0, UIScreen.main.bounds.size.width - 100, UIScreen.main.bounds.size.width, 120)//headerImageView.bounds
        
        let step = 5
        var colors = [CGColor]()
     
//        colors.append(UIColor.white.withAlphaComponent(CGFloat(0.05)).cgColor)
 
//        for i in 1...step{
//            let alpha =  CGFloat(i) / CGFloat(step)
////            colors.append(UIColor.black.withAlphaComponent(CGFloat(alpha)).cgColor)
//        }
//        colors.append(UIColor.white.cgColor)
        
        colors.append(UIColor.clear.cgColor)
        colors.append(UIColor.black.cgColor)
     
        gradientLayer.colors = colors
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 하단
//        gradientLayer.locations = [0.7, 0.3]
        //        view.layer.insertSublayer(gradientLayer, at: 0)
        //        view.layer.insertSublayer(gradientLayer, at: 3)
        view.layer.insertSublayer(gradientLayer, at: 4)
  
    }
    
    func setupBenefitLabel(){
        
        let benetfitView = UIView()
        benetfitView.frame = CGRectMake(0, UIScreen.main.bounds.size.width - 100, UIScreen.main.bounds.size.width, 100)
        benetfitView.backgroundColor = .clear
        
        titleLabel = UILabel()
        titleLabel.text = "subscribe_desc0".localized
        titleLabel.font = UIFont(name: "Helvetica", size: 24)//UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = Constants.titleColor
        titleLabel.numberOfLines = 0
        benetfitView.addSubview(titleLabel)
        
        let logoT = UIView()
        logoT.backgroundColor = Constants.brandColor
        logoT.layer.cornerRadius = 10
        
        benetfitView.addSubview(logoT)
        
        let logo = UILabel()
        
        logo.backgroundColor = Constants.brandColor
        logo.textColor = Constants.titleColor
        logo.font = UIFont(name: "Helvetica", size: 12)
        logo.text = "PREMIUM"
        logo.textAlignment = .center
        logoT.addSubview(logo)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(30)
            make.top.equalToSuperview().offset(30)
            
        }
        
        logoT.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.top.equalToSuperview()
            make.width.equalTo(80)
            make.height.equalTo(20)
            
        }
        logo.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(10)
            make.top.equalToSuperview()
            make.height.equalTo(20)
            
        }
        self.view.addSubview(benetfitView)
    }
    // 닫기 버튼을 이미지로 설정
    func setupCloseButton() {
        closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(systemName:"xmark.circle")?.withRenderingMode(.alwaysTemplate), for: .normal) // "xmark.circle" 아이콘 사용
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        // 버튼 이미지 크기 조정
        //        closeButton.imageEdgeInsets = UIEdgeInsets(top: -10, left: -10, bottom: -10, right: -10)
        
        self.view.addSubview(closeButton)
        closeButton.layer.zPosition = 100
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(0)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(50) // 버튼 크기를 50x50으로 설정
        }
    }
    
    
    @objc func closeTapped() {
        onSubscribeViewClosed?() // 구독화면이 닫히면 콜백 호출
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.end = false
        //        ivSlideshow.image = UIImage(named: "n0")
//        setupCloseButton()
//        
//        setupUI()
//        buildImagesArraySlideshow()
//       
//        retrieveProductInfo()
//        setupLegalLinks()
//        showSlide()
//        setupGradientBackground()
//       
//        self.navigationController?.isNavigationBarHidden = false
        
       
    }
    
    //    func setupUI() {
    //        // 슬라이드쇼 이미지 뷰 설정
    //        ivSlideshow = UIImageView()
    //        ivSlideshow.contentMode = .scaleAspectFill
    //        ivSlideshow.clipsToBounds = true
    //        ivSlideshow.layer.cornerRadius = 16
    //        ivSlideshow.layer.masksToBounds = true
    //        self.view.addSubview(ivSlideshow)
    //
    //        ivSlideshow.snp.makeConstraints { make in
    //            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
    //            make.leading.equalToSuperview().offset(20)
    //            make.trailing.equalToSuperview().offset(-20)
    //            make.height.equalTo(ivSlideshow.snp.width)
    //        }
    //
    //        descriptionLabel0 = UILabel()
    //        descriptionLabel0.text = "You get unlimited:"
    //        descriptionLabel0.numberOfLines = 0
    //        descriptionLabel0.textColor = .label//.white
    //        descriptionLabel0.font = UIFont(name: "Helvetica-Bold", size: 17)
    //        self.view.addSubview(descriptionLabel0)
    //        descriptionLabel0.snp.makeConstraints { make in
    //            make.top.equalTo(ivSlideshow.snp.bottom).offset(30)
    //            make.leading.equalTo(ivSlideshow.snp.leading)
    //            make.trailing.equalTo(ivSlideshow.snp.trailing)
    //        }
    //        // 구독에 관한 설명 레이블
    //        descriptionLabel = UILabel()
    ////        descriptionLabel.text = "Subscribe now to get premium filters, remove ads, and unlock additional features."
    //        descriptionLabel.text = "- Premium filters without watermark\n  (AI filter, Beauty Effect, Background Removal)\n\n- Remove ads\n"
    //        descriptionLabel.numberOfLines = 0
    //        descriptionLabel.textColor = .secondaryLabel//.white
    ////        descriptionLabel.textAlignment = .center
    //        descriptionLabel.font = UIFont(name: "Helvetica", size: 15)//UIFont.systemFont(ofSize: 14)
    //        self.view.addSubview(descriptionLabel)
    //
    //        descriptionLabel.snp.makeConstraints { make in
    //            make.top.equalTo(descriptionLabel0.snp.bottom).offset(15)
    //            make.leading.equalTo(ivSlideshow.snp.leading)
    //            make.trailing.equalTo(ivSlideshow.snp.trailing)
    //        }
    //
    //        // 라디오 버튼 그룹을 감싸는 컨테이너 뷰 설정
    ////        radioButtonContainerView = UIView()
    ////        radioButtonContainerView.layer.cornerRadius = 16
    ////        radioButtonContainerView.layer.borderWidth = 1
    ////        radioButtonContainerView.layer.borderColor = UIColor.white.cgColor//UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0).cgColor//UIColor.lightGray.cgColor
    ////        self.view.addSubview(radioButtonContainerView)
    ////
    ////        radioButtonContainerView.snp.makeConstraints { make in
    ////            make.top.equalTo(descriptionLabel.snp.bottom).offset(15)
    ////            make.leading.equalTo(ivSlideshow.snp.leading)
    ////            make.trailing.equalTo(ivSlideshow.snp.trailing)
    ////        }
    //
    //        // 라디오 버튼 설정
    ////        setupRadioButtons()
    //
    //        // 플로팅 구독 버튼 설정
    //        setupFloatingSubscribeButton()
    //    }
    private let iconImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "crown.fill"))
        imageView.tintColor = .systemYellow
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private func setupUI() {
        view.backgroundColor =  Constants.mainColor  //UIColor.white// UIColor.systemGray6
        
        if(headerImageView != nil){
            headerImageView.removeFromSuperview()
        }
        // Animated Header Image
        headerImageView = UIImageView()
        headerImageView.image = UIImage(named: "n0") // Replace with your image asset
        headerImageView.contentMode = .scaleAspectFill
        headerImageView.clipsToBounds = true
        headerImageView.layer.cornerRadius = 10
        view.addSubview(headerImageView)
        
        // Animate header image
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.headerImageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: nil)
        
        // Title Label
        //        if titleLabel != nil{
        //            titleLabel.removeFromSuperview()
        //        }
        //        titleLabel = UILabel()
        //        titleLabel.text = "subscribe_title".localized
        //        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        //        titleLabel.textAlignment = .center
        //        titleLabel.numberOfLines = 0
        //        titleLabel.textColor = Constants.titleColor
        //        view.addSubview(titleLabel)
        view.addSubview(iconImageView)
        
        
        //        "🚀 무제한 필터 사용 가능",
        //        "📸 광고 없이 깔끔한 환경",
        //        "🎨 고급 편집 기능 지원",
        //        "🌟 신규 기능 우선 사용"
        // Benefit Labels
        let benefitLabel1 = createBenefitLabel(text: "🚀  " + "subscribe_desc0".localized)
        let benefitLabel2 = createBenefitLabel(text: "📸  " + "subscribe_desc1".localized)
        let benefitLabel3 = createBenefitLabel(text: "🎨  " + "subscribe_desc2".localized)
        
//        if( benefitStack != nil){
//            benefitStack.removeFromSuperview()
//        }
//        benefitStack = UIStackView(arrangedSubviews: [benefitLabel1, benefitLabel2, benefitLabel3])
//        benefitStack.axis = .vertical
//        benefitStack.spacing = 12
//        view.addSubview(benefitStack)
        
        if yearlyPlanButton != nil{
            yearlyPlanButton.removeFromSuperview()
        }
        // Yearly Subscription Button
        yearlyPlanButton = createPlanButton(title: "Subscribe")
        yearlyPlanButton.addTarget(self, action: #selector(subscribeTapped), for: .touchUpInside)
        yearlyPlanButton.backgroundColor = UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
        view.addSubview(yearlyPlanButton)
        
        // Restore Purchases Button
        //        let restoreButton = UIButton(type: .system)
        //        restoreButton.setTitle("Restore Purchases", for: .normal)
        //        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        //        restoreButton.addTarget(self, action: #selector(restorePurchases), for: .touchUpInside)
        //        view.addSubview(restoreButton)
        
        // Layout using SnapKit
        headerImageView.snp.makeConstraints { make in
            //            make.top.equalTo(self.closeButton.snp.bottom).offset(10)
            make.top.equalToSuperview()
            make.centerX.trailing.equalToSuperview()//.inset(16)
            make.height.equalTo(3.0*UIScreen.main.bounds.size.width/3.0)
        }
        
        //        titleLabel.snp.makeConstraints { make in
        //            make.top.equalTo(self.closeButton.snp.top).offset(12)
        //            make.centerX.equalTo(view.snp.centerX)
        ////            make.leading.trailing.equalToSuperview().inset(16)
        //        }
        //        iconImageView.snp.makeConstraints { make in
        //            make.top.equalTo(self.closeButton.snp.top).offset(12)
        //            make.trailing.equalTo(titleLabel.snp.leading).offset(-10)
        //        }
//        benefitStack.snp.makeConstraints { make in
//            make.top.equalTo(headerImageView.snp.bottom).offset(40)
//            make.leading.trailing.equalToSuperview().inset(16)
//        }
        for plan in SubscriptionPlan.allCases {
            let button = createPlanButton(for: plan)
            button.snp.makeConstraints { make in
                make.width.equalTo(400)
//                make.leading.trailing.equalToSuperview()
       
                make.height.equalTo(70)

            }
            planStackView.addArrangedSubview(button)
        }
        self.view.addSubview(planStackView)
        planStackView.snp.makeConstraints { make in
            make.top.equalTo(headerImageView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        setupFloatingSubscribeButton()
        //        yearlyPlanButton.snp.makeConstraints { make in
        //            make.top.equalTo(benefitStack.snp.bottom).offset(30)
        //            make.leading.trailing.equalToSuperview().inset(16)
        //            make.height.equalTo(60)
        //        }
        
        //        restoreButton.snp.makeConstraints { make in
        //            make.top.equalTo(yearlyPlanButton.snp.bottom).offset(16)
        //            make.centerX.equalToSuperview()
        //        }
    }
    private func createBenefitLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = UIFont(name: "Helvetica", size: 13)//UIFont.systemFont(ofSize: 14)
        label.textColor = Constants.labelColor
        label.numberOfLines = 0
        return label
    }
    
    private func createPlanButton(title: String) -> UIButton {
        let button = GradientButton()//UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 255/255, green: 182/255, blue: 193/255, alpha: 1.0)
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.lightGray.cgColor//UIColor.black.cgColor
        button.layer.shadowOpacity = 0.2
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }
    
    @objc private func yearlyPlanSelected() {
        print("Yearly Plan Selected")
        // Implement subscription purchase logic here
    }
    
    @objc private func restorePurchases() {
        print("Restore Purchases")
        // Implement restore purchases logic here
    }
    
    //    // 라디오 버튼 설정
    //    func setupRadioButtons() {
    //        yearRadioButton = createRadioButton(title: "Yearly Plan", isSelected: true)
    //        radioButtonContainerView.addSubview(yearRadioButton)
    //        yearRadioButton.snp.makeConstraints { make in
    //            make.top.equalTo(radioButtonContainerView.snp.top).offset(15)
    //            make.leading.equalToSuperview().offset(15)
    //            make.trailing.equalToSuperview().offset(-15)
    //            make.height.equalTo(40)
    //        }
    //
    //        monthRadioButton = createRadioButton(title: "Monthly Plan", isSelected: false)
    //        radioButtonContainerView.addSubview(monthRadioButton)
    //        monthRadioButton.snp.makeConstraints { make in
    //            make.top.equalTo(yearRadioButton.snp.bottom).offset(10)
    //            make.leading.equalToSuperview().offset(15)
    //            make.trailing.equalToSuperview().offset(-15)
    //            make.height.equalTo(40)
    //        }
    //
    //        weekRadioButton = createRadioButton(title: "Weekly Plan", isSelected: false)
    //        radioButtonContainerView.addSubview(weekRadioButton)
    //        weekRadioButton.snp.makeConstraints { make in
    //            make.top.equalTo(monthRadioButton.snp.bottom).offset(10)
    //            make.leading.equalToSuperview().offset(15)
    //            make.trailing.equalToSuperview().offset(-15)
    //            make.height.equalTo(40)
    //            make.bottom.equalToSuperview().offset(-15)
    //        }
    //
    //        yearRadioButton.otherButtons = [monthRadioButton, weekRadioButton]
    //    }
    
    //    func createRadioButton(title: String, isSelected: Bool) -> DLRadioButton {
    //        let radioButton = DLRadioButton()
    //        radioButton.setTitle(title, for: .normal)
    //        radioButton.setTitleColor(.white, for: .normal)
    //        radioButton.isIconSquare = false
    //        radioButton.isSelected = isSelected
    //        radioButton.titleLabel?.font = UIFont(name: "Helvetica", size: 13)//UIFont.systemFont(ofSize: 14)
    //        radioButton.contentHorizontalAlignment = .left
    //        return radioButton
    //    }
    
    func setupFloatingSubscribeButton() {
        
        if subscribeBt != nil{
            subscribeBt.removeFromSuperview()
        }
        subscribeBt = createPlanButton(title: "subscribe_button".localized)
        subscribeBt.addTarget(self, action: #selector(subscribeTapped), for: .touchUpInside)
        subscribeBt.layer.cornerRadius = 30
        self.view.addSubview(subscribeBt)
        
        subscribeBt.snp.makeConstraints { make in
            //            make.centerX.equalToSuperview()
//            make.bottom.equalToSuperview().offset(-120)
           
            make.top.equalTo(planStackView.snp.bottom).offset(30)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(60)
        }
        subscribeBt.layoutIfNeeded()
        if descriptionLabel2 != nil{
            descriptionLabel2.removeFromSuperview()
        }
        descriptionLabel2 = UILabel()
        
        descriptionLabel2.numberOfLines = 0
        descriptionLabel2.textColor = Constants.labelColor//.white
        //        descriptionLabel.textAlignment = .center
        descriptionLabel2.font = UIFont(name: "Helvetica", size: 12)//UIFont.systemFont(ofSize: 14)
        descriptionLabel2.textAlignment = .center
        self.view.addSubview(descriptionLabel2)
        
        descriptionLabel2.snp.makeConstraints { make in
            make.top.equalTo(subscribeBt.snp.bottom).offset(15)
            make.leading.trailing.equalToSuperview().inset(16)
        }
//        setupGradientLayer()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        gradientLayer2.frame = subscribeBt.frame
//        gradientLayer.frame = CGRectMake(0, 0, UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.width * 1.2)//headerImageView.bounds
//        gradientLayer.frame = CGRectMake(0, 0, UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.width * 1.2)//headerImageView.bounds
      
    }
    private func setupGradientLayer() {
        gradientLayer2.colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        gradientLayer2.startPoint = CGPoint(x: 0.0, y: 0.5) // 좌측에서 시작
        gradientLayer2.endPoint = CGPoint(x: 1.0, y: 0.5)   // 우측으로 끝
        subscribeBt.layer.cornerRadius = 30
        gradientLayer2.frame = subscribeBt.frame
//        subscribeBt.layer.insertSublayer(gradientLayer2, at: 100)
        view.layer.insertSublayer(gradientLayer2, at: 100)
        
        animateGradient()
    }
    
    private func animateGradient() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        animation.toValue = [UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer2.add(animation, forKey: "gradientAnimation")
    }
    func buildImagesArraySlideshow() {
        
//        imageNames = ["n0","n1","n2","hq","n4","n5","n6", "n7", "n8", "n9", "n10",
//                      "n11","n12","n13","n14","n15","n16","n17","n18","n19","n20",
//                      "n21","n22","n23","n24","n25","n26","n27","n28","n29","n30",
//                      "n31","n32","n33","n34","n35","n36"
//        ]
        imageNames = ["n0","seg0","seg1","remove0","remove1","outfocus0",
                      "n31","n6"
        ]
        descs = [ "subscribe_desc0".localized,"subscribe_desc1".localized,"subscribe_desc6".localized,
                  "subscribe_desc1".localized,"subscribe_desc6".localized,"subscribe_desc6".localized,
                  "subscribe_desc6".localized,"subscribe_desc6".localized,"subscribe_desc6".localized,
                  "subscribe_desc6".localized,"subscribe_desc6".localized,"subscribe_desc6".localized,
                  "subscribe_desc5".localized,"subscribe_desc9".localized,"subscribe_desc9".localized,
                  "subscribe_desc9".localized,"subscribe_desc9".localized,"subscribe_desc9".localized,
                  "subscribe_desc9".localized,"subscribe_desc9".localized,"subscribe_desc1".localized,
                  "subscribe_desc2".localized,"subscribe_desc4".localized,"subscribe_desc5".localized,
                  "subscribe_desc0".localized,"subscribe_desc1".localized,"subscribe_desc2".localized,
                  "subscribe_desc3".localized,"subscribe_desc4".localized,"subscribe_desc5".localized,
                  "subscribe_desc0".localized,"subscribe_desc1".localized,"subscribe_desc2".localized,
                  "subscribe_desc3".localized,"subscribe_desc4".localized,"subscribe_desc5".localized,
                  "subscribe_desc0".localized,"subscribe_desc1".localized,"subscribe_desc2".localized,
                         
        ]
        
    }
    func createPlanButton(for plan: SubscriptionPlan) -> UIButton {
        let button = UIButton(type: .system)
//        button.setTitle(plan.displayName, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.borderColor = UIColor.systemMint.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 12
        button.setTitleColor(selectedPlan == plan ? Constants.titleColor : Constants.subLabelColor
                             , for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = selectedPlan == plan ? Constants.brandColor2.cgColor : Constants.subLabelColor.cgColor
       
//        button.backgroundColor = selectedPlan == plan ? UIColor.systemMint : .clear
        button.addTarget(self, action: #selector(planSelected(_:)), for: .touchUpInside)
        button.tag = plan.rawValue
        return button
    }
    @objc private func planSelected(_ sender: UIButton) {
        if let plan = SubscriptionPlan(rawValue: sender.tag) {
            selectedPlan = plan
            print("\(plan.displayName) 선택됨")
            updatePlanSelection()
        }
    }
    
    private func updatePlanSelection() {
        for case let button as UIButton in planStackView.arrangedSubviews {
            if let plan = SubscriptionPlan(rawValue: button.tag) {
                button.layer.borderColor = selectedPlan == plan ? Constants.brandColor2.cgColor : Constants.subLabelColor.cgColor
                button.setTitleColor(selectedPlan == plan ? Constants.titleColor : Constants.subLabelColor
                                     , for: .normal)
                
                if selectedPlan == .basic{
                    subscribeBt.setTitle("Continue".localized, for: .normal)
   
                }
                else{
                    subscribeBt.setTitle("subscribe_button".localized, for: .normal)
             
                }
                subscribeBt.layoutIfNeeded()
               
            }
            
        }
    }
    func showSlide() {
        self.end = false
        
        startImageAnimation(for: headerImageView)
        
    }
    func startImageAnimation(for imageView: UIImageView) {
        var currentImageIndex = 0
        
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.3, repeats: true) { timer in
            currentImageIndex = (currentImageIndex + 1) % self.imageNames.count
            //            imageView.image = UIImage(named: self.imageNames[currentImageIndex])
            UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                imageView.image = UIImage(named: self.imageNames[currentImageIndex])
                self.titleLabel.text = self.descs[currentImageIndex]//"subscribe_desc0".localized
            }, completion: nil)
            
        }
        
    }
    func setupLegalLinks() {
        privacyPolicyButton = UIButton(type: .system)
        privacyPolicyButton.setTitle("Privacy Policy".localized, for: .normal)
        privacyPolicyButton.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        privacyPolicyButton.setTitleColor(Constants.labelColor, for: .normal)
        //        privacyPolicyButton.tintColor = .secondaryLabel
        privacyPolicyButton.addTarget(self, action: #selector(privacyPolicyTapped), for: .touchUpInside)
        self.view.addSubview(privacyPolicyButton)
        termsOfServiceButton = UIButton(type: .system)
        termsOfServiceButton.setTitle("Terms of Service".localized, for: .normal)
        termsOfServiceButton.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        termsOfServiceButton.setTitleColor(Constants.labelColor, for: .normal)
        //        termsOfServiceButton.tintColor = .secondaryLabel
        termsOfServiceButton.addTarget(self, action: #selector(termsOfServiceTapped), for: .touchUpInside)
        self.view.addSubview(termsOfServiceButton)
        
        restorePurchaseButton = UIButton(type: .system)
        restorePurchaseButton.setTitle("Restore Purchase".localized, for: .normal)
        restorePurchaseButton.titleLabel?.font = UIFont(name: "Helvetica", size: 11)
        restorePurchaseButton.setTitleColor(Constants.labelColor, for: .normal)
        //        restorePurchaseButton.tintColor = .secondaryLabel
        restorePurchaseButton.addTarget(self, action: #selector(restorePurchaseTapped), for: .touchUpInside)
        self.view.addSubview(restorePurchaseButton)
       
        let lSeperator = UIView()
        lSeperator.backgroundColor = Constants.labelColor
        self.view.addSubview(lSeperator)
       
        let rSeperator = UIView()
        rSeperator.backgroundColor = Constants.labelColor
        self.view.addSubview(rSeperator)
     
        restorePurchaseButton.snp.makeConstraints { make in
            make.centerX.equalTo(self.view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        privacyPolicyButton.snp.makeConstraints { make in
            make.trailing.equalTo(restorePurchaseButton.snp.leading).offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        lSeperator.snp.makeConstraints { make in
            make.trailing.equalTo(restorePurchaseButton.snp.leading).offset(-10)
            make.width.equalTo(1)
            make.height.equalTo(11)
            make.top.equalTo(restorePurchaseButton.snp.top).offset(7)
        }
        termsOfServiceButton.snp.makeConstraints { make in
            make.leading.equalTo(restorePurchaseButton.snp.trailing).offset(20)
            
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
        rSeperator.snp.makeConstraints { make in
            make.trailing.equalTo(restorePurchaseButton.snp.trailing).offset(10)
            make.width.equalTo(1)
            make.height.equalTo(11)
            make.top.equalTo(restorePurchaseButton.snp.top).offset(7)
        }
    }
    
    func retrieveProductInfo() {
        SwiftyStoreKit.retrieveProductsInfo(["com.junsoft.retrovip",  "com.junsoft.retrovip12"]) { [self] result in
            for product in result.retrievedProducts {
                let identifier = product.productIdentifier
                let priceString = product.localizedPrice ?? ""
                
                if identifier == "com.junsoft.retrovip12" {
                    let yearlyPrice = product.price.doubleValue
                    let monthlyPrice = yearlyPrice / 12
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = product.priceLocale
                    
                    let formattedMonthlyPrice = formatter.string(from: NSNumber(value: monthlyPrice)) ?? ""
                    
                    let msg = "subscribe_button_desc".localized + " \(priceString) " + "/ " + "year".localized + "\n(\(formattedMonthlyPrice) / " + "month".localized + ")"
                    //                    yearRadioButton.setTitle(msg, for: .normal)
                    //                    yearRadioButton.titleLabel?.textColor = .white
                    //                    yearRadioButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)//UIFont.systemFont(ofSize: 14)
                    
                    //                    yearlyPlanButton.setTitle(msg, for: .normal)
                    
                    for case let button as UIButton in planStackView.arrangedSubviews {
                        if let plan = SubscriptionPlan(rawValue: button.tag) {
                            if plan == .pro{
                                let title = "Yearly".localized + "  \(priceString) "  + "/ " + "year".localized
//                                button.setTitle(title, for: .normal)
                                
                                yearSubTitle = "\(formattedMonthlyPrice) / " + "month".localized
                                button.setTitle(title, subtitle: yearSubTitle)

                            }

                        }
                    }
                    
//                    descriptionLabel2.text = msg
                }
                
//                else if identifier == "com.junsoft.beautycameravipw" {
//                    let msg = "Weekly Plan: \(priceString) / week"
//                    //                    weekRadioButton.setTitle(msg, for: .normal)
//                    //                    weekRadioButton.titleLabel?.textColor = .white
//                    //                    weekRadioButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
//                }
//                
                else if identifier == "com.junsoft.retrovip" {
                    let msg = "Monthly Plan: \(priceString) / month"
                    for case let button as UIButton in planStackView.arrangedSubviews {
                        if let plan = SubscriptionPlan(rawValue: button.tag) {
                            if plan == .basic{
                                let title = "Monthly".localized + "  \(priceString) "  + "/ " + "month".localized
                                button.setTitle(title, for: .normal)

                            }

                        }
                    }
                    
                    //                    monthRadioButton.setTitle(msg, for: .normal)
                    //                    monthRadioButton.titleLabel?.textColor = .white
                    //                    monthRadioButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
                }
            }
        }
    }

    
    @objc func privacyPolicyTapped() {
        showSafariViewController(URL(string:"http://www.junsoft.org/privacy_e.html")!)
    }
    
    @objc func termsOfServiceTapped() {
        showSafariViewController(URL(string:"http://www.junsoft.org/terms_e.html")!)
    }
//    func show(msg:String)
//    {
//        let snackbar = TTGSnackbar(message: msg, duration: .long)
//        
//        // Action 1
//        snackbar.messageTextFont = UIFont(name: "Helvetica", size: 12)!
//        snackbar.leftMargin = 16
//        snackbar.rightMargin = 16
//        snackbar.cornerRadius = 6
//        snackbar.animationSpringWithDamping = 1.0
//        
//        snackbar.frame.size.height = 34
//        snackbar.contentInset = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
//        
//        snackbar.backgroundColor = .black//UIColor(red: 68, green: 68, blue: 68, alpha: 1.0)
//        
//        
//        snackbar.dismissBlock = { [self] (snackbar) in
//            
//            
//        }
//        snackbar.show()
//    }
    @objc func restorePurchaseTapped() {
        print("Restore Purchase Tapped")
        activityIndicator.startAnimating()
        
        SwiftyStoreKit.restorePurchases(atomically: true) { [self] results in
            
            //  Spinner.stop()
            
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                //                           self.showAlertView(msg: "Restore Failed",title: "Info")
                
                show(msg:"Restore Failed")
                
                UserDefaults.standard.set(false,forKey: "BUY_VIP")
                UserDefaults.standard.synchronize()
                
                show(msg:"Restore Failed: \(results.restoreFailedPurchases)")
                
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
                
                
                UserDefaults.standard.set(true,forKey: "BUY_VIP")
                UserDefaults.standard.synchronize()
                //     self.showAlertView(msg: "Restore Success",title: "Info")
                //
                //                           isProcessing = false
                
                show(msg:"Restore Success")
                //                           self.complete(buy:1)
                
                
                self.closeTapped()
                
                
            }
            else {
                print("Nothing to Restore")
                
                show(msg:"Nothing to Restore")
                
            }
            //                 isProcessing = false
            activityIndicator.stopAnimating()
            
            
        }
    }
    
    func showSafariViewController(_ url: URL) {
        let svc = SFSafariViewController(url: url)
        self.present(svc, animated: true, completion: nil)
    }
    
    @objc func subscribeTapped() {
        var selectedPos = 2
        
        var product :String = "com.junsoft.retrovip12"
        //        var type = 2
        if selectedPlan == .basic{
            product = "com.junsoft.retrovip"
      
        }
        else{
            product = "com.junsoft.retrovip12"
      
        }
//        "com.junsoft.beautycameravip12"
        Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
            AnalyticsParameterItemID: "id-Subscribe",
            AnalyticsParameterItemName: product,
            AnalyticsParameterContentType: "Subscribe",
        ])
        activityIndicator.startAnimating()
        
        
        SwiftyStoreKit.purchaseProduct(product, atomically: true) {[self] result in
            
            if case .success(let purchase) = result {
                
                Analytics.logEvent(AnalyticsEventSelectContent, parameters: [
                    AnalyticsParameterItemID: "id-Subscribe",
                    AnalyticsParameterItemName: product,
                    AnalyticsParameterContentType: "buy",
                ])
                UserDefaults.standard.set(true,forKey: "BUY_VIP")
                
                UserDefaults.standard.set(true, forKey: "isProUpgradePurchased1")
                
                UserDefaults.standard.set(true, forKey: "isProUpgradePurchased2")
                
                UserDefaults.standard.set(true, forKey: "isProUpgradePurchased4")
                
                
                UserDefaults.standard.synchronize()
                
                //    Spinner.stop()
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: IAPHelper.sharedSecret)
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { [self] result in
                    switch result {
                    case .success(let receipt):
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable, // or .nonRenewing (see below)
                            productId: product,
                            inReceipt: receipt)
                        var buy = 0
                        switch purchaseResult {
                        case .purchased(let expiryDate):
                            
                            buy = 1
                        case .expired(let expiryDate):
                            buy = 0
                        case .notPurchased:
                            
                            buy = 0
                        }
                        
                        //                        self.complete(buy:buy, type:type)
                        activityIndicator.stopAnimating()
                        //                        isProcessing = false
                        
                        //                        self.close()
                        self.closeTapped()
                        
                    case .error(let error):
                        print("Receipt verification failed: \(error)")
                        activityIndicator.stopAnimating()
                        //                        show(msg: "Receipt verification failed")
                        
                    }
                }
                
                
            } else {
                //    Spinner.stop()
                // purchase error
                //                isProcessing = false
                activityIndicator.stopAnimating()
                
                if case .error(let error) = result {
                    
                    var msg =  "\(error)"
                    //                    show(msg: "Receipt verification failed")
                    
                    print("Receipt verification failed: \(error.code)")
                    
                }
                
                
            }
        }
    }
    
    @objc func moreButtonTapped() {
        let moreDetailsVC = MoreDetailsViewController()
        self.navigationController?.pushViewController(moreDetailsVC, animated: true)
    }
    
    @objc func backTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.end = true
    }
}

// 새로운 뷰 컨트롤러
class MoreDetailsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "More Details"
        
        let label = UILabel()
        label.text = "Here is more information about the subscription plans."
        label.numberOfLines = 0
        label.textAlignment = .center
        self.view.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        
    }
}
extension UIButton {
    
    func setTitle(_ title: String, subtitle: String, titleColor: UIColor = .white, subtitleColor: UIColor = .gray) {
        let titleFont = UIFont.boldSystemFont(ofSize: 18)
        let subtitleFont = UIFont.systemFont(ofSize: 14)
        
        let titleString = NSAttributedString(
            string: title + "\n",
            attributes: [
                .font: titleFont,
                .foregroundColor: titleColor
            ])
        
        let subtitleString = NSAttributedString(
            string: subtitle,
            attributes: [
                .font: subtitleFont,
                .foregroundColor: subtitleColor
            ])
        
        let fullString = NSMutableAttributedString()
        fullString.append(titleString)
        fullString.append(subtitleString)
        
        self.setAttributedTitle(fullString, for: .normal)
        self.titleLabel?.numberOfLines = 2
        self.titleLabel?.textAlignment = .center
    }
}

class GradientButton: UIButton {
    
    private let gradientLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    private func setupGradient() {
        self.clipsToBounds = true
        gradientLayer.colors = [ UIColor.systemYellow.cgColor,/*Constants.pink2.cgColor,*/UIColor.systemRed.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5) // 좌측
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)   // 우측
        gradientLayer.cornerRadius = self.layer.cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 0)
        
        animateGradient()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    func animateGradient() {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.fromValue = [UIColor.systemYellow.cgColor, Constants.pink2.cgColor,UIColor.systemRed.cgColor/*,UIColor.systemBlue.cgColor*/]//[UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor]
        animation.toValue = [/*UIColor.systemBlue.cgColor,*/ UIColor.systemRed.cgColor,Constants.pink2.cgColor,UIColor.systemYellow.cgColor]//[Constants.yellow0.cgColor, Constants.pink2.cgColor,UIColor.systemRed.cgColor,UIColor.systemBlue.cgColor]//[UIColor.systemPurple.cgColor, UIColor.systemBlue.cgColor]
        animation.duration = 2.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "gradientAnimation")
    }
}
