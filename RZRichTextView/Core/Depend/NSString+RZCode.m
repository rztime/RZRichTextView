//
//  NSString+RZCode.m
//  RZRichTextView
//
//  Created by xk_mac_mini on 2019/11/11.
//  Copyright © 2019 Rztime. All rights reserved.
//

#import "NSString+RZCode.h"

@implementation NSString (RZCode)
- (NSString *)rz_encodedString {
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)self,
                                                              (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                                              NULL,
                                                              kCFStringEncodingUTF8));
    return encodedString;
}
-(NSString *)rz_decodedString {
    NSString *encodedString = self;
    NSString *decodedString  = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                                                     (__bridge CFStringRef)encodedString,
                                                                                                                     CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    return decodedString;
}
  
@end
