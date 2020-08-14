//
//  RZRTColorView.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/23.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface  RZRTColorCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton    *borderView;

@end

@interface RZRTColorView : UIView <RZRTViewDelegate>

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy) void(^didSelectedColor)(UIColor *color);

@end

NS_ASSUME_NONNULL_END
