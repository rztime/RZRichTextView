//
//  RZRichSelectionCell.h
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RZRichTextViewModel.h"
#import <RZColorful/RZColorful.h>

@interface RZRichSelectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;


@property (nonatomic, strong) RZRichTextViewModel *viewModel;

- (void)viewDidClicked;

@end
