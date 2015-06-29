//
//  Analytics.h
//  followme
//
//  Created by Толя Ларин on 03/06/14.
//  Copyright (c) 2014 Толя Ларин. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIAnalytics : NSObject

typedef enum {
  TrackerEventClassCustom,
  TrackerEventClassRegistration,
  TrackerEventClassLogin,
} TrackerEventClass;

+ (TIAnalytics *) shared;

-(void) initialize: (NSDictionary*) tokens;

-(void) trackScreen:(NSString *) name;
-(void) trackScreen:(NSString *) name objectId:(NSString *) objectId;

-(void) trackEvent: (NSString *) name;
-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties;

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers;

-(void) trackTimedEvent: (NSString*) name properties: (NSDictionary *) properties;
-(void) trackTimedEventEnd: (NSString*) name addproperties: (NSDictionary *) properties;

-(void) trackError: (NSString *) name properties: (NSDictionary *) properties;

-(void) identify: (NSString *)identity;
-(void) signUp:(NSString *)identity;

-(void) registerSuperProperties: (NSDictionary *) properties;

-(void) peopleSet: (NSDictionary *) data;
-(void) peopleSet: (NSString *)property to:(id)object;
-(void) peopleIncrement:(NSString *)property by:(NSNumber *)amount;
//peopleSet not only simple calls to MixPanel people, but also stores value in NSDefauls, so in such way we can get property value back and use, for example, for touchin-rate me condition
-(id) peopleGet:(NSString*) property;
-(NSInteger) peopleGetInteger:(NSString*) property;

- (void)applicationDidBecomeActive;
- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication;
@end
