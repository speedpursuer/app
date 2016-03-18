//
//  YYImageExample.m
//  YYKitExample
//
//  Created by ibireme on 15/7/18.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYImageExample.h"
#import "YYImage.h"
#import "UIView+YYAdd.h"
#import <ImageIO/ImageIO.h>
#import <WebP/demux.h>
#import "YYWebImageExample.h"

@interface YYImageExample()
@property (nonatomic, strong) NSMutableArray *titles;
@property (nonatomic, strong) NSMutableArray *classNames;
@end

@implementation YYImageExample{
	NSArray *list;
}

- (void)viewDidLoad {
    self.title = @"YYWebImage Demo";
    [super viewDidLoad];
    self.titles = @[].mutableCopy;
    self.classNames = @[].mutableCopy;
//    [self addCell:@"Animated Image" class:@"YYImageDisplayExample"];
//    [self addCell:@"Progressive Image" class:@"YYImageProgressiveExample"];
    [self addCell:@"Web Image1" class:@"YYWebImageExample"];
	[self addCell:@"Web Image2" class:@"YYWebImageExample"];
	[self addCell:@"Web Image3" class:@"YYWebImageExample"];
    //[self addCell:@"Benchmark" class:@"YYImageBenchmark"];
    [self.tableView reloadData];
	list = @[
		@[
		  @"http://i1.hoopchina.com.cn/u/1209/28/090/3862090/9f626780.gif",
		  @"http://i1.hoopchina.com.cn/u/1209/28/090/3862090/2e9e782a.gif",
		  @"http://i1.hoopchina.com.cn/u/1209/28/090/3862090/79692f49.gif",
		  @"http://i1.hoopchina.com.cn/user/090/3862090/1290442077391dd.gif"
		],
		@[
		  @"http://i1.hoopchina.com.cn/u/1209/16/090/3862090/64d0db32.gif",
		  @"http://i1.hoopchina.com.cn/u/1111/25/090/3862090/831526f8.gif",
		  @"http://i1.hoopchina.com.cn/u/1111/25/090/3862090/3dc78f7d.gif",
		  @"http://i1.hoopchina.com.cn/user/090/3862090/1290441758de38f.gif"
		],
		@[
		  @"http://i1.hoopchina.com.cn/u/1111/25/090/3862090/288aa545.gif",
		  @"http://i1.hoopchina.com.cn/u/1111/25/090/3862090/f46b6dee.gif",
		  @"http://i1.hoopchina.com.cn/u/1111/25/090/3862090/5807cae1.gif",
		  @"http://i1.hoopchina.com.cn/user/090/3862090/1290442364d7a09.gif"
		]
	];

}

- (void)addCell:(NSString *)title class:(NSString *)className {
    [self.titles addObject:title];
    [self.classNames addObject:className];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YY"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YY"];
    }
    cell.textLabel.text = _titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *className = self.classNames[indexPath.row];
    Class class = NSClassFromString(className);
    if (class) {
        YYWebImageExample *ctrl = class.new;
        ctrl.title = _titles[indexPath.row];
		ctrl.imageLinks = list[indexPath.row];
		[self.navigationController pushViewController:ctrl animated: YES];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
