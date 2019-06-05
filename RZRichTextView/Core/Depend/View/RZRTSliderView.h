//
//  RZRTSliderView.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/22.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRTSliderView : UIView <RZRTViewDelegate>

@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UILabel *minLabel;
@property (nonatomic, strong) UILabel *maxLabel;

@property (nonatomic, copy) void(^valueChanged)(CGFloat value);
@end

NS_ASSUME_NONNULL_END
