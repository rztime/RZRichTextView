//
//  RZRichTextView.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextView.h"
#import "RZRichTextInputAccessoryView.h"
#import "RZRictAttributeSetingViewController.h"
#import "RZRichAlertViewController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface RZRichTextView ()<UITextViewDelegate>

@property (nonatomic, assign) NSRange willChangedRange;
@property (nonatomic, copy)   NSString *willChangedText;

@property (nonatomic, assign) NSInteger firstResonseCount;

@property (nonatomic, strong) RZRichTextInputAccessoryView *kinputAccessoryView;

@property (nonatomic, assign) BOOL editing;

@property (nonatomic, strong) NSMutableArray *revokeArray;
@property (nonatomic, strong) NSMutableArray *reStoreArray;
@end

@implementation RZRichTextView

- (NSMutableArray *)revokeArray {
    if (!_revokeArray) {
        _revokeArray = [NSMutableArray new];
    }
    return _revokeArray;
}

- (NSMutableArray *)reStoreArray {
    if (!_reStoreArray) {
        _reStoreArray = [NSMutableArray new];
    }
    return _reStoreArray;
}

- (NSMutableDictionary<NSAttributedStringKey,id> *)rz_attributedDictionays {
    if (!_rz_attributedDictionays) {
        _rz_attributedDictionays = [NSMutableDictionary new];
        _rz_attributedDictionays[NSFontAttributeName] = [UIFont systemFontOfSize:17];
        _rz_attributedDictionays[NSForegroundColorAttributeName] = [UIColor blackColor];
    }
    _rz_attributedDictionays[@"NSOriginalFont"] = nil;
    _rz_attributedDictionays[@"NSLink"] = nil;
    return _rz_attributedDictionays;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) { 
        self.firstResonseCount = 0;
        self.rz_maxrevoke = 20;
        self.delegate = self;
        self.rz_attributeItems = RZRichTextConfigureManager.manager.rz_attributeItems;
    }
    return self;
}

- (RZRichTextInputAccessoryView *)kinputAccessoryView {
    if (!_kinputAccessoryView) {
        _kinputAccessoryView = [[RZRichTextInputAccessoryView alloc] initWithFrame:CGRectMake(0, 0, rz_k_screen_width, 44)];
        rz_weakObj(self);
        _kinputAccessoryView.rz_attributeItems = self.rz_attributeItems;
        _kinputAccessoryView.cellForItemAtIndePath = self.cellForItemAtIndePath;
        _kinputAccessoryView.didClcikedAttrItemIndex = ^(NSInteger index) {
            [selfWeak didClickedAttributeIndex:index];
        };
        self.inputAccessoryView = _kinputAccessoryView;
    }
    return _kinputAccessoryView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    NSAssert([self.delegate isEqual:self], @"请勿将富文本编辑器的delegate设置为自定义的，否则将不能正常使用,请使用block替代");
}

