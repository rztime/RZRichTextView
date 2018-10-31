//
//  RZFontConfigureView.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/30.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZFontConfigureView.h"
#import <Masonry/Masonry.h>

@interface RZFontConfigureView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *fontSizeTableView;
@property (nonatomic, strong) UITableView *fontColorTableView;

@property (nonatomic, strong) RZRichTextViewModel *viewModel;
@property (nonatomic, copy) void(^SelectedFinish)(void);

@property (nonatomic, assign) CGFloat loacationX;

@end

@implementation RZFontConfigureView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame viewModel:(RZRichTextViewModel *)viewModel locationX:(CGFloat)locationX {
    if (self = [super initWithFrame:frame]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:btn];
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        [btn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
        
        self.viewModel = viewModel;
        self.loacationX = locationX;
        
        self.fontSizeTableView = [[UITableView alloc] initWithFrame:CGRectMake(_loacationX, 0, 50, 100) style:UITableViewStylePlain];
        [self addSubview:self.fontSizeTableView];
        self.fontSizeTableView.delegate = self;
        self.fontSizeTableView.dataSource = self;
        
        self.fontColorTableView = [[UITableView alloc] initWithFrame:CGRectMake(_loacationX + 100, 0, 50, 100) style:UITableViewStylePlain];
        [self addSubview:self.fontColorTableView];
        self.fontColorTableView.delegate = self;
        self.fontColorTableView.dataSource = self;
        
        [self.fontSizeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_lessThanOrEqualTo(self).offset(locationX);
            make.bottom.equalTo(self).offset(-44);
            make.height.equalTo(@150);
            make.width.equalTo(@50);
        }];
        
        [self.fontColorTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.fontSizeTableView.mas_right).offset(5);
            make.bottom.equalTo(self).offset(-44);
            make.height.equalTo(@150);
            make.width.equalTo(@60);
            make.right.mas_lessThanOrEqualTo(self).offset(-15);
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSInteger row = self.viewModel.textModel.fontSize - 10;
            if (row < 0) {
                row = 0;
            }
            if (row > 65) {
                row = 65;
            }
            [self.fontSizeTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        });
    }
    return self;
}

- (void)closeView {
    [self removeFromSuperview];
    self.viewModel.hadShowFontView = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.fontSizeTableView) {
        return 66;
    }
    return self.colors.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (tableView == self.fontSizeTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.textLabel.font = RZFontNormal(14);
        }
        NSInteger size = 10 + indexPath.row;
        if (size == self.viewModel.textModel.fontSize) {
            cell.textLabel.textColor = krz_rich_theme_color;
        } else {
            cell.textLabel.textColor = krz_rich_defult_color;
        }
        cell.textLabel.text = [NSString stringWithFormat:@"%ld", size];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            UIView *view = [[UIView alloc] init];
            [cell.contentView addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(cell.contentView);
                make.width.height.equalTo(@20);
            }];
            view.tag = 10;
            view.layer.borderWidth = 1;
            view.layer.borderColor = rgb(225, 225, 225).CGColor;
        }
        UIView *view = [cell.contentView viewWithTag:10];
        NSArray *colors = self.colors[indexPath.row];
        view.backgroundColor = colors[1];
        return cell;
    }
    
}

- (NSArray *)colors {
    return @[
             @[@"黑", rgb(0, 0, 0)], 
             @[@"灰1", rgb(51, 51, 51)],
             @[@"灰2", rgb(102, 102, 102)],
             @[@"灰3", rgb(153, 153, 153)],
             @[@"灰4", rgb(204, 204, 204)],
             @[@"白", rgb(238, 238, 238)],
             @[@"红", rgb(255, 0, 0)],
             @[@"橙", rgb(255, 156, 0)],
             @[@"黄", rgb(255, 255, 0)],
             @[@"绿", rgb(0, 255, 0)],
             @[@"青", rgb(0, 255, 255)],
             @[@"蓝", rgb(0, 0, 255)],
             @[@"紫", rgb(255, 0, 255)],
             ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.fontSizeTableView) {
        self.viewModel.textModel.fontSize = 10 + indexPath.row;
        [tableView reloadData]; 
    } else {
        NSArray *colors = self.colors[indexPath.row];
        self.viewModel.textModel.textColor = colors[1];
    }

    if (self.viewModel.rz_changeRich) {
        self.viewModel.rz_changeRich(YES);
    }
}

- (void)dealloc {
    NSLog(@"字体库被销毁了");
}

@end
