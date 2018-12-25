//
//  RZRichTextViewModel.m
//  RZRichTextView
//
//  Created by Admin on 2018/12/14.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextViewModel.h"
#import <RZColorful/RZColorful.h>
#import "RZRichItemView.h"
#import <Masonry/Masonry.h>
#import "UIView+RZFrame.h"
#import <TZImagePickerController/TZImagePickerController.h>

@implementation RZRichTextViewModel

- (RZRichTextContent *)content {
    if (!_content) {
        _content = [[RZRichTextContent alloc] init];
    }
    return _content;
}

- (NSMutableArray<NSDictionary *> *)historyText {
    if (!_historyText) {
        _historyText = [NSMutableArray new];
    }
    return _historyText;
}

- (NSMutableArray<NSDictionary *> *)reagainHistoryText {
    if (!_reagainHistoryText) {
        _reagainHistoryText = [NSMutableArray new];
    }
    return _reagainHistoryText;
}

- (instancetype)init {
    if (self = [super init]) { 
        _editBarSource = [NSMutableArray arrayWithObjects:
                          @(RZRichTextFunc_image),
                          @(RZRichTextFunc_revoke),
                          @(RZRichTextFunc_reagain),
                          @(RZRichTextFunc_bold),
                          @(RZRichTextFunc_italic),
                          @(RZRichTextFunc_underLine),
                          @(RZRichTextFunc_strikeThrough),
                          @(RZRichTextFunc_font),
                          @(RZRichTextFunc_wordSpace),
                          @(RZRichTextFunc_aligment),
                          @(RZRichTextFunc_markUp),
                          @(RZRichTextFunc_markDwon),
                          @(RZRichTextFunc_stroke),
                          @(RZRichTextFunc_shadown) ,
                          @(RZRichTextFunc_expansion),
                           nil];
    }
    return self;
}

#pragma mark - 富文本相关处理

- (NSAttributedString *)contentByFunc:(RZRichTextFunc)func {
    __weak typeof(self) weakSelf = self;
    NSAttributedString *attr = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
        confer.paragraphStyle.alignment(NSTextAlignmentCenter);
        switch (func) {
            case RZRichTextFunc_image: {
                confer.appendImage(rz_rich_image(@"添加图片"));
                break;
            }
            case RZRichTextFunc_revoke: {
                confer.appendImage(rz_rich_image(weakSelf.historyText.count <= 1? @"撤销" : @"撤销_h"));
                break;
            }
            case RZRichTextFunc_reagain: {
                confer.appendImage(rz_rich_image(weakSelf.reagainHistoryText.count == 0? @"恢复" : @"恢复_h"));
                break;
            }
            case RZRichTextFunc_bold:{
                confer.text(@"B").font((weakSelf.content.rz_bold? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17])).textColor(weakSelf.content.rz_bold ? kblue:kgray);
                break;
            }
            case RZRichTextFunc_italic:{
                confer.text(@"I").font(weakSelf.content.rz_italic? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17]).textColor(weakSelf.content.rz_italic? kblue : kgray).italic(@0.3);
                break;
            }
            case RZRichTextFunc_underLine:{
                confer.text(@"ab").font(weakSelf.content.rz_underLine? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17]).textColor(weakSelf.content.rz_underLine? kblue : kgray).underLineStyle(1);
                break;
            }
            case RZRichTextFunc_strikeThrough:{
                confer.text(@"cc").font(weakSelf.content.rz_strikethrough? [UIFont boldSystemFontOfSize:17] : [UIFont systemFontOfSize:17]).textColor(weakSelf.content.rz_strikethrough? kblue : kgray).strikeThrough(1);
                break;
            }
            case RZRichTextFunc_font:{
                confer.text(@"T").font([UIFont systemFontOfSize:17]).textColor(kgray);
                break;
            }
            case RZRichTextFunc_aligment:{
                NSString *name = @[@"左对齐", @"中对齐", @"右对齐"][weakSelf.content.rz_aligment];
                confer.appendImage(rz_rich_image(name));
                break;
            }
            case RZRichTextFunc_markUp:{
                confer.text(@"X").font([UIFont systemFontOfSize:17]).textColor(weakSelf.content.rz_mark == RZRichTextContentMark_Up? kblue:kgray);
                confer.text(@"2").font([UIFont systemFontOfSize:12]).textColor(weakSelf.content.rz_mark == RZRichTextContentMark_Up? kblue:kgray).baselineOffset(@5);
                break;
            }
            case RZRichTextFunc_markDwon:{
                confer.text(@"X").font([UIFont systemFontOfSize:17]).textColor(weakSelf.content.rz_mark == RZRichTextContentMark_Down? kblue:kgray);
                confer.text(@"a").font([UIFont systemFontOfSize:12]).textColor(weakSelf.content.rz_mark == RZRichTextContentMark_Down? kblue:kgray).baselineOffset(@-5);
                break;
            }
            case RZRichTextFunc_stroke:{
                confer.text(@"描边").font(weakSelf.content.rz_stroke? [UIFont boldSystemFontOfSize:13] : [UIFont systemFontOfSize:14]).textColor(weakSelf.content.rz_stroke? kblue : kgray).strokeWidth(weakSelf.content.rz_stroke? @3 : @0);
                break;
            }
            case RZRichTextFunc_expansion:{
                confer.appendImage(rz_rich_image((weakSelf.content.rz_expansion? @"扁平_h":@"扁平")));
                break;
            }
            case RZRichTextFunc_shadown:{
                NSInteger value = weakSelf.content.rz_shadown? 2:0;
                confer.text(@"阴影").font(weakSelf.content.rz_shadown? [UIFont boldSystemFontOfSize:13] : [UIFont systemFontOfSize:14]).textColor(weakSelf.content.rz_shadown? kblue : kgray).shadow.offset(CGSizeMake(value, value));
                break;
            }
            case RZRichTextFunc_wordSpace:{
                confer.text(@"间距").font([UIFont boldSystemFontOfSize:13]).textColor(kgray);
                break;
            }
            default:
                break;
        }
    }];
    return attr;
}
#pragma mark - 工具栏点击事件
- (void (^)(RZRichTextFunc))rz_didEditBarClicked {
    __weak typeof(self) weakSelf = self;
    return ^(RZRichTextFunc func) {
        UIView *view = [weakSelf didclickedFunc:func];
        if (weakSelf.rz_didEditBarclickedShowExView) {
            weakSelf.rz_didEditBarclickedShowExView(view);
        }
    };
}

