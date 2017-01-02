//
//  ViewController.m
//  XPQWebViewDome
//
//  Created by apple on 2016/12/29.
//  Copyright © 2016年 XPQ. All rights reserved.
//

#import "ViewController.h"
#import "XPQWebViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickButton:(UIButton *)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"html"];
    NSURL *fileURL = [NSURL fileURLWithPath:path];
    XPQWebViewController *vc = [[XPQWebViewController alloc] initWithUrl:fileURL];
    [self.navigationController pushViewController:vc animated:YES];
//    [self presentViewController:vc animated:YES completion:nil];
}

@end
