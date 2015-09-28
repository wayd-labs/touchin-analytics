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

-(void) trackSignUp: (NSString*) method properties: (NSDictionary *) properties;
-(void) trackLogin: (NSString*) method properties: (NSDictionary *) properties;

-(void) identify: (NSString *)identity;
-(void) signUp:(NSString *)identity;

-(void) peopleSet: (NSDictionary *) data;

- (void)applicationDidBecomeActive;
- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication;

@end
