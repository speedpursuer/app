//
//  AlbumViewController.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/30.
//
//

#import "AlbumViewController.h"
#import "Album.h"

@interface AlbumViewController ()
@property (strong, nonatomic) IBOutlet CBLUITableSource *dataSource;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property CBLService *service;
//@property CBLLiveQuery *liveQuery;
@end

@implementation AlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	[self setNavBar];
	[self setup];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resetNavBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setNavBar {
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)resetNavBar {
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		[self.navigationController setNavigationBarHidden:YES];
	}
}

- (void)setup {
	_service = [CBLService sharedManager];
	//	_database = ((CBLService *)[CBLService sharedManager]).database;
	_dataSource.query = [_service queryAllAlbums].asLiveQuery;
	_dataSource.labelProperty = @"title";
	_dataSource.deletionAllowed = YES;
	_dataSource.rowInsertAnimation = UITableViewRowAnimationLeft;
	_dataSource.rowDeleteAnimation = UITableViewRowAnimationRight;
//	self.liveQuery = [cbl queryAllAlbums].asLiveQuery;
//	[self.liveQuery addObserver:self forKeyPath:@"rows" options:0 context:nil];
}

- (void)createListWithTitle:(NSString*)title {
	
	Album *album = [_service creatAlubmWithTitle:title];
	
	NSError *error;
	if (![album save:&error]) {
		NSLog(@"error in saving");
	}
}

- (IBAction)addAlbum:(id)sender {
	UIAlertView* alert= [[UIAlertView alloc] initWithTitle:@"New Album"
												   message:@"Title for new list:"
												  delegate:self
										 cancelButtonTitle:@"Cancel"
										 otherButtonTitles:@"Create", nil];
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	[alert show];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alert didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex > 0) {
		NSString* title = [alert textFieldAtIndex:0].text;
		if (title.length > 0) {
			[self createListWithTitle:title];
		}
	}
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if(section == 0) {
		return 1;
	}else{
		return 7;
	}
}

- (UITableViewCell *)couchTableSource:(CBLUITableSource*)source
				cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:@"album"];
	
	if(indexPath.section == 0) {
		cell.textLabel.text = @"我的最爱";
		cell.imageView.image = nil;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	else {
		CBLQueryRow* row = [self.dataSource rowAtIndex:indexPath.row];
		Album *album = [Album modelForDocument:row.document];
		
		//		Album *album = (self.albums)[indexPath.row];
		
		cell.textLabel.text = album.title;
		//		cell.imageView.image = album.thumb;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		return NO;
	}else{
		return YES;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return nil;
	}else{
		return @"我的收藏夹";
	}
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
