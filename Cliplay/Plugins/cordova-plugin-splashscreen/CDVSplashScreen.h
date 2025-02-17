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

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import "DGActivityIndicatorView.h"

typedef struct {
    BOOL iPhone;
    BOOL iPad;
    BOOL iPhone5;
    BOOL iPhone6;
    BOOL iPhone6Plus;
    BOOL retina;
    
} CDV_iOSDevice;

@interface CDVSplashScreen : CDVPlugin {
    UIActivityIndicatorView* _activityView;
    UIImageView* _imageView;
    NSString* _curImageName;
    BOOL _visible;
	DGActivityIndicatorView *activityIndicatorView;
}

- (void)show:(CDVInvokedUrlCommand*)command;
- (void)hide:(CDVInvokedUrlCommand*)command;
- (void)addProgress:(CDVInvokedUrlCommand*)command;
@end
