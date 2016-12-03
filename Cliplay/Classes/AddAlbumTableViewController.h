//
//  AddAlbumTableViewController.h
//  Cliplay
//
//  Created by 邢磊 on 2016/11/23.
//
//

#import <UIKit/UIKit.h>

@interface AddAlbumTableViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) void (^didScrollToTopBlock)();
@end
