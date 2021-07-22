//
//  RZRichTextInputAVCell.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichTextInputAVCell.h"
#import <Masonry/Masonry.h>

@implementation RZRichTextInputAVCell

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
            make.width.height.equalTo(@28);
        }];
    }
    return _imageView;
}

@end
