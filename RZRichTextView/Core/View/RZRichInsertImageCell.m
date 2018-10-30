//
//  RZRichInsertImageCell.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZRichInsertImageCell.h"
#import <TZImagePickerController/TZImagePickerController.h>

@implementation RZRichInsertImageCell

- (void)setViewModel:(RZRichTextViewModel *)viewModel {
    [super setViewModel:viewModel];
    
    self.imageView.image = rz_rich_imageName(@"插入图片");
}
- (void)viewDidClicked {
    TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    vc.allowPickingVideo = NO;
    vc.allowTakeVideo = NO;
    vc.allowPickingOriginalPhoto = NO;
    kWeakSelf
    [vc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count == 1) {
            if (weakSelf.viewModel.rz_insertImage) {
                weakSelf.viewModel.rz_insertImage([photos firstObject]);
            }
        } 
    }];
    [self.rz_currentViewController presentViewController:vc animated:YES completion:nil];
}
@end
