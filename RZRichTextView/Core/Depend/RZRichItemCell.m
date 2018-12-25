//
//  RZRichItemCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/18.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichItemCell.h" 
#import <Masonry/Masonry.h>

@interface RZRichItemCell ()

@end

@implementation RZRichItemCell

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        [self.contentView addSubview:_label];
        _label.textAlignment = NSTextAlignmentCenter;
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return _label;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@20);
        }];
        _imageView.layer.borderColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
        _imageView.layer.borderWidth = 0.3;
    }
    return _imageView;
}
@end
