#import "TIAmplitudeProvider.h"
#import "Amplitude.h"

@implementation TIAmplitudeProvider

#if TIA_AMPLITUDE_EXISTS
-(id) initialize: (NSDictionary *) tokens {
  NSString* token = [tokens objectForKey:@"amplitude"];
  [[Amplitude instance] initializeApiKey:token];
  return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
  [[Amplitude instance] logEvent:name withEventProperties:properties];
}

-(void) identify: (NSString *) userId {
  [[Amplitude instance] setUserId:userId];
}

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
  //FIXME currency use
  [[Amplitude instance] logRevenue:name quantity:1 price:amount];
}
//TODO people set
#endif

@end
