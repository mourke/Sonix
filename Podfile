use_frameworks!

source 'https://github.com/CocoaPods/Specs'

def pods
    pod 'XCDYouTubeKit', '~> 2.5.6'
    pod 'Kingfisher', '~> 4.10.0'
    pod 'Reachability', :git => 'https://github.com/tonymillion/Reachability'
    pod 'MarqueeLabel/Swift', '~> 3.2.0'
    pod 'PutKit', '~> 1.0.1'
    pod 'PopcornKit', '~> 1.0.1'
end

target 'Sonix tvOS' do
    platform :tvos, '12.0'
    pods
end

target 'Sonix iOS' do
    platform :ios, '12.0'
    pods
    pod 'google-cast-sdk', '~> 4.3.2'
    pod 'OBSlider', '~> 1.1.1'
end
