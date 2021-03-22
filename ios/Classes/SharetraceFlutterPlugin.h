#import <Flutter/Flutter.h>

@interface SharetraceFlutterPlugin : NSObject<FlutterPlugin>

/**
 * 处理 URI Schemes 逻辑
 * @param url 通过Schemes调起时，系统回调回来的URL
 * @return bool Sharetrace是否成功识别该URL
 */
+ (BOOL)handleSchemeLinkURL:(NSURL * _Nullable)url;

/**
 * 处理 Universal link 逻辑
 * @param userActivity 通过Universal link调起时，包含系统回调回来的URL信息的NSUserActivity
 * @return bool Sharetrace是否成功识别该URL
 */
+ (BOOL)handleUniversalLink:(NSUserActivity * _Nullable)userActivity;

@end
