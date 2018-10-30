//
//  RZColoseKeyBoardView.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZColoseKeyBoardView.h"
#import "RZDefine.h"
#import <Masonry/Masonry.h>

@interface RZColoseKeyBoardView ()

@property (nonatomic, strong) UIButton *button;

@end

@implementation RZColoseKeyBoardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setImage:rz_rich_imageName(@"键盘") forState:UIControlStateNormal];
        [self addSubview:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) { 
            make.edges.equalTo(self);
        }];
        
        [self.button addTarget:self action:@selector(closeKeyboard) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)closeKeyboard {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

@end
