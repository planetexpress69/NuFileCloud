source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.1'
#link_with 'Ranglistenpunkte-A', 'Ranglistenpunkte-B'
pod 'MKNetworkKit'
pod 'FontAwesome+iOS'
pod 'MBProgressHUD'

post_install do | installer |
    require 'fileutils'
    FileUtils.cp_r('Pods/Target Support Files/Pods/Pods-acknowledgements.markdown', './Acknowledgements.markdown', :remove_destination => true);
end
