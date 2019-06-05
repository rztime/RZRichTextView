//
//  RZRTShadowView.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/27.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRTShadowView.h"
#import "RZRTSliderView.h"
#import "RZRTColorView.h"
#import <Masonry/Masonry.h>
#import "RZRichTextConstant.h"

@interface RZRTShadowView ()

@property (nonatomic, assign) NSInteger x;
@property (nonatomic, assign) NSInteger y;
@property (nonatomic, assign) NSInteger r;
@property (nonatomic, strong) UIColor *color;

@property (nonatomic, strong) UIView *xyView;
@property (nonatomic, strong) RZRTSliderView *xSlider;
@property (nonatomic, strong) RZRTSliderView *ySlider;
@property (nonatomic, strong) RZRTSliderView *rSlider;
@property (nonatomic, strong) RZRTColorView  *colorView;

@property (nonatomic, strong) UILabel *xyLabel;
@property (nonatomic, strong) UILabel *rLabel;
@end

@implementation RZRTShadowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _xyView = [[UIView alloc] init];
        [self addSubview:_xyView];
        
        _xSlider = [[RZRTSliderView alloc] init];
        [_xyView addSubview:_xSlider];
     
        _ySlider = [[RZRTSliderView alloc] init];
        [_xyView addSubview:_ySlider];
        
        _rSlider = [[RZRTSliderView alloc] init];
        [self addSubview:_rSlider];
        
        _xyLabel = [[UILabel alloc] init];
        [self addSubview:_xyLabel];
        
        _rLabel = [[UILabel alloc] init];
        [self addSubview:_rLabel];
        
        _colorView = [[RZRTColorView alloc] init];
        [self addSubview:_colorView];
        
        CGFloat margin = 0;
   
        [_xSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.xyView).offset(margin);
            make.right.equalTo(self.xyView).offset(-margin);
            make.top.equalTo(self.xyView);
            make.height.equalTo(@(self.xSlider.viewHeight));
        }];
        
        [_ySlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.xSlider);
            make.top.equalTo(self.xSlider.mas_bottom);
            make.height.equalTo(self.xSlider);
            make.bottom.equalTo(self.xyView);
        }];
        
        [_rSlider mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.xyView);
            make.left.equalTo(self.xyView.mas_right).offset(margin);
            make.right.equalTo(self).offset(-margin);
            make.height.equalTo(self.xSlider);
        }];
        
        [self.xyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self);
            make.right.equalTo(self.mas_centerX);
            make.height.equalTo(@(2 * self.xSlider.viewHeight));
        }];
        
        [_xyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.xyView);
            make.top.equalTo(self.xyView.mas_bottom);
            make.height.equalTo(@20);
        }];
        
        [_rLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.rSlider);
            make.centerY.equalTo(self.xyLabel);
            make.height.equalTo(@20);
        }];
        
        [self.colorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(margin);
            make.right.equalTo(self).offset(-margin);
            make.top.equalTo(self.xyLabel.mas_bottom);
            make.height.equalTo(@(self.colorView.viewHeight));
            make.bottom.equalTo(self);
        }];
        
        [self setSliderViewChanged];
    }
    return self;
}

- (CGFloat)viewHeight {
    return _xSlider.viewHeight * 2 + _colorView.viewHeight + 20;
}

- (void)setslider:(RZRTSliderView *)slider min:(NSInteger)min max:(NSInteger)max def:(NSInteger)value{
    slider.slider.minimumValue = min;
    slider.slider.maximumValue = max;
    slider.slider.value = value;
}

- (void)setShadow:(NSShadow *)shadow {
    _shadow = shadow;
    self.x = self.shadow.shadowOffset.width;
    self.y = self.shadow.shadowOffset.height;
    self.r = (NSInteger)self.shadow.shadowBlurRadius;
    self.color = self.shadow.shadowColor;
    self.colorView.color = self.color;
    
    [self setslider:_xSlider min:-100 max:100 def:self.x];
    [self setslider:_ySlider min:-100 max:100 def:self.y];
    [self setslider:_rSlider min:0 max:20 def:self.r];
    
    [self valueChanged];
}

- (void)setSliderViewChanged {
    rz_weakObj(self);
    self.xSlider.valueChanged = ^(CGFloat value) {
        selfWeak.x = (NSInteger)value;
        [selfWeak valueChanged];
    };
    self.ySlider.valueChanged = ^(CGFloat value) {
        selfWeak.y = (NSInteger)value;
        [selfWeak valueChanged];
    };
    self.rSlider.valueChanged = ^(CGFloat value) {
        selfWeak.r = (NSInteger)value;
        [selfWeak valueChanged];
    };
    
    self.colorView.didSelectedColor = ^(UIColor * _Nonnull color) {
        selfWeak.color = color;
        [selfWeak valueChanged];
    };
}

- (void)valueChanged {
    self.xyLabel.text = [NSString stringWithFormat:@"位置偏移:(%@, %@)", @(self.x), @(self.y)];
    self.rLabel.text = [NSString stringWithFormat:@"阴影大小:%@", @(self.r)];
    self.shadow.shadowOffset = CGSizeMake(self.x, self.y);
    self.shadow.shadowBlurRadius = self.r;
    self.shadow.shadowColor = self.color;
    if (self.didChangeShadow) {
        self.didChangeShadow(self.shadow);
    }
}

@end
