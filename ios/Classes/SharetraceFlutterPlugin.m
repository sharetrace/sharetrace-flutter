#import "SharetraceFlutterPlugin.h"
#import <SharetraceSDK/SharetraceSDK.h>

@interface SharetraceFlutterPlugin ()<SharetraceDelegate>

@property (strong, nonatomic)FlutterMethodChannel * flutterMethodChannel;
@property (nonatomic, strong)NSDictionary *wakeUpTraceDict;
@property (nonatomic, assign)BOOL hasRegisterWakeUp;
@property (nonatomic, assign)BOOL hasInit;
@property (nonatomic, strong)NSURL *cacheSchemeLinkURL;
@property (nonatomic, strong)NSUserActivity *cacheUserActivity;

+ (id<SharetraceDelegate> _Nonnull)allocWithZone:(NSZone *_Nullable)zone;
@end

@implementation SharetraceFlutterPlugin

static NSString * const key_code = @"code";
static NSString * const key_msg = @"msg";
static NSString * const key_paramsData = @"paramsData";
static NSString * const key_channel = @"channel";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"sharetrace_flutter_plugin"
                                     binaryMessenger:[registrar messenger]];
    SharetraceFlutterPlugin* instance = [SharetraceFlutterPlugin allocWithZone:nil];
    [registrar addApplicationDelegate:instance];
    instance.flutterMethodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

+ (id)allocWithZone:(NSZone *)zone {
    static SharetraceFlutterPlugin *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
        sharedInstance.wakeUpTraceDict = [[NSDictionary alloc] init];
    });
    return sharedInstance;
}

+ (void)initSharetrace {
    SharetraceFlutterPlugin * _Nonnull module = [SharetraceFlutterPlugin allocWithZone:nil];
    if (module.hasInit) {
        return;
    }
    
    module.hasInit = YES;
    [Sharetrace initWithDelegate:module];
    
    if (module.cacheSchemeLinkURL != nil) {
        [Sharetrace handleSchemeLinkURL:module.cacheSchemeLinkURL];
        module.cacheSchemeLinkURL = nil;
    }
    
    if (module.cacheUserActivity != nil) {
        [Sharetrace handleUniversalLink:module.cacheUserActivity];
        module.cacheUserActivity = nil;
    }
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getInstallTrace" isEqualToString:call.method]) {
        [SharetraceFlutterPlugin initSharetrace];
        NSTimeInterval timeout = 10;
        if (call.arguments != nil) {
            id timeoutSeconds = call.arguments[@"timeoutSeconds"];
            if (timeoutSeconds != nil) {
                NSString *targetTime = [NSString stringWithString:timeoutSeconds];
                NSTimeInterval targetTimeInterval  = [targetTime doubleValue];
                if (targetTimeInterval > 0) {
                    timeout = targetTimeInterval;
                }
            }
        }
        NSTimeInterval targetTimeout = timeout * 1000;
        [Sharetrace getInstallTraceWithTimeout:targetTimeout success:^(AppData * _Nullable appData) {
            if (appData == nil) {
                NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:-1 :@"Extract data fail." :@"" :@""];
                [self response:ret];
                return;
            }

            NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:200 :@"Success" :appData.paramsData :appData.channel];
            [self response:ret];
        } fail:^(NSInteger code, NSString * _Nonnull msg) {
            NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:code :msg :@"" :@""];
            [self response:ret];
        }];
    } else if ([@"registerWakeup" isEqualToString:call.method]) {
        if (!self.hasRegisterWakeUp) {
            if (self.wakeUpTraceDict != nil && self.wakeUpTraceDict.count != 0) {
                [self wakeupResponse:self.wakeUpTraceDict];
                self.wakeUpTraceDict = nil;
            }
            self.hasRegisterWakeUp = YES;
        }
    } else if ([@"init" isEqualToString:call.method]) {
        [SharetraceFlutterPlugin initSharetrace];
    } else if ([@"disableClipboard" isEqualToString:call.method]) {
        [Sharetrace disableClipboard];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (void)response:(NSDictionary *) ret {
    [self.flutterMethodChannel invokeMethod:@"onInstallResponse" arguments:ret];
}

- (void)wakeupResponse:(NSDictionary *) ret {
    [self.flutterMethodChannel invokeMethod:@"onWakeupResponse" arguments:ret];
}

+ (NSDictionary*)parseToResultDict:(NSInteger)code :(NSString*)msg :(NSString*)paramsData :(NSString*)channel {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    dict[key_code] = [[NSNumber numberWithInteger:code] stringValue];
    dict[key_msg] = msg;
    dict[key_paramsData] = paramsData;
    dict[key_channel] = channel;

    return dict;
}

- (void)getWakeUpTrace:(AppData *)appData {
    if (appData == nil) {
        return;
    }
    
    NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:200 :@"Success" :appData.paramsData :appData.channel];
    
    if (self.hasRegisterWakeUp) {
        [self wakeupResponse:ret];
        self.wakeUpTraceDict = nil;
    } else {
        @synchronized(self) {
            self.wakeUpTraceDict = ret;
        }
    }
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)url {
    SharetraceFlutterPlugin * _Nonnull module = [SharetraceFlutterPlugin allocWithZone:nil];
    if (module.hasInit) {
        [Sharetrace handleSchemeLinkURL:url];
    } else {
        module.cacheSchemeLinkURL = url;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    SharetraceFlutterPlugin * _Nonnull module = [SharetraceFlutterPlugin allocWithZone:nil];
    if (module.hasInit) {
        [Sharetrace handleSchemeLinkURL:url];
    } else {
        module.cacheSchemeLinkURL = url;
    }
    return NO;
}

- (BOOL)application:(UIApplication*)application continueUserActivity:(NSUserActivity*)userActivity restorationHandler:(void (^)(NSArray*))restorationHandler {
    SharetraceFlutterPlugin * _Nonnull module = [SharetraceFlutterPlugin allocWithZone:nil];
    if (module.hasInit) {
        [Sharetrace handleUniversalLink:userActivity];
    } else {
        module.cacheUserActivity = userActivity;
    }
    return NO;
}

+ (BOOL)handleSchemeLinkURL:(NSURL * _Nullable)url {
    SharetraceFlutterPlugin * _Nonnull module = [SharetraceFlutterPlugin allocWithZone:nil];
    if (module.hasInit) {
        return [Sharetrace handleSchemeLinkURL:url];
    } else {
        module.cacheSchemeLinkURL = url;
        return NO;
    }
}

+ (BOOL)handleUniversalLink:(NSUserActivity * _Nullable)userActivity {
    SharetraceFlutterPlugin * _Nonnull module = [SharetraceFlutterPlugin allocWithZone:nil];
    if (module.hasInit) {
        return [Sharetrace handleUniversalLink:userActivity];
    } else {
        module.cacheUserActivity = userActivity;
        return NO;
    }
}

@end
