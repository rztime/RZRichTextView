//
//  RZFontConfigureView.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextViewModel.h"

@interface RZFontConfigureView : UIView

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RZRichTextViewModel *)viewModel locationX:(CGFloat)locationX;

@end
