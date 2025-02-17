//
//  PlayController.m
//  YYKitExample
//
//  Created by ibireme on 15/7/19.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "PlayController.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import "YYImageExampleHelper.h"
#import "ClipPlayController.h"
#import "DRImagePlaceholderHelper.h"
#import "DOFavoriteButton.h"
#import "Reachability.h"

#define kCellHeight ceil((kScreenWidth) * 3.0 / 4.0)
#define kScreenWidth ((UIWindow *)[UIApplication sharedApplication].windows.firstObject).width
#define cHeight ([UIScreen mainScreen].bounds.size.height - 64) / 2

@interface PlayControllerCell : UITableViewCell
@property (nonatomic, strong) YYAnimatedImageView *webImageView;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) BOOL downLoaded;
//@property (nonatomic, strong) UIImageView *errPage;
@property (nonatomic, assign) CGFloat scale;
@end

@implementation PlayControllerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	self.backgroundColor = [UIColor whiteColor];
	//	self.backgroundColor = [UIColor clearColor];
	//  self.contentView.backgroundColor = [UIColor clearColor];
	self.contentView.backgroundColor = [UIColor whiteColor];
	self.size = CGSizeMake(kScreenWidth, cHeight);
	self.contentView.size = self.size;
	_webImageView = [YYAnimatedImageView new];
	_webImageView.size = CGSizeMake(kScreenWidth * 0.9, cHeight - 40);
	_webImageView.centerX = self.centerX;
	_webImageView.top = 20;
	_webImageView.clipsToBounds = YES;
	_webImageView.contentMode = UIViewContentModeScaleAspectFill;
	_webImageView.backgroundColor = [UIColor whiteColor];
	[self.contentView addSubview:_webImageView];
	
	
	_indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	_indicator.center = CGPointMake(self.width / 2, self.height / 2);
	_indicator.hidden = YES;
	//    [self.contentView addSubview:_indicator]; //use progress bar instead..
	
//	UIImage *img = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:CGSizeMake(self.width, self.height) text:@""];
//	_errPage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
//	_errPage.image = img;
//	_errPage.hidden = YES;
//	[self.contentView addSubview:_errPage];
	
	_label = [UILabel new];
	_label.size = self.size;
	_label.textAlignment = NSTextAlignmentCenter;
	_label.text = @"下载异常, 点击重试";
	_label.centerX = self.centerX;
	_label.centerY = _webImageView.centerY + _webImageView.height * 0.2;
//	_label.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
	_label.textColor = [UIColor whiteColor];
	_label.hidden = YES;
	_label.userInteractionEnabled = YES;
	[self.contentView addSubview:_label];
	
	
	CGFloat lineHeight = 4;
	_progressLayer = [CAShapeLayer layer];
	_progressLayer.size = CGSizeMake(_webImageView.width, lineHeight);
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0, _progressLayer.height / 2)];
	[path addLineToPoint:CGPointMake(_webImageView.width, _progressLayer.height / 2)];
	_progressLayer.lineWidth = lineHeight;
	_progressLayer.path = path.CGPath;
	//    _progressLayer.strokeColor = [UIColor colorWithRed:0.000 green:0.640 blue:1.000 alpha:0.720].CGColor;
	
	_progressLayer.strokeColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0].CGColor;
	_progressLayer.lineCap = kCALineCapButt;
	_progressLayer.strokeStart = 0;
	_progressLayer.strokeEnd = 0;
	[_webImageView.layer addSublayer:_progressLayer];
	
	__weak typeof(self) _self = self;
	UITapGestureRecognizer *g = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		[_self setImageURL:_self.webImageView.yy_imageURL];
	}];
	[_label addGestureRecognizer:g];
	
	_scale = 1;
	
	return self;
}

