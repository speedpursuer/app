//
//  BottomSheetNewAlbumViewController.m
//  Cliplay
//
//  Created by 邢磊 on 2016/11/26.
//
//

#import "BottomSheetNewAlbumViewController.h"

@interface BottomSheetNewAlbumViewController ()
@property (weak, nonatomic) IBOutlet UITextField *albumTitle;

@end

@implementation BottomSheetNewAlbumViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.title = @"填写收藏夹名称";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(createAlbum)];
		self.contentSizeInPopup = CGSizeMake(0, 100);
		self.landscapeContentSizeInPopup = CGSizeMake(0, 100);
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_albumTitle.delegate = self;
//	_albumTitle.text = @"请输入...";
//	_albumTitle.textColor = [UIColor lightGrayColor];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
	[_albumTitle becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)createAlbum {
	[self.popupController pushViewController:[[UIStoryboard storyboardWithName:@"favorite" bundle:nil] instantiateViewControllerWithIdentifier:@"addDesc"] animated:YES];
}


//- (void)textFieldDidBeginEditing:(UITextField *)textField {
//	if ([_albumTitle.text isEqualToString:@"placeholder text here..."]) {
//		_albumTitle.text = @"";
//		_albumTitle.textColor = [UIColor blackColor]; //optional
//	}
////	[_albumTitle becomeFirstResponder];
//}
//- (void)textFieldDidEndEditing:(UITextField *)textField {
//	if ([_albumTitle.text isEqualToString:@""]) {
//		_albumTitle.text = @"placeholder text here...";
//		_albumTitle.textColor = [UIColor lightGrayColor]; //optional
//	}
////	[_albumTitle resignFirstResponder];
//}

@end
