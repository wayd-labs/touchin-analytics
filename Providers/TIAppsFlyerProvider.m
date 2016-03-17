#import "TIAppsFlyerProvider.h"

@implementation TIAppsFlyerProvider

#if TIA_APPSFLYER_EXISTS

#import "AppsFlyerTracker.h"

-(id) initialize: (NSDictionary *) tokens {
    NSArray* token = [tokens objectForKey:@"appsflyer"];
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = token[0];
    [AppsFlyerTracker sharedTracker].appleAppID = token[1];
    NSLog(@"AppsFlyer initialized");
    return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
    if (sendToTrackers) {
        [[AppsFlyerTracker sharedTracker] trackEvent:name withValues:properties];
    }
}

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
     NSDictionary *properties = @{
        @"name": name,
        @"amount": amount,
        @"currency": currency,
        AFEventParamRevenue: amount,
        AFEventParamPrice: amount
    };
    [[AppsFlyerTracker sharedTracker] trackEvent:[NSString stringWithFormat:@"BUY_%@", name] withValues:properties];
}

- (void)applicationDidBecomeActive {
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
}

#endif

@end
