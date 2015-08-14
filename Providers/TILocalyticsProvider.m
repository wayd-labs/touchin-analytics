#import "TILocalyticsProvider.h"
#import "LocalyticsSession.h"

@implementation TILocalyticsProvider


#if TIA_LOCALYTICS_EXISTS
-(BOOL) initialize: (NSArray *) tokens {
}

-(void) trackEvent: (NSString *) name properties: (NSDictionary *) properties sendToTrackers: (bool) sendToTrackers {
}

-(void) trackScreen {
//  [[LocalyticsSession shared] tagScreen:name];
}
#endif

@end
