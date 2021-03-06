# most of this podfile and architecture of lib was taken from https://github.com/orta/ARAnalytics
#

Pod::Spec.new do |s|
  s.name             = "touchin-analytics"
  s.version          = "1.4.1"
  s.summary          = "A short description of touchin-analytics."
  s.homepage         = "https://github.com/wayd-labs/touchin-analytics"
  s.license          = 'MIT'
  s.author           = { "alarin" => "me@alarin.ru" }
  s.source           = { :git => "https://github.com/wayd-labs/touchin-analytics.git", :tag => s.version.to_s }

  s.platform     = :ios, '7.0'
  s.requires_arc = true

  localytics     = { :spec_name => "Localytics",          :dependency => "Localytics" }
  flurry         = { :spec_name => "Flurry",              :dependency => "Flurry-iOS-SDK/FlurrySDK" }
  appsflyer      = { :spec_name => "AppsFlyer", :dependency => "AppsFlyer-SDK", :frameworks => "AdSupport.framework" }
  amplitude      = { :spec_name => "Amplitude", :dependency => "Amplitude-iOS" }
  tune = { :spec_name => "Tune", :dependency => "MobileAppTracker"} 
  mixpanel = { :spec_name => "Mixpanel", :dependency => "Mixpanel"}
  answers = { :spec_name => "Answers", :dependency => "Crashlytics"}
  launchkit = { :spec_name => "LaunchKit", :dependency => "LaunchKit"}  

  all_analytics = [answers, localytics, flurry, amplitude, appsflyer, tune, mixpanel, launchkit]

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
      ss.source_files = ["Providers/TI#{providername}Provider.{h,m}", "Empty.m"]
      ss.dependency 'touchin-analytics/CoreIOS'
      ss.platform = :ios
      # If there's a podspec dependency include it
      Array(analytics_spec[:dependency]).each do |dep|
        ss.dependency dep

        ss.pod_target_xcconfig = {
           'FRAMEWORK_SEARCH_PATHS' => '$(inherited) $(PODS_ROOT)/' + analytics_spec[:dependency],
           'OTHER_LDFLAGS'          => '$(inherited) -undefined dynamic_lookup'
        }
     end

    end
  end

  s.dependency 'touchin-trivia'
end
