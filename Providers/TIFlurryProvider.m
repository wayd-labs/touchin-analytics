//
//  FlurryProvider.m
//  Pods
//
//  Created by Толя Ларин on 13/08/15.
//
//

#import "TIFlurryProvider.h"
#import "Flurry.h"

@implementation TIFlurryProvider

#if TIA_FLURRY_EXISTS


-(id) initialize: (NSDictionary *) tokens {
  NSString* flurrytoken = [tokens objectForKey:@"flurry"];
  [Flurry setCrashReportingEnabled:NO];
  [Flurry startSession:flurrytoken];
  return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
  [Flurry logEvent:name withParameters:properties];
}
#endif

@end