- (void)didClickedAttributeIndex:(NSInteger)index {
    RZRichTextAttributeItem *item = self.rz_attributeItems[index];
    if (self.didClickedCell) {
        BOOL flag = self.didClickedCell(self, item);
        if (flag) {
            return ;
        }
    }
    if (RZRichTextConfigureManager.manager.didClickedCell) {
        BOOL flag = RZRichTextConfigureManager.manager.didClickedCell(self, item);
        if (flag) {
            return ;
        }
    }
    switch (item.type) {
        case RZRichTextAttributeTypeAttachment: {
            [self inserImage];
            break;
        }
        case RZRichTextAttributeTypeRevoke: {
            [self revokeText:YES];
            break;
        }
        case RZRichTextAttributeTypeRestore: {
            [self revokeText:NO];
            break;
        }
        case RZRichTextAttributeTypeFontSize: {
            [self fontSizeSetting];
            break;
        }
        case RZRichTextAttributeTypeFontColor: {
            [self fontColor];
            break;
        }
        case RZRichTextAttributeTypeFontBackgroundColor: {
            [self fontBgColor];
            break;
        }
        case RZRichTextAttributeTypeBold: {
            UIFont *font = self.rz_attributedDictionays[NSFontAttributeName];
            BOOL bold = [font.description containsString:@"font-weight: bold"];
            if (bold) {
                font = [UIFont systemFontOfSize:font.pointSize];
            } else {
                font = [UIFont boldSystemFontOfSize:font.pointSize];
            }
            self.rz_attributedDictionays[NSFontAttributeName] = font;
            break;
        }
        case RZRichTextAttributeTypeItalic: {
            [self italic];
            break;
        }
        case RZRichTextAttributeTypeUnderline: {
            [self underLine];
            break;
        }
        case RZRichTextAttributeTypeStrikeThrough: {
            [self deleteLine];
            break;
        }
        case RZRichTextAttributeTypeMarkUp: {
            [self markUp];
            break;
        }
        case RZRichTextAttributeTypeMarkDown: {
            [self markDown];
            break;
        }
        case RZRichTextAttributeTypeParagraph: {
            [self paragraph];
            break;
        }
        case RZRichTextAttributeTypeStroke: {
            [self miaobian];
            break;
        }
        case RZRichTextAttributeTypeExpansion: {
            [self expansion];
            break;
        }
        case RZRichTextAttributeTypeShadown: {
            [self shadow];
            break;
        }
        case RZRichTextAttributeTypeURL: {
            [self editUrl];
            break;
        }
        case RZRichTextAttributeTypeEndEdit: {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            break;
        }
        default: {
            break;
        }
    }
    [self rz_reloadAttributeData];
}

- (void)rz_reloadAttributeData {
    NSMutableDictionary *dict = self.rz_attributedDictionays;
    UIColor *textColor = dict[NSForegroundColorAttributeName];
    UIColor *textBgColor = dict[NSBackgroundColorAttributeName];
    UIFont *font = dict[NSFontAttributeName];
    BOOL bold = [font.description containsString:@"font-weight: bold"];
    BOOL italic = [dict[NSObliquenessAttributeName] floatValue] == 0? NO: YES;
    
    UIColor *mbColor = dict[NSStrokeColorAttributeName];
    
    BOOL underLine = [dict[NSUnderlineStyleAttributeName] integerValue] == 0? NO: YES;
    BOOL deleteLine = [dict[NSStrikethroughStyleAttributeName] integerValue] == 0? NO: YES;
    
    NSInteger offline =  [dict[NSBaselineOffsetAttributeName] integerValue];
    BOOL markUp = offline > 0? YES: NO;
    BOOL markDown = offline < 0? YES: NO;
    
    BOOL shadow = dict[NSShadowAttributeName] ? YES : NO;
    
    NSMutableArray <RZRichTextAttributeItem *>*items = self.rz_attributeItems;
    [items enumerateObjectsUsingBlock:^(RZRichTextAttributeItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        switch (obj.type) {
            case RZRichTextAttributeTypeAttachment: {
                break;
            }
            case RZRichTextAttributeTypeRevoke: {
                obj.highlight = self.revokeArray.count <= 1? NO : YES;
                break;
            }
            case RZRichTextAttributeTypeRestore: {
                obj.highlight = self.reStoreArray.count;
                break;
            }
            case RZRichTextAttributeTypeFontSize: {
                break;
            }
            case RZRichTextAttributeTypeFontColor: {
                obj.exParams[@"color"] = textColor;
                break;
            }
            case RZRichTextAttributeTypeFontBackgroundColor: {
                obj.exParams[@"color"] = textBgColor;
                break;
            }
            case RZRichTextAttributeTypeBold: {
                obj.highlight = bold;
                break;
            }
            case RZRichTextAttributeTypeItalic: {
                obj.highlight = italic;
                break;
            }
            case RZRichTextAttributeTypeUnderline: {
                obj.highlight = underLine;
                break;
            }
            case RZRichTextAttributeTypeStrikeThrough: {
                obj.highlight = deleteLine;
                break;
            }
            case RZRichTextAttributeTypeMarkUp: {
                obj.highlight = markUp;
                break;
            }
            case RZRichTextAttributeTypeMarkDown: {
                obj.highlight = markDown;
                break;
            }
            case RZRichTextAttributeTypeStroke: {
                obj.exParams[@"color"] = mbColor;
                break;
            }
            case RZRichTextAttributeTypeExpansion: {
                
                break;
            }case RZRichTextAttributeTypeShadown: {
                obj.highlight = shadow;
                break;
            }
            case RZRichTextAttributeTypeURL: {
    
                break;
            }
            case RZRichTextAttributeTypeEndEdit: {
                
                break;
            }
            default:
                break;
        }
    }];
    [self.kinputAccessoryView reloadData];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray <UIImage *> *)rz_richTextImages {
    return [self.attributedText rz_images];
}