- (UIView *)didclickedFunc:(RZRichTextFunc)func {
    UIView *view;
    switch (func) {
        case RZRichTextFunc_image: {
            TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
            vc.allowPickingVideo = NO;
            vc.allowTakeVideo = NO;
            vc.allowPickingOriginalPhoto = NO;
            __weak typeof(self) weakSelf = self;
            [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
                if (photos.count == 1 && weakSelf.rz_didhandleExFunc) {
                    weakSelf.rz_didhandleExFunc(RZRichTextFunc_image, photos.firstObject);
                }
            }];
            [self.rz_currentViewController presentViewController:vc animated:YES completion:nil];
            break;
        }
        case RZRichTextFunc_revoke: {
            if (self.rz_didhandleExFunc) {
                self.rz_didhandleExFunc(RZRichTextFunc_revoke, nil);
            }
            break;
        }
        case RZRichTextFunc_reagain: {
            if (self.rz_didhandleExFunc) {
                self.rz_didhandleExFunc(RZRichTextFunc_reagain, nil);
            }
            break;
        }
        case RZRichTextFunc_bold:{
            self.content.rz_bold = !self.content.rz_bold;
            break;
        }
        case RZRichTextFunc_italic:{
            self.content.rz_italic = !self.content.rz_italic;
            break;
        }
        case RZRichTextFunc_underLine:{
            self.content.rz_underLine = !self.content.rz_underLine;
            break;
        }
        case RZRichTextFunc_strikeThrough:{
            self.content.rz_strikethrough = !self.content.rz_strikethrough;
            break;
        }
        case RZRichTextFunc_font:{
            if (self.showFunc != RZRichTextFunc_font) {
                view = [self fontView];
            }
            break;
        }
        case RZRichTextFunc_aligment:{
            if (self.showFunc != func) {
                view = [self aligmentView];
            }
            break;
        }
        case RZRichTextFunc_markUp:{
            self.content.rz_mark = self.content.rz_mark == RZRichTextContentMark_Up? RZRichTextContentMark_Defaule: RZRichTextContentMark_Up;
            break;
        }
        case RZRichTextFunc_markDwon:{
            self.content.rz_mark = self.content.rz_mark == RZRichTextContentMark_Down? RZRichTextContentMark_Defaule: RZRichTextContentMark_Down;
            break;
        }
        case RZRichTextFunc_stroke:{
            if (self.showFunc != func) {
                view = [self strokeView];
            }
            break;
        }
        case RZRichTextFunc_expansion:{
            if (self.showFunc != func) {
                view = [self expansionView];
            }
            break;
        }
        case RZRichTextFunc_shadown:{
            if (self.showFunc != func) {
                view = [self shadownView];
            }
            break;
        }
        case RZRichTextFunc_wordSpace:{
            if (self.showFunc != RZRichTextFunc_wordSpace) {
                view = [self wordSpaceView];
            }
            break;
        }
        case RZRichTextFunc_closeKeyboard: {
            [[UIApplication sharedApplication].keyWindow endEditing:YES];
            break;
        }
        case RZRichTextFunc_closeEXItemView: {
            
            break;
        }
        default:
            break;
    }
    if (view) {
        self.showFunc = func;
        return view;
    }
    self.showFunc = RZRichTextFunc_None;
    return nil;
}

