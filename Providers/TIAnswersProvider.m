
#import "TIAnswersProvider.h"
#import "Answers.h"
@implementation TIAnswersProvider

#if TIA_ANSWERS_EXISTS
-(id) initialize: (NSDictionary *) tokens {
    return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
    if (sendToTrackers) {
        [Answers logCustomEventWithName:name customAttributes:properties];
    }
}

-(void) trackPurchaseWithItemName: (NSString*) name amount: (NSDecimalNumber*) amount currency: (NSString*) currency {
    [Answers logPurchaseWithPrice:amount
                         currency:currency
                          success:@YES
                         itemName:nil
                         itemType:nil
                           itemId:name
                 customAttributes:@{}];
}
#endif

@end