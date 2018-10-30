//
//  RZRichSelectionCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichSelectionCell.h"
#import <Masonry/Masonry.h>

@interface RZRichSelectionCell ()

@property (nonatomic, strong) UIButton *btn;

@end

@implementation RZRichSelectionCell


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.btn];
        [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [self.btn addTarget:self action:@selector(viewDidClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
- (void)viewDidClicked {
    
}
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView]; 
        
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return _imageView;
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        [self.contentView addSubview:_textLabel];
        _textLabel.font = [UIFont systemFontOfSize:11];
        _textLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1];
        [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.equalTo(self.contentView);
            make.height.equalTo(self.contentView);
        }];
        _textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _textLabel;
}



@end
