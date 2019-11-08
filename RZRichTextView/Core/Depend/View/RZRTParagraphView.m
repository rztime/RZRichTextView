//
//  RZRTParagraphView.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/23.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRTParagraphView.h"
#import "RZRichTextConstant.h"
#import <Masonry/Masonry.h>
#import "RZRichTextConfigureManager.h"

@interface RZRTParagraphView ()

@property (nonatomic, strong) UIButton *aliginLeftBtn;
@property (nonatomic, strong) UIButton *aliginCenterBtn;
@property (nonatomic, strong) UIButton *aliginRightBtn;


@property (nonatomic, strong) UITextField *sj_beforeTF;
@property (nonatomic, strong) UITextField *sj_TF;
@property (nonatomic, strong) UITextField *sj_endTF;

@property (nonatomic, strong) UITextField *jj_beforeTF;
@property (nonatomic, strong) UITextField *jj_TF;
@property (nonatomic, strong) UITextField *jj_endTF;
@end

@implementation RZRTParagraphView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *cgView = self.cgView;
        UIView *sjView = self.sjView;
        UIView *jjView = self.jjView;
        
        [self addSubview:cgView];
        [self addSubview:sjView];
        [self addSubview:jjView];
        
        [cgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self).offset(10);
            make.right.equalTo(self).offset(-10);
            make.height.equalTo(@94);
        }];
        [sjView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cgView);
            make.top.equalTo(cgView.mas_bottom);
            make.height.equalTo(@(176));
        }];
        [jjView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(cgView);
            make.top.equalTo(sjView.mas_bottom);
            make.height.equalTo(@(176));
        }];
        
        [self addBottomLine:self.sj_beforeTF];
        [self addBottomLine:self.sj_TF];
        [self addBottomLine:self.sj_endTF];
        
        [self addBottomLine:self.jj_beforeTF];
        [self addBottomLine:self.jj_TF];
        [self addBottomLine:self.jj_endTF];
        
        [self addNotification];
        [self addAliginBtnsAction];
    }
    return self;
}

- (void)addAliginBtnsAction {
    NSArray <UIButton *> *btns = @[self.aliginLeftBtn, self.aliginCenterBtn, self.aliginRightBtn];
    rz_weakObj(self);
    [btns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addTarget:selfWeak action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)addNotification {
    NSArray *textfieds = @[self.sj_beforeTF, self.sj_TF, self.sj_endTF, self.jj_beforeTF, self.jj_TF, self.jj_endTF];
    
    for (UITextField *textfield in textfieds) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textValueChangeged:) name:UITextFieldTextDidChangeNotification object:textfield];
    }
}

- (void)textValueChangeged:(NSNotification *)notification {
    UITextField *textField = notification.object;
    CGFloat value = [textField.text floatValue]; 
    if ([textField isEqual:self.sj_beforeTF]) {
        self.paragraph.firstLineHeadIndent = value;
    } else if ([textField isEqual:self.sj_TF]) {
        self.paragraph.headIndent = value;
    } else if ([textField isEqual:self.sj_endTF]) {
        self.paragraph.tailIndent = value;
    } else if ([textField isEqual:self.jj_beforeTF]) {
        self.paragraph.paragraphSpacingBefore = value;
    } else if ([textField isEqual:self.jj_TF]) {
        self.paragraph.lineSpacing = value;
    } else if ([textField isEqual:self.jj_endTF]) {
        self.paragraph.paragraphSpacing = value;
    }
    if (self.didChangeParagraph) {
        self.didChangeParagraph(self.paragraph);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setParagraph:(NSMutableParagraphStyle *)paragraph {
    _paragraph = paragraph;
    [self aliginBtnsHighlight:self.paragraph.alignment]; 
    [self paragraphAttri];
}

- (void)btnAction:(UIButton *)sender {
    [self aliginBtnsHighlight:sender.tag];
    self.paragraph.alignment = sender.tag;
    if (self.didChangeParagraph) {
        self.didChangeParagraph(self.paragraph);
    }
}

- (void)aliginBtnsHighlight:(NSInteger)tagindex {
    NSArray <UIButton *> *btns = @[self.aliginLeftBtn, self.aliginCenterBtn, self.aliginRightBtn];
    [btns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.tag == tagindex) {
            obj.layer.borderColor = RZRichTextConfigureManager.manager.themeColor.CGColor;
            obj.layer.borderWidth = 1;
        } else {
            obj.layer.borderWidth = 0;
        }
    }];
}

- (void)paragraphAttri {
    self.sj_beforeTF.text = [NSString stringWithFormat:@"%@", @(self.paragraph.firstLineHeadIndent)];
    self.sj_TF.text = [NSString stringWithFormat:@"%@", @(self.paragraph.headIndent)];
    self.sj_endTF.text = [NSString stringWithFormat:@"%@", @(self.paragraph.tailIndent)];

    self.jj_beforeTF.text = [NSString stringWithFormat:@"%@", @(self.paragraph.paragraphSpacingBefore)];
    self.jj_TF.text = [NSString stringWithFormat:@"%@", @(self.paragraph.lineSpacing)];
    self.jj_endTF.text = [NSString stringWithFormat:@"%@", @(self.paragraph.paragraphSpacing)];
}



