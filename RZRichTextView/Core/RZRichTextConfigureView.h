//
//  RZRichTextConfigureView.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/29.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextViewModel.h"

@interface RZRichTextConfigureView : UIView

@property (nonatomic, strong) RZRichTextViewModel *viewModel;

@property (nonatomic, copy) void(^rz_insertImage)(UIImage *image);
@property (nonatomic, copy) void(^rz_changeRich)(BOOL changed);

@end
