//
//  RZRichAlertViewCell.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/6/3.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextConstant.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRichAlertViewCell : UICollectionViewCell

@property (nonatomic, assign) RZRichAlertViewType type;

@property (nonatomic, strong) NSDictionary *title;

@property (nonatomic, assign) BOOL hightLight;
@property (nonatomic, strong) UIColor *hightLightTextColor;

@end

NS_ASSUME_NONNULL_END