- (void)setImageURL:(NSURL *)url {
	
	_label.hidden = YES;
	_indicator.hidden = NO;
//	_errPage.hidden = YES;
	[_indicator startAnimating];
	__weak typeof(self) _self = self;
	
	[CATransaction begin];
	[CATransaction setDisableActions: YES];
	self.progressLayer.hidden = YES;
	self.progressLayer.strokeEnd = 0;
	[CATransaction commit];
	
	_self.downLoaded = FALSE;
	
//	_webImageView.autoPlayAnimatedImage = FALSE;

	
	UIImage *placeholderImage = [[DRImagePlaceholderHelper sharedInstance] placerholderImageWithSize:CGSizeMake(self.width, self.height) text: @"球路"];
	
	[_webImageView yy_setImageWithURL:url
	                           placeholder:placeholderImage
//						  placeholder: nil
							  options:YYWebImageOptionProgressiveBlur |YYWebImageOptionSetImageWithFadeAnimation | YYWebImageOptionShowNetworkActivity
							 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
								 if (expectedSize > 0 && receivedSize > 0) {
									 CGFloat progress = (CGFloat)receivedSize / expectedSize;
									 progress = progress < 0 ? 0 : progress > 1 ? 1 : progress;
									 if (_self.progressLayer.hidden) _self.progressLayer.hidden = NO;
									 _self.progressLayer.strokeEnd = progress;
								 }
							 }
							transform:nil
						   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
							   if (stage == YYWebImageStageFinished) {
								   _self.progressLayer.hidden = YES;
								   [_self.indicator stopAnimating];
								   _self.indicator.hidden = YES;
								   if (!image) {
									   _self.label.hidden = NO;
//									   _self.errPage.hidden = NO;
								   }
								   
								   if(!error) {
									   _self.downLoaded = TRUE;
									   //[self resizeImageView: image.size];
									   __weak typeof(image) _image = image;
									   [_self setImageViewSize: _image.size];
								   }
							   }
						   }];
}

- (void)prepareForReuse {
	//nothing
}

- (void)resizeImageView:(CGSize) size {
	
	CGFloat w = self.size.height * size.width / size.height;
	CGSize newSize = CGSizeMake(w * _scale, self.size.height * _scale);
	_webImageView.size = newSize;
}

- (void) setImageViewSize:(CGSize) size {
	
	__weak typeof(self) _self = self;
	
	CGFloat imageWidthToHeight = size.width / size.height;
	
	CGFloat width = _self.size.width * 0.9;
	CGFloat height = _self.size.height - 40;
	CGFloat margin = _self.size.width * 0.05;
	CGFloat viewWidthToHeight = width / height;
	
	if(viewWidthToHeight > imageWidthToHeight) {
		CGFloat imageViewWidth = height * imageWidthToHeight;
		CGFloat left = (width - imageViewWidth) / 2;
		CGRect frame = CGRectMake(left + margin, 20, imageViewWidth, height);
		_self.webImageView.frame = frame;
		
	}else {
		CGFloat imageViewHeight = width / imageWidthToHeight;
		CGFloat top = (height - imageViewHeight) / 2;
		
//		if(top < 20) top = 20;
//		CGRect frame = CGRectMake(margin, 20, width, imageViewHeight);
		CGRect frame = CGRectMake(margin, top + 20, width, imageViewHeight);
		_self.webImageView.frame = frame;
		
//		if(self.interfaceOrientation == UIInterfaceOrientationPortrait) {
//			CGRect frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height);
//			imageView.frame = frame;
//		}else {
//			CGFloat imageViewHeight = self.view.bounds.size.width / imageWidthToHeight;
//			CGFloat top = (self.view.bounds.size.height - imageViewHeight) / 2;
//			CGRect frame = CGRectMake(0.0f, top, self.view.bounds.size.width, imageViewHeight);
//			_webImageView.frame = frame;
//		}
	}
}

@end

@interface PlayController()<UIGestureRecognizerDelegate>

@end
@implementation PlayController {
	//	CGPoint lastOffset;
	//	BOOL hideBar;
	DOFavoriteButton *infoButton;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == ReachableViaWWAN) {
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 1;
	} else {
		[YYWebImageManager sharedManager].queue.maxConcurrentOperationCount = 2;
	}
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.view.backgroundColor = [UIColor whiteColor];
	self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	
	//hideBar = false;
	
	//UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(reload)];
	//self.navigationItem.rightBarButtonItem = button;
	//self.view.backgroundColor = [UIColor colorWithWhite:0.217 alpha:1.000];
	
	[self addInfoIcon];
	
	if(_showInfo) {
		[self showPopup];
	}
	
	[self.tableView reloadData];
//	[self scrollViewDidScroll:self.tableView];
}

