//
//  TIMatProvider.m
//  Pods
//
//  Created by Толя Ларин on 18/08/15.
//
//

#import "TITuneProvider.h"

#import <MobileAppTracker/MobileAppTracker.h>
#import <AdSupport/AdSupport.h>

@implementation TITuneProvider

#if TIA_TUNE_EXISTS
-(id) initialize: (NSDictionary *) tokens {
    NSArray* token = [tokens objectForKey:@"tune"];
    [Tune initializeWithTuneAdvertiserId:token[0]
                       TuneConversionKey:token[1]];
    return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
    if (sendToTrackers) {
        TuneEvent *event = [TuneEvent eventWithName:TUNE_EVENT_LEVEL_ACHIEVED];
        [Tune measureEvent:event];
    }
}

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
    TuneEventItem *item1 = [TuneEventItem eventItemWithName:name unitPrice:amount.floatValue quantity:1];
    NSArray *eventItems = @[item1];

    TuneEvent *event = [TuneEvent eventWithName:TUNE_EVENT_PURCHASE];
    event.eventItems = eventItems;
    event.revenue = [amount doubleValue];
    event.currencyCode = currency;
    
    [Tune measureEvent:event];
}

- (void)applicationDidBecomeActive {
    [Tune measureSession];
}

- (void)applicationOpenUrl:(NSURL*) url sourceApplication:(NSString*) sourceApplication
{
    [Tune applicationDidOpenURL:[url absoluteString] sourceApplication:sourceApplication];
}

#endif

@end
