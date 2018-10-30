//
//  RZRichTextViewModel.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichTextViewModel.h"



@implementation RZRichTextViewModel

- (RZRichText *)textModel {
    if (!_textModel) {
        _textModel = [[RZRichText alloc] init];
    }
    return _textModel;
}

- (NSMutableArray<NSString *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
        [self rz_configure];
    }
    return _dataSource;
}

- (void)rz_configure {
    self.dataSource = @[
                        @"RZRichInsertImageCell",
                        @"RZRichBoldCell",
                        @"RZRichItalicCell",
                        @"RZRichUnderLineCell",
                        @"RZRichStrikethroughCell",
                        @"RZRichFontCell",
                        @"RZRichAlignCell",
                        ].mutableCopy;
}

@end
