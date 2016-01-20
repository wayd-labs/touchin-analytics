# most of this podfile and architecture of lib was taken from https://github.com/orta/ARAnalytics
#

Pod::Spec.new do |s|
  s.name             = "touchin-analytics"
  s.version          = "1.2.2"
  s.summary          = "A short description of touchin-analytics."
  s.description      = <<-DESC
                       An optional longer description of touchin-analytics

                       * Markdown format.
                       * Don't worry about the indent, we strip it!
                       DESC
  s.homepage         = "https://github.com/touchinstinct/touchin-analytics"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "alarin" => "me@alarin.ru" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/touchin-analytics.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  localytics     = { :spec_name => "Localytics",          :dependency => "Localytics" }
  flurry         = { :spec_name => "Flurry",              :dependency => "Flurry-iOS-SDK/FlurrySDK" }
  appsflyer      = { :spec_name => "AppsFlyer",           :dependency => "AppsFlyer-SDK" }
  amplitude      = { :spec_name => "Amplitude", :dependency => "Amplitude-iOS" }
  tune = { :spec_name => "Tune", :dependency => "MobileAppTracker"} 
  mixpanel = { :spec_name => "Mixpanel", :dependency => "Mixpanel"}
  answers = { :spec_name => "Answers", :dependency => "Fabric"}
  launchkit = { :spec_name => "LaunchKit", :dependency => "LaunchKit"}  

  all_analytics = [localytics, flurry, amplitude, appsflyer, mixpanel, answers, launchkit]

  s.subspec "CoreIOS" do |ss|
    ss.source_files = ['*.{h,m}', 'Providers/TIAnalyticsProviders.h']
    ss.platform = :ios
  end

  # make specs for each analytics
  all_analytics.each do |analytics_spec|
    s.subspec analytics_spec[:spec_name] do |ss|
      providername = analytics_spec[:spec_name]

      # Each subspec adds a compiler flag saying that the spec was included
      ss.prefix_header_contents = "#define TIA_#{providername.upcase}_EXISTS 1"
      sources = ["Providers/TI#{providername}Provider.{h,m}"]

      ss.ios.source_files = sources
      ss.dependency 'touchin-analytics/CoreIOS'
      ss.platform = :ios

      # If there's a podspec dependency include it
      Array(analytics_spec[:dependency]).each do |dep|
        ss.dependency dep
      end

    end
  end

  # s.frameworks = 'UIKit', 'MapKit'
  #s.dependency 'FlurrySDK'
  #s.dependency 'Mixpanel'
  #s.dependency 'AppsFlyer-SDK', '2.5.3.15.1'
  #s.dependency 'MobileAppTracker', '~>3.8.1'
  #s.dependency 'Localytics-AMP'
  #s.dependency 'Facebook-iOS-SDK', '~>4'
end
