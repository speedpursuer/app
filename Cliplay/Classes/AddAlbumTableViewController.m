//
//  AddAlbumTableViewController.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/23.
//
//

#import "AddAlbumTableViewController.h"
#import "Album.h"

@interface AddAlbumTableViewController ()
@property (nonatomic, strong) NSMutableArray *albums;
@end

@implementation AddAlbumTableViewController

- (instancetype)init
{
	self = [super init];
	if (self) {
		[self initialize];
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self loadTableView];
	[self initData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)initialize {
	[self loadTableView];
	[self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadTableView
{
	CGRect tableViewFrame = CGRectMake(0, 0, 320, 300);
	_tableView = [[UITableView alloc] initWithFrame:tableViewFrame
																		  style:UITableViewStylePlain];
//	[tableView setBackgroundColor:[UIColor clearColor]];
//	[tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
//	[tableView setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
//	[_tableView setContentInset:UIEdgeInsetsMake(70, 0, 0, 0)];
//	[_tableView setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth];
//	[self setTableView:tableView];
	[_tableView setDelegate:self];
	[_tableView setDataSource:self];
//	[_tableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
//	[self.view addSubview:_tableView];
}

- (void)initData {
	
	_albums = [NSMutableArray arrayWithCapacity:60];
	
	[_albums addObject:[Album initWithTitle:@"新建歌单"]];
	
	for(int i=0; i<8; i++) {
		//		Album *album = [[Album alloc] init];
		//		NSNumber *index = [NSNumber numberWithInt:i];
		//		album.title = [index stringValue];
		//		album.thumb = [UIImage imageNamed:@"finger"];
		[_albums addObject:[Album initWithTitle:[[NSNumber numberWithInt:i] stringValue]]];
	}
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_albums count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCell"];
	
	if (!cell){
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addCell"];
	}
	
	Album *album = (self.albums)[indexPath.row];
	cell.textLabel.text = album.title;
	
	return cell;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
	NSLog(@"scroll to top");
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	NSLog(@"scrollViewWillBeginDragging, contentOffset = %f", scrollView.contentOffset.y);
	if(scrollView.contentOffset.y == 0) {
		if(self.didScrollToTopBlock) {
			self.didScrollToTopBlock();
		}		
	}
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	return @"加入收藏夹";
//}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
