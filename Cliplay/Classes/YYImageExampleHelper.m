//
//  YYImageExampleUtils.m
//  YYKitExample
//
//  Created by ibireme on 15/7/20.
//  Copyright (c) 2015 ibireme. All rights reserved.
//

#import "YYImageExampleHelper.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+YYAdd.h"
#import "CALayer+YYAdd.h"
#import "UIGestureRecognizer+YYAdd.h"
#import <ImageIO/ImageIO.h>
#import <Accelerate/Accelerate.h>
#import "ClipPlayController.h"
#import "ClipPlayController.h"
#import "MainViewController.h"
//#import <bpg/libbpg.h>

@implementation YYImageExampleHelper

+ (void)addTapControlToAnimatedImageView:(YYAnimatedImageView *)view {
    if (!view) return;
    view.userInteractionEnabled = YES;
    __weak typeof(view) _view = view;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
        if ([_view isAnimating]) [_view stopAnimating];
        else  [_view startAnimating];
        
        // add a "bounce" animation
        UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
        [UIView animateWithDuration:0.1 delay:0 options:op animations:^{
            _view.layer.transformScale = 0.97;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 delay:0 options:op animations:^{
                _view.layer.transformScale = 1.008;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 delay:0 options:op animations:^{
                    _view.layer.transformScale = 1;
                } completion:NULL];
            }];
        }];
    }];
	
	tap.numberOfTapsRequired = 1;
	
    [view addGestureRecognizer:tap];
}

+ (void)addPanControlToAnimatedImageView:(YYAnimatedImageView *)view {
    if (!view) return;
    view.userInteractionEnabled = YES;
    __weak typeof(view) _view = view;    
    __block BOOL previousIsPlaying;
    
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
            previousIsPlaying = [_view isAnimating];
//            [_view stopAnimating];
            _view.currentAnimatedImageIndex = image.animatedImageFrameCount * progress;
        } else if (gesture.state == UIGestureRecognizerStateEnded ||
                   gesture.state == UIGestureRecognizerStateCancelled) {
//            if (previousIsPlaying) [_view startAnimating];
        } else {
            _view.currentAnimatedImageIndex = image.animatedImageFrameCount * progress;
        }
    }];
    [view addGestureRecognizer:pan];    
}

@end
