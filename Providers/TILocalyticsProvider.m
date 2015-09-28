#import "TILocalyticsProvider.h"
#import "Localytics.h"

@implementation TILocalyticsProvider

#if TIA_LOCALYTICS_EXISTS
-(id) initialize: (NSDictionary *) tokens {
    NSString* localyticstoken = [tokens objectForKey:@"localytics"];
    [Localytics autoIntegrate:localyticstoken launchOptions:nil];
    return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
    [Localytics tagEvent:name attributes:properties];
}

-(void) trackScreen:(NSString *) name objectId:(NSString *) objectId {
    [Localytics tagScreen:name];
}

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
    NSDictionary *attributes = @{
        @"name": name,
        @"amount": amount,
        @"currency": currency
    };
[Localytics tagEvent:[NSString stringWithFormat:@"BUY_%@", name] attributes: attributes customerValueIncrease:amount];
}

- (void) peopleSet:(NSDictionary *)data {
  for(id key in data) {
    [Localytics setValue:data[key] forIdentifier:key];
  }
}

- (void) identify:(NSString *)identity {
  [Localytics setCustomerId:identity];
}
#endif

@end
