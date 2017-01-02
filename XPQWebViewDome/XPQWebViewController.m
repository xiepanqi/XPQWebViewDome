//
//  XPQWebViewController.m
//  XPQWebViewDome
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 XPQ. All rights reserved.
//

#import "XPQWebViewController.h"

#import "WKWebView+XPQAdd.h"
#import "UIColor+XPQAdd.h"
#import <WebKit/WebKit.h>

/// (NSString *)视图控制器标题。
#define kXPQWebViewControllerTitle                  @"title"
///// (NSDictionary *)视图控制器标题样式，可以指定字体，文字颜色，阴影等，键值参考'NSAttributedString.h'
//#define kXPQWebViewControllerTitleTextAttributes    @"titleTextAttributes"
/// (NSNumer 或 NSDictionary)
#define kXPQWebViewControllerNavigationColor        @"navigationColor"

/* (NSArray<NSDictionary *>* 或者 NSDictionary) navigation左侧按钮，一个或者多个。
 *  键值：text:按钮文本; icon:按钮图标; backCall:回调函数名;
 */
#define kXPQWebViewControllerLeftButton             @"leftButton"

@interface XPQWebViewController () <WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

/// js注册名称和调用方法
static NSDictionary *s_jsMethod = nil;
///
static NSDictionary *s_controllerStyle = nil;

@implementation XPQWebViewController

+ (void)load {
    s_jsMethod = @{
#ifdef DEBUG
                   @"log":@"jsLog:",
#endif
                   @"update":@"updateController:"
                   };
    
    s_controllerStyle = @{
            /* (NSString *)视图控制器标题。 */
            @"title":@"jsUpdateTitle:",
            
//            /* (NSDictionary *)视图控制器标题样式，可以指定字体，文字颜色，阴影等，键值参考'NSAttributedString.h'。 */
//            @"titleTextAttributes":@"jsUpdateTitleTextAttributes:",
            
            /* (NSNumer 或 NSDictionary)头部颜色。 */
            @"navigationColor":@"jsUpdateNavigationColor:",
            
            /* (NSArray<NSDictionary *>* 或者 NSDictionary) navigation左侧按钮，一个或者多个。
             *  键值：text:按钮文本; icon:按钮图标; backCall:回调函数名;
             */
            @"leftButton":@"jsUpdateLeftButton:"
                          };
}

- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

- (void)dealloc {
    for (NSString *methodName in s_jsMethod.allKeys) {
        [_webView removeScriptName:methodName];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    _webView.navigationDelegate = self;
    for (NSString *methodName in s_jsMethod.allKeys) {
        [_webView addScriptName:methodName andDelegate:self];
    }
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:_url]];
    
//    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.absoluteString hasPrefix:@"push:"]) {
        decisionHandler(WKNavigationActionPolicyCancel);
        NSString *urlStr = [navigationAction.request.URL.absoluteString substringFromIndex:5];
        XPQWebViewController *vc = [[XPQWebViewController alloc] initWithUrl:[NSURL URLWithString:urlStr]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"加载完成");
}


#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if (s_jsMethod[message.name]) {
        SEL method = NSSelectorFromString(s_jsMethod[message.name]);
        if ([self respondsToSelector:method]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [self performSelector:method withObject:message.body];
#pragma clang diagnostic pop
        }
        else {
            NSLog(@"XPQWebViewController error:'%@'未实现", s_jsMethod[message.name]);
            NSAssert(NO, @"ERROR:'%@'未实现", s_jsMethod[message.name]);
        }
    }
}

#pragma mark - s_jsMethod
#ifdef DEBUG
- (void)jsLog:(id)data {
    NSLog(@"%@", data);
}
#endif

- (void)updateController:(NSDictionary *)data {
    if (![data isKindOfClass:[NSDictionary class]]) {
        NSLog(@"XPQWebViewController error:更新控制器数据格式错误。");
        return;
    }
    
    [data enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if (s_controllerStyle[key]) {
            SEL method = NSSelectorFromString(s_controllerStyle[key]);
            if ([self respondsToSelector:method]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [self performSelector:method withObject:obj];
#pragma clang diagnostic pop
            }
            else {
                NSLog(@"XPQWebViewController error:'%@'未实现", s_controllerStyle[key]);
                NSAssert(NO, @"ERROR:'%@'未实现", s_controllerStyle[key]);
            }
        }
        else {
            NSLog(@"XPQWebViewController waring:s_controllerStyle 不包含'%@'这建值", key);
        }
    }];
}

/// 更新标题
- (void)jsUpdateTitle:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        self.navigationItem.title = data;
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateTitle:'参数格式错误，正确格式为NSString");
    }
}

/// 更新标题样式
- (void)jsUpdateTitleTextAttributes:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        self.navigationController.navigationBar.titleTextAttributes = data;
    }
}

/// 更新头部背景色
- (void)jsUpdateNavigationColor:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithDictionary:data]];
    }
    else if ([data isKindOfClass:[NSNumber class]]) {
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRGBValue:[data unsignedIntValue]]];
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateNavigationColor:'参数格式错误，正确格式为NSDictionary或者NSNumber");
    }
}

/// 更新左侧按钮
- (void)jsUpdateLeftButton:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:data[@"text"] style:UIBarButtonItemStylePlain target:self action:@selector(clickButton:)];
        self.navigationItem.leftBarButtonItem = button;
    }
    else if ([data isKindOfClass:[NSArray<NSDictionary *> class]]) {
        
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateLeftButton:'参数格式错误，正确格式为NSDictionary或者NSArray<NSDictionary *>");
    }
}

- (void) clickButton:(id)sender {
    
}
@end
