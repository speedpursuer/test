//
//  FavoriateMgr.m
//  Cliplay
//
//  Created by 邢磊 on 16/4/29.
//
//

#import "FavoriateMgr.h"

@implementation FavoriateMgr

static FavoriateMgr *sharedObject = nil;
static NSUserDefaults *userDefaults = nil;
static NSString* const key = @"favorite";

+ (FavoriateMgr *)sharedInstance
{
	static dispatch_once_t _singletonPredicate;
	
	dispatch_once(&_singletonPredicate, ^{
		sharedObject = [[self alloc] init];
	});
	
	return sharedObject;
}

- (id)init
{
	self = [super init];
	if (self) {
		userDefaults = [NSUserDefaults standardUserDefaults];
		NSArray *array = [userDefaults arrayForKey:key];
		
		if(array != nil) {
			images = [NSMutableArray arrayWithArray:array];
		}else {
			images = [NSMutableArray array];
		}
	}
	return self;
}

- (void)setFavoriate:(NSString *)url {
	if(![self isFavoriate:url]) {
		[images insertObject:url atIndex: 0];
	}
}

- (void)persistData {
	[userDefaults setObject:[images copy] forKey:key];
	[userDefaults synchronize];
}

- (void)unsetFavoriate:(NSString *)url {
	[images removeObject: url];
}

- (NSArray *)getFavoriateImages {
	return (NSArray *)[images copy];
}

- (BOOL)isFavoriate:(NSString *)url {
	return ([images indexOfObject:url] != NSNotFound);
}
@end