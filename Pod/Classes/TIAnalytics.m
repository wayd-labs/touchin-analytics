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
#import "AppsFlyerTracker.h"
#import "LocalyticsSession.h"
#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
#import <GAI.h>
#import <GAIDictionaryBuilder.h>
#import <GAIFields.h>

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
NSArray* appsflyertoken;
NSArray* mattoken;
NSString* localyticstoken;
NSString* gatoken;

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

-(BOOL) is_appsflyer {
    return [appsflyertoken count] == 2;
}

-(BOOL) is_localytics {
    return [localyticstoken length] != 0;
}

-(BOOL) is_ga {
    return [gatoken length] != 0;
}

- (NSString*) isoNowDate {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    return [dateFormatter stringFromDate:[NSDate date]];
}

- (NSString*) nowTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    return [dateFormatter stringFromDate:[NSDate date]];
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
    
    if ([tokens objectForKey:@"appsflyer"]) {
        appsflyertoken = [tokens objectForKey:@"appsflyer"];
        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = appsflyertoken[0];
        [AppsFlyerTracker sharedTracker].appleAppID = appsflyertoken[1];
        [AppsFlyerTracker sharedTracker].isHTTPS = YES;
        NSLog(@"AppsFlyer initialized");
    }

    if ([tokens objectForKey:@"localytics"]) {
        localyticstoken = [tokens objectForKey:@"localytics"];
        [[LocalyticsSession shared] integrateLocalytics:localyticstoken launchOptions:nil];
        [[LocalyticsSession shared] resume];
        NSLog(@"Localytics initialized");
    }
    
    if ([tokens objectForKey:@"google-analytics"]) {
        gatoken = [tokens objectForKey:@"google-analytics"];
        [[GAI sharedInstance] trackerWithTrackingId:gatoken];
        NSLog(@"Google Analytics initialized");
    }
    
    //track lauch and first launch
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *datetimeprop = @{@"date": self.isoNowDate, @"time": self.nowTime};
    if (![prefs boolForKey:@"was_launched"]) {
        [self trackEvent:@"APP_LAUNCH_FIRST" properties:datetimeprop];
        [prefs setBool:true forKey:@"was_launched"];
    }
    [self trackEvent:@"APP_LAUNCH" properties:datetimeprop];
    
    //required for MAT attribution tracking
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) trackScreen:(NSString *) name {
    [self trackScreen:name objectId:nil];
}

-(void) trackScreen:(NSString *) name objectId:(NSString *) objectId {
    if (self.is_ga) {
        id tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:name];
        [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    }
    if (self.is_localytics) {
        [[LocalyticsSession shared] tagScreen:name];
        //Should we also send an Event?
    }
    
    [self trackEvent:[name stringByAppendingString:@"_SHOWN"] properties:objectId ? @{@"objectId": objectId}: nil];
    NSLog(@"ANALYTICS SCREEN: %@, %@", name, objectId);
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
    if (self.is_localytics) {
        [[LocalyticsSession shared] tagEvent:name attributes:properties];
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
    NSString *timeformatted = [NSString stringWithFormat:@"%.1f", time];
    NSLog(@"ANALYTICS timed event end %@ %@", name, timeformatted);
    NSMutableDictionary *fullProperties = [NSMutableDictionary new];
    [fullProperties addEntriesFromDictionary:timedEvents[name]];
    [fullProperties addEntriesFromDictionary:addproperties];
    fullProperties[@"duration"] = timeformatted;
    [fullProperties removeObjectForKey:@"time"];
    [timedEvents removeObjectForKey:name];
    [self trackEvent:[name stringByAppendingString:@"_finished"] properties:fullProperties];
}

-(void) trackError: (NSString *) name properties: (NSDictionary *) properties {
    NSMutableDictionary *props = [NSMutableDictionary new];
    [props addEntriesFromDictionary:properties];
    props[@"error_name"] = name;
    [self trackEvent:@"ERROR" properties:props];
}

-(void) identify: (NSString *)identity {
    if (self.is_mixpanel) {
        [Mixpanel.sharedInstance identify:identity];
    }
    [self peopleSet:@"last_login" to:[NSDate date]];
    NSLog(@"ANALYTICS IDENTIFY: %@", identity);
}

-(void) signUp:(NSString *)identity {
    if (self.is_mixpanel) {
        [Mixpanel.sharedInstance createAlias:identity forDistinctID:Mixpanel.sharedInstance.distinctId];
    }    
    [self peopleSet:@"sign_up" to:[NSDate date]];
    [self identify:identity];
}

-(void) registerSuperProperties: (NSDictionary *) properties {
    if ([self is_mixpanel]) {
        [Mixpanel.sharedInstance registerSuperProperties:properties];
    }
}

-(void) peopleSet: (NSDictionary *) data {
    if (self.is_mixpanel) {
        [Mixpanel.sharedInstance.people set:data];
    }
    NSLog(@"ANALYTICS PeopleSet: %@", data);
}

-(void) peopleSet: (NSString *)property to:(id)object {
    if (self.is_mixpanel) {
        [Mixpanel.sharedInstance.people set:property to:object];
    }
    NSLog(@"ANALYTICS PeopleSet %@ to %@", property, object);
}

-(void) peopleIncrement: (NSDictionary *) data {
    if (self.is_mixpanel) {
        [Mixpanel.sharedInstance.people increment:data];        
    }
    NSLog(@"ANALYTICS People Increment: %@", data);
}

- (void)applicationDidBecomeActive
{
    if (self.is_mat) {
        // MAT will not function without the measureSession call included
        [MobileAppTracker measureSession];
    }
    if (self.is_appsflyer) {
        // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
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
