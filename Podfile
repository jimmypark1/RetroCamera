# Uncomment the next line to define a global platform for your project
#platform :ios, '12.0'

target 'RetroCamera' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  pod 'GPUImage'
  pod 'Hero'
  pod 'Alamofire'

  pod "TTGSnackbar"
  pod "AFNetworking"
  pod 'Kingfisher'

  pod 'Google-Mobile-Ads-SDK'
  pod 'SSZipArchive'
  pod 'Hue'
  pod 'SwiftyStoreKit'
 
  pod 'FirebaseAnalytics', '~> 9.6.0'
  pod 'FirebaseCrashlytics', '~> 9.6.0'
  
  pod 'FirebaseCore', '~> 9.6.0'
  pod 'SnapKit'
  pod 'SiriusRating'
  pod 'Siren'

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['APPLICATION_EXTENSION_API_ONLY'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0' # 원하는 최소 버전
    end
  end
end
