/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import "CDVSplashScreen.h"
#import <Cordova/CDVViewController.h>
#import <Cordova/CDVScreenOrientationDelegate.h>
#import "CDVViewController+SplashScreen.h"



#define kSplashScreenDurationDefault 3000.0f


@implementation CDVSplashScreen

- (void)pluginInitialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pageDidLoad) name:CDVPageDidLoadNotification object:nil];

    [self setVisible:YES];
}

- (void)show:(CDVInvokedUrlCommand*)command
{
    [self setVisible:YES];
}

- (void)hide:(CDVInvokedUrlCommand*)command
{
    [self setVisible:NO];
}

- (void)addProgress:(CDVInvokedUrlCommand*)command
{
	[self showProgressBar];
}

- (void)pageDidLoad
{
    id autoHideSplashScreenValue = [self.commandDelegate.settings objectForKey:[@"AutoHideSplashScreen" lowercaseString]];

    // if value is missing, default to yes
    if ((autoHideSplashScreenValue == nil) || [autoHideSplashScreenValue boolValue]) {
        [self setVisible:NO];
    }
}


- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    [self updateImage];
}

- (void)createViews
{
    /*
     * The Activity View is the top spinning throbber in the status/battery bar. We init it with the default Grey Style.
     *
     *     whiteLarge = UIActivityIndicatorViewStyleWhiteLarge
     *     white      = UIActivityIndicatorViewStyleWhite
     *     gray       = UIActivityIndicatorViewStyleGray
     *
     */

    // Determine whether rotation should be enabled for this device
    // Per iOS HIG, landscape is only supported on iPad and iPhone 6+
    CDV_iOSDevice device = [self getCurrentDevice];
    BOOL autorotateValue = (device.iPad || device.iPhone6Plus) ?
        [(CDVViewController *)self.viewController shouldAutorotateDefaultValue] :
        NO;
    
    [(CDVViewController *)self.viewController setEnabledAutorotation:autorotateValue];

    NSString* topActivityIndicator = [self.commandDelegate.settings objectForKey:[@"TopActivityIndicator" lowercaseString]];
    UIActivityIndicatorViewStyle topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;

    if ([topActivityIndicator isEqualToString:@"whiteLarge"])
    {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    else if ([topActivityIndicator isEqualToString:@"white"])
    {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    }
    else if ([topActivityIndicator isEqualToString:@"gray"])
    {
        topActivityIndicatorStyle = UIActivityIndicatorViewStyleGray;
    }

    UIView* parentView = self.viewController.view;
    parentView.userInteractionEnabled = NO;  // disable user interaction while splashscreen is shown
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:topActivityIndicatorStyle];
    _activityView.center = CGPointMake(parentView.bounds.size.width / 2, parentView.bounds.size.height / 2);
    _activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin
        | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [_activityView startAnimating];

    // Set the frame & image later.
    _imageView = [[UIImageView alloc] init];
    [parentView addSubview:_imageView];

    id showSplashScreenSpinnerValue = [self.commandDelegate.settings objectForKey:[@"ShowSplashScreenSpinner" lowercaseString]];
    // backwards compatibility - if key is missing, default to true
    if ((showSplashScreenSpinnerValue == nil) || [showSplashScreenSpinnerValue boolValue])
    {
        [parentView addSubview:_activityView];
    }

    // Frame is required when launching in portrait mode.
    // Bounds for landscape since it captures the rotation.
    [parentView addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [parentView addObserver:self forKeyPath:@"bounds" options:0 context:nil];

    [self updateImage];
}

- (void)hideViews
{
    [_imageView setAlpha:0];
    [_activityView setAlpha:0];
}

- (void)destroyViews
{
    [(CDVViewController *)self.viewController setEnabledAutorotation:[(CDVViewController *)self.viewController shouldAutorotateDefaultValue]];

    [_imageView removeFromSuperview];
    [_activityView removeFromSuperview];
    _imageView = nil;
    _activityView = nil;
    _curImageName = nil;
	if(activityIndicatorView) {
		[activityIndicatorView removeFromSuperview];
		activityIndicatorView = nil;
	}


    self.viewController.view.userInteractionEnabled = YES;  // re-enable user interaction upon completion
    [self.viewController.view removeObserver:self forKeyPath:@"frame"];
    [self.viewController.view removeObserver:self forKeyPath:@"bounds"];
}

- (CDV_iOSDevice) getCurrentDevice
{
    CDV_iOSDevice device;
    
    UIScreen* mainScreen = [UIScreen mainScreen];
    CGFloat mainScreenHeight = mainScreen.bounds.size.height;
    CGFloat mainScreenWidth = mainScreen.bounds.size.width;
    
    int limit = MAX(mainScreenHeight,mainScreenWidth);
    
    device.iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    device.iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    device.retina = ([mainScreen scale] == 2.0);
    device.iPhone5 = (device.iPhone && limit == 568.0);
    // note these below is not a true device detect, for example if you are on an
    // iPhone 6/6+ but the app is scaled it will prob set iPhone5 as true, but
    // this is appropriate for detecting the runtime screen environment
    device.iPhone6 = (device.iPhone && limit == 667.0);
    device.iPhone6Plus = (device.iPhone && limit == 736.0);
    
    return device;
}

- (NSString*)getImageName:(UIInterfaceOrientation)currentOrientation delegate:(id<CDVScreenOrientationDelegate>)orientationDelegate device:(CDV_iOSDevice)device
{
    // Use UILaunchImageFile if specified in plist.  Otherwise, use Default.
    NSString* imageName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UILaunchImageFile"];
    
    NSUInteger supportedOrientations = [orientationDelegate supportedInterfaceOrientations];
    
    // Checks to see if the developer has locked the orientation to use only one of Portrait or Landscape
    BOOL supportsLandscape = (supportedOrientations & UIInterfaceOrientationMaskLandscape);
    BOOL supportsPortrait = (supportedOrientations & UIInterfaceOrientationMaskPortrait || supportedOrientations & UIInterfaceOrientationMaskPortraitUpsideDown);
    // this means there are no mixed orientations in there
    BOOL isOrientationLocked = !(supportsPortrait && supportsLandscape);
    
    if (imageName)
    {
        imageName = [imageName stringByDeletingPathExtension];
    }
    else
    {
        imageName = @"Default";
    }
    
    if (device.iPhone5)
    { // does not support landscape
        imageName = [imageName stringByAppendingString:@"-568h"];
    }
    else if (device.iPhone6)
    { // does not support landscape
        imageName = [imageName stringByAppendingString:@"-667h"];
    }
    else if (device.iPhone6Plus)
    { // supports landscape
        if (isOrientationLocked)
        {
            imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"")];
        }
        else
        {
            switch (currentOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                        imageName = [imageName stringByAppendingString:@"-Landscape"];
                    break;
                default:
                    break;
            }
        }
        imageName = [imageName stringByAppendingString:@"-736h"];

    }
    else if (device.iPad)
    {   // supports landscape
        if (isOrientationLocked)
        {
            imageName = [imageName stringByAppendingString:(supportsLandscape ? @"-Landscape" : @"-Portrait")];
        }
        else
        {
            switch (currentOrientation)
            {
                case UIInterfaceOrientationLandscapeLeft:
                case UIInterfaceOrientationLandscapeRight:
                    imageName = [imageName stringByAppendingString:@"-Landscape"];
                    break;
                    
                case UIInterfaceOrientationPortrait:
                case UIInterfaceOrientationPortraitUpsideDown:
                default:
                    imageName = [imageName stringByAppendingString:@"-Portrait"];
                    break;
            }
        }
    }
    
    return imageName;
}

