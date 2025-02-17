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

//
//  MainViewController.h
//  Cliplay
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "MainViewController.h"
#import "PostController.h"
#import "ClipPlayController.h"
#import "PlayController.h"
#import "ArticleController.h"
#import "GalleryController.h"
#import "ClipController.h"
#import "AlbumTableViewController.h"


@implementation MainViewController

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Uncomment to override the CDVCommandDelegateImpl used
        // _commandDelegate = [[MainCommandDelegate alloc] initWithViewController:self];
        // Uncomment to override the CDVCommandQueue used
        // _commandQueue = [[MainCommandQueue alloc] initWithViewController:self];	
    }
    return self;
}

- (void)disableScroll {
//	self.webView.scrollView.scrollEnabled = NO;
//	self.webView.scrollView.bounces = NO;
	((UIScrollView*)[self.webView scrollView]).scrollEnabled = NO;
	((UIScrollView*)[self.webView scrollView]).bounces = NO;
}

- (void)showPostView:(NSArray*)list {
	
	UIViewController *top  = [self.navigationController topViewController];
	if([top isKindOfClass:[GalleryController class]]) {
//		NSLog(@"XXXXXXXXXXXXXXXXXXXXXX");
		return;
	}
	
	NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:[[list objectAtIndex:1] dataUsingEncoding: NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
	
	NSArray *images = rootDict[@"image"];
	
	if(images.count > 1) {
		GalleryController *vc = [GalleryController new];
		vc.showInfo = [[list objectAtIndex: 0] boolValue];
		vc.articleURLs = images;
		vc.headerText = rootDict[@"header"];
		
		[self.navigationController pushViewController:vc animated:YES];
		[self.navigationController setNavigationBarHidden:NO];

	}else{
		ClipPlayController *vc = [ClipPlayController new];
		
		vc.clipURL = [images objectAtIndex:0];
		vc.favorite = TRUE;
		vc.showLike = FALSE;
		vc.standalone = TRUE;
		vc.delegate = self;
		
		vc.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self presentViewController:vc animated:YES completion:nil];
	}
}

- (void)showPostView_:(NSArray*)list {
	
	PostController *vc = [PostController new];
	
	NSMutableArray *tempArray = [NSMutableArray arrayWithArray:list];
	
	vc.showInfo = [[list objectAtIndex: 0] boolValue];
	
	[tempArray removeObjectAtIndex: 0];
	
	vc.imageLinks = [NSArray arrayWithArray: tempArray];
	
	[self.navigationController pushViewController:vc animated:YES];
	[self.navigationController setNavigationBarHidden:NO];
	//self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	//self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)showPlayView:(NSArray*)list {
	
	UIViewController *top  = [self.navigationController topViewController];
	if([top isKindOfClass:[PlayController class]]) {
//		NSLog(@"XXXXXXXXXXXXXXXXXXXXXX");
		return;
	}
	
	PlayController *vc = [PlayController new];
	
	NSMutableArray *tempArray = [NSMutableArray arrayWithArray:list];
	
	vc.showInfo = [[list objectAtIndex: 0] boolValue];
	
	[tempArray removeObjectAtIndex: 0];
	
	vc.imageLinks = [NSArray arrayWithArray: tempArray];
	
	[self.navigationController pushViewController:vc animated:YES];
	[self.navigationController setNavigationBarHidden:NO];
	//self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	//self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)showClipView:(NSString*)url {

	ClipPlayController *vc = [ClipPlayController new];

	vc.clipURL = url;
	
	vc.favorite = TRUE;
	vc.showLike = FALSE;
	vc.standalone = TRUE;
	
	vc.modalPresentationStyle = UIModalPresentationCurrentContext;
	
	vc.delegate = self;
	
	[self presentViewController:vc animated:YES completion:nil];
}

- (void)showArticleView:(NSArray*)list {
	
	UIViewController *top  = [self.navigationController topViewController];
	if([top isKindOfClass:[ClipController class]]) {
		return;
	}
	
	ClipController *vc = [ClipController new];
	
	NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:[[list objectAtIndex: 2] dataUsingEncoding: NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
	
	vc.showInfo = [[list objectAtIndex: 0] boolValue];
	vc.postID = [list objectAtIndex: 1];
	vc.articleDicts = rootDict[@"image"];
	vc.header = rootDict[@"header"];
	vc.summary = rootDict[@"summary"];

	[self.navigationController setNavigationBarHidden:NO];
	[self.navigationController pushViewController:vc animated:YES];
	//self.navigationController.navigationBar.tintColor = [UIColor blackColor];
	//self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
}

- (void)showFavoriteView_old{
	
	UIViewController *top  = [self.navigationController topViewController];
	if([top isKindOfClass:[ClipController class]]) {
		return;
	}
	
	ClipController *vc = [ClipController new];
	
	vc.favorite = true;
	
	[self.navigationController setNavigationBarHidden:NO];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)showFavoriteView{
	
	UIViewController *top  = [self.navigationController topViewController];
	if([top isKindOfClass:[AlbumTableViewController class]]) {
		return;
	}
	
//	ClipController *vc = [ClipController new];
//	
//	vc.favorite = true;
	
	UIStoryboard *sb = [UIStoryboard storyboardWithName:@"favorite" bundle:nil];
	UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"list"];
	//	vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
//	[self presentViewController:vc animated:YES completion:NULL];
	[self.navigationController setNavigationBarHidden:NO];
	[self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // View defaults to full size.  If you want to customize the view's size, or its subviews (e.g. webView),
    // you can do so here.

    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	//self.webView.scrollView.scrollEnabled = NO;
	//self.webView.scrollView.bounces = NO;
	//[self.webView stringByEvaluatingJavaScriptFromString:@"alert();"];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return [super shouldAutorotateToInterfaceOrientation:interfaceOrientation];
}

/* Comment out the block below to over-ride */

/*
- (UIWebView*) newCordovaViewWithFrame:(CGRect)bounds
{
    return[super newCordovaViewWithFrame:bounds];
}
*/

#pragma mark UIWebDelegate implementation

- (void)webViewDidFinishLoad:(UIWebView*)theWebView
{
    // Black base color for background matches the native apps
    theWebView.backgroundColor = [UIColor blackColor];

    return [super webViewDidFinishLoad:theWebView];
}

/* Comment out the block below to over-ride */

/*

- (void) webViewDidStartLoad:(UIWebView*)theWebView
{
    return [super webViewDidStartLoad:theWebView];
}

- (void) webView:(UIWebView*)theWebView didFailLoadWithError:(NSError*)error
{
    return [super webView:theWebView didFailLoadWithError:error];
}

- (BOOL) webView:(UIWebView*)theWebView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    return [super webView:theWebView shouldStartLoadWithRequest:request navigationType:navigationType];
}
*/

@end

@implementation MainCommandDelegate

/* To override the methods, uncomment the line in the init function(s)
   in MainViewController.m
 */

#pragma mark CDVCommandDelegate implementation

- (id)getCommandInstance:(NSString*)className
{
    return [super getCommandInstance:className];
}

- (NSString*)pathForResource:(NSString*)resourcepath
{
    return [super pathForResource:resourcepath];
}

@end

@implementation MainCommandQueue

/* To override, uncomment the line in the init function(s)
   in MainViewController.m
 */
- (BOOL)execute:(CDVInvokedUrlCommand*)command
{
    return [super execute:command];
}

@end
