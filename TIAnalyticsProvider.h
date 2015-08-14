//
//  TIAnalyticsProvider.h
//  Pods
//
//  Created by Толя Ларин on 13/08/15.
//
//

#import <Foundation/Foundation.h>

@interface TIAnalyticsProvider : NSObject

-(id) initialize: (NSDictionary *) tokens;

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers;


/* optional */
-(void) trackError: (NSString *) name properties: (NSDictionary *) properties;

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency;

-(void) identify: (NSString *)identity;
-(void) signUp:(NSString *)identity;

-(void) peopleSet: (NSDictionary *) data;
-(void) peopleSet: (NSString *)property to:(id)object;
-(void) peopleIncrement:(NSString *)property by:(NSNumber *)amount;
//peopleSet not only simple calls to MixPanel people, but also stores value in NSDefauls, so in such way we can get property value back and use, for example, for touchin-rate me condition
-(id) peopleGet:(NSString*) property;
-(NSInteger) peopleGetInteger:(NSString*) property;

- (void)applicationDidBecomeActive;
- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication;

@end
