//
//  ViewController.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "ViewController.h"
#import "RZRichTextView.h"
#import <RZColorful/RZColorful.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    RZRichTextView *view = [[RZRichTextView alloc] initWithFrame:CGRectMake(10, 100, 300, 300)];
    view.backgroundColor = [UIColor grayColor];
    view.rz_didChangedText = ^(RZRichTextView * _Nonnull textView) {
        NSLog(@"text:%@",textView.text);
    };
    [self.view addSubview:view];
}


@end