- (UIScrollView *)rz_richItemView {
    UIScrollView *view = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kRZScreenWidth, 0)];
    view.backgroundColor = [UIColor colorWithWhite:0.88 alpha:1];
    return view;
}

- (UIView *)fontView {
    UIView * view = [self rz_richItemView];
    __weak typeof(self) weakSelf = self;
    RZRichItemView *fontsize = [RZRichItemView initWithNumber:weakSelf.content.rz_fontSize type:RZRichItemViewType_fontSize title:@"请选择字体大小" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_fontSize =  [result integerValue];
    }];
    [view addSubview:fontsize];
    [fontsize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
    }];
    RZRichItemView *textColor = [RZRichItemView initWithColor:self.content.rz_textColor type:RZRichItemViewType_textColor title:@"请设置字体颜色" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_textColor = (UIColor *)result;
    }];
    [view addSubview:textColor];
    [textColor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fontsize.mas_bottom);
        make.left.right.equalTo(view);
    }];
    RZRichItemView *textbgColor = [RZRichItemView initWithColor:self.content.rz_textBackgroundColor type:RZRichItemViewType_textBgColor title:@"请设置字体背景颜色" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_textBackgroundColor = (UIColor *)result;
    }];
    [view addSubview:textbgColor];
    [textbgColor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(textColor.mas_bottom);
        make.left.right.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_greaterThanOrEqualTo([UIScreen mainScreen].bounds.size.width);
    }];
    view.height = 88*3;
    return view;
}

- (UIView *)aligmentView {
    __weak typeof(self) weakSelf = self;
    UIView * view = [self rz_richItemView];
    RZRichItemView *aligment = [RZRichItemView initWithAligment:self.content.rz_aligment title:@"请选择对齐方式" complete:^(id  _Nonnull result) {
        self.content.rz_aligment = [result integerValue];
        if (weakSelf.rz_valueChangedRefreshEditBar) {
            weakSelf.rz_valueChangedRefreshEditBar(YES);
        }
    }];
    [view addSubview:aligment];
    [aligment mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_greaterThanOrEqualTo([UIScreen mainScreen].bounds.size.width);
    }];
    view.height = 88;
    return view;
}

- (UIView *)strokeView {
    __weak typeof(self) weakSelf = self;
    UIView * view = [self rz_richItemView];
    
    RZRichItemView *open = [RZRichItemView initWithFuncEnable:self.content.rz_stroke title:@"开启描边功能" complete:^(id  _Nonnull result) {
        BOOL enable = [result boolValue];
        weakSelf.content.rz_stroke = enable;
        if (weakSelf.rz_valueChangedRefreshEditBar) {
            weakSelf.rz_valueChangedRefreshEditBar(YES);
        }
    }];
    [view addSubview:open];
    [open mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
    }];
    
    RZRichItemView *fontsize = [RZRichItemView initWithNumber:weakSelf.content.rz_strokeWidth type:RZRichItemViewType_stroke title:@"请选择描边大小" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_strokeWidth =  [result integerValue];
    }];
    [view addSubview:fontsize];
    [fontsize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(open.mas_bottom);
        make.left.right.equalTo(view);
    }];
    RZRichItemView *textColor = [RZRichItemView initWithColor:self.content.rz_strokeColor type:RZRichItemViewType_textColor title:@"请设置描边颜色" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_strokeColor = (UIColor *)result;
    }];
    [view addSubview:textColor];
    [textColor mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(fontsize.mas_bottom);
        make.left.right.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_greaterThanOrEqualTo([UIScreen mainScreen].bounds.size.width);
    }];
    view.height = 88 * 3;
    return view;
}

