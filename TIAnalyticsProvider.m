//
//  TIAnalyticsProvider.m
//  Pods
//
//  Created by Толя Ларин on 13/08/15.
//
//

#import "TIAnalyticsProvider.h"

@implementation TIAnalyticsProvider

-(void) trackScreen:(NSString *) name objectId:(NSString *) objectId {
  [self trackEvent:[name stringByAppendingString:@"_SHOWN"] properties:objectId ? @{@"objectId": objectId}: nil sendToTrackers:@NO];
  NSLog(@"ANALYTICS SCREEN: %@, %@", name, objectId);
}

-(void) trackError: (NSString *) name properties: (NSDictionary *) properties {
  NSMutableDictionary *props = [NSMutableDictionary new];
  [props addEntriesFromDictionary:properties];
  props[@"error_name"] = name;
  [self trackEvent:@"ERROR" properties:props sendToTrackers:@NO];
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
  
}

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
    NSDictionary *attributes = @{
                                 @"name": name,
                                 @"amount": amount,
                                 @"currency": currency
    };
    [self trackEvent:[NSString stringWithFormat:@"PURCHASE_%@", name] properties:attributes sendToTrackers:true];
}

-(void) trackSignUp: (NSString*) method properties: (NSDictionary *) properties {
  NSMutableDictionary* prop = [NSMutableDictionary dictionaryWithDictionary:properties];
  prop[@"method"] = method;
  [self trackEvent:@"SIGNUP" properties:prop sendToTrackers:@YES];
}

-(void) trackLogin: (NSString*) method properties: (NSDictionary *) properties {
  NSMutableDictionary* prop = [NSMutableDictionary dictionaryWithDictionary:properties];
  prop[@"method"] = method;
  [self trackEvent:@"LOGGED_IN" properties:prop sendToTrackers:@YES];
}

-(void) identify: (NSString *)identity {
  
}

-(void) signUp:(NSString *)identity {
  
}

-(void) peopleSet: (NSDictionary *) data {
  
}

-(void) peopleSet: (NSString *)property to:(id)object {
  
}
-(void) peopleIncrement:(NSString *)property by:(NSNumber *)amount {
  
}

-(id) peopleGet:(NSString*) property {
}

-(NSInteger) peopleGetInteger:(NSString*) property {
  return 0;
}

- (void)applicationDidBecomeActive {
  
}
- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication {
  
}

@end
