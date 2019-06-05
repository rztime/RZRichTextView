//
//  RZRichAlertViewCell.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/6/3.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichAlertViewCell.h"
#import <Masonry/Masonry.h>

#define defaultTextColor [UIColor colorWithRed:102/255.f green:102/255.f blue:102/255.f alpha:1]
@interface RZRichAlertViewCell()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel     *titleLabel;

@property (nonatomic, strong) UIView      *seqLine;

@property (nonatomic, strong) UIColor     *textColor;

@end

@implementation RZRichAlertViewCell

- (UIView *)seqLine {
    if (!_seqLine) {
        _seqLine = [[UIView alloc]init];
        [self.contentView addSubview:_seqLine];
        [_seqLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self.contentView);
            make.height.equalTo(@1);
        }];
        _seqLine.backgroundColor = rz_rgb(238, 238, 238);
        _seqLine.hidden = YES;
    }
    if (_type == RZRichAlertViewTypeList) {
        _seqLine.hidden = NO;
    } else {
        _seqLine.hidden = YES;
    }
    return _seqLine;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        [self.contentView addSubview:_titleLabel];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _textColor = defaultTextColor;
        _titleLabel.textColor = _textColor;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (void)setTitle:(NSDictionary *)title {
    _title = title;
    [self seqLine];
    
    NSString *titlestring;
    UIImage *image;
    UIColor *textColor;
    NSArray *keys = title.allKeys;
    for (id key in keys) {
        id value = [title objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            titlestring = value;
            continue;
        }
        if ([value isKindOfClass:[UIImage class]]) {
            image = value;
            continue;
        }
        if ([value isKindOfClass:[UIColor class]]) {
            textColor = value;
            continue;
        }
    }
    self.titleLabel.text = titlestring;
    if (textColor) {
        _textColor = textColor;
    } else {
        _textColor = defaultTextColor;
    }
    
    if (image) {
        self.imageView.image = image;
        if (_type == RZRichAlertViewTypeList) {
            [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@20);
                make.left.equalTo(self.contentView).offset(15);
                make.centerY.equalTo(self.contentView);
            }];
            
            [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.imageView.mas_right).offset(15);
                make.centerY.equalTo(self.imageView);
            }];
            _titleLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.width.height.equalTo(@45);
                make.centerX.equalTo(self.contentView);
                make.centerY.equalTo(self.contentView).offset(-10);
            }];
            [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.imageView.mas_bottom).offset(5);
                make.centerX.equalTo(self.imageView);
            }];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
        }
        
    } else {
        self.imageView.image = nil;
        [_imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@0);
        }];
        [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

- (void)setHightLight:(BOOL)hightLight {
    if (hightLight) {
        _titleLabel.textColor = self.hightLightTextColor;
    } else {
        _titleLabel.textColor = _textColor;
    }
}
@end