- (void)showPopup {
	
	NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
	paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"操作说明" attributes:@{NSFontAttributeName : [UIFont boldSystemFontOfSize:24], NSParagraphStyleAttributeName : paragraphStyle}];
	NSAttributedString *lineOne = [[NSAttributedString alloc] initWithString:@"单击短片播放/暂停" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
	
//	NSAttributedString *lineOne1 = [[NSAttributedString alloc] initWithString:@"直接滑屏慢放" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSParagraphStyleAttributeName : paragraphStyle}];
	
	NSAttributedString *lineTwo = [[NSAttributedString alloc] initWithString:@"短片上直接滑动慢放" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18], NSForegroundColorAttributeName : [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0], NSParagraphStyleAttributeName : paragraphStyle}];
	
	CNPPopupButton *button = [[CNPPopupButton alloc] initWithFrame:CGRectMake(0, 0, 200, 60)];
	[button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	button.titleLabel.font = [UIFont boldSystemFontOfSize:18];
	[button setTitle:@"知道了" forState:UIControlStateNormal];
	button.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	button.layer.cornerRadius = 4;
	
	UILabel *titleLabel = [[UILabel alloc] init];
	titleLabel.numberOfLines = 0;
	titleLabel.attributedText = title;
	
	UILabel *lineOneLabel = [[UILabel alloc] init];
	lineOneLabel.numberOfLines = 0;
	lineOneLabel.attributedText = lineOne;
	
//	UILabel *lineOneLabel1 = [[UILabel alloc] init];
//	lineOneLabel1.numberOfLines = 0;
//	lineOneLabel1.attributedText = lineOne1;
	
	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tip"]];
	
	UILabel *lineTwoLabel = [[UILabel alloc] init];
	lineTwoLabel.numberOfLines = 0;
	lineTwoLabel.attributedText = lineTwo;
	
	CNPPopupController *popupController = [[CNPPopupController alloc] initWithContents:@[titleLabel, lineOneLabel, lineTwoLabel, imageView, button]];
	popupController.theme = [CNPPopupTheme defaultTheme];
	popupController.theme.popupStyle = CNPPopupStyleCentered;
	popupController.theme.cornerRadius = 10.0f;
	
	popupController.delegate = self;
	
	button.selectionHandler = ^(CNPPopupButton *button){
		[popupController dismissPopupControllerAnimated:YES];
	};
	
	[popupController presentPopupControllerAnimated:YES];
}

- (void)popupControllerDidDismiss:(CNPPopupController *)controller {
	if(!infoButton.selected) [infoButton select];
}

- (void)addInfoIcon {
	
	if(!_showInfo) {
		infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: true];
	}else {
		infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"] selected: false];
	}
	
	//	infoButton = [[DOFavoriteButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 44,[UIApplication sharedApplication].statusBarFrame.size.height, 44, 44) image:[UIImage imageNamed:@"info"]];
	
	infoButton.imageColorOn = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	infoButton.circleColor = [UIColor colorWithRed:255.0 / 255.0 green:64.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	infoButton.lineColor = [UIColor colorWithRed:245.0 / 255.0 green:54.0 / 255.0 blue:0.0 / 255.0 alpha:1.0];
	
	[infoButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
	
	UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
	
	self.navigationItem.rightBarButtonItem = button;
}

- (void)tappedButton:(DOFavoriteButton *)sender {
	[self showPopup];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	_fullScreen = false;
	//self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
	//[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	//    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	//    self.navigationController.navigationBar.tintColor = nil;
	//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
	
	if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) {
		// back button was pressed.  We know this is true because self is no longer
		// in the navigation stack.
		[self.navigationController setNavigationBarHidden:YES];
	}
	
	if(!_fullScreen) {
		[[YYWebImageManager sharedManager].queue cancelAllOperations];
		[[YYImageCache sharedCache].memoryCache removeAllObjects];
	}
}

//- (void) viewDidDisappear:(BOOL)animated {
//	[super viewDidDisappear:animated];
//
//}

- (void)reload {
	[[YYImageCache sharedCache].memoryCache removeAllObjects];
	[[YYImageCache sharedCache].diskCache removeAllObjectsWithBlock:nil];
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.1];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _imageLinks.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return kCellHeight * 0.9 + 20;
	return cHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	PlayControllerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" ];
	
	if (!cell){
		cell = [[PlayControllerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
	}
	
	[cell setImageURL:[NSURL URLWithString:_imageLinks[indexPath.row]]];
	
	[self addClickControlToAnimatedImageView: cell];

	return cell;
}

- (void)addClickControlToAnimatedImageView:(PlayControllerCell *)cell {
	if (!cell) return;
//	cell.webImageView.userInteractionEnabled = YES;
	cell.contentView.userInteractionEnabled = YES;
	__weak typeof(cell.webImageView) _view = cell.webImageView;
	__weak typeof(cell.contentView) _contentView = cell.contentView;
	__weak typeof(cell) _cell = cell;
	
	UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_cell.downLoaded) return;
		
		if ([_view isAnimating]) [_view stopAnimating];
		else [_view startAnimating];
		
		UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
		[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
			_view.layer.transformScale = 0.97 * _cell.scale;
		} completion:^(BOOL finished) {
			[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
				_view.layer.transformScale = 1.008 * _cell.scale;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.1 delay:0 options:op animations:^{
					_view.layer.transformScale = 1 * _cell.scale;
				} completion:NULL];
			}];
		}];
	}];
	
	singleTap.numberOfTapsRequired = 1;
	
	[_contentView addGestureRecognizer:singleTap];

	__weak typeof(self) _self = self;
	
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		
		if(!_cell.downLoaded) return;
		
		[_view stopAnimating];
		
		[_self showClipView:[[_view yy_imageURL] absoluteString]];
	}];
	
	doubleTap.numberOfTapsRequired = 2;
	
	[_contentView addGestureRecognizer:doubleTap];
	