- (NSString *)rz_codingToHtmlWithImageURLS:(NSArray <NSString *> *)urls {
    return [self.attributedText rz_codingToHtmlWithImagesURLSIfHad:urls];
}

#pragma mark - delegate useable
- (void)textViewDidChange:(UITextView *)textView {
    NSString *lang = [[UIApplication sharedApplication]textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) {
        UITextRange *selectedRange = [self markedTextRange];
        UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
        if (position) {
            return ;
        }
    }
    if (self.willChangedText.length != 0) {
        self.editing = YES;
        NSRange editSelectRange = self.selectedRange; 
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:self.willChangedText];
        [attrString setAttributes:self.rz_attributedDictionays range:NSMakeRange(0, attrString.length)];
        
        NSMutableAttributedString *attr = self.attributedText.mutableCopy;
        NSRange changedRange = NSMakeRange(self.willChangedRange.location, self.willChangedText.length);
        if (changedRange.location + changedRange.length <= attr.length) {
            [attr replaceCharactersInRange:changedRange withAttributedString:attrString];
        }
        [attr removeAttribute:@"NSOriginalFont" range:NSMakeRange(0, attr.length)];
        self.attributedText = attr.copy;
        
        self.selectedRange = editSelectRange;
    }
    self.editing = NO;
    
    if (self.rz_textViewDidChange) {
        self.rz_textViewDidChange(self);
    }
    
    if (self.rz_didChangedText){
        self.rz_didChangedText(self);
    }
    [self addDataToHistory];
    [self rz_reloadAttributeData];
}

- (void)textViewDidChangeSelection:(UITextView *)textView {
    if (self.rz_textViewDidChangeSelection) {
        self.rz_textViewDidChangeSelection(self);
    }
    if (self.editing) {
        return;
    }
    // 只有在手动改变range时，才会去重置到当前的属性
    NSMutableDictionary *dict = [self rz_attributesAtSelectedRange].mutableCopy;
    if (dict) {
        self.rz_attributedDictionays = dict;
    }
    [self rz_reloadAttributeData];
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.rz_shouldChangeTextInRange) {
        if (!self.rz_shouldChangeTextInRange(self, range, text)) {
            return NO;
        }
    }
    self.willChangedRange = range;
    self.willChangedText = text;
    self.editing = YES;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (self.rz_textViewDidBeginEditing) {
        self.rz_textViewDidBeginEditing(self);
    }
    if (self.firstResonseCount == 0) {
        [self addDataToHistory];
    }
    self.firstResonseCount++;
}

#pragma mark - delegate other
- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.rz_textViewDidEndEditing) {
        self.rz_textViewDidEndEditing(self);
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (self.rz_textViewShouldBeginEditing) {
        if (!self.rz_textViewShouldBeginEditing(self)) {
            return NO;
        }
    }
    [self kinputAccessoryView];
    return YES;
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (self.rz_textViewShouldEndEditing) {
        if (!self.rz_textViewShouldEndEditing(self)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0) {
    if(self.rz_shouldInteractWithURL) {
        if(!self.rz_shouldInteractWithURL(self, URL, characterRange, interaction)) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0) {
    if(self.rz_shouldInteractWithTextAttachment) {
        if(!self.rz_shouldInteractWithTextAttachment(self, textAttachment, characterRange, interaction)) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if(self.rz_shouldInteractWithURL_ios7) {
        if(!self.rz_shouldInteractWithURL_ios7(self, URL, characterRange)) {
            return NO;
        }
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange {
    if(self.rz_shouldInteractWithTextAttachment_ios7) {
        if(!self.rz_shouldInteractWithTextAttachment_ios7(self, textAttachment, characterRange)) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - default rich function
#pragma mark - 插入图片
- (void)inserImage {
    TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    vc.allowPickingVideo = NO;
    vc.allowTakeVideo = NO;
    rz_weakObj(self);
    [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *image = photos[0];
            if (RZRichTextConfigureManager.manager.rz_shouldInserImage) {
                image = RZRichTextConfigureManager.manager.rz_shouldInserImage(image);
            }
            if (!image) {
                return ;
            }
            [selfWeak insertImage:image];
        }
    }];
    vc.imagePickerControllerDidCancelHandle = ^{
        [selfWeak becomeFirstResponder];
    };
    [RZRichTextConfigureManager.rz_currentViewController presentViewController:vc animated:YES completion:nil];
}

- (void)insertImage:(UIImage *)image {
    if (!image) {
        return ;
    }
    self.editing = YES;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (width > self.frame.size.width  - 20) {
        width = self.frame.size.width  - 20;
        height = height * width / image.size.width;
    }
    NSTextAttachment *attchment = [[NSTextAttachment alloc] init];
    attchment.image = image;
    attchment.bounds = CGRectMake(0, 0, width, height);
    NSMutableAttributedString *imageString = [NSMutableAttributedString attributedStringWithAttachment:attchment].mutableCopy;
    [imageString addAttributes:self.rz_attributedDictionays range:NSMakeRange(0, imageString.length)];
    
    NSMutableAttributedString *attr = self.attributedText.mutableCopy;
    NSRange selectRaneg = self.selectedRange;
    [attr replaceCharactersInRange:selectRaneg withAttributedString:imageString];
    self.attributedText = attr;
    self.selectedRange = NSMakeRange(selectRaneg.location + imageString.length, 0);
    
    [self becomeFirstResponder];
    [self addDataToHistory];
    self.editing = NO;
    [self rz_reloadAttributeData];
}
#pragma mark - 增加历史记录
- (void)addDataToHistory {
    NSAttributedString *string = self.attributedText.copy;
    if (!string) {
        string = [NSAttributedString new];
    }
    NSDictionary *dict = @{@"text":string, @"range":[NSValue valueWithRange:self.selectedRange]};
    [self.revokeArray addObject:dict];
    if (self.revokeArray.count > self.rz_maxrevoke) {
        [self.revokeArray removeObjectAtIndex:0];
    }
    [self.reStoreArray removeAllObjects];
}

- (void)revokeText:(BOOL)revoke {
    if (revoke) { // 撤销
        NSDictionary *currentDict = [self.revokeArray rz_safeObjAtIndex:self.revokeArray.count - 2];
        if (currentDict) {
            NSAttributedString *text = currentDict[@"text"];
            NSRange range = [currentDict[@"range"] rangeValue];
            self.attributedText = text;
            self.selectedRange = range;
        }
        NSDictionary *revoeDict = [self.revokeArray rz_safeObjAtIndex:self.revokeArray.count - 1];
        if (revoeDict) {
            [self.revokeArray removeObject:revoeDict];
            [self.reStoreArray addObject:revoeDict];
        }
    } else {   // 恢复
        NSDictionary *restore = [self.reStoreArray rz_safeObjAtIndex:self.reStoreArray.count - 1];
        if (restore) {
            NSAttributedString *text = restore[@"text"];
            NSRange range = [restore[@"range"] rangeValue];
            self.attributedText = text;
            self.selectedRange = range;
            [self.revokeArray addObject:restore];
            [self.reStoreArray removeObject:restore];
        }
    }
}

#pragma mark - 字体大小
- (void)fontSizeSetting {
    __block UIFont *font = self.rz_attributedDictionays[NSFontAttributeName];
    rz_weakObj(self);
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    vc.displayLabel.text =  [NSString stringWithFormat:@"字号:%@", @(font.pointSize)];
    vc.displayLabel.font = font;
    rz_weakObj(vc);
    [vc sliderValue:font.pointSize min:5 max:100 didSliderValueChanged:^(CGFloat value) {
        NSInteger font = (NSInteger)value;
        vcWeak.displayLabel.font = [UIFont systemFontOfSize:font];
        vcWeak.displayLabel.text = [NSString stringWithFormat:@"字号:%@", @(font)];
    } complete:^(CGFloat value) {
        UIFont *tempfont = [font fontWithSize:((NSInteger)value)];
        selfWeak.rz_attributedDictionays[NSFontAttributeName] = tempfont;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 字体颜色
- (void)fontColor {
    UIColor *color = self.rz_attributedDictionays[NSForegroundColorAttributeName];
    rz_weakObj(self);
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    vc.displayLabel.text = @"字体颜色";
    vc.displayLabel.textColor = color;
    rz_weakObj(vc);
    [vc color:color didChanged:^(UIColor * _Nonnull color) {
        vcWeak.displayLabel.textColor = color;
    } complete:^(UIColor * _Nonnull color) {
        selfWeak.rz_attributedDictionays[NSForegroundColorAttributeName] = color;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 字体背景颜色
- (void)fontBgColor {
    UIColor *color = self.rz_attributedDictionays[NSForegroundColorAttributeName];
    UIColor *bgcolor = self.rz_attributedDictionays[NSBackgroundColorAttributeName];
    rz_weakObj(self);
    
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    vc.displayLabel.text = @"字体背景颜色";
    vc.displayLabel.textColor = color;
    vc.displayLabel.backgroundColor = bgcolor;
    rz_weakObj(vc);
    [vc color:[UIColor blackColor] didChanged:^(UIColor * _Nonnull color) {
        vcWeak.displayLabel.backgroundColor = color;
    } complete:^(UIColor * _Nonnull color) {
        selfWeak.rz_attributedDictionays[NSBackgroundColorAttributeName] = color;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 斜体
- (void)italic {
    __block NSInteger type = [self.rz_attributedDictionays[NSObliquenessAttributeName] floatValue] * 10;
    rz_weakObj(self);
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text([NSString stringWithFormat:@"设置倾斜:%@", @(type)]).font(rz_font(30)).italic(@(type/10.f));
    }];
    rz_weakObj(vc);
    [vc sliderValue:type min:-20 max:20 didSliderValueChanged:^(CGFloat value) {
        type = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"设置倾斜:%@", @(type)]).font(rz_font(30)).italic(@(type/10.f));
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSObliquenessAttributeName] = @(type/10.f);
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 描边
- (void)miaobian {
    __block NSInteger width = [self.rz_attributedDictionays[NSStrokeWidthAttributeName] integerValue];
    __block UIColor *color = self.rz_attributedDictionays[NSStrokeColorAttributeName];
    
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text([NSString stringWithFormat:@"给字体描边:%@", @(width)]).font([UIFont systemFontOfSize:40]).strokeWidth(@(width)).strokeColor(color);
    }];
    rz_weakObj(self);
    rz_weakObj(vc);
    [vc sliderValue:width min:-15 max:15 didSliderValueChanged:^(CGFloat value) {
        width = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"给字体描边:%@", @(width)]).font([UIFont systemFontOfSize:40]).strokeWidth(@(width)).strokeColor(color);
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSStrokeWidthAttributeName] = @((NSInteger)value);
        [selfWeak rz_reloadAttributeData];
    }];
    
    [vc color:color didChanged:^(UIColor * _Nonnull tcolor) {
        color = tcolor;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"给字体描边:%@", @(width)]).font([UIFont systemFontOfSize:40]).strokeWidth(@(width)).strokeColor(color);
        }];
    } complete:^(UIColor * _Nonnull color) {
        selfWeak.rz_attributedDictionays[NSStrokeColorAttributeName] = color;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 下划线
- (void)underLine {
    __block NSInteger type = [self.rz_attributedDictionays[NSUnderlineStyleAttributeName] integerValue];
    __block UIColor *color = self.rz_attributedDictionays[NSUnderlineColorAttributeName];
    
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text([NSString stringWithFormat:@"下划线:%@", @(type)]).font([UIFont systemFontOfSize:40]).underLineStyle(type).underLineColor(color);
    }];
    rz_weakObj(self);
    rz_weakObj(vc);
    [vc sliderValue:type min:0 max:15 didSliderValueChanged:^(CGFloat value) {
        type = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"下划线:%@", @(type)]).font([UIFont systemFontOfSize:40]).underLineStyle(type).underLineColor(color);
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSUnderlineStyleAttributeName] = @(type);
        [selfWeak rz_reloadAttributeData];
    }];
    
    [vc color:color didChanged:^(UIColor * _Nonnull tcolor) {
        color = tcolor;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"下划线:%@", @(type)]).font([UIFont systemFontOfSize:40]).underLineStyle(type).underLineColor(color);
        }];
    } complete:^(UIColor * _Nonnull color) {
        selfWeak.rz_attributedDictionays[NSUnderlineColorAttributeName] = color;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 删除线
- (void)deleteLine {
    __block NSInteger type = [self.rz_attributedDictionays[NSStrikethroughStyleAttributeName] integerValue];
    __block UIColor *color = self.rz_attributedDictionays[NSStrikethroughColorAttributeName];
    
    
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text([NSString stringWithFormat:@"删除线:%@", @(type)]).font([UIFont systemFontOfSize:40]).strikeThrough(type).strikeThroughColor(color);
    }];
    rz_weakObj(self);
    rz_weakObj(vc);
    [vc sliderValue:0 min:0 max:15 didSliderValueChanged:^(CGFloat value) {
        type = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"删除线:%@", @(type)]).font([UIFont systemFontOfSize:40]).strikeThrough(type).strikeThroughColor(color);
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSStrikethroughStyleAttributeName] = @(type);
        [selfWeak rz_reloadAttributeData];
    }];
    
    [vc color:color didChanged:^(UIColor * _Nonnull tcolor) {
        color = tcolor;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"删除线:%@", @(type)]).font([UIFont systemFontOfSize:40]).strikeThrough(type).strikeThroughColor(color);
        }];
    } complete:^(UIColor * _Nonnull color) {
        selfWeak.rz_attributedDictionays[NSStrikethroughColorAttributeName] = color;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 上标
- (void)markUp {
    __block NSInteger type = [self.rz_attributedDictionays[NSBaselineOffsetAttributeName] integerValue];
    if (type < 0) {
        type = 0;
    }
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"这是基准线: ").font(rz_font(15));
        confer.text([NSString stringWithFormat:@"这是上标:%@", @(type)]).font(rz_font(15)).baselineOffset(@(type));
        confer.text(@" 这是基准线").font(rz_font(15));
    }];
    rz_weakObj(self);
    rz_weakObj(vc);
    [vc sliderValue:type min:0 max:100 didSliderValueChanged:^(CGFloat value) {
        type = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text(@"这是基准线: ").font(rz_font(15));
            confer.text([NSString stringWithFormat:@"这是上标:%@", @(type)]).font(rz_font(15)).baselineOffset(@(type));
            confer.text(@" 这是基准线").font(rz_font(15));
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSBaselineOffsetAttributeName] = @(type);
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 下标
- (void)markDown {
    __block NSInteger type = [self.rz_attributedDictionays[NSBaselineOffsetAttributeName] integerValue];
    if (type > 0) {
        type = 0;
    }
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"这是基准线: ").font(rz_font(15));
        confer.text([NSString stringWithFormat:@"这是下标:%@", @(type)]).font(rz_font(15)).baselineOffset(@(type));
        confer.text(@" 这是基准线").font(rz_font(15));
    }];
    rz_weakObj(self);
    rz_weakObj(vc);
    [vc sliderValue:type min:-100 max:0 didSliderValueChanged:^(CGFloat value) {
        type = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text(@"这是基准线: ").font(rz_font(15));
            confer.text([NSString stringWithFormat:@"这是下标:%@", @(type)]).font(rz_font(15)).baselineOffset(@(type));
            confer.text(@" 这是基准线").font(rz_font(15));
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSBaselineOffsetAttributeName] = @(type);
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 扩展
- (void)expansion {
    __block NSInteger type = (NSInteger)([self.rz_attributedDictionays[NSExpansionAttributeName] floatValue] * 10);
    
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    
    [vc.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text([NSString stringWithFormat:@"设置拉伸属性:%@", @(type)]).font([UIFont systemFontOfSize:30]).expansion(@(type/10.f)).textColor([UIColor blackColor]);
    }];
    rz_weakObj(self);
    rz_weakObj(vc);
    [vc sliderValue:type min:-20 max:20 didSliderValueChanged:^(CGFloat value) {
        type = (NSInteger)value;
        [vcWeak.displayLabel rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text([NSString stringWithFormat:@"设置拉伸属性:%@", @(type)]).font([UIFont systemFontOfSize:30]).expansion(@(type/10.f));
        }];
    } complete:^(CGFloat value) {
        selfWeak.rz_attributedDictionays[NSExpansionAttributeName] = @(type/10.f);
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}

- (void)paragraph {
    NSMutableParagraphStyle *tempstyle = self.rz_attributedDictionays[NSParagraphStyleAttributeName];
    __block NSMutableParagraphStyle *style = tempstyle.mutableCopy;
    if (!style) {
        style = [[NSMutableParagraphStyle alloc] init];
    }
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    
    NSMutableAttributedString *text =  [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"这是第一段，这是第一段这是第一段这是第一段这是第一段这是第一段这是第一段这是第一段这是第一段\n").font(rz_font(15)).textColor([UIColor grayColor]);
        confer.text(@"这是第二段，测试文字测试文字测测试文字测试文字测测试文字测试文字测测试文字测试文字测结束\n").font(rz_font(15)).textColor([UIColor blackColor]);
    }].mutableCopy;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    vc.textView.attributedText = text;
    rz_weakObj(vc);
    rz_weakObj(self);
    [vc pargraph:style didChanged:^(NSMutableParagraphStyle * _Nonnull paragraph) {
        style = paragraph;
        NSMutableAttributedString *text =  [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text(@"这是第一段，这是第一段这是第一段这是第一段这是第一段这是第一段这是第一段这是第一段这是第一段\n").font(rz_font(15)).textColor([UIColor grayColor]);
            confer.text(@"这是第二段，测试文字测试文字测测试文字测试文字测测试文字测试文字测测试文字测试文字测结束\n").font(rz_font(15)).textColor([UIColor blackColor]);
        }].mutableCopy;
        [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
        vcWeak.textView.attributedText = text;
    } complete:^(NSMutableParagraphStyle * _Nonnull paragraph) {
        selfWeak.rz_attributedDictionays[NSParagraphStyleAttributeName] = paragraph;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}
#pragma mark - 阴影
- (void)shadow {
    __block NSShadow *shadow = [self.rz_attributedDictionays[NSShadowAttributeName] copy];
    if (!shadow) {
        shadow = [[NSShadow alloc] init];
    }
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    vc.displayLabel.numberOfLines = 2;
    
    NSMutableAttributedString *attr = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
        confer.text(@"阴影效果").font(rz_font(30));
    }].mutableCopy;
    [attr addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, attr.length)];
    vc.displayLabel.attributedText = attr;
    rz_weakObj(vc);
    rz_weakObj(self);
    [vc shadow:shadow didChanged:^(NSShadow * _Nonnull shadow) {
        vcWeak.displayLabel.text = nil;
        NSMutableAttributedString *attr1 = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer * _Nonnull confer) {
            confer.text(@"阴影效果").font(rz_font(30));
        }].mutableCopy;
        [attr1 addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, attr.length)];
        vcWeak.displayLabel.attributedText = attr1;
    } complete:^(NSShadow * _Nonnull shadow) {
        if (CGColorEqualToColor(((UIColor *)shadow.shadowColor).CGColor, [UIColor clearColor].CGColor)) {
            shadow = nil;
        }
        selfWeak.rz_attributedDictionays[NSShadowAttributeName] = shadow;
        [selfWeak rz_reloadAttributeData];
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}

