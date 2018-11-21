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

@property (nonatomic, copy) NSAttributedString *lastAttributedText;

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
    kWeakSelf;
    [self rz_colorfulConferInsetTo:rzConferInsertPositionCursor append:^(RZColorfulConferrer * _Nonnull confer) {
        confer.appendImage(image).bounds(CGRectMake(0, 0, width, height)).paragraphStyle.alignment(weakSelf.richView.viewModel.textModel.aligment);
    }];
    [self becomeFirstResponder];
    [self textChanged:NSMakeRange(0, 0) text:nil];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    _lastAttributedText = self.attributedText;
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
    // 光标位置
    NSInteger cursorLocation = self.selectedRange.location;
    // 尾部未修改内容
    NSString *sufText = [self.attributedText.string substringFromIndex:cursorLocation]; 
    // 1. 找修改的光标起始
    // 2. 找结束位置
    // 3. 修改的内容
    { //
        NSString *lastText;
        if ([self.lastAttributedText.string hasSuffix:sufText]) {
            lastText = [self.lastAttributedText.string substringToIndex:self.lastAttributedText.string.length - sufText.length];
        } else {
            lastText = self.lastAttributedText.string;
        }
        NSString *cuText;
        if ([self.attributedText.string hasSuffix:sufText]) {
            cuText = [self.attributedText.string substringToIndex:self.attributedText.string.length - sufText.length];
        } else {
            cuText = self.attributedText.string;
        }
        
        NSInteger star = 0;
        NSInteger length = 0;
        NSInteger idx = lastText.length > cuText.length? lastText.length:cuText.length;
        for (NSInteger i = 0; i < idx; i++) {
            NSString *lc = i >= lastText.length? @"" : [lastText substringWithRange:NSMakeRange(i, 1)];
            NSString *cc = i >= cuText.length? @"" : [cuText substringWithRange:NSMakeRange(i, 1)];
            if (![lc isEqualToString:cc]) {
                star = i;
                length = lastText.length - i;
                self.willChangedText = [cuText substringFromIndex:i];
                break;
            }
        }
        self.willChangedRange = NSMakeRange(star, length);
    }
    [self textChanged:self.willChangedRange text:self.willChangedText]; 
}

- (void)textChanged:(NSRange)range text:(NSString *)text {
    if (text.length != 0) {
        NSRange selectedRange = self.selectedRange;
        
        NSAttributedString *attr = [self.richView.viewModel.textModel rz_factoryByString:text];
        NSMutableAttributedString *tempAttr = self.attributedText.mutableCopy;
        [tempAttr replaceCharactersInRange:NSMakeRange(range.location, text.length) withAttributedString:attr];
        
        self.attributedText = tempAttr;
        
        self.selectedRange = selectedRange;
    } 
    if (self.didChanegdText){
        self.didChanegdText(self);
    }
    self.lastAttributedText = self.attributedText;
}

- (NSArray <UIImage *> *)rz_richTextImages {
    return [self.attributedText rz_images];
}

- (NSString *)rz_codingToHtmlWithImageURLS:(NSArray <NSString *> *)urls {
    return [self.attributedText rz_codingToHtmlWithImagesURLSIfHad:urls]; 
}
@end
