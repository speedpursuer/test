//
//  Created by Eddy Borja.
//  Copyright (c) 2014 Eddy Borja. All rights reserved.
//
/*
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */


#import <UIKit/UIKit.h>
#import <JTTableViewController.h>
#import "EBCommentsViewDelegate.h"
#import "ClipController.h"
#import "MyLBDelegate.h"

#define COMMENT_CHART_LIMIT       140

@class EBCommentsView;
//@interface EBCommentsViewController: JTTableViewController <UITextViewDelegate, UITableViewDelegate, UITableViewDataSource, EBCommentsViewDelegate>

@interface EBCommentsViewController: JTTableViewController <UITextViewDelegate,EBCommentsViewDelegate, CommentDelegate>


@property (weak) ClipController *delegate;
@property (weak, readwrite) EBCommentsView *commentsView;
//@property (weak, readonly) EBCommentsView *commentsView;
@property (strong) NSString *clipID;
@property (strong) NSArray *comments;

- (id)init;
- (EBCommentsView *)getCommentsView;
- (void)deleteCellWithNotification:(NSNotification *)notification;
- (void)setCommentsHidden:(BOOL)commentsHidden;
- (void)loadComments:(NSArray *)comments;
- (void)setCommentingEnabled:(BOOL)enableCommenting;
- (void)hideComments;
- (void)showComments;
- (void)cancelCommentingWithNotification:(NSNotification *)notification;
@end
