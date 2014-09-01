//
//  Analytics.m
//  followme
//
//  Created by Толя Ларин on 03/06/14.
//  Copyright (c) 2014 Толя Ларин. All rights reserved.
//

#import "TIAnalytics.h"
#import "Flurry.h"
#import "MixPanel.h"
#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>

@implementation TIAnalytics

+ (Analytics *)shared
{
    static Analytics *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton) {
            sharedSingleton = [[Analytics alloc] init];
        }
        
        return sharedSingleton;
    }
}

#import "TIAnalytics-Conf.h"

-(BOOL) is_mixpanel {
    return [mixpaneltoken length] != 0;
}

-(BOOL) is_flurry {
    return [flurrytoken length] != 0;
}

-(BOOL) is_mat {
    return [mat_advertiserid length] && [mat_conversionkey length];
}

-(void) initialize {
    //    [TestFlight takeOff:@"90ae10d6-8abc-4988-970d-3c89f9fc76b9"];
//    NSString* localyticstoken = @"2699aeea00eb662ecd7ec6e-964dbb54-eaee-11e3-45f7-00a426b17dd8";
    
    if (self.is_mixpanel) {
        [Mixpanel sharedInstanceWithToken:mixpaneltoken];
        NSLog(@"Mixpanel initialized");
    }
    
    if (self.is_flurry) {
        [Flurry setCrashReportingEnabled:NO];
        [Flurry startSession:flurrytoken];
        NSLog(@"Flurry initialized");
    }
    
    if (self.is_mat) {
        [MobileAppTracker initializeWithMATAdvertiserId:mat_advertiserid
                                       MATConversionKey:mat_conversionkey];
        [MobileAppTracker setAppleAdvertisingIdentifier:[[ASIdentifierManager sharedManager] advertisingIdentifier]
                         advertisingTrackingEnabled:[[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]];
        NSLog(@"MAT initialized");
    }
    
    //track lauch and first launch
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs boolForKey:@"was_launched"]) {
        [self trackEvent:@"APP_LAUNCH_FIRST"];
        [prefs setBool:true forKey:@"was_launched"];
    }
    [self trackEvent:@"APP_LAUNCH"];
}

-(void) trackEvent:(NSString *) name {
    [self trackEvent:name properties:nil];
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties {
    if (self.is_mixpanel) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:name properties:properties];
    }
    if (self.is_flurry) {
        [Flurry logEvent:name withParameters:properties];
    }
    NSLog(@"ANALYTICS: %@, %@", name, properties);

}

-(void) identify: (NSString *)identity {
    //activates mixpanel people (to be honest no, it's not)
    if (self.is_mixpanel) {
        [Mixpanel.sharedInstance identify:identity];
    }
    NSLog(@"ANALYTICS IDENTIFY: %@", identity);
}

- (void)applicationDidBecomeActive
{
    if (self.is_mat) {
        // MAT will not function without the measureSession call included
        [MobileAppTracker measureSession];
    }
    [self trackEvent:@"SESSION_START"];
}

- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication
{
    if (self.is_mat) {
        [MobileAppTracker applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];
    }
}

@end
