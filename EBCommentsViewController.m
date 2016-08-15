//
//  EBCommentsViewController.m
//  Cliplay
//
//  Created by 邢磊 on 16/8/12.
//
//

#import "EBCommentsViewController.h"
#import "EBPhotoCommentProtocol.h"
#import "EBCommentCell.h"
#import "EBCommentsView.h"
#import "EBCommentsTableView.h"
#import "FRDLivelyButton.h"

@interface EBCommentsViewController()
@property (nonatomic, strong) FRDLivelyButton *closeButton;
@end

@implementation EBCommentsViewController

- (id)initWithComments:(NSArray *)comments
{
	self = [super init];
	self.comments = comments;
	return self;
}

- (void)initialize
{
	CGRect viewFrame = [[UIScreen mainScreen] bounds];
	UIView *mainView = [[UIView alloc] initWithFrame:viewFrame];
	[self setView:mainView];
}

- (void)viewDidLoad {	
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
//	_size = self.view.frame.size;
	EBCommentsView *commentsView = [self getCommentsView];
	[self.view addSubview:commentsView];
	[self loadCloseButton];
}

- (void)loadCloseButton {
	_closeButton = [[FRDLivelyButton alloc] initWithFrame:CGRectMake(6,16,36,28)];
	[_closeButton setStyle:kFRDLivelyButtonStyleClose animated:NO];
	[_closeButton addTarget:self action:@selector(closeCommentsView) forControlEvents:UIControlEventTouchUpInside];
	[_closeButton setOptions:@{ kFRDLivelyButtonLineWidth: @(2.0f),
								kFRDLivelyButtonColor: [UIColor whiteColor]}];
	
	[self.view addSubview:_closeButton];
}

#pragma mark - (Comments)
- (void)setCommentsHidden:(BOOL)commentsHidden
{
	commentsHidden ? [self hideComments] : [self showComments];
}


- (void)hideComments
{
	//self.commentsAreHidden = YES;
	[self.commentsView setHidden:YES];
}

- (void)showComments
{
	//self.commentsAreHidden = NO;
	[self.commentsView setHidden:NO];
	[self.commentsView setNeedsDisplay];
}

- (void)cancelCommentingWithNotification:(NSNotification *)aNotification
{
	[self.commentsView cancelCommenting];
}

- (void)loadComments:(NSArray *)comments
{
	[self setComments:comments];
	[self.commentsView reloadComments];
}

- (void)setCommentingEnabled:(BOOL)enableCommenting
{
	if(enableCommenting){
		[self.commentsView enableCommenting];
	} else {
		[self.commentsView disableCommenting];
	}
}

- (void)startCommenting
{
	[self.commentsView startCommenting];
}

#pragma mark - Comments Tableview Datasource & Delegate


- (void)deleteCellWithNotification:(NSNotification *)notification
{
	UITableViewCell *cell = notification.object;
	
	if([cell isKindOfClass:[UITableViewCell class]] == NO){
		return;
	}
	
	NSIndexPath *indexPath = [self.commentsView.tableView indexPathForCell:cell];
	
	if(indexPath){
		id<EBPhotoCommentProtocol>deletedComment = self.comments[indexPath.row];
		
		NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:self.comments];
		[remainingComments removeObjectAtIndex:indexPath.row];
		[self setComments:[NSArray arrayWithArray:remainingComments]];
		
		[self.commentsView.tableView beginUpdates];
		[self.commentsView.tableView deleteRowsAtIndexPaths:@[indexPath]
										   withRowAnimation:UITableViewRowAnimationLeft];
		[self.commentsView.tableView endUpdates];
		
		//		[self.delegate photoViewController:self didDeleteComment:deletedComment];
		
		[self updateCommentIcon];
		
		[self.commentsView.tableView reloadData];
		
		//[self reloadData];
	}
}

- (void)updateCommentIcon {
	
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	EBCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	id <EBPhotoCommentProtocol> comment = self.comments[indexPath.row];
	NSAssert([comment conformsToProtocol:@protocol(EBPhotoCommentProtocol)],
			 @"Comment objects must conform to the EBPhotoCommentProtocol.");
	[self configureCell:cell
		 atRowIndexPath:indexPath
			withComment:comment];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	const CGFloat MinimumRowHeight = 60;
	
	id<EBPhotoCommentProtocol> comment = self.comments[indexPath.row];
	CGFloat rowHeight = 0;
	NSString *textForRow = nil;
	
	if([comment respondsToSelector:@selector(attributedCommentText)] &&
	   [comment attributedCommentText]){
		textForRow = [[comment attributedCommentText] string];
	} else {
		textForRow = [comment commentText];
	}
	
	//Get values from the comment cell itself, as an abstract class perhaps.
	//OR better, from reference cells dequeued from the table
	//http://stackoverflow.com/questions/10239040/dynamic-uilabel-heights-widths-in-uitableviewcell-in-all-orientations
	/*
	 NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:textForRow attributes:@{NSFontAttributeName:@"HelveticaNeue-Light"}];
	 
	 CGRect textViewRect = [attributedText boundingRectWithSize:(CGSize){285, CGFLOAT_MAX}
	 options:NSStringDrawingUsesLineFragmentOrigin
	 context:nil];
	 CGSize textViewSize = textViewRect.size;
	 */
	
	CGRect textViewSize = [textForRow boundingRectWithSize:CGSizeMake(285, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:16]} context:nil];
	CGFloat textViewHeight = 25;
	const CGFloat additionalSpace = MinimumRowHeight - textViewHeight + 10;
	
	rowHeight = textViewSize.size.height + additionalSpace;
	
	return rowHeight;
}

