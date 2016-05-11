plugin 'cocoapods-no-dev-schemes'

source 'https://github.com/CocoaPods/Specs.git'
#source 'http://madeatsampa.com/sppodspec.git'

platform :ios, '7.0'
inhibit_all_warnings!

target 'Footbl' do
    # madeatsampa
    pod 'SPHipster', :path => 'Footbl/Pods/SPHipster' #'0.5.3'
    pod 'SPNotifier', :path => 'Footbl/Pods/SPNotifier' #'0.2.2'
    
    # Analytics
    pod 'Fabric', '1.6.7'
    pod 'Crashlytics', '3.7.0'
    pod 'GoogleAnalytics', '3.14.0'
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
    pod 'SVPullToRefresh', '0.4.1'
end

target 'FootblTests' do
    pod 'KIF', '3.0.8'
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name == 'Tweaks' && config.name.include?('Development')
                config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'FB_TWEAK_ENABLED=1']
            end
        end
    end
end
