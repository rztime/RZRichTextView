//
//  RZViewController.m
//  RZRichTextView
//
//  Created by rztime on 07/22/2021.
//  Copyright (c) 2021 rztime. All rights reserved.
//

#import "RZViewController.h"
#import <RZRichTextView/RZRichTextView.h>
#import <RZRichTextView/RZRictAttributeSetingViewController.h>
#import <RZRichTextView/RZRichTextInputFontColorCell.h>
#import <RZRichTextInputFontBgColorCell.h>


@interface RZViewController ()

/** ui */
@property (nonatomic, strong) RZRichTextView *textView;;
/** ui */
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation RZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.rz_colorCreaterStyle(0, UIColor.whiteColor, UIColor.blackColor);
    // Do any additional setup after loading the view, typically from a nib.
    // 全局的自定义功能实现 (点击工具栏上的功能将会调用的方法)
    RZRichTextConfigureManager.manager.didClickedCell = ^BOOL(RZRichTextView * _Nonnull textView, RZRichTextAttributeItem * _Nonnull item) {
        if (item.type == RZRichTextAttributeTypeFontSize) {
            __block UIFont *font = textView.rz_attributedDictionays[NSFontAttributeName];
            rz_weakObj(textView);
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
                textViewWeak.rz_attributedDictionays[NSFontAttributeName] = tempfont;
                [textViewWeak rz_reloadAttributeData];  // 刷新工具条
            }];
            [RZRichTextConfigureManager presentViewController:vc animated:YES];
            return YES;
        }
        return NO;
    };
    // 键盘上的工具栏的cell
    RZRichTextConfigureManager.manager.cellForItemAtIndePath = ^UICollectionViewCell * _Nonnull(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, RZRichTextAttributeItem * _Nonnull item) {
        if (item.type == RZRichTextAttributeTypeFontColor || item.type == RZRichTextAttributeTypeStroke) {
            RZRichTextInputFontColorCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"def1Cell" forIndexPath:indexPath];
            cell.imageView.image = item.displayImage;
            UIColor *color = item.exParams[@"color"];
            cell.colorImageView.backgroundColor = color;
            return cell;
        }
        return nil;
    };
    // 全局的图片的处理
    RZRichTextConfigureManager.manager.rz_shouldInserImage = ^UIImage * _Nullable(UIImage * _Nullable image) {
        UIImage *imaget = [UIImage imageWithData:UIImageJPEGRepresentation(image, 0.4)];
        return imaget;
    };
//   设置键盘背景色
//    RZRichTextConfigureManager.manager.keyboardColor = UIColor.rz_colorCreaterStyle(1, UIColor.greenColor, UIColor.blueColor);
    // 设置键盘默认模式
//    RZRichTextConfigureManager.manager.overrideUserInterfaceStyle = RZUserInterfaceStyleDark;
    // 富文本输入框
    self.textView = [[RZRichTextView alloc] initWithFrame:CGRectMake(10, 100, rz_k_screen_width-20, 300)];
    self.textView.font = [UIFont systemFontOfSize:17];
    self.textView.backgroundColor = UIColor.rz_colorCreaterStyle(0, [UIColor grayColor], [UIColor whiteColor]);