- (void)configureCell:(EBCommentCell *)cell
atRowIndexPath:(NSIndexPath *)indexPath
withComment:(id<EBPhotoCommentProtocol>)comment
{
	EBCommentsView *commentsView = [self getCommentsView];
	
	//	BOOL configureCell = [self.delegate respondsToSelector:@selector(photoViewController:shouldConfigureCommentCell:forRowAtIndexPath:withComment:)] ?
	//	[self.delegate photoViewController:self shouldConfigureCommentCell:cell forRowAtIndexPath:indexPath withComment:comment] : YES;
	
	BOOL configureCell = YES;
	
	if([cell isKindOfClass:[EBCommentCell class]] && configureCell){
		[cell setComment:comment];
		[cell setHighlightColor:commentsView.commentCellHighlightColor];
	}
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[cell setBackgroundColor:[UIColor clearColor]];
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	if (action == @selector(copy:)) {
		return YES;
	}
	
	if (action == @selector(delete:)) {
		id<EBPhotoCommentProtocol> commentToDelete = self.comments[indexPath.row];
		if([self canDeleteComment:commentToDelete]){
			return YES;
		}
	}
	
	return NO;
}

- (BOOL)canDeleteComment: (id<EBPhotoCommentProtocol>)comment {
	return TRUE;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
	if (action == @selector(copy:)) {
		id<EBPhotoCommentProtocol> comment = self.comments[indexPath.row];
		NSString *copiedText = nil;
		if([comment respondsToSelector:@selector(attributedCommentText)]){
			copiedText = [[comment attributedCommentText] string];
		}
		
		if(copiedText == nil){
			copiedText = [comment commentText];
		}
		
		[[UIPasteboard generalPasteboard] setString:copiedText];
	} else if (action == @selector(delete:)) {
		[self tableView:tableView
	 commitEditingStyle:UITableViewCellEditingStyleDelete
	  forRowAtIndexPath:indexPath];
	}
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		id<EBPhotoCommentProtocol>deletedComment = self.comments[indexPath.row];
		
		NSMutableArray *remainingComments = [NSMutableArray arrayWithArray:self.comments];
		[remainingComments removeObjectAtIndex:indexPath.row];
		[self setComments:[NSArray arrayWithArray:remainingComments]];
		
		[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
		//		[self.delegate photoViewController:self didDeleteComment:deletedComment];
		[self deleteComment:deletedComment];
	}
	else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
	}
}

- (void)deleteComment: (id<EBPhotoCommentProtocol>)deletedComment {
	
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	// Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
	 // ...
	 // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 */
	NSLog(@"select row");
}

#pragma mark - Comments View Delegate

- (void)commentsView:(id)view didPostNewComment:(NSString *)commentText
{
//		[self.delegate photoViewController:self didPostNewComment:commentText];
	[self postNewComment:commentText];
}

- (void)postNewComment:(NSString *)commentText {
	
}

#pragma mark - Comments UITextViewDelegate

#pragma mark - UITextView Delegate


- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	//clear out text
	[textView setText:nil];
	return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
	//	[[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidBeginCommentingNotification object:self];
	[self.commentsView setInputPlaceholderEnabled:NO];
	[self.commentsView setPostButtonHidden:NO];

}


- (void)textViewDidEndEditing:(UITextView *)textView
{
	//	[[NSNotificationCenter defaultCenter] postNotificationName:EBPhotoViewControllerDidEndCommentingNotification object:self];
	[self.commentsView setInputPlaceholderEnabled:YES];
	[self.commentsView setPostButtonHidden:YES];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
	//check message length
	return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
	if(textView.isFirstResponder){
		if(textView.text == nil || [textView.text isEqualToString:@""]){
			[self.commentsView setPostButtonHidden:YES];
			[self.commentsView setInputPlaceholderEnabled:YES];
		} else {
			[self.commentsView setPostButtonHidden:NO];
			[self.commentsView setInputPlaceholderEnabled:NO];
		}
	}
}

- (EBCommentsView *)getCommentsView {
	
	//	CGSize tableViewSize = CGSizeMake(self.view.frame.size.width,
	//									  self.view.frame.size.height);
	
	if ([self commentsView]) {
		return [self commentsView];
	}else {
		
		CGRect tableViewFrame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
		
		EBCommentsView *commentsView = [[EBCommentsView alloc] initWithFrame:tableViewFrame];
		
		[commentsView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin];
		
		[commentsView.tableView setDataSource:self];
		[commentsView.tableView setDelegate:self];
		[commentsView setCommentCellHighlightColor:[self commentCellTintColor]];
		
		static NSString *CellReuseIdentifier= @"Cell";
		NSAssert([EBCommentCell class],
				 @"If an EBPhotoPagesFactory object doesn't specify a UINib for Comment UITableViewCells it must at least specify a Class to register.");
		[commentsView.tableView registerClass:[EBCommentCell class] forCellReuseIdentifier:CellReuseIdentifier];
		[commentsView.commentTextView setDelegate:self];
		[commentsView setCommentsDelegate:self];
		
		[commentsView setNeedsLayout];
		
		[self setCommentsView: commentsView];
		
//		[commentsView startCommenting];
		
		[self setCommentingEnabled:TRUE];
		
		return commentsView;
	}
}

- (UIColor *)commentCellTintColor
{
	UIColor *photoPagesColor = [self photoPagesTintColor];
	return [photoPagesColor colorWithAlphaComponent:0.35];
}

- (UIColor *)photoPagesTintColor
{
	return [UIColor colorWithWhite:0.99 alpha:1.0];
}

- (void)closeCommentsView {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end