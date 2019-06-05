//
//  UITextField+SelectedRange.m
//  RZColorfulExample
//
//  Created by rztime on 2017/11/16.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "UITextField+SelectedRange.h"

@implementation UITextField (SelectedRange)

-(NSRange)selectedRange {
    UITextPosition *beginning = self.beginningOfDocument;
    UITextRange    *selectedRange = self.selectedTextRange;
    UITextPosition *selectionStart = selectedRange.start;
    UITextPosition *selectionEnd = selectedRange.end;
    
    const NSInteger location = [self offsetFromPosition:beginning toPosition:selectionStart];
    const NSInteger length = [self offsetFromPosition:selectionStart toPosition:selectionEnd];
    return NSMakeRange(location, length);
}

-(void)setSelectedRange:(NSRange)range {
    UITextPosition *beginning = self.beginningOfDocument;
    UITextPosition *startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition *endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange    *selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    [self setSelectedTextRange:selectionRange];
}

@end
