//
//  RZRTShadowView.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/27.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRTShadowView : UIView <RZRTViewDelegate>

@property (nonatomic, strong) NSShadow *shadow;
@property (nonatomic, copy) void(^didChangeShadow)(NSShadow *shadow);

@end

NS_ASSUME_NONNULL_END
