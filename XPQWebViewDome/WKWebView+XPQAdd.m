//
//  WKWebView+XPQAdd.m
//  XPQWebViewDome
//
//  Created by apple on 2017/1/1.
//  Copyright © 2017年 XPQ. All rights reserved.
//

#import "WKWebView+XPQAdd.h"

@implementation WKWebView (XPQAdd)

- (UIImage *)getCaptureImage {
    UIGraphicsBeginImageContext(self.frame.size);
    for(UIView *subview in self.subviews) {
        [subview drawViewHierarchyInRect:subview.bounds afterScreenUpdates:YES];
    }
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef ref = CGImageCreateWithImageInRect(img.CGImage, self.bounds);
    UIImage *CGImg = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    return CGImg;
}

@end



@interface WeakScriptMessageDelegate : NSObject<WKScriptMessageHandler>
@property (nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;
@end
@implementation WeakScriptMessageDelegate
- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
    self = [super init];
    if (self) {
        _scriptDelegate = scriptDelegate;
    }
    return self;
}
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
}
@end

@implementation WKWebView (RegisterScript)
- (void)addScriptName:(NSString *)name andDelegate:(id<WKScriptMessageHandler>)delegate {
    [self.configuration.userContentController addScriptMessageHandler:[[WeakScriptMessageDelegate alloc] initWithDelegate:delegate] name:name];
}

- (void)removeScriptName:(NSString *)name {
    [self.configuration.userContentController removeScriptMessageHandlerForName:name];
}
@end
