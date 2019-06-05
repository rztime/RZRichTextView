//
//  UIView+RZContinueFirstResponder.m
//  TextInputViewFocusDemo
//
//  Created by rztime on 2017/11/10.
//  Copyright © 2017年 rztime. All rights reserved.
//

#import "UIView+RZContinueFirstResponder.h"
#import <objc/runtime.h>

@implementation UIViewResponderHelper

- (instancetype)init {
    if (self = [super init]) {
        _nextFirstResponderTagIdentity = @"";
        _nextFirstResponderIndex = -1;
    }
    return self;
}

@end

@implementation UIView (RZContinueFirstResponder)

- (void)setTagIdentity:(NSString *)tagIdentity {
    objc_setAssociatedObject(self, @"rzTagIdentity", tagIdentity, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)tagIdentity {
    return objc_getAssociatedObject(self, @"rzTagIdentity");
}

// 1. 获取当前view的所有的输入文本框
// 2. 拿到当前view第一响应者的tagIdentity，以及其在所有的文本框中的index，
// 3. 保存第一响应键盘
// 4. 刷新
// 5. 指定下一个nextFirstResponderTagIdentity第一响应的文本框
// 6. 或者按原tagIdentity还原第一响应
// 7. 如果没有tagIdentity， 则按之前的index，还原，
// 8. 如果index越界，则取最后一个

- (void)rzContinueFirstResponderAndExecuteCode:(void (^)(UIViewResponderHelper *nextResponder))code {
    // 1
    NSMutableArray *array = [NSMutableArray arrayWithArray:[self getAllTextField]];
    NSInteger index = -1;
    NSString *tagIdentity = @"";
    id tagView;
    // 2
    for (int i = 0;  i < array.count; i++) {
        UIView *view = array[i];
        if ([view isFirstResponder]) {
            index = i;
            tagIdentity = view.tagIdentity;
            tagView = view;
            break ;
        }
    }
    // 3  保持界面第一响应
    id copyView;
    if (tagView) {
        copyView = [NSClassFromString(NSStringFromClass([tagView class])) new];
        [[self superview] addSubview:copyView];
        [copyView becomeFirstResponder];
    }
    // 4.刷新
    [array removeAllObjects];
    
    UIViewResponderHelper *responderHelper = [[UIViewResponderHelper alloc]init];
    if (code) {
        code(responderHelper);
    }
    [self layoutIfNeeded];
    
    array = [NSMutableArray arrayWithArray:[self getAllTextField]];
    // 没有可用文本框，则结束
    if (array.count == 0) {
        [copyView resignFirstResponder];
        [copyView removeFromSuperview];
        return;
    }
    
    
    UIView *firstResponderView;
    // 5 指定下一个
    if (responderHelper.nextFirstResponderTagIdentity.length != 0) {
        for (UIView * view in array) {
            if ([view.tagIdentity isEqualToString:responderHelper.nextFirstResponderTagIdentity]) {
                firstResponderView = view;
                break;
            }
        }
    }
    
    // 之前的和下一个没找到，则按index寻找，越界则取最后一个
    if (!firstResponderView && responderHelper.nextFirstResponderIndex >= 0) {
        if (responderHelper.nextFirstResponderIndex >= array.count - 1) {
            firstResponderView = [array lastObject];
        } else {
            firstResponderView = array[responderHelper.nextFirstResponderIndex];
        }
    }
    
    // 6 还原之前的
    if (!firstResponderView && tagIdentity.length != 0) {
        for (UIView * view in array) {
            if ([view.tagIdentity isEqualToString:tagIdentity]) {
                firstResponderView = view;
                break;
            }
        }
    }
    // 之前的和下一个没找到，则按index寻找，越界则取最后一个
    if (!firstResponderView && index >= 0) {
        if (index >= array.count - 1) {
            firstResponderView = [array lastObject];
        } else {
            firstResponderView = array[index];
        }
    }
    if (firstResponderView) {
        [firstResponderView becomeFirstResponder];
    }
    // 移除
    [copyView removeFromSuperview];
}

#pragma mark - 获取当前view的所有的可输入文本框
// 获得当前控制器的所有的文本框
- (NSArray *)getAllTextField {
    // 获得所有的文本框，默认按照位置排序
    NSArray *textArray = [self deepResponderViews:self];
    
    return textArray;
}

// 通过递归，来获得控件中的所有的textField
- (NSArray*)deepResponderViews:(UIView *)superView {
    NSMutableArray *textFields = [[NSMutableArray alloc] init];
    for (UIView *textField in superView.subviews) {
        if ([self canBecomeFirstResponder:textField]) {
            [textFields addObject:textField];
        }
        if (textField.subviews.count && [textField isUserInteractionEnabled] && ![textField isHidden] && [textField alpha]!=0.0) {
            [textFields addObjectsFromArray:[self deepResponderViews:textField]];
        }
    }
    // 按照位置从上到下，（从左到右进行排序）
    __weak typeof(self) weakself = self;
    return [textFields sortedArrayUsingComparator:^NSComparisonResult(UIView *view1, UIView *view2) {
        CGRect frame1 = [view1 convertRect:view1.bounds toView:weakself];
        CGRect frame2 = [view2 convertRect:view2.bounds toView:weakself];
        
        CGFloat x1 = CGRectGetMinX(frame1);
        CGFloat y1 = CGRectGetMinY(frame1);
        CGFloat x2 = CGRectGetMinX(frame2);
        CGFloat y2 = CGRectGetMinY(frame2);
        
        if (y1 < y2) {
            return NSOrderedAscending;
        } else if (y1 > y2) {
            return NSOrderedDescending;
        }
        //Else both y are same so checking for x positions
        else if (x1 < x2) {
            return NSOrderedAscending;
        } else if (x1 > x2) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    
    return textFields;
}

// 是否是可以响应的文本框
-(BOOL)canBecomeFirstResponder:(UIView *)view {
    BOOL canBecomeFirstResponder = NO;
    if ([view isKindOfClass:[UITextField class]]) {
        canBecomeFirstResponder = [(UITextField*)view isEnabled];
    } else if ([view isKindOfClass:[UITextView class]]) {
        canBecomeFirstResponder = [(UITextView*)view isEditable];
    }
    if (canBecomeFirstResponder == YES) {
        canBecomeFirstResponder = ([view isUserInteractionEnabled] && ![view isHidden] && [view alpha]!=0.0 && ![self isAlertViewTextField:view]  && ![self isSearchBarTextField:view]);
    }
    return canBecomeFirstResponder;
}

// 是否是alertView中的文本框
-(BOOL)isAlertViewTextField:(UIView *)view {
    UIResponder *alertViewController = [self viewController];
    BOOL isAlertViewTextField = NO;
    while (alertViewController && isAlertViewTextField == NO) {
        if ([alertViewController isKindOfClass:[UIAlertController class]]) {
            isAlertViewTextField = YES;
            break;
        }
        alertViewController = [alertViewController nextResponder];
    }
    return isAlertViewTextField;
}

// 是否是搜索框
-(BOOL)isSearchBarTextField:(UIView *)view {
    UIResponder *searchBar = [self nextResponder];
    BOOL isSearchBarTextField = NO;
    while (isSearchBarTextField == NO) {
        if ([searchBar isKindOfClass:[UISearchBar class]]) {
            isSearchBarTextField = YES;
            break;
        } else if ([searchBar isKindOfClass:[UIViewController class]]) {
            break;
        }
        searchBar = [searchBar nextResponder];
    }
    return isSearchBarTextField;
}

- (UIViewController *)viewController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)next;
        }
        next = [next nextResponder];
    } while (next != nil);
    return nil;
}

@end