- (void)editUrl {
    NSArray *urlsString =  [self rz_allUrlAttributedString];
    if (urlsString.count == 0) {
        [self editURL:nil];
        return ;
    }
    RZRichAlertViewController *vc = [[RZRichAlertViewController alloc] initWithType:RZRichAlertViewTypeList];
    vc.titles = ({
        NSMutableArray *array = [NSMutableArray new];
        [array addObject:@{@"text":@"新增", @"color":[UIColor redColor], @"image":[UIImage new]}];
        for (NSDictionary *dict in urlsString) {
            NSMutableDictionary *tempdict = [NSMutableDictionary dictionaryWithDictionary:dict];
            NSString *text = dict[@"text"];
            NSURL *url = dict[@"url"];
            tempdict[@"text"] = [NSString stringWithFormat:@"%@%@%@", text, (text.length> 0 && url.absoluteString.length > 0) ? @"\n":@"", url.absoluteString];
            tempdict[@"image"] = [dict[@"image"] isKindOfClass:[UIImage class]]? dict[@"image"]: [UIImage new];
            [array addObject:tempdict];
        }
        array;
    });
    rz_weakObj(self);
    vc.didSelected = ^(NSUInteger index, BOOL isCancel) {
        if (isCancel) {
            return ;
        }
        NSDictionary *dict;
        if (index > 0) {
            dict = [urlsString rz_safeObjAtIndex:(index - 1)];
        }
        [selfWeak editURL:dict];
    };
    [vc show];
}

- (void)editURL:(NSDictionary *)dict {
    RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
    rz_weakObj(self);
    [vc urlString:dict[@"attr"] didEditComplete:^(NSAttributedString * _Nonnull urlString) {
        NSMutableAttributedString *tempUrl = urlString.mutableCopy;
        [tempUrl addAttributes:selfWeak.rz_attributedDictionays range:NSMakeRange(0, urlString.length)];
        NSMutableAttributedString *text = selfWeak.attributedText.mutableCopy;
        if (dict) {
            NSRange range = [dict[@"range"] rangeValue];
            [text replaceCharactersInRange:range withAttributedString:tempUrl];
        } else {
            [text appendAttributedString:tempUrl];
        }
        selfWeak.attributedText = text;
    }];
    [RZRichTextConfigureManager presentViewController:vc animated:YES];
}

@end
#pragma clang diagnostic pop
