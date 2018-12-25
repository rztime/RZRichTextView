//
//  RZRichTextView.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextView.h"
#import "RzrichTextEditBar.h"
#import <RZColorful/RZColorful.h>
#import "RZRichTextViewModel.h"

@interface RZRichTextView ()

@property (nonatomic, assign) NSRange lastSelectRange;
@property (nonatomic, assign) NSRange willChangedRange;
@property (nonatomic, copy) NSString * willChangedText;

@property (nonatomic, copy) NSAttributedString *lastAttributedText;

@property (nonatomic, strong) RZRichTextEditBar *kinputAccessoryView;

@property (nonatomic, strong) RZRichTextViewModel *viewModel;

@property (nonatomic, assign) NSInteger firstResonseCount;

@end

@implementation RZRichTextView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (RZRichTextViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RZRichTextViewModel alloc] init];
        __weak typeof(self) weakSelf = self;
        _viewModel.rz_didhandleExFunc = ^(RZRichTextFunc func, id  _Nonnull obj) {
            [weakSelf handleEXFunc:func obj:obj];
        };
    }
    return _viewModel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _kinputAccessoryView = [[RZRichTextEditBar alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 44)];
        _kinputAccessoryView.viewModel = self.viewModel;
        
        self.inputAccessoryView = _kinputAccessoryView;
        self.font = [UIFont systemFontOfSize:17];
        self.firstResonseCount = 0;
        self.rz_maxrevoke = 20;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidchanged:) name:UITextViewTextDidChangeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextViewTextDidChangeNotification
                                                  object:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)insertImage:(UIImage *)image {
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (width > self.frame.size.width  - 20) {
        width = self.frame.size.width  - 20;
        height = height * width / image.size.width;
    }
    __weak typeof(self) weakSelf = self;
    [self rz_colorfulConferInsetTo:rzConferInsertPositionCursor append:^(RZColorfulConferrer * _Nonnull confer) {
        confer.appendImage(image).bounds(CGRectMake(0, 0, width, height)).paragraphStyle.alignment(weakSelf.kinputAccessoryView.viewModel.content.rz_aligment);
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

- (void)textViewDidBeginEditing:(UITextView *)textView {
    _lastAttributedText = self.attributedText;
    if (self.firstResonseCount == 0) {
        [self addDataToHistory];
    }
    self.firstResonseCount++;
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
        
        NSAttributedString *attr = [self.kinputAccessoryView.viewModel.content rz_factoryByString:text];
        NSMutableAttributedString *tempAttr = self.attributedText.mutableCopy;
        [tempAttr replaceCharactersInRange:NSMakeRange(range.location, text.length) withAttributedString:attr];
        
        self.attributedText = tempAttr;
        
        self.selectedRange = selectedRange;
    }
    if (self.rz_didChangedText){
        self.rz_didChangedText(self);
    }
    self.lastAttributedText = self.attributedText;
    
    [self addDataToHistory];
    
    if (self.viewModel.rz_valueChangedRefreshEditBar) {
        self.viewModel.rz_valueChangedRefreshEditBar(YES);
    }
}
// 将数据加入到撤销数组中
- (void)addDataToHistory {
    NSAttributedString *string = self.lastAttributedText.copy;
    if (!string) {
        string = [NSAttributedString new];
    }
    NSDictionary *dict = @{@"text":string, @"range":[NSValue valueWithRange:self.selectedRange]};
    
    [self.viewModel.historyText addObject:dict];
    if (self.viewModel.historyText.count > self.rz_maxrevoke) {
        [self.viewModel.historyText removeObjectAtIndex:0];
    }
    [self.viewModel.reagainHistoryText removeAllObjects];
}

- (NSArray <UIImage *> *)rz_richTextImages {
    return [self.attributedText rz_images];
}

- (NSString *)rz_codingToHtmlWithImageURLS:(NSArray <NSString *> *)urls {
    return [self.attributedText rz_codingToHtmlWithImagesURLSIfHad:urls];
}


- (void)handleEXFunc:(RZRichTextFunc)func obj:(id)obj {
    switch (func) {
        case RZRichTextFunc_image: {
            [self insertImage:obj];
            break;
        }
        case RZRichTextFunc_revoke: {
            if (self.viewModel.historyText.count > 0) {
                NSDictionary *dict = [RZRichTextView rz_array:self.viewModel.historyText index:self.viewModel.historyText.count - 2];
                if (!dict) {
                    return ;
                }
                self.attributedText = dict[@"text"];
                self.selectedRange = [dict[@"range"] rangeValue];
                [self.viewModel.reagainHistoryText addObject:self.viewModel.historyText.lastObject];
                [self.viewModel.historyText removeLastObject];
                
                if (self.rz_didChangedText){
                    self.rz_didChangedText(self);
                }
            }
            break;
        }
        case RZRichTextFunc_reagain: {
            if (self.viewModel.reagainHistoryText.count > 0) {
                NSDictionary *dict = [RZRichTextView rz_array:self.viewModel.reagainHistoryText index:self.viewModel.reagainHistoryText.count - 1];
                if (!dict) {
                    return ;
                }
                self.attributedText = dict[@"text"];
                self.selectedRange = [dict[@"range"] rangeValue];
                [self.viewModel.historyText addObject:self.viewModel.reagainHistoryText.lastObject];
                [self.viewModel.reagainHistoryText removeLastObject];
                
                if (self.rz_didChangedText){ 
                    self.rz_didChangedText(self);
                }
            }
            break;
        }
        default:
            break;
    }
}

+ (id)rz_array:(NSArray *)array index:(NSInteger)index {
    if (array.count == 0) {
        return nil;
    }
    if (index > array.count - 1) {
        return nil;
    }
    return array[index];
}

@end