// Sets the view's frame and image.
- (void)updateImage
{
    NSString* imageName = [self getImageName:[[UIApplication sharedApplication] statusBarOrientation] delegate:(id<CDVScreenOrientationDelegate>)self.viewController device:[self getCurrentDevice]];

    if (![imageName isEqualToString:_curImageName])
    {
        UIImage* img = [UIImage imageNamed:imageName];
        _imageView.image = img;
        _curImageName = imageName;
    }

    // Check that splash screen's image exists before updating bounds
    if (_imageView.image)
    {
        [self updateBounds];
    }
    else
    {
        NSLog(@"WARNING: The splashscreen image named %@ was not found", imageName);
    }
}

- (void)updateBounds
{
    UIImage* img = _imageView.image;
    CGRect imgBounds = (img) ? CGRectMake(0, 0, img.size.width, img.size.height) : CGRectZero;

    CGSize screenSize = [self.viewController.view convertRect:[UIScreen mainScreen].bounds fromView:nil].size;
    UIInterfaceOrientation orientation = self.viewController.interfaceOrientation;
    CGAffineTransform imgTransform = CGAffineTransformIdentity;

    /* If and only if an iPhone application is landscape-only as per
     * UISupportedInterfaceOrientations, the view controller's orientation is
     * landscape. In this case the image must be rotated in order to appear
     * correctly.
     */
    BOOL isIPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (UIInterfaceOrientationIsLandscape(orientation) && !isIPad)
    {
        imgTransform = CGAffineTransformMakeRotation(M_PI / 2);
        imgBounds.size = CGSizeMake(imgBounds.size.height, imgBounds.size.width);
    }

    // There's a special case when the image is the size of the screen.
    if (CGSizeEqualToSize(screenSize, imgBounds.size))
    {
        CGRect statusFrame = [self.viewController.view convertRect:[UIApplication sharedApplication].statusBarFrame fromView:nil];
        if (!(IsAtLeastiOSVersion(@"7.0")))
        {
            imgBounds.origin.y -= statusFrame.size.height;
        }
    }
    else if (imgBounds.size.width > 0)
    {
        CGRect viewBounds = self.viewController.view.bounds;
        CGFloat imgAspect = imgBounds.size.width / imgBounds.size.height;
        CGFloat viewAspect = viewBounds.size.width / viewBounds.size.height;
        // This matches the behaviour of the native splash screen.
        CGFloat ratio;
        if (viewAspect > imgAspect)
        {
            ratio = viewBounds.size.width / imgBounds.size.width;
        }
        else
        {
            ratio = viewBounds.size.height / imgBounds.size.height;
        }
        imgBounds.size.height *= ratio;
        imgBounds.size.width *= ratio;
    }

    _imageView.transform = imgTransform;
    _imageView.frame = imgBounds;
}

