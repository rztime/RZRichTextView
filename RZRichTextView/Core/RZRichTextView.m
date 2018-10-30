//
//  RZRichTextView.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextView.h"
#import "RZRichTextConfigureView.h"
#import "RZDefine.h"
#import <RZColorful/RZColorful.h>

@interface RZRichTextView () <UITextViewDelegate>

@property (nonatomic, strong) RZRichTextConfigureView *richView;

@property (nonatomic, assign) NSRange lastSelectRange;
@property (nonatomic, assign) NSRange willChangedRange;
@property (nonatomic, copy) NSString * willChangedText;

@end

@implementation RZRichTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.richView = [[RZRichTextConfigureView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        self.inputAccessoryView = self.richView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidchanged:) name:UITextViewTextDidChangeNotification object:self];
        
        kWeakSelf;
        self.richView.rz_insertImage = ^(UIImage *image) {
            if (!image) {
                return ;
            }
            [weakSelf insertImage:image];
        };
        
        self.richView.rz_changeRich = ^(BOOL changed) {
            [weakSelf keyboardChangedRich:changed];
        };
    }
    return self;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                   name:UITextViewTextDidChangeNotification
                                                 object:nil];
}
- (void)insertImage:(UIImage *)image {
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (width > self.frame.size.width  - 20) {
        width = self.frame.size.width  - 20;
        height = height * width / image.size.width;
    }
    
    [self rz_colorfulConferInsetTo:rzConferInsertPositionCursor append:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"\n");
        confer.appendImage(image).bounds(CGRectMake(0, 0, width, height));
        confer.text(@"\n");
    }];
    [self becomeFirstResponder];
}

- (void)keyboardChangedRich:(BOOL)changed {
    if (!changed) {
        return ;
    }
    
    NSRange range = self.selectedRange;
    if (range.length == 0) {
        return ;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.willChangedRange = range;
    self.willChangedText = text;
    self.lastSelectRange = self.selectedRange;
    return YES;
}
- (void)textViewDidchanged:(NSNotification *)obj {
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (position) {
            return ;
        }
    }
    [self textChanged:self.willChangedRange text:self.willChangedText];
}

- (void)textChanged:(NSRange)range text:(NSString *)text {
    if (text.length == 0) {
        return;
    }
    NSRange selectedRange = self.selectedRange;

    NSAttributedString *attr = [self.richView.viewModel.textModel rz_factoryByString:text];
    NSMutableAttributedString *tempAttr = self.attributedText.mutableCopy;
    [tempAttr replaceCharactersInRange:NSMakeRange(range.location, text.length) withAttributedString:attr];

    self.attributedText = tempAttr;

    self.selectedRange = selectedRange;
}

@end
