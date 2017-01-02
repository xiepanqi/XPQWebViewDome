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
