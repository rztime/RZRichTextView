//
//  RZRTURLView.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/29.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRTURLView.h"
#import <Masonry/Masonry.h>
#import "RZRichTextConstant.h"
#import "RZRichTextConfigureManager.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import <RZColorful/NSAttributedString+RZColorful.h>
#import "NSString+RZCode.h"

@interface RZRTURLView ()

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIButton *imageBtn;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UITextField *urlTextField;

@end

@implementation RZRTURLView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = RZRichTextConfigureManager.manager.keyboardColor;
        self.layer.cornerRadius = 5;
        self.imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.imageBtn];
        [self.imageBtn setImage:k_rz_richImage(@"rz_url_btn") forState:UIControlStateNormal];
        self.imageBtn.imageView.layer.masksToBounds = YES;
        self.imageBtn.imageView.layer.cornerRadius = 3;
        self.imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        self.textField = [[UITextField alloc] init];
        [self addSubview:self.textField];
        self.textField.placeholder = @"请输入内容";
        self.textField.layer.borderColor = rz_rgb(238, 238, 238).CGColor;
        self.textField.layer.borderWidth = 1;
        [self.textField addTarget:self action:@selector(resetURLString) forControlEvents:UIControlEventEditingChanged];
        self.textField.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
        self.textField.attributedPlaceholder = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
            confer.text(@"请输入内容").textColor(UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor)).font([UIFont systemFontOfSize:16]);
        }];//
        
        self.urlTextField = [[UITextField alloc] init];
        [self addSubview:self.urlTextField];
        self.urlTextField.placeholder = @"链接";
        self.urlTextField.layer.borderColor = rz_rgb(238, 238, 238).CGColor;
        self.urlTextField.layer.borderWidth = 1;
        [self.urlTextField addTarget:self action:@selector(resetURLString) forControlEvents:UIControlEventEditingChanged];
        self.urlTextField.keyboardType = UIKeyboardTypeURL;
        self.urlTextField.textColor = UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor);
        self.urlTextField.attributedPlaceholder = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
                confer.text(@"请输入链接").textColor(UIColor.rz_colorCreaterStyle(RZRichTextConfigureManager.manager.overrideUserInterfaceStyle, UIColor.blackColor, UIColor.whiteColor)).font([UIFont systemFontOfSize:16]);
            }];//
        
        [self.imageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self);
            make.width.height.equalTo(@60);
        }];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.imageBtn.mas_bottom).offset(10);
            make.height.equalTo(@44);
            make.width.equalTo(@300);
        }];
        
        [self.urlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.textField.mas_bottom).offset(10);
            make.centerX.height.width.equalTo(self.textField);
            make.bottom.equalTo(self).offset(-10);
        }];
        
        [self.imageBtn addTarget:self action:@selector(imageBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (CGFloat)viewHeight {
    return /*(60 + 10 +44 + 10 + 44 +10 = ) */ 178;
}

- (void)setUrlString:(NSAttributedString *)urlString {
    _urlString = urlString;
    NSInteger length = urlString.length;
    if (length == 0) {
        return ;
    }
    
    NSArray *images = _urlString.rz_images;
    if (images.count > 0) {
        self.image = images[0];
        [self.imageBtn setImage:self.image forState:UIControlStateNormal];
    }
    self.textField.text = _urlString.string;
    // 只有在手动改变range时，才会去重置到当前的属性
  
    NSRange range = NSMakeRange(0, 1);
    NSDictionary *attrDict = [urlString attributesAtIndex:0 effectiveRange:&range];
    NSString *urlText = attrDict[NSLinkAttributeName];
    if ([urlText isKindOfClass:[NSURL class]]) {
        urlText = [(NSURL *)urlText absoluteString];
    }
    self.urlTextField.text = urlText.rz_decodedString;
}

- (void)imageBtnClicked:(UIButton *)sender {
    if (self.image) {
        [self delegateImage];
    } else {
        [self inserImage];
    }
}

- (void)delegateImage {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"要删除图片吗？" preferredStyle:UIAlertControllerStyleActionSheet];
    rz_weakObj(self);
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        selfWeak.image = nil;
        [selfWeak.imageBtn setImage:k_rz_richImage(@"rz_url_btn") forState:UIControlStateNormal];
        [selfWeak resetURLString];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:confirm];
    [alert addAction:cancel];
    [RZRichTextConfigureManager.rz_currentViewController presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 插入图片
- (void)inserImage {
    TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    vc.allowPickingVideo = NO;
    vc.allowTakeVideo = NO;
    vc.allowCrop = NO;
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
            selfWeak.image = image;
            [selfWeak.imageBtn setImage:image forState:UIControlStateNormal];
            [selfWeak resetURLString];
        }
    }];
    [RZRichTextConfigureManager.rz_currentViewController presentViewController:vc animated:YES completion:nil];
}

- (void)resetURLString {
    rz_weakObj(self);
    NSAttributedString *attr = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
        if (selfWeak.image) {
            CGFloat width = selfWeak.image.size.width;
            CGFloat height = selfWeak.image.size.height;
            
            confer.appendImage(selfWeak.image).bounds(CGRectMake(0, 0, width , height)).tapAction( selfWeak.urlTextField.text.rz_encodedString);
        }
        confer.text(selfWeak.textField.text).tapAction(selfWeak.urlTextField.text.rz_encodedString);
    }];
    _urlString = attr.copy;
}

@end
