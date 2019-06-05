//
//  RZRTSliderView.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRTSliderView.h"
#import <Masonry/Masonry.h>
#import "RZRichTextConfigureManager.h"

@implementation RZRTSliderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        self.slider = [[UISlider alloc] init];
        [self addSubview:self.slider];
        [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        self.minLabel = [[UILabel alloc] init];
        [self addSubview:self.minLabel];
        
        self.maxLabel = [[UILabel alloc] init];
        [self addSubview:self.maxLabel];
        
        self.minLabel.textAlignment = NSTextAlignmentCenter;
        self.maxLabel.textAlignment = NSTextAlignmentCenter;
        
        [self.minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self).offset(10);
            make.width.equalTo(@40);
        }];
        [self.maxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.right.equalTo(self).offset(-10);
            make.width.equalTo(@40);
        }];
        
        [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.minLabel.mas_right).offset(2);
            make.right.equalTo(self.maxLabel.mas_left).offset(-2);
            make.height.equalTo(@30);
        }];
        self.slider.maximumTrackTintColor = RZRichTextConfigureManager.manager.themeColor;
        self.slider.minimumTrackTintColor = RZRichTextConfigureManager.manager.themeColor;
        [self.slider setThumbImage:RZRichTextConfigureManager.manager.sliderImage forState:UIControlStateNormal];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.minLabel.text = [NSString stringWithFormat:@"%@", @(self.slider.minimumValue)];
    self.maxLabel.text = [NSString stringWithFormat:@"%@", @(self.slider.maximumValue)];
}

- (void)sliderValueChanged:(UISlider *)sender {
    if (self.valueChanged) {
        self.valueChanged(sender.value);
    }
}

- (CGFloat)viewHeight {
    return 50;
}

@end
