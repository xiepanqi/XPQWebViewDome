//
//  XPQWebViewController.h
//  XPQWebViewDome
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 XPQ. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 *  依赖第三方开源库：SDWebImage(https://github.com/rs/SDWebImage)
 */
@interface XPQWebViewController : UIViewController

- (instancetype)initWithUrl:(NSURL *)url;

@property (nonatomic, strong) NSURL *url;

@end