- (UIView *)expansionView {
    __weak typeof(self) weakSelf = self;
    UIView * view = [self rz_richItemView];
    RZRichItemView *open = [RZRichItemView initWithFuncEnable:self.content.rz_expansion title:@"开启拉伸功能" complete:^(id  _Nonnull result) {
        BOOL enable = [result boolValue];
        weakSelf.content.rz_expansion = enable;
        if (weakSelf.rz_valueChangedRefreshEditBar) {
            weakSelf.rz_valueChangedRefreshEditBar(YES);
        }
    }];
    [view addSubview:open];
    [open mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
    }];
    
    RZRichItemView *fontsize = [RZRichItemView initWithNumber:weakSelf.content.rz_expansionValue type:RZRichItemViewType_expansion title:@"请选择伸缩值(>0:拉伸 <0:压缩)" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_expansionValue =  [result floatValue];
    }];
    [view addSubview:fontsize];
    [fontsize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(open.mas_bottom);
        make.left.right.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_greaterThanOrEqualTo([UIScreen mainScreen].bounds.size.width);
    }];
    view.height = 88 * 2;
    return view;
}

- (UIView *)shadownView {
    __weak typeof(self) weakSelf = self;
    UIView * view = [self rz_richItemView];
    
    RZRichItemView *open = [RZRichItemView initWithFuncEnable:self.content.rz_shadown title:@"开启阴影功能" complete:^(id  _Nonnull result) {
        BOOL enable = [result boolValue];
        weakSelf.content.rz_shadown = enable;
        if (weakSelf.rz_valueChangedRefreshEditBar) {
            weakSelf.rz_valueChangedRefreshEditBar(YES);
        }
    }];
    [view addSubview:open];
    [open mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
    }];
    
    RZRichItemView *shadowX = [RZRichItemView initWithNumber:weakSelf.content.rz_shadownOffsetX type:RZRichItemViewType_shadow title:@"请选择阴影偏移X轴值" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_shadownOffsetX =  [result integerValue];
    }];
    [view addSubview:shadowX];
    [shadowX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(open.mas_bottom);
        make.left.right.equalTo(view);
    }];
    
    RZRichItemView *shadowY = [RZRichItemView initWithNumber:weakSelf.content.rz_shadownOffsetY type:RZRichItemViewType_shadow title:@"请选择阴影偏移Y轴值" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_shadownOffsetY =  [result integerValue];
    }];
    [view addSubview:shadowY];
    [shadowY mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shadowX.mas_bottom);
        make.left.right.equalTo(view);
    }];
    
    RZRichItemView *shadowRadius = [RZRichItemView initWithNumber:weakSelf.content.rz_shadownRadius type:RZRichItemViewType_shadowRadius title:@"请选择阴影画笔值" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_shadownRadius =  [result integerValue];
    }];
    [view addSubview:shadowRadius];
    [shadowRadius mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shadowY.mas_bottom);
        make.left.right.equalTo(view);
    }];
    
    RZRichItemView *color = [RZRichItemView initWithColor:self.content.rz_shadownColor type:RZRichItemViewType_textColor title:@"请设置阴影颜色" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_shadownColor = (UIColor *)result;
    }];
    [view addSubview:color];
    [color mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(shadowRadius.mas_bottom);
        make.left.right.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_greaterThanOrEqualTo([UIScreen mainScreen].bounds.size.width);
    }];
    view.height = 88 * 4;
    return view;
}

- (UIView *)wordSpaceView {
    __weak typeof(self) weakSelf = self;
    UIView * view = [self rz_richItemView];
    RZRichItemView *shadowX = [RZRichItemView initWithNumber:weakSelf.content.rz_wordSpace type:RZRichItemViewType_shadow title:@"请选择字间距(<0:减小 >0:增加)" complete:^(id  _Nonnull result) {
        weakSelf.content.rz_wordSpace =  [result integerValue];
    }];
    [view addSubview:shadowX];
    [shadowX mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_greaterThanOrEqualTo([UIScreen mainScreen].bounds.size.width);
    }];
    view.height = 88;
    return view;
}


- (UIViewController *)rz_currentViewController{
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal){
        // 获取应用程序所有的窗口
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows){
            if (tmpWin.windowLevel == UIWindowLevelNormal){
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}
@end
