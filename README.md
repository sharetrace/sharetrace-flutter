# sharetrace_flutter_plugin

请先从[ShareTrace控制台](https://www.sharetrace.com/)获取`AppKey`

### 一、安装

#### 1.1 添加依赖

在项目的pubspec.yaml文件中添加以下内容:

``` xml
dependencies:
  sharetrace_flutter_plugin: ^1.3.0
```

#### 1.2 安装

通过命令行安装

```cmd
flutter pub get
```

### 二、配置

#### Android配置
找到项目的`AndroidManifest.xml`文件，在`<application>...</application>`中增加以下配置

```xml
<meta-data 
	android:name="com.sharetrace.APP_KEY"
	android:value="SHARETRACE_APPKEY"/>
```

> **请将 SHARETRACE_APPKEY 替换成 sharetrace 为应用分配的 appkey**

#### iOS配置
在Info.plist中增加以下配置

```xml
	<key>com.sharetrace.APP_KEY</key>
	<string> SHARETRACE_APPKEY </string>
```
> **请将 SHARETRACE_APPKEY 替换成 sharetrace 为应用分配的 appkey**

### 三、获取安装携带的参数

#### 3.1. 导入接口定义

```dart
import 'package:sharetrace_flutter_plugin/sharetrace_flutter_plugin.dart';
```

#### 3.2. 定义结果回调

```dart
  Future responseHandler(Map<String, String> data) async {
    setState(() {
      result = "getInstallTrace: \n\n"
           + "code= " + data['code'] + "\n"
           + "msg= " + data['msg'] + "\n"
           + "paramsData= " + data['paramsData'] + "\n"
           + "channel= " + data['channel'];
    });
  }
```

#### 3.3. 请求获取参数
```dart
    SharetraceFlutterPlugin _sharetraceFlutterPlugin = SharetraceFlutterPlugin.getInstance();
    _sharetraceFlutterPlugin.getInstallTrace(responseHandler);
```
### 四、一键调起

Sharetrace支持通过标准的Scheme和Universal Links(iOS>=9)，接入Sharetrace SDK后，在各种浏览器，包括微信，微博等内置浏览器一键调起app，并传递网页配置等自定义动态参数。配置只需简单几个步骤即可，如下：

#### 4.1 开启一键调起功能
登录Sharetrace的管理后台，找到iOS配置，开启相关功能和填入配置
![5_apple_config_on.png](https://res.sharetrace.com/img/5_apple_config_on.png)

其中Team Id可以在[Apple开发者](https://developer.apple.com/account/#/membership/)后台查看

#### 4.2 开启Associated Domains服务

##### 方法一（推荐）：Xcode一键开启

（这里以Xcode 12为例，其他Xcode版本类似)

![5_1_domains.png](https://res.sharetrace.com/img/5_1_domains.png)

在如下图所示位置填入Sharetrace后台提供的applinks

![5_applinks_value.png](https://res.sharetrace.com/img/5_applinks_value.png)


##### 方法二：通过Apple开发者管理后台手动开启

登录到[Apple管理后台](https://developer.apple.com/account),在Identifiers找到所需开启到App ID

![5_apple_dev_config.png](https://res.sharetrace.com/img/5_apple_dev_config.png)


#### 4.3 Scheme配置

找到项目Info配置，填入后台分配的Scheme, 如下图:

![ios_scheme_value.png](https://res.sharetrace.com/img/ios_scheme_value.png)

#### 4.4 代码配置

##### iOS 配置
找到AppDelegate文件，参考以下配置

**Objective-C**
``` objc
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
    [SharetraceFlutterPlugin handleUniversalLink:userActivity];

    //其他代码
    return YES;
}

//iOS9以下 Scheme
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    [SharetraceFlutterPlugin handleSchemeLinkURL:url];

    //其他代码
    return YES;
}

//iOS9以上 Scheme
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(nonnull NSDictionary *)options {
    [SharetraceFlutterPlugin handleSchemeLinkURL:url];
    
    //其他代码
    return YES;
}

@end
```

**Swift**
``` swift
import UIKit
import Flutter
import sharetrace_flutter_plugin

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        SharetraceFlutterPlugin.handleSchemeLinkURL(url)
        return true
    }

    override func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        SharetraceFlutterPlugin.handleSchemeLinkURL(url)
        return true
    }

    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        SharetraceFlutterPlugin.handleUniversalLink(userActivity)
        return true
    }
}
```

#### 4.5 获取一键调起参数
``` dart
class _MyAppState extends State<MyApp> {
  String result;
  SharetraceFlutterPlugin _sharetraceFlutterPlugin;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    _sharetraceFlutterPlugin = SharetraceFlutterPlugin.getInstance();
    _sharetraceFlutterPlugin.registerWakeupHandler(wakeupHandler);

    setState(() {
      result = "";
    });
  }

  Future wakeupHandler(Map<String, String> data) async {
    setState(() {
      result = "wakeupTrace: \n\n"
          + "code= " + data['code'] + "\n"
          + "msg= " + data['msg'] + "\n"
          + "paramsData= " + data['paramsData'] + "\n"
          + "channel= " + data['channel'];
    });
  }

}
```

### 五、配置安装方式
SDK 集成完成后，按照`sharetrace`控制台接入流程完成后续的配置。

