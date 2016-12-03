//
//  AlbumAddClipDescViewController.h
//  Cliplay
//
//  Created by 邢磊 on 2016/11/26.
//
//

#import <UIKit/UIKit.h>

@interface AlbumAddClipDescViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *desc;
@property NSString *url;
@property BOOL shouldSave;
@end
