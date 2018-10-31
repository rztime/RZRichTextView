//
//  RZAlignConfigureView.m
//  RZRichTextView
//
//  Created by Admin on 2018/10/31.
//  Copyright © 2018 Rztime. All rights reserved.
//

#import "RZAlignConfigureView.h"
#import <Masonry/Masonry.h>

@interface RZAlignConfigureView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) RZRichTextViewModel *viewModel;
@property (nonatomic, copy) void(^SelectedFinish)(void);

@property (nonatomic, assign) CGFloat loacationX;

@end

@implementation RZAlignConfigureView


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
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(_loacationX, 0, 50, 90) style:UITableViewStylePlain];
        [self addSubview:self.tableView];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_lessThanOrEqualTo(self).offset(locationX);
            make.bottom.equalTo(self).offset(-44);
            make.height.equalTo(@90);
            make.width.equalTo(@50);
            make.right.mas_lessThanOrEqualTo(self).offset(-5);
        }];
    }
    return self;
}

- (void)closeView {
    [self removeFromSuperview];
    self.viewModel.hadShowAlignView = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.imageView.image = rz_rich_imageName([self imageName:indexPath.row]);
    return cell;
}

- (NSString *)imageName:(NSInteger)index {
    NSArray *names = @[@"左对齐", @"中对齐", @"右对齐"];
    return names[index];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        self.viewModel.textModel.aligment = NSTextAlignmentLeft;
    } else if (indexPath.row == 1) {
        self.viewModel.textModel.aligment = NSTextAlignmentCenter;
    } else if (indexPath.row == 2) {
        self.viewModel.textModel.aligment = NSTextAlignmentRight;
    }
    if (self.viewModel.rz_changeRich) {
        self.viewModel.rz_changeRich(YES);
    }
}

- (void)dealloc {
    NSLog(@"字体库被销毁了");
}


@end
