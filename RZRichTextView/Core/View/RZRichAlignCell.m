//
//  RZRichAlignCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichAlignCell.h"

@implementation RZRichAlignCell

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    switch (self.viewModel.textModel.aligment) {
        case NSTextAlignmentLeft: {
            self.imageView.image = rz_rich_imageName(@"左对齐");
            break;
        }
        case NSTextAlignmentCenter: {
            self.imageView.image = rz_rich_imageName(@"中对齐");
            break;
        }
        case NSTextAlignmentRight: {
            self.imageView.image = rz_rich_imageName(@"右对齐");
            break;
        }
        default:
            break;
    }
    
}
- (void)viewDidClicked {
    UIWindow * window= [UIApplication sharedApplication].keyWindow;
    CGRect selfRect= [self convertRect: self.bounds toView:window];
    
    if (self.viewModel.rz_showAlignView) {
        self.viewModel.rz_showAlignView(selfRect.origin.x, NO);
    }
}
@end
