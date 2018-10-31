//
//  ViewController.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/29.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "ViewController.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "RZRichTextView.h"

@interface ViewController () <UITextViewDelegate>

@property (nonatomic, strong) RZRichTextView *textView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [IQKeyboardManager sharedManager].enable = YES;
    
    _textView = [[RZRichTextView alloc] initWithFrame:CGRectMake(10, 100, UIScreen.mainScreen.bounds.size.width - 20, UIScreen.mainScreen.bounds.size.height - 100 - 66)];
    _textView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    [self.view addSubview:_textView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"获取图片" style:UIBarButtonItemStylePlain target:self action:@selector(getImages)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"获取html" style:UIBarButtonItemStylePlain target:self action:@selector(getHtml)];
}

- (void)getImages {
    NSArray *array = [self.textView rz_rictTextImages];
    NSLog(@"ar:%@", array);
}
- (void)getHtml {
    // 地址和上边rz_rictTextImages 顺序要一一对应
    NSString *text = [self.textView rz_codingToHtmlWithImageURLS:@[@"图片1地址", @"图片2地址", @"图片3地址"]];
    NSLog(@"ar:%@", text);
}
@end