- (UIView *)cgView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rz_k_screen_width, 94)];
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    label.text = @"常规";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    self.aliginLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.aliginLeftBtn setImage:k_rz_richImage(@"rz_left") forState:UIControlStateNormal];
    self.aliginLeftBtn.tag = NSTextAlignmentLeft;
    
    self.aliginCenterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.aliginCenterBtn setImage:k_rz_richImage(@"rz_center") forState:UIControlStateNormal];
    self.aliginCenterBtn.tag = NSTextAlignmentCenter;
    
    self.aliginRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.aliginRightBtn setImage:k_rz_richImage(@"rz_right") forState:UIControlStateNormal];
    self.aliginRightBtn.tag = NSTextAlignmentRight;
    
    [view addSubview:self.aliginLeftBtn];
    [view addSubview:self.aliginCenterBtn];
    [view addSubview:self.aliginRightBtn];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(view).offset(10);
        make.height.equalTo(@44);
    }];
    
    [self.aliginLeftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label).offset(10);
        make.width.height.equalTo(@44);
        make.top.equalTo(label.mas_bottom);
    }];
    
    [self.aliginCenterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerY.equalTo(self.aliginLeftBtn);
        make.left.equalTo(self.aliginLeftBtn.mas_right).offset(30);
    }];
    
    [self.aliginRightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.centerY.equalTo(self.aliginLeftBtn);
        make.left.equalTo(self.aliginCenterBtn.mas_right).offset(30);
    }];
    return view;
}

- (UIView *)sjView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rz_k_screen_width, 176)];
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    label.text = @"缩进";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    UILabel *label1 = [[UILabel alloc] init];
    [view addSubview:label1];
    label1.text = @"文本首行:";
    label1.font = [UIFont systemFontOfSize:15];
    label1.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    self.sj_beforeTF = [[UITextField alloc] init];
    self.sj_beforeTF.keyboardType = UIKeyboardTypeNumberPad;
    self.sj_beforeTF.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    UILabel *label2 = [[UILabel alloc] init];
    [view addSubview:label2];
    label2.text = @"文本缩进:";
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    self.sj_TF = [[UITextField alloc] init];
    self.sj_TF.keyboardType = UIKeyboardTypeNumberPad;
    self.sj_TF.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    UILabel *label3 = [[UILabel alloc] init];
    [view addSubview:label3];
    label3.text = @"文本之后:";
    label3.font = [UIFont systemFontOfSize:15];
    label3.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    self.sj_endTF = [[UITextField alloc] init];
    self.sj_endTF.keyboardType = UIKeyboardTypeNumberPad;
    self.sj_endTF.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    [view addSubview:self.sj_beforeTF];
    [view addSubview:self.sj_TF];
    [view addSubview:self.sj_endTF];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(view).offset(10);
        make.height.equalTo(@44);
    }];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label).offset(10);
        make.height.equalTo(@44);
        make.width.equalTo(@80);
        make.top.equalTo(label.mas_bottom);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1);
        make.width.height.equalTo(label1);
        make.top.equalTo(label1.mas_bottom);
    }];
    
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1);
        make.width.height.equalTo(label1);
        make.top.equalTo(label2.mas_bottom);
    }];
    
    [self.sj_beforeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1.mas_right).offset(10);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerY.equalTo(label1);
    }];
    
    [self.sj_TF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(self.sj_beforeTF);
        make.centerY.equalTo(label2);
    }];
    
    [self.sj_endTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(self.sj_beforeTF);
        make.centerY.equalTo(label3);
    }];
    return view;
}


- (UIView *)jjView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rz_k_screen_width, 176)];
    UILabel *label = [[UILabel alloc] init];
    [view addSubview:label];
    label.text = @"间距";
    label.font = [UIFont systemFontOfSize:15];
    label.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    UILabel *label1 = [[UILabel alloc] init];
    [view addSubview:label1];
    label1.text = @"段前距:";
    label1.font = [UIFont systemFontOfSize:15];
    label1.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    self.jj_beforeTF = [[UITextField alloc] init];
    self.jj_beforeTF.keyboardType = UIKeyboardTypeNumberPad;
    self.jj_beforeTF.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    UILabel *label2 = [[UILabel alloc] init];
    [view addSubview:label2];
    label2.text = @"段间距:";
    label2.font = [UIFont systemFontOfSize:15];
    label2.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    self.jj_TF = [[UITextField alloc] init];
    self.jj_TF.keyboardType = UIKeyboardTypeNumberPad;
    self.jj_TF.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    UILabel *label3 = [[UILabel alloc] init];
    [view addSubview:label3];
    label3.text = @"段后距:";
    label3.font = [UIFont systemFontOfSize:15];
    label3.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    self.jj_endTF = [[UITextField alloc] init];
    self.jj_endTF.keyboardType = UIKeyboardTypeNumberPad;
    self.jj_endTF.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
    
    [view addSubview:self.jj_beforeTF];
    [view addSubview:self.jj_TF];
    [view addSubview:self.jj_endTF];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(view).offset(10);
        make.height.equalTo(@44);
    }];
    
    [label1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label).offset(10);
        make.height.equalTo(@44);
        make.width.equalTo(@80);
        make.top.equalTo(label.mas_bottom);
    }];
    
    [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1);
        make.width.height.equalTo(label1);
        make.top.equalTo(label1.mas_bottom);
    }];
    
    [label3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1);
        make.width.height.equalTo(label1);
        make.top.equalTo(label2.mas_bottom);
    }];
    
    [self.jj_beforeTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(label1.mas_right).offset(10);
        make.width.equalTo(@80);
        make.height.equalTo(@30);
        make.centerY.equalTo(label1);
    }];
    
    [self.jj_TF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(self.jj_beforeTF);
        make.centerY.equalTo(label2);
    }];
    
    [self.jj_endTF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(self.jj_beforeTF);
        make.centerY.equalTo(label3);
    }];
    return view;
}

- (void)addBottomLine:(UIView *)view {
    UIView *line = [[UIView alloc] init];
    [view addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(view);
        make.height.equalTo(@1);
    }];
    line.backgroundColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, [UIColor blackColor], [UIColor whiteColor]);
}


- (CGFloat)viewHeight {
    return 94 + 10 + 176 * 2 + 10;
}

@end
