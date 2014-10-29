source 'https://github.com/CocoaPods/Specs.git'
source 'git@git.madeatsampa.com:madeatsampa/sppodspec.git'

platform :ios, '7.0'

# madeatsampa
pod 'SPHipster', '0.5.3'
pod 'SPNotifier', '0.2.2'

# Analytics
pod 'GoogleAnalytics-iOS-SDK', '3.0.9'
pod 'FlurrySDK', '5.4.0'

# Networking
pod 'AFNetworking', '2.4.1'
pod 'AFNetworkActivityLogger', '2.0.3'
pod 'SDWebImage', '3.7.1'
pod 'TransformerKit', '0.5.3'

# Security
pod 'FXKeychain', '1.5.1'

# Utilities
pod 'APAddressBook', '0.1.2'
pod 'CargoBay', '2.1.0'
pod 'Cloudinary', '1.0.12'
pod 'iRate', '1.10.3'
pod 'MBProgressHUD', '0.9'
pod 'RMStore', '0.5.2'
pod 'StyledPageControl', '1.0'
pod 'SVPullToRefresh', '0.4.1'
pod 'Tweaks', '1.1.0'
pod 'UIAlertView-Blocks', '1.0'

target 'FootblTests', :exclusive => true do
    pod 'KIF', '~> 3.0'
end

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        if target.name == "Pods-Tweaks"
            target.build_configurations.each do |config|
                if config.name == 'QA'
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'FB_TWEAK_ENABLED=1']
                end
            end
        end
    end
end