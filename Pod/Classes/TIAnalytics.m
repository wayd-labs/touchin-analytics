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
#import "MobileAppTracker.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>

@implementation TIAnalytics

+ (instancetype)shared {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

NSString* flurrytoken;
NSString* mixpaneltoken;
NSArray* mattoken;

NSMutableDictionary* timedEvents;


-(BOOL) is_mixpanel {
    return [mixpaneltoken length] != 0;
}

-(BOOL) is_flurry {
    return [flurrytoken length] != 0;
}

-(BOOL) is_mat {
//    return [mat_advertiserid length] && [mat_conversionkey length];
    return [mattoken count] == 2;
}

-(void) initialize: (NSDictionary*) tokens {
    if ([tokens objectForKey:@"flurry"]) {
        flurrytoken = [tokens objectForKey:@"flurry"];
        [Flurry setCrashReportingEnabled:NO];
        [Flurry startSession:flurrytoken];
        NSLog(@"Flurry initialized");
    }
    
    if ([tokens objectForKey:@"mixpanel"]) {
        mixpaneltoken = [tokens objectForKey:@"mixpanel"];
        [Mixpanel sharedInstanceWithToken:mixpaneltoken];
        NSLog(@"Mixpanel initialized");
    }
    
    if ([tokens objectForKey:@"mat"]) {
        mattoken = [tokens objectForKey:@"mat"];
        [MobileAppTracker initializeWithMATAdvertiserId:mattoken[0]
                                       MATConversionKey:mattoken[1]];
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
    
    //required for MAT attribution tracking
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
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

-(void) trackTimedEvent: (NSString*) name properties: (NSDictionary *) properties {
    if (!timedEvents) {
        timedEvents = [NSMutableDictionary new];
    }
    
    if ([timedEvents objectForKey:name]) {
        NSLog(@"DOUBLED TIMED EVENT! %@", name);
    }
    NSMutableDictionary* mutableProps = [NSMutableDictionary new];
    [mutableProps addEntriesFromDictionary:properties];
    timedEvents[name] = mutableProps;
    timedEvents[name][@"time"] = [NSDate date];
    [self trackEvent:[name stringByAppendingString:@"_start"] properties:properties];
    NSLog(@"ANALYTICS timed event start %@ %@", name, timedEvents[name][@"time"]);
}

-(void) trackTimedEventEnd: (NSString*) name addproperties: (NSDictionary *) addproperties {
    NSTimeInterval time = -1;
    if (![timedEvents objectForKey:name]) {
        NSLog(@"NO SUCH TIMED EVENT! %@", name);
    } else {
        time = [[NSDate date] timeIntervalSinceDate:timedEvents[name][@"time"]];
    }
    NSString *timeformatted = [NSString stringWithFormat:@"%f", time];
    NSLog(@"ANALYTICS timed event end %@ %@", name, timeformatted);
    NSMutableDictionary *fullProperties = [NSMutableDictionary new];
    [fullProperties addEntriesFromDictionary:timedEvents[name]];
    [fullProperties addEntriesFromDictionary:addproperties];
    fullProperties[@"time"] = timeformatted;
    [timedEvents removeObjectForKey:name];
    [self trackEvent:[name stringByAppendingString:@"_end"] properties:fullProperties];
}

-(void) trackError: (NSString *) name properties: (NSDictionary *) properties {
    NSMutableDictionary *props = [NSMutableDictionary new];
    [props addEntriesFromDictionary:properties];
    props[@"error_name"] = name;
    [self trackEvent:@"ERROR" properties:props];
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

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

@end