- (void)setVisible:(BOOL)visible
{
    if (visible != _visible)
    {
        _visible = visible;

        id fadeSplashScreenValue = [self.commandDelegate.settings objectForKey:[@"FadeSplashScreen" lowercaseString]];
        id fadeSplashScreenDuration = [self.commandDelegate.settings objectForKey:[@"FadeSplashScreenDuration" lowercaseString]];

        float fadeDuration = fadeSplashScreenDuration == nil ? kSplashScreenDurationDefault : [fadeSplashScreenDuration floatValue];

        if ((fadeSplashScreenValue == nil) || ![fadeSplashScreenValue boolValue])
        {
            fadeDuration = 0;
        }
        else if(fadeDuration < 30)
        {
            // [CB-9750] This value used to be in decimal seconds, so we will assume that if someone specifies 10
            // they mean 10 seconds, and not the meaningless 10ms
            fadeDuration *= 1000;
        }
        
        if (_visible)
        {
            if (_imageView == nil)
            {
                [self createViews];
            }
        }
        else if (fadeDuration == 0)
        {
            [self destroyViews];
        }
        else
        {
            __weak __typeof(self) weakSelf = self;
            [UIView transitionWithView:self.viewController.view
                            duration:(fadeDuration / 1000)
                            options:UIViewAnimationOptionTransitionNone
                            animations:^(void) {
                                [weakSelf hideViews];
                            }
                            completion:^(BOOL finished) {
                                if (finished) {
                                    [weakSelf destroyViews];
                                    // TODO: It might also be nice to have a js event happen here -jm
                                }
                            }
             ];
        }
    }
}

- (void)showProgressBar
{
	if(activityIndicatorView) {
		return;
	}
	UIView* parentView = self.viewController.view;
	
	activityIndicatorView = [[DGActivityIndicatorView alloc] initWithType:(DGActivityIndicatorAnimationType)[@(DGActivityIndicatorAnimationTypeLineScale) integerValue] tintColor:[UIColor whiteColor]];
	
	CGFloat size = parentView.bounds.size.height * 0.1f;
	
	activityIndicatorView.frame = CGRectMake((parentView.bounds.size.width - size) / 2, parentView.bounds.size.height * 0.6, size, size);
	[parentView addSubview:activityIndicatorView];
	[activityIndicatorView startAnimating];
}

@end
