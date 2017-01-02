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

#import "UIButton+WebCache.h"

#import <WebKit/WebKit.h>

#define BarButtonTag        7000

@interface XPQWebViewController () <WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, strong) NSDictionary *configDict;

/// navigationItem按钮的回调JS
@property (nonatomic, strong) NSMutableArray<NSString *> *barButtonBackCallArr;

@end

/// js注册名称和调用方法
static NSDictionary *s_jsMethod = nil;
///
static NSDictionary *s_controllerStyle = nil;

@implementation XPQWebViewController

+ (void)load {
    s_jsMethod = @{
#ifdef DEBUG
                   /* 打印日志 */
                   @"log":@"jsLog:",
#endif
                   /* 更新配置内容 */
                   @"update":@"jsUpdate:",
                   /* push视图控制器 */
                   @"push":@"jsPush:"
                   };
    
    s_controllerStyle = @{
            /* (NSString) 视图控制器标题。 */
            @"title":@"jsUpdateTitle:",
            
//            /* (NSDictionary *)视图控制器标题样式，可以指定字体，文字颜色，阴影等，键值参考'NSAttributedString.h'。 */
//            @"titleTextAttributes":@"jsUpdateTitleTextAttributes:",
            
            /* (NSNumer或NSDictionary) 头部颜色。 */
            @"navigationColor":@"jsUpdateNavigationColor:",
            
            /* (NSString) 返回按钮文本。只在父控制视图设置才生效，并且只要有leftButton则会覆盖backButton */
            @"backButtonText":@"jsUpdateBackButton:",
            /* (NSArray<NSDictionary>或NSDictionary) navigation左侧按钮，一个或者多个。覆盖bcakButton。
             *  键值：text:按钮文本; icon:按钮图标; systemStyle:系统图标按钮; backCall:回调函数名;
             *  具体参考 -barButtonWithJsData:
             */
            @"leftButton":@"jsUpdateLeftButton:",
            /* (NSArray<NSDictionary>或NSDictionary) navigation右侧按钮，格式同leftButton。 */
            @"rightButton":@"jsUpdateRightButton:"
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
    _barButtonBackCallArr = [NSMutableArray array];
    if (_configDict) {
        [self jsUpdate:_configDict];
    }
    
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
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

#pragma mark - jsLog
#ifdef DEBUG
- (void)jsLog:(id)data {
    NSLog(@"%@", data);
}
#endif

#pragma mark - jsUpdate
- (void)jsUpdate:(NSDictionary *)data {
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

/*  
 *  更新标题
 *  @param data NSString类型。
 */
- (void)jsUpdateTitle:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        self.navigationItem.title = data;
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateTitle:'参数格式错误，正确格式为NSString");
    }
}

/*
 *  更新标题样式(暂未实现)
 *  @param data
 */
- (void)jsUpdateTitleTextAttributes:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        self.navigationController.navigationBar.titleTextAttributes = data;
    }
}

/*  
 *  更新头部背景色
 *  @param data NSDictionary或NSNumber类型。NSDictionary的键值为{"red","green","blue","alphe"}
 */
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

/*  
 *  设置返回按钮文本
 *  @param data NSString类型。
 */
- (void)jsUpdateBackButton:(id)data {
    if ([data isKindOfClass:[NSString class]]) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:data style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateBackButton:'参数格式错误，正确格式为NSString");
    }
}

/*
 *  更新左侧按钮
 *  @param data 有效类型为NSDictionary和NSArray<NSDictionary *>。
                类型为NSDictionary则只一个按钮，如果为NSArray则按钮个数与数组长度相当。
                NSDictionary中的键值关系请参考 -barButtonWithJsData:
*/
- (void)jsUpdateLeftButton:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        self.navigationItem.leftBarButtonItem = [self barButtonWithJsData:data];
    }
    else if ([data isKindOfClass:[NSArray<NSDictionary *> class]]) {
        NSMutableArray *buttons = [NSMutableArray array];
        for (NSDictionary *dict in data) {
            [buttons addObject:[self barButtonWithJsData:dict]];
        }
        self.navigationItem.leftBarButtonItems = buttons;
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateLeftButton:'参数格式错误，正确格式为NSDictionary或者NSArray<NSDictionary *>");
    }
}

