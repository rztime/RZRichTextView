//
//  RZDefine.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#ifndef RZDefine_h
#define RZDefine_h

#define rz_rich_imageName(name) [UIImage imageNamed:[NSString stringWithFormat:@"RZRichSources.bundle/%@", name]]
#define RZFontBold(size) [UIFont boldSystemFontOfSize:size]
#define RZFontNormal(size) [UIFont systemFontOfSize:size]

#define rgb(r, g, b) rgba(r, g, b, 1)
#define rgba(r, g , b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define krz_rich_theme_color rgb(57, 136, 251)
#define krz_rich_defult_color rgb(102, 102, 102)

#define kWeakSelf __weak typeof(self) weakSelf = self;

#import "NSObject+RZCategoryTools.h"

#endif /* RZDefine_h */
