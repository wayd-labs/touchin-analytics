//
//  Analytics.h
//  followme
//
//  Created by Толя Ларин on 03/06/14.
//  Copyright (c) 2014 Толя Ларин. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIAnalytics : NSObject

+ (TIAnalytics *) shared;

-(void) initialize: (NSDictionary*) tokens;

-(void) trackEvent:(NSString *) name;
-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties;

-(void) trackTimedEvent: (NSString*) name properties: (NSDictionary *) properties;
-(void) trackTimedEventEnd: (NSString*) name addproperties: (NSDictionary *) properties;

-(void) trackError: (NSString *) name properties: (NSDictionary *) properties;

-(void) identify: (NSString *)identity;

- (void)applicationDidBecomeActive;
- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication;
@end
