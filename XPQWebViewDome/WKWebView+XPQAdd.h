//
//  WKWebView+XPQAdd.h
//  XPQWebViewDome
//
//  Created by apple on 2017/1/1.
//  Copyright © 2017年 XPQ. All rights reserved.
//

#import <WebKit/WebKit.h>

/*
 * 解决WKWebView截屏白屏BUG
 */
@interface WKWebView (Capture)
/*
 *  获取WKWebView的截屏
 */
- (UIImage *)getCaptureImage;
@end

/*
 * 解决WKWebView注册JS方法后内存泄漏BUG
 */
@interface WKWebView (RegisterScript)
/*
 *  添加脚本方法
 */
- (void)addScriptName:(NSString *)name andDelegate:(id<WKScriptMessageHandler>)delegate;
/*
 *  移除脚本方法
 */
- (void)removeScriptName:(NSString *)name;
@end

@interface WKWebView (callJS)

/*
 *  根据js方法名和参数拼接成js代码
 *  @param  method 方法名
 *  @param  ...  参数，支持类型有NSString/NSNumber/NSArray/NSDictionry。必须以nil结尾，不然会报错。
 *  @return 拼接好后的JS代码
 */
+ (NSString *)jsCodeWithMethodName:(NSString *)method, ...;

@end

/*
 *  js方法字符串参数对' " \转义
 */
NSString* jsStrConver(NSString *str);
