#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
#import <sharetrace_flutter_plugin/SharetraceFlutterPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

// Universal Link
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([SharetraceFlutterPlugin handleUniversalLink:userActivity]) {
        return YES;
    }

    //其他代码
    return YES;
}

//iOS9以下 Scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    if ([SharetraceFlutterPlugin handleSchemeLinkURL:url]) {
        return YES;
    }

    //其他代码
    return YES;
}

//iOS9以上 Scheme
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options {
    if ([SharetraceFlutterPlugin handleSchemeLinkURL:url]) {
        return YES;
    }
    
    //其他代码
    return YES;
}

@end
