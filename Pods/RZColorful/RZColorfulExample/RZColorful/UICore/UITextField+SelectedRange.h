//
//  UITextField+SelectedRange.h
//  RZColorfulExample
//
//  Created by rztime on 2017/11/16.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (SelectedRange)

//获取焦点的位置
-(NSRange)selectedRange;
//设置焦点的位置
-(void)setSelectedRange:(NSRange)range;

@end