//	[singleTap requireGestureRecognizerToFail:doubleTap];

	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithActionBlock:^(id sender) {
		UIImage<YYAnimatedImage> *image = (id)_view.image;
		if (![image conformsToProtocol:@protocol(YYAnimatedImage)]) return;
		UIPanGestureRecognizer *gesture = sender;
		CGPoint p = [gesture locationInView:gesture.view];
		//        CGFloat progress = p.x / gesture.view.width;
		
		CGFloat progress = 0;
		
		if(p.x < 10 || p.x > gesture.view.width - 10) {
			return;
		}else{
			progress = (p.x - 10) / (gesture.view.width - 20);
		}
		[_view stopAnimating];
		if (gesture.state == UIGestureRecognizerStateBegan) {
			//            [_view stopAnimating];
			_view.currentAnimatedImageIndex = image.animatedImageFrameCount * progress;
		} else if (gesture.state == UIGestureRecognizerStateEnded ||
				   gesture.state == UIGestureRecognizerStateCancelled) {
			//            if (previousIsPlaying) [_view startAnimating];
		} else {
			_view.currentAnimatedImageIndex = image.animatedImageFrameCount * progress;
		}
	}];
//	[_view addGestureRecognizer:pan];
	[_contentView addGestureRecognizer:pan];
	
//	for (UIGestureRecognizer *g in cell.webImageView.gestureRecognizers) {
//		g.delegate = self;
//	}
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//	
//	CGFloat viewHeight = scrollView.height + scrollView.contentInset.top;
//	for (PlayControllerCell *cell in [self.tableView visibleCells]) {
//		CGFloat y = cell.centerY - scrollView.contentOffset.y;
//		CGFloat p = y - viewHeight / 2;
//		CGFloat scale = cos(p / viewHeight * 0.8) * 0.95;
//		cell.scale = scale;
//		[UIView animateWithDuration:0.15 delay:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState animations:^{
//			cell.webImageView.transform = CGAffineTransformMakeScale(scale, scale);
//			cell.errPage.transform = CGAffineTransformMakeScale(scale, scale);
//		} completion:NULL];
//	}
//}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	return NO;
}

//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//	if (scrollView.contentOffset.y < lastOffset.y) {
//		[self hideBar];
//	} else if (scrollView.contentOffset.y > lastOffset.y){
//		[self showBar];
//	}
//}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView
//				 willDecelerate:(BOOL)decelerate {
//	if (scrollView.contentOffset.y < lastOffset.y) {
//		[self hideBar];
//	} else{
//		[self showBar];
//	}
//}
//
//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//	lastOffset = scrollView.contentOffset;
//}
//
//- (BOOL)prefersStatusBarHidden {
//	return hideBar;
//}

//- (void)showBar {
//	[[[self navigationController] navigationBar] setHidden:NO];
//	hideBar = false;
//	[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//}
//
//- (void)hideBar {
//	[[[self navigationController] navigationBar] setHidden:YES];
//	hideBar = true;
//	[self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
//}

- (void)showClipView:(NSString*)url {

	self.fullScreen = true;
	
	ClipPlayController *_clipCtr = [ClipPlayController new];

	_clipCtr.clipURL = url;
	_clipCtr.favorite = TRUE;
	_clipCtr.showLike = FALSE;
	_clipCtr.standalone = false;

	_clipCtr.modalPresentationStyle = UIModalPresentationCurrentContext;
	_clipCtr.delegate = self;

	[self presentViewController:_clipCtr animated:YES completion:nil];
}
//
//- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
//	[self showBar];
//}

@end
