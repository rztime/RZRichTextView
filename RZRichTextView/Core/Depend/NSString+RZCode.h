//
//  NSString+RZCode.h
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/11/11.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (RZCode)
// 对string进行URL encode转码
- (NSString *)rz_encodedString;
// 对string进行URL decode解码
- (NSString *)rz_decodedString;
@end

NS_ASSUME_NONNULL_END
