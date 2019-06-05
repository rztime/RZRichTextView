//
//  RZRichTextInputFontColorCell.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichTextInputFontColorCell.h"
#import <Masonry/Masonry.h>

@implementation RZRichTextInputFontColorCell
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.centerY.equalTo(self.contentView).offset(-2);
            make.width.height.equalTo(@20);
        }];
    }
    return _imageView;
}

- (UIImageView *)colorImageView {
    if (!_colorImageView) {
        _colorImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_colorImageView];
        _colorImageView.layer.cornerRadius = 2;
        _colorImageView.layer.masksToBounds = YES;
        [_colorImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.contentView);
            make.top.equalTo(self.imageView.mas_bottom);
            make.width.equalTo(@20);
            make.height.equalTo(@4);
        }];
    }
    return _colorImageView;
}
@end
