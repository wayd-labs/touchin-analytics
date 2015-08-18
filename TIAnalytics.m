//
//  Analytics.m
//  followme
//
//  Created by Толя Ларин on 03/06/14.
//  Copyright (c) 2014 Толя Ларин. All rights reserved.
//

#import "TIAnalytics.h"

//#import "MixPanel.h"
//#import "MobileAppTracker.h"
//#import "AppsFlyerTracker.h"
//#import <AdSupport/AdSupport.h>
#import <UIKit/UIKit.h>
//#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "TIAnalyticsProviders.h"

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
BOOL facebook;

NSMutableArray* providers;

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

-(BOOL) is_facebook {
  return facebook;
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
//    if ([tokens objectForKey:@"mixpanel"]) {
//        mixpaneltoken = [tokens objectForKey:@"mixpanel"];
//        [Mixpanel sharedInstanceWithToken:mixpaneltoken];
//        NSLog(@"Mixpanel initialized");
//    }

//    if ([tokens objectForKey:@"appsflyer"]) {
//        appsflyertoken = [tokens objectForKey:@"appsflyer"];
//        [AppsFlyerTracker sharedTracker].appsFlyerDevKey = appsflyertoken[0];
//        [AppsFlyerTracker sharedTracker].appleAppID = appsflyertoken[1];
//        [AppsFlyerTracker sharedTracker].isHTTPS = YES;
//        NSLog(@"AppsFlyer initialized");
//    }
//
    providers = [NSMutableArray new];

#if TIA_FLURRY_EXISTS
    [providers addObject:[[TIFlurryProvider new] initialize:tokens]];
#endif

#if TIA_LOCALYTICS_EXISTS
    [providers addObject:[[TILocalyticsProvider new] initialize:tokens]];
    NSLog(@"Locatytics initialized");
#endif

#if TIA_AMPLITUDE_EXISTS
    [providers addObject:[[TIAmplitudeProvider new] initialize:tokens]];
    NSLog(@"Amplitude initialized");
#endif
    
#if TIA_TUNE_EXISTS
    [providers addObject:[[TITuneProvider new] initialize:tokens]];
    NSLog(@"Tune initialized");
#endif
    
    if ([providers count] != [tokens count]) {
        [NSException raise:@"TIAnalytics. Not all tokens initialazied." format:@"Not all analytics tokens (tokens: %lu, initialized: %lu) used, check pods and names",
            (unsigned long)[tokens count], (unsigned long)[providers count]];
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
    [self trackEvent:[name stringByAppendingString:@"_SHOWN"] properties:objectId ? @{@"objectId": objectId}: nil];
    NSLog(@"ANALYTICS SCREEN: %@, %@", name, objectId);
}

-(void) trackEvent:(NSString *) name {
    [self trackEvent:name properties:nil];
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers:(bool)sendToTrackers {
    for (int i=0; i < [providers count]; i++) {
      [providers[i] trackEvent:name properties:properties sendToTrackers:sendToTrackers];
    }
//  if (self.is_mixpanel) {
//    Mixpanel *mixpanel = [Mixpanel sharedInstance];
//    [mixpanel track:name properties:properties];
//  }
//  if (sendToTrackers) {
//    if (self.is_appsflyer) {
//      [[AppsFlyerTracker sharedTracker] trackEvent:name withValues:properties];
//    }
//  }
    NSLog(@"ANALYTICS%@: %@, %@", sendToTrackers ? @"+TRACKERS" : @"", name, properties);
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties {
  [self trackEvent:name properties:properties sendToTrackers:false];
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

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
    for (int i=0; i < [providers count]; i++) {
        [providers[i] trackPurchaseWithItemName:name amount:amount currency:currency];
    }
}

-(void) identify: (NSString *)identity {
//    if (self.is_mixpanel) {
//        [Mixpanel.sharedInstance identify:identity];
//    }
    [self peopleSet:@"last_login" to:[NSDate date]];
    NSLog(@"ANALYTICS IDENTIFY: %@", identity);
}

-(void) signUp:(NSString *)identity {
//    if (self.is_mixpanel) {
//        [Mixpanel.sharedInstance createAlias:identity forDistinctID:Mixpanel.sharedInstance.distinctId];
//    }    
    [self peopleSet:@"sign_up" to:[NSDate date]];
    [self identify:identity];
}

-(void) registerSuperProperties: (NSDictionary *) properties {
//    if ([self is_mixpanel]) {
//        [Mixpanel.sharedInstance registerSuperProperties:properties];
//    }
}

NSString* UD_PREFIX = @"TIAnalytics";

-(void) peopleSet: (NSDictionary *) data {
//    if (self.is_mixpanel) {
//        [Mixpanel.sharedInstance.people set:data];
//    }
    NSLog(@"ANALYTICS PeopleSet: %@", data);
}

-(void) peopleSet: (NSString *)property to:(id)object {
//    if (self.is_mixpanel) {
//        [Mixpanel.sharedInstance.people set:property to:object];
//    }
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:[UD_PREFIX stringByAppendingString:property]];
    NSLog(@"ANALYTICS PeopleSet %@ to %@", property, object);
}

-(void) peopleIncrement:(NSString *)property by:(NSNumber *)amount {
//    if (self.is_mixpanel) {
//        [Mixpanel.sharedInstance.people increment:property by:amount];
//    }
    NSObject* was = [[NSUserDefaults standardUserDefaults] objectForKey:[UD_PREFIX stringByAppendingString:property]];
    NSInteger prev = 0;
    if ((was != nil) && [was isKindOfClass:[NSNumber class]]) {
        prev = ((NSNumber*) was).intValue;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:prev+1] forKey:[UD_PREFIX stringByAppendingString:property]];
    NSLog(@"ANALYTICS People Increment: %@ by %@ (was %ld)", property, amount, (long)prev);
}

-(id) peopleGet:(NSString*) property {
    return [[NSUserDefaults standardUserDefaults] objectForKey:[UD_PREFIX stringByAppendingString:property]];
}

-(NSInteger) peopleGetInteger:(NSString*) property {
    NSObject* obj = [self peopleGet:property];
    if ((obj == nil) || ![obj isKindOfClass:[NSNumber class]]) {
        return 0;
    }
    NSInteger val = [((NSNumber*) obj) integerValue];
    NSLog(@"ANALYTICS People Get: %@ = %ld)", property, val);
    return val;
}


- (void)applicationDidBecomeActive
{
    for (int i=0; i < [providers count]; i++) {
        [providers[i] applicationDidBecomeActive];
    }
    
//    if (self.is_appsflyer) {
//        // Track Installs, updates & sessions(app opens) (You must include this API to enable tracking)
//        [[AppsFlyerTracker sharedTracker] trackAppLaunch];
//    }
}

- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication
{
    for (int i=0; i < [providers count]; i++) {
        [providers[i] applicationOpenUrl:url sourceApplication:sourceApplication];
    }
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
}

@end