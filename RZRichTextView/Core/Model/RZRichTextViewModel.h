//
//  RZRichTextViewModel.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h> 
#import "RZRichText.h"
#import "RZDefine.h"

@interface RZRichTextViewModel : NSObject
@property (nonatomic, strong) RZRichText *textModel;
@property (nonatomic, strong) NSMutableArray <NSString *> *dataSource;

@property (nonatomic, copy) void(^rz_insertImage)(UIImage *image);
@property (nonatomic, copy) void(^rz_changeRich)(BOOL changed);

@end
