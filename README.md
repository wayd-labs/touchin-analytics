touchin-analytics
=========
Common interface for Flurry, MixPanel and Localytics.
Automatically adds APPLAUNCH_FIRST, APPLAUNCH and SESSION_START events.

Correctly initialize AppsFlyer and MobileAppsTracking (but don't send events to them).

```objectivec
//initialize Analytics, just skip key if not need
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef APPSTORE
    [TIAnalytics.shared initialize:@{
        @"flurry": @"NJRFMCVD8HBKHZ7...",
        @"mixpanel": @"d2da20415faef3d9a018dc2d46....",
        @"appsflyer": @[@"BSaAakwjoAmiaN8F...", @"912362233"],
        @"mat": @[@"225..", @"b6c3978bba597784e1663c69...."],
        @"localytics": @"4a1931b9bfca292ece0081f-0e64af8e-6912-11e4-....",
    }];
#else
    [TIAnalytics.shared initialize:@{
        @"flurry": @"7Z3YHH7HZR9G7D....",
        @"mixpanel": @"ff107b4ff5fc9f02d97484f3a....",
        @"appsflyer": @[@"BSaAakwjoAmiaN8F...", @"912362233"],
        @"mat": @[@"225..", @"b6c3978bba597784e1663c69..."],
        @"localytics": @"d595a8b9e9c74fec2da926a-cecabe00-68f2-11e4-4ed8....",
    }];
#endif
```

```objectivec
- (void)viewDidAppear:(BOOL)animated {
    [TIAnalytics.shared trackScreen:@"INFO"];
}
```

```objectivec
[TIAnalytics.shared trackEvent:@"ANSWER-ALERT_SHOWN" properties:@{
    @"from_name": name ? name : @"", 
    @"from": _hit.from ? _hit.from : @""
}];
```
