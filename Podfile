platform :ios, '7.0'

# madeatsampa
pod 'SPHipster'
pod 'SPNotifier'

# Analytics
pod 'GoogleAnalytics-iOS-SDK', '3.0.3'

# Networking
pod 'AFNetworking', '~> 2.0'
pod 'AFNetworkActivityLogger'
pod 'SDWebImage'
pod 'TransformerKit'

# Security
pod 'FXKeychain'

# Utilities
pod 'APAddressBook'
pod 'CargoBay'
pod 'Cloudinary'
pod 'MBProgressHUD'
pod 'RMStore'
pod 'StyledPageControl'
pod 'SVPullToRefresh'
pod 'Tweaks'
pod 'UIAlertView-Blocks'

target 'FootblTests', :exclusive => true do
    pod 'KIF', '~> 3.0'
end

post_install do |installer_representation|
    installer_representation.project.targets.each do |target|
        if target.name == "Pods-Tweaks"
            target.build_configurations.each do |config|
                if config.name == 'Release'
                    config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'FB_TWEAK_ENABLED=1']
                end
            end
        end
    end
end