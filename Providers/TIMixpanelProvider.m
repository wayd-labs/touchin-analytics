#import "TIMixpanelProvider.h"
#import "Mixpanel.h"

@implementation TIMixpanelProvider

#if TIA_MIXPANEL_EXISTS
-(id) initialize: (NSDictionary *) tokens {
    NSString* mixpaneltoken = [tokens objectForKey:@"mixpanel"];
    [Mixpanel sharedInstanceWithToken:mixpaneltoken];
    return self;
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
    [[Mixpanel sharedInstance] track:name properties:properties];
}

-(void) identify: (NSString *) userId {
    [Mixpanel.sharedInstance identify:userId];
}
#endif

@end
