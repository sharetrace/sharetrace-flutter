#import "SharetraceFlutterPlugin.h"
#import <SharetraceSDK/SharetraceSDK.h>

@interface SharetraceFlutterPlugin ()<SharetraceDelegate>

@property (strong, nonatomic) FlutterMethodChannel * flutterMethodChannel;

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
    SharetraceFlutterPlugin* instance = [[SharetraceFlutterPlugin alloc] init];
    instance.flutterMethodChannel = channel;
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [Sharetrace initWithDelegate:self];
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"getInstallTrace" isEqualToString:call.method]) {
        [Sharetrace getInstallTrace:^(AppData * _Nullable appData) {
            if (appData == nil) {
                NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:-1 :@"Extract data fail." :@"" :@""];
                [self response:ret];
                return;
            }

            NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:200 :@"Success" :appData.paramsData :appData.channel];
            [self response:ret];

        } :^(NSInteger code, NSString * _Nonnull msg) {
            NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:code :msg :@"" :@""];
            [self response:ret];
        }];
    } else if ([@"registerWakeup" isEqualToString:call.method]) {
        
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
    if (appData != nil) {
        NSDictionary *ret = [SharetraceFlutterPlugin parseToResultDict:200 :@"Success" :appData.paramsData :appData.channel];
        [self wakeupResponse:ret];
    }
}

+ (BOOL)handleSchemeLinkURL:(NSURL * _Nullable)url {
    return [Sharetrace handleSchemeLinkURL:url];
}

+ (BOOL)handleUniversalLink:(NSUserActivity * _Nullable)userActivity {
    return [Sharetrace handleUniversalLink:userActivity];
}

@end
