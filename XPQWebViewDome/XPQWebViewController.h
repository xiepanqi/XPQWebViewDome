//
//  XPQWebViewController.h
//  XPQWebViewDome
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 XPQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XPQWebViewController : UIViewController

- (instancetype)initWithUrl:(NSURL *)url;

@property (nonatomic, strong) NSURL *url;

@end
