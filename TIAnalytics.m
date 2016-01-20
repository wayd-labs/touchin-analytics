//
//  Analytics.m
//  followme
//
//  Created by Толя Ларин on 03/06/14.
//  Copyright (c) 2014 Толя Ларин. All rights reserved.
//

#import "TIAnalytics.h"
#import "TIAnalyticsProviders.h"
#import "TILog.h"

@implementation TIAnalytics

+ (instancetype)shared {
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

NSMutableArray* providers;
NSMutableDictionary* timedEvents;

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
    providers = [NSMutableArray new];

#if TIA_FLURRY_EXISTS
    [providers addObject:[[TIFlurryProvider new] initialize:tokens]];
#endif

#if TIA_LOCALYTICS_EXISTS
    [providers addObject:[[TILocalyticsProvider new] initialize:tokens]];
    [TILog info:[NSString stringWithFormat:@"Locatytics initialized"]];
#endif

#if TIA_AMPLITUDE_EXISTS
    [providers addObject:[[TIAmplitudeProvider new] initialize:tokens]];
    [TILog info:[NSString stringWithFormat:@"Amplitude initialized"]];
#endif
    
#if TIA_TUNE_EXISTS
    [providers addObject:[[TITuneProvider new] initialize:tokens]];
    [TILog info:[NSString stringWithFormat:@"Tune initialized"]];
#endif

#if TIA_APPSFLYER_EXISTS
    [providers addObject:[[TIAppsFlyerProvider new] initialize:tokens]];
#endif

#if TIA_MIXPANEL_EXISTS
    [providers addObject:[[TIMixpanelProvider new] initialize:tokens]];
    [TILog info:[NSString stringWithFormat:@"Mixpanel initialized"]];
#endif
    
#if TIA_ANSWERS_EXISTS
    [providers addObject:[[TIAnswersProvider new] initialize:tokens]];
    [TILog info:[NSString stringWithFormat:@"Answers initialized"]];
#endif

#if TIA_LAUNCHKIT_EXISTS
  [providers addObject:[[TILaunchKitProvider new] initialize:tokens]];
  [TILog info:[NSString stringWithFormat:@"LaunchKit initialized"]];
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
    [TILog info:[NSString stringWithFormat:@"ANALYTICS SCREEN: %@, %@", name, objectId]];
}

-(void) trackEvent:(NSString *) name {
    [self trackEvent:name properties:nil];
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers:(bool)sendToTrackers {
    for (int i=0; i < [providers count]; i++) {
      [providers[i] trackEvent:name properties:properties sendToTrackers:sendToTrackers];
    }
    [TILog info:[NSString stringWithFormat:@"ANALYTICS%@: %@, %@", sendToTrackers ? @"+TRACKERS" : @"", name, properties]];
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties {
  [self trackEvent:name properties:properties sendToTrackers:false];
}

-(void) trackSignUp: (NSString*) method properties: (NSDictionary *) properties {
  for (int i=0; i < [providers count]; i++) {
    [providers[i] trackSignUp:method properties:properties];
  }
  [TILog info:[NSString stringWithFormat:@"#ti-analytics SIGNUP: %@, %@", method, properties]];
}

-(void) trackLogin: (NSString*) method properties: (NSDictionary *) properties {
  for (int i=0; i < [providers count]; i++) {
    [providers[i] trackLogin:method properties:properties];
  }
  [TILog info:[NSString stringWithFormat:@"#ti-analytics LOGGED_IN: %@, %@", method, properties]];
}


-(void) trackTimedEvent: (NSString*) name properties: (NSDictionary *) properties {
    if (!timedEvents) {
        timedEvents = [NSMutableDictionary new];
    }
    
    if ([timedEvents objectForKey:name]) {
        [TILog info:[NSString stringWithFormat:@"DOUBLED TIMED EVENT! %@", name]];
    }
    NSMutableDictionary* mutableProps = [NSMutableDictionary new];
    [mutableProps addEntriesFromDictionary:properties];
    timedEvents[name] = mutableProps;
    timedEvents[name][@"time"] = [NSDate date];
    [self trackEvent:[name stringByAppendingString:@"_start"] properties:properties];
    [TILog info:[NSString stringWithFormat:@"ANALYTICS timed event start %@ %@", name, timedEvents[name][@"time"]]];
}

-(void) trackTimedEventEnd: (NSString*) name addproperties: (NSDictionary *) addproperties {
    NSTimeInterval time = -1;
    if (![timedEvents objectForKey:name]) {
        [TILog info:[NSString stringWithFormat:@"NO SUCH TIMED EVENT! %@", name]];
    } else {
        time = [[NSDate date] timeIntervalSinceDate:timedEvents[name][@"time"]];
    }
    NSString *timeformatted = [NSString stringWithFormat:@"%.1f", time];
    [TILog info:[NSString stringWithFormat:@"ANALYTICS timed event end %@ %@", name, timeformatted]];
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
  [self peopleSet:@"paying" to:[[NSNumber alloc] initWithBool:true]];
}

-(void) identify: (NSString *)identity {
    [self peopleSet:@"last_login" to:[NSDate date]];
    for (int i=0; i < [providers count]; i++) {
       [providers[i] identify:identity];
    }
    [TILog info:[NSString stringWithFormat:@"ANALYTICS IDENTIFY: %@", identity]];
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
    for (int i=0; i < [providers count]; i++) {
       [providers[i] peopleSet:data];
    }
    [TILog info:[NSString stringWithFormat:@"ANALYTICS PeopleSet: %@", data]];
}

-(void) peopleSet: (NSString *)property to:(id)object {
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:[UD_PREFIX stringByAppendingString:property]];
    [self peopleSet:@{property:object}];
    [TILog info:[NSString stringWithFormat:@"ANALYTICS PeopleSet %@ to %@", property, object]];
}

-(void) peopleIncrement:(NSString *)property by:(NSNumber *)amount {
//    if (self.is_mixpanel) {
//        [Mixpanel.sharedInstance.people increment:property by:amount];
//    }
    NSInteger prev = [self peopleGetInteger:property];
    NSInteger new = prev + amount.integerValue;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:new] forKey:[UD_PREFIX stringByAppendingString:property]];

    for (int i=0; i < [providers count]; i++) {
      if ([providers[i] respondsToSelector:@selector(peopleIncrement:by:)]) {
        [providers[i] peopleIncrement:property by:amount];
      } else {
        [providers[i] peopleSet:property to:[[NSNumber alloc]initWithInteger:new]];
      }
    }
    [TILog info:[NSString stringWithFormat:@"ANALYTICS People Increment: %@ by %@ (was %ld)", property, amount, (long)prev]];
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
    [TILog info:[NSString stringWithFormat:@"ANALYTICS People Get: %@ = %ld)", property, val]];
    return val;
}

- (void)applicationDidBecomeActive
{
    for (int i=0; i < [providers count]; i++) {
        [providers[i] applicationDidBecomeActive];
    }
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
