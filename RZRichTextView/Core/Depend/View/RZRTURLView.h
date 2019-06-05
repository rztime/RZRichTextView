//
//  RZRTURLView.h
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/29.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RZRTURLView : UIView <RZRTViewDelegate>

@property (nonatomic, copy) NSAttributedString *urlString;

@property (nonatomic, copy) void(^didURLEditComplete)(NSAttributedString *urlString);

@end

NS_ASSUME_NONNULL_END
