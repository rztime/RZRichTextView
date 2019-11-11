//
//  RZRichTextConfigureManager.m
//  RZRichTextView
//
//  Created by 若醉 on 2019/5/21.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "RZRichTextConfigureManager.h"
#import "RZRictAttributeSetingViewController.h"
#import <RZColorful/RZColorful.h>

@interface RZRichTextConfigureManager ()
@property (nonatomic, strong) NSMutableDictionary *registerCells;
@end

@implementation RZRichTextConfigureManager

+ (instancetype)manager {
    static RZRichTextConfigureManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[RZRichTextConfigureManager alloc] init];
        [manager loadAttributeItemDatas];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _themeColor = rz_rgb(120, 100, 200); // 紫色
        self.sliderImage = k_rz_richImage(@"rz_lf_slider");
        self.overrideUserInterfaceStyle = RZUserInterfaceStyleUnspecified;
        _keyboardColor = UIColor.rz_colorCreaterStyle(RZUserInterfaceStyleUnspecified, [UIColor colorWithWhite:1 alpha:1], rz_rgba(86, 87, 91, 1));
    }
    return self;
}

- (void)setKeyboardColor:(UIColor *)keyboardColor {
    _keyboardColor = UIColor.rz_colorCreaterStyle(self.overrideUserInterfaceStyle, keyboardColor.rz_defColor, keyboardColor.rz_darkModeColor);
}

- (void)setOverrideUserInterfaceStyle:(RZUserInterfaceStyle)overrideUserInterfaceStyle {
    _overrideUserInterfaceStyle = overrideUserInterfaceStyle;
    _keyboardColor = UIColor.rz_colorCreaterStyle(overrideUserInterfaceStyle, _keyboardColor.rz_defColor, _keyboardColor.rz_darkModeColor);
}

- (NSMutableArray<RZRichTextAttributeItem *> *)rz_attributeItems {
    if (!_rz_attributeItems) {
        _rz_attributeItems = [NSMutableArray new];
    }
    return _rz_attributeItems;
}

- (void)loadAttributeItemDatas {
    // 图片
    RZRichTextAttributeItem *item1 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeAttachment defaultImage:k_rz_richImage(@"rz_image") highlightImage:nil highlight:NO];
    [self addAttributeItem:item1];
    
    // 撤销
    RZRichTextAttributeItem *item2 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeRevoke defaultImage:k_rz_richImage(@"rz_revoke_d") highlightImage:k_rz_richImage(@"rz_revoke_h") highlight:NO];
    [self addAttributeItem:item2];
    
    // 恢复
    RZRichTextAttributeItem *item3 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeRestore defaultImage:k_rz_richImage(@"rz_restore_d") highlightImage:k_rz_richImage(@"rz_restore_h") highlight:NO];
    [self addAttributeItem:item3];
    
    // 字体大小
    RZRichTextAttributeItem *item4 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeFontSize defaultImage:k_rz_richImage(@"rz_fontsize") highlightImage:nil highlight:NO];
    [self addAttributeItem:item4];
    
    // 字体颜色
    RZRichTextAttributeItem *item5 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeFontColor defaultImage:k_rz_richImage(@"rz_fontcolor") highlightImage:nil highlight:NO];
    item5.exParams[@"color"] = [UIColor blackColor];
    [self addAttributeItem:item5];
    
    // 字体所在背景颜色
    RZRichTextAttributeItem *item6 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeFontBackgroundColor defaultImage:k_rz_richImage(@"rz_fontcolor") highlightImage:nil highlight:NO];
    [self addAttributeItem:item6];
    
    // 粗体
    RZRichTextAttributeItem *item7 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeBold defaultImage:k_rz_richImage(@"rz_bold_d") highlightImage:k_rz_richImage(@"rz_bold_h") highlight:NO];
    [self addAttributeItem:item7];
    
    // 斜体
    RZRichTextAttributeItem *item8 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeItalic defaultImage:k_rz_richImage(@"rz_italic_d") highlightImage:k_rz_richImage(@"rz_italic_h") highlight:NO];
    [self addAttributeItem:item8];
    
    // 描边
    RZRichTextAttributeItem *item15 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeStroke defaultImage:k_rz_richImage(@"rz_mb_d") highlightImage:k_rz_richImage(@"rz_mb_h") highlight:NO];
    [self addAttributeItem:item15];
    
    // 下划线
    RZRichTextAttributeItem *item9 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeUnderline defaultImage:k_rz_richImage(@"rz_underline_d") highlightImage:k_rz_richImage(@"rz_underline_h") highlight:NO];
    [self addAttributeItem:item9];
    
    // 删除线
    RZRichTextAttributeItem *item10 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeStrikeThrough defaultImage:k_rz_richImage(@"rz_stroke_d") highlightImage:k_rz_richImage(@"rz_stroke_h") highlight:NO];
    [self addAttributeItem:item10];
    
    // 上标
    RZRichTextAttributeItem *item11 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeMarkUp defaultImage:k_rz_richImage(@"rz_markup_d") highlightImage:k_rz_richImage(@"rz_markup_h") highlight:NO];
    [self addAttributeItem:item11];
    
    // 下标
    RZRichTextAttributeItem *item12 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeMarkDown defaultImage:k_rz_richImage(@"rz_markdown_d") highlightImage:k_rz_richImage(@"rz_markdown_h") highlight:NO];
    [self addAttributeItem:item12];
    
    // 段落样式
    RZRichTextAttributeItem *item14 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeParagraph defaultImage:k_rz_richImage(@"rz_paragraph") highlightImage:nil highlight:NO];
    [self addAttributeItem:item14];

    // 拉伸
    RZRichTextAttributeItem *item16 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeExpansion defaultImage:k_rz_richImage(@"rz_kz_h") highlightImage:nil highlight:NO];
    [self addAttributeItem:item16];
    
    // 阴影
    RZRichTextAttributeItem *item17 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeShadown defaultImage:k_rz_richImage(@"rz_yy_d") highlightImage:k_rz_richImage(@"rz_yy_h") highlight:NO];
    [self addAttributeItem:item17];
    
    // 链接
    RZRichTextAttributeItem *item18 = [RZRichTextAttributeItem initWithType:RZRichTextAttributeTypeURL defaultImage:k_rz_richImage(@"rz_url_d") highlightImage:nil highlight:NO];
    [self addAttributeItem:item18];
}