/*
 *  更新右侧按钮
 *  @param data 有效类型为NSDictionary和NSArray<NSDictionary *>。
                类型为NSDictionary则只一个按钮，如果为NSArray则按钮个数与数组长度相当。
                NSDictionary中的键值关系请参考 -barButtonWithJsData:
 */
- (void)jsUpdateRightButton:(id)data {
    if ([data isKindOfClass:[NSDictionary class]]) {
        self.navigationItem.rightBarButtonItem = [self barButtonWithJsData:data];
    }
    else if ([data isKindOfClass:[NSArray<NSDictionary *> class]]) {
        NSMutableArray *buttons = [NSMutableArray array];
        for (NSDictionary *dict in data) {
            [buttons addObject:[self barButtonWithJsData:dict]];
        }
        self.navigationItem.rightBarButtonItems = buttons;
    }
    else {
        NSLog(@"XPQWebViewController waring:'jsUpdateLeftButton:'参数格式错误，正确格式为NSDictionary或者NSArray<NSDictionary *>");
    }
}

/*
 *  根据数据生成barButton。
 *  @param data 按钮相关数据。
                |    key      |        type       |              explain          |
                | systemStyle | NSNumber/NSString | 生成系统自带图标按钮，            |
                |             |                   | 传UIBarButtonSystemItem的枚举值 |
                |    icon     |      NSString     | 传图片URL生成一个图标按钮         |
                |    text     |      NSString     | 生成一个文本按钮                 |
                |  backCall   |      NSString     | 按钮回调JS代码                  |
 */
- (UIBarButtonItem *)barButtonWithJsData:(NSDictionary *)data {
    if (data[@"systemStyle"]
        && ([data[@"systemStyle"] isKindOfClass:[NSNumber class]] || [data[@"systemStyle"] isKindOfClass:[NSString class]])) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:[data[@"systemStyle"] integerValue] target:self action:@selector(clickBarButton:)];
        if (data[@"backCall"] && [data[@"backCall"] isKindOfClass:[NSString class]]) {
            button.tag = BarButtonTag + _barButtonBackCallArr.count;
            [_barButtonBackCallArr addObject:data[@"backCall"]];
        }
        return button;
    }
    else if (data[@"icon"] && [data[@"icon"] isKindOfClass:[NSString class]]) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        [button sd_setImageWithURL:[NSURL URLWithString:data[@"icon"]] forState:UIControlStateNormal];
        if (data[@"backCall"] && [data[@"backCall"] isKindOfClass:[NSString class]]) {
            [button addTarget:self action:@selector(clickBarButton:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = BarButtonTag + _barButtonBackCallArr.count;
            [_barButtonBackCallArr addObject:data[@"backCall"]];
        }
        return [[UIBarButtonItem alloc] initWithCustomView:button];
    }
    else if (data[@"text"] && [data[@"text"] isKindOfClass:[NSString class]]) {
        UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:data[@"text"] style:UIBarButtonItemStylePlain target:self action:@selector(clickBarButton:)];
        if (data[@"backCall"] && [data[@"backCall"] isKindOfClass:[NSString class]]) {
            button.tag = BarButtonTag + _barButtonBackCallArr.count;
            [_barButtonBackCallArr addObject:data[@"backCall"]];
        }
        return button;
    }
    else {
        return nil;
    }
}

- (void)clickBarButton:(id)sender {
    NSString *jsName = _barButtonBackCallArr[[sender tag] - BarButtonTag];
    [_webView evaluateJavaScript:jsName completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if (error) {
            NSLog(@"XPQWebViewController waring:UIBarButtonItem回调JS失败，%@", error);
        }
    }];
}

#pragma mark - jsPush
- (void)jsPush:(NSDictionary *)data {
    if ([data isKindOfClass:[NSDictionary class]] && data[@"url"]) {
        NSURL *url = [NSURL URLWithString:data[@"url"]];
        XPQWebViewController *vc = [[XPQWebViewController alloc] initWithUrl:url];
        if (data[@"config"] && [data[@"config"] isKindOfClass:[NSDictionary class]]) {
            if (data[@"config"][@"backButton"]) {
                [self jsUpdateBackButton:data[@"config"][@"backButtonText"]];
            }
            vc.configDict = data[@"config"];
        }
        [self.navigationController pushViewController:vc animated:YES];
    }
}
@end
