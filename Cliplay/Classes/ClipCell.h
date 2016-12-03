//
//  ClipCell.h
//  Cliplay
//
//  Created by 邢磊 on 16/8/18.
//
//

#import <Foundation/Foundation.h>
#import <YYWebImage/YYWebImage.h>
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "DOFavoriteButton.h"
#import "TTTAttributedLabel.h"
#import "ArticleEntity.h"
#import "ClipController.h"

@interface ClipCell : UITableViewCell
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL downLoaded;
@property (nonatomic, strong) DOFavoriteButton *heartButton;
@property (nonatomic, strong) UIButton *commentBtn;
@property (nonatomic, strong) UIButton *shareBtn;
@property (nonatomic, strong) UIButton *albumBtn;
@property (nonatomic, weak) ClipController *delegate;
- (void)setCellData:(ArticleEntity*) entity isForHeight:(BOOL)isForHeight;
- (void)updateCommentQty;
@end

@interface TitleCell : UITableViewCell
@property (nonatomic, strong) TTTAttributedLabel *imageLabel;
- (void)setCellData:(ArticleEntity*) entity isForHeight:(BOOL)isForHeight;
@end
