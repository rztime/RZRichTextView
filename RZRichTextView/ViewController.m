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
}

@end