//    if (@available(iOS 13.0, *)) {
//        self.textView.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
//    } else {
//        // Fallback on earlier versions
//    }
    // 只针对当前textView的功能点击的实现
    self.textView.didClickedCell = ^BOOL(RZRichTextView * _Nonnull textView, RZRichTextAttributeItem * _Nonnull item) {
        if (item.type == RZRichTextAttributeTypeFontColor) {
            UIColor *color = [textView.rz_attributedDictionays[NSForegroundColorAttributeName] copy];
            rz_weakObj(textView);
            RZRictAttributeSetingViewController *vc = [[RZRictAttributeSetingViewController alloc] init];
            vc.displayLabel.text = @"字体颜色";
            vc.displayLabel.textColor = color;
            rz_weakObj(vc);
            [vc color:color didChanged:^(UIColor * _Nonnull color) {
                vcWeak.displayLabel.textColor = color;
            } complete:^(UIColor * _Nonnull color) {
                textViewWeak.rz_attributedDictionays[NSForegroundColorAttributeName] = color;
                [textViewWeak rz_reloadAttributeData];  // 刷新工具条
            }];
            [RZRichTextConfigureManager presentViewController:vc animated:YES];
            return YES;
        }
        return NO;
    };
    // 只针对当前textView 的工具条cell的实现
    self.textView.cellForItemAtIndePath = ^UICollectionViewCell * _Nonnull(UICollectionView * _Nonnull collectionView, NSIndexPath * _Nonnull indexPath, RZRichTextAttributeItem * _Nonnull item) {
        if (item.type == RZRichTextAttributeTypeFontBackgroundColor) {
            RZRichTextInputFontBgColorCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"def2Cell" forIndexPath:indexPath];
            cell.imageView.image = item.displayImage;
            UIColor *color = item.exParams[@"color"];
            cell.colorImageView.backgroundColor = color;
            return cell;
        }
        return nil;
    };
    self.textView.rzDidTapTextView = ^BOOL(id  _Nullable tapObj) {
        NSLog(@"%@", tapObj);
        return NO;
    };
    [self.view addSubview:self.textView];
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"存草稿" style:UIBarButtonItemStyleDone target:self action:@selector(save:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取草稿" style:UIBarButtonItemStyleDone target:self action:@selector(getCache:)];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 420, rz_k_screen_width-20, 300)];
    [self.view addSubview:self.webView];
}
// 保存草稿，仅做参考
- (void)save:(id)sender {
    NSAttributedString *attr = self.textView.attributedText;
    NSArray *images = attr.rz_images;
    NSMutableArray *imageUrls = NSMutableArray.new;
    
    [images enumerateObjectsUsingBlock:^(UIImage *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *time = [NSString stringWithFormat:@"%@", NSDate.new];
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent: [NSString stringWithFormat:@"Documents/%@.png",time]];
        [UIImagePNGRepresentation(obj) writeToFile:path atomically:true];
        // 需要将“xxx_自定义_xxx” 替换为自己的 NSHomeDirectory()   拼接其相对路径
        [imageUrls addObject:[NSString stringWithFormat:@"file://xxx_自定义_xxx/Documents/%@.png", time]];
    }];
    // 一种是系统方法，此方法在转换之后会丢失部分属性
//    NSString *html = [attr rz_codingToHtmlWithImagesURLSIfHad:imageUrls];
    // 自定义转换为web的方法，将系统方法转换后丢失的属性，代码注入style，转换
    NSString *html = [attr rz_codingToHtmlByWebWithImagesURLSIfHad:imageUrls];
    
    [[NSUserDefaults standardUserDefaults] setObject:html forKey:@"htmlcache"];
}

- (void)getCache:(id)sender {
    // 取缓存
    NSString *html = [[NSUserDefaults standardUserDefaults] objectForKey:@"htmlcache"];
    html = [html stringByReplacingOccurrencesOfString:@"xxx_自定义_xxx" withString:NSHomeDirectory()];
    NSMutableAttributedString *attr = [NSAttributedString htmlString:html].mutableCopy;

    // 图片的尺寸，在转换保存的时候，是保存的图片本身的size（px），在转换为富文本的时候，并没有转为pt，所以会有可能变大并别裁剪，这里做一个尺寸适配
    NSArray <RZAttributedStringInfo *> *array = [attr rz_attributedStringByAttributeName:NSAttachmentAttributeName];
    [array enumerateObjectsUsingBlock:^(RZAttributedStringInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTextAttachment *att = obj.value;
        UIImage *image = att.image;
        if (image == nil) {
            image = [UIImage imageWithData:att.fileWrapper.regularFileContents];
        }
        CGFloat width = MIN(image.size.width, self.textView.frame.size.width - 20);
        CGFloat height = MIN(image.size.height, image.size.height * width / image.size.width);
        CGRect bounds = att.bounds;
        bounds.size = CGSizeMake(width, height);
        NSAttributedString *temp = [NSAttributedString rz_colorfulConfer:^(RZColorfulConferrer *confer) {
            confer.image(image).bounds(bounds);
        }];
        [attr replaceCharactersInRange:obj.range withAttributedString:temp];
    }];
    
    self.textView.attributedText = attr;
    
    [self.webView loadHTMLString:html baseURL:nil];
}
@end
