//
//  TIMixpanelProvider.h
//  Pods
//
//  Created by Толя Ларин on 18/08/15.
//
//

#import "TIAnalyticsProvider.h"

@interface TIMixpanelProvider : TIAnalyticsProvider

-(void) peopleIncrement:(NSString*) property by:(NSNumber *)amount;

@end