- (void)addAttributeItem:(RZRichTextAttributeItem *)attrItem {
    [self.rz_attributeItems addObject:attrItem];
}

- (void)insertAttributeItem:(RZRichTextAttributeItem *)attrItem atIndex:(NSInteger)index {
    [self.rz_attributeItems insertObject:attrItem atIndex:index];
}

- (NSMutableDictionary *)registerCells {
    if (!_registerCells) {
        _registerCells = [NSMutableDictionary new];
    }
    return _registerCells;
}

- (void)registerRZRichTextAttributeItemClass:(Class)classNa forAccessoryItemCellWithIdentifier:(NSString *)identifier {
    self.registerCells[identifier] = classNa;
}

- (UIViewController *)rz_currentViewController{
    return [RZRichTextConfigureManager rz_currentViewController];
}

+ (UIViewController *)rz_currentViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

+ (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if ([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [self getCurrentVCFrom:[rootVC presentedViewController]];
    }
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    } else if ([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    } else {
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

// 模态弹出框，背景将显示出来
+ (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL flag = NO;
        UIViewController *vc =  [self rz_currentViewController];
        __weak typeof(vc) weakVC = vc;
        flag = vc.definesPresentationContext;
        vc.definesPresentationContext = YES;
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        if ((vc.navigationController.viewControllers.count == 1 && !vc.tabBarController) || vc.navigationController.viewControllers.count > 1) {
            [vc.navigationController presentViewController:viewController animated:animated completion:^{
                weakVC.definesPresentationContext = flag;
            }];
        } else if(vc.tabBarController){
            [vc.tabBarController presentViewController:viewController animated:animated completion:^{
                weakVC.definesPresentationContext = flag;
            }];
        } else {
            [vc presentViewController:viewController animated:animated completion:^{
                weakVC.definesPresentationContext = flag;
            }];
        }
    });
}
@end


@implementation NSArray (RZSafe)

- (id)rz_safeObjAtIndex:(NSUInteger)index {
    if (self.count == 0) {
        return nil;
    }
    if (index > self.count - 1) {
        return nil;
    }
    return self[index];
}

@end
