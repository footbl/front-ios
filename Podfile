source 'https://github.com/CocoaPods/Specs.git'
#source 'http://madeatsampa.com/sppodspec.git'

platform :ios, '7.0'
inhibit_all_warnings!

# madeatsampa
pod 'SPHipster', :path => 'Footbl/Pods/SPHipster' #'0.5.3'
pod 'SPNotifier', :path => 'Footbl/Pods/SPNotifier' #'0.2.2'

# Analytics
#pod 'CrashlyticsFramework', '2.2.5'
pod 'GoogleAnalytics-iOS-SDK', '3.0.9'
pod 'Flurry-iOS-SDK', '7.5.2'

# Networking
pod 'AFNetworking', '2.4.1'
pod 'AFNetworkActivityLogger', '2.0.3'
pod 'SDWebImage', '3.7.1'
pod 'TransformerKit', '0.5.3'
pod 'Mantle', '~> 2.0.3'

# Security
pod 'FXKeychain', '1.5.2'

# Utilities
pod 'APAddressBook', '0.1.4'
pod 'CargoBay', '2.1.0'
pod 'Cloudinary', '1.0.12'
#pod 'Facebook-iOS-SDK', '3.19.0'
pod 'FBSDKCoreKit', '4.10.1'
pod 'FBSDKShareKit', '4.10.1'
pod 'FBSDKLoginKit', '4.10.1'
pod 'iRate', '1.11.3'
pod 'MBProgressHUD', '0.9'
pod 'RMStore', '0.6.0'
pod 'StyledPageControl', '1.0'
pod 'SVPullToRefresh', '0.4.1'
pod 'Tweaks', '1.1.0'
pod 'UIAlertView-Blocks', '1.0'

target 'FootblTests', :exclusive => true do
    pod 'KIF', '3.0.8'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == "Pods-Tweaks"
            target.build_configurations.each do |config|
                if config.name == 'QA'
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'FB_TWEAK_ENABLED=1']
                end
            end
        end
    end
end
