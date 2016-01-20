#import "TILaunchKitProvider.h"
#import <LaunchKit/LaunchKit.h>

@implementation TILaunchKitProvider

#if TIA_LAUNCHKIT_EXISTS
-(id) initialize: (NSDictionary *) tokens {
    NSString* token = [tokens objectForKey:@"launchkit"];
    [LaunchKit launchWithToken:token];
    return self;
}

- (void) peopleSet:(NSDictionary *)data {
  if (data[@"name"] && data[@"user_id"]) {
    [[LaunchKit sharedInstance] setUserIdentifier:data[@"user_id"]
                                            email:nil
                                             name:data[@"name"]];
  }
}

- (void) identify:(NSString *)identity {
  [[LaunchKit sharedInstance] setUserIdentifier:identity
                                          email:nil
                                           name:nil];
}
#endif

@end
