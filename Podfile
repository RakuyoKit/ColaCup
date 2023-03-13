# source 'https://cdn.cocoapods.org/'

platform :ios, '10.0'

use_frameworks!

use_modular_headers!
inhibit_all_warnings!

install! 'cocoapods',
         :preserve_pod_file_structure => true,
         :generate_multiple_pod_projects => true
#         :incremental_installation => true

target 'ColaCup' do
  
  pod 'RaLog'
  pod 'JSONPreview'
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      
      config.build_settings["CODE_SIGN_IDENTITY"] = ''
      
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '10.0'
      
    end
  end
end
