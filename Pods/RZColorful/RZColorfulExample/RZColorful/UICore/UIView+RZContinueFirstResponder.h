//
//  UIView+RZContinueFirstResponder.h
//  TextInputViewFocusDemo
//
//  Created by rztime on 2017/11/10.
//  Copyright © 2017年 rztime. All rights reserved.
//


/******************
 在如tableview中加入了大量的输入框时，可以在[rzContinueFirstResponderAndExecuteCode]方法中写入刷新代码，那么刷新之后输入框焦点不会丢失，且设置UIViewResponderHelper时，可以指定刷新后焦点指定到特定的输入框
*******************/

#import <UIKit/UIKit.h>

@interface UIViewResponderHelper : NSObject

/**
 指定下一个响应的tagIdentity
 */
@property (nonatomic, copy) NSString *nextFirstResponderTagIdentity;


/**
 指定下一个响应的index  如果设置了nextFirstResponderTagIdentity 则优先设置到nextFirstResponderTagIdentity
 */
@property (nonatomic, assign) NSInteger nextFirstResponderIndex;

@end

#pragma mark - 让view中的第一响应者在刷新界面过后依然保持第一响应
@interface UIView (RZContinueFirstResponder)

/**
 扩展的身份标志，唯一
 如果需要精准的在刷新界面之后，还原到之前的第一响应，或者指定下一个响应，则需要设置此id
 如果未设置，则默认按照刷新前在view中的排位index，刷新之后依然按照此index还原第一响应
 如果新增了或者删除了，要精确还原到原第一响应，则需要设置此id，除非是加在当前第一响应者的下边
 */
@property (nonatomic, copy) NSString *tagIdentity;


/**
 刷新界面的扩展方法 将刷新界面的code写在这个code的block中，
 
 放心使用，没有循环引用的问题
 
 如果确定是scrollview 如tableivew或者collectionview，则最好直接使用[tableview rzContinueFirstResponderAndExecuteCode]来刷新，这样获取界面的可响应者时，效率更高
 @param code nextResponder指定下一个需要响应的方法 
 */
- (void)rzContinueFirstResponderAndExecuteCode:(void (^)(UIViewResponderHelper *nextResponder))code;

@end
