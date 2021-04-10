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

// 从Sharetrace flutter plugin 1.4.0 开始，一键调起逻辑由插件内部处理以解决与其他插件冲突的问题
// 如果无法使用Sharetrace 一键调起，则需要AppDelegate处理，如下面代码所示：（注：需要自行处理与其他插件冲突的问题，详情参考文档）
// 文档地址：https://sharetrace.com/docs/third/flutter.html

//// Universal Link
//- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
//    if ([SharetraceFlutterPlugin handleUniversalLink:userActivity]) {
//        return YES;
//    }
//
//    //其他代码
//    return YES;
//}
//
////iOS9以下 Scheme
//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//    if ([SharetraceFlutterPlugin handleSchemeLinkURL:url]) {
//        return YES;
//    }
//
//    //其他代码
//    return YES;
//}
//
////iOS9以上 Scheme
//- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options {
//    if ([SharetraceFlutterPlugin handleSchemeLinkURL:url]) {
//        return YES;
//    }
//    
//    //其他代码
//    return YES;
//}

@end
