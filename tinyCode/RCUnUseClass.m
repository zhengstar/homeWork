//
//  RCUnUseClass.m
//  R360Credit
//
//  Created by zmx on 2019/8/28.
//  Copyright © 2019 Winner. All rights reserved.
//

#import "RCUnUseClass.h"
#import <objc/runtime.h>
#import <dlfcn.h>
#import <mach-o/ldsyms.h>
#import <objc/objc.h>
#import "RDPStatEnumDef.h"
#import "R360Json.h"

@interface RCUnUseClass ()
@property (nonatomic, strong) NSSet *allClassNameSet;
@property (nonatomic, strong) NSMutableSet *unUseClasses;
@property (nonatomic, strong) NSMutableSet *usedClasses;
@property (nonatomic, strong) dispatch_queue_t queue;
@end

@implementation RCUnUseClass
DEF_SINGLETON(RCUnUseClass)

- (instancetype)init {
  self = [super init];
  if (self) {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(enterBackGround)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
  }
  return self;
}

- (void)addUsedClassName:(NSString *)name {
  if (![name isKindOfClass:[NSString class]]) {
    return;
  }
  dispatch_async(self.queue, ^{
    [self.usedClasses addObject:name];
  });
}

- (void)enterBackGround {
  UIApplication *app = [UIApplication sharedApplication];
  __block UIBackgroundTaskIdentifier bgTask;
  bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
    if (bgTask != UIBackgroundTaskInvalid) {
      [app endBackgroundTask:bgTask];
      bgTask = UIBackgroundTaskInvalid;
    }
  }];
  
  dispatch_async(self.queue, ^{
    [self.unUseClasses minusSet:self.usedClasses];
    [self.usedClasses removeAllObjects];
    
    NSString *str = [self.unUseClasses.allObjects JSONRepresentation];
    //上传未使用类到服务器供后续使用
    
    [app endBackgroundTask:bgTask];
    bgTask = UIBackgroundTaskInvalid;
  });
}

- (dispatch_queue_t)queue {
  if (!_queue) {
    _queue = dispatch_queue_create("com.r.unuse", DISPATCH_QUEUE_SERIAL);
    dispatch_set_target_queue(_queue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0));
  }
  return _queue;
}

- (NSMutableSet *)unUseClasses {
  if (!_unUseClasses) {
    _unUseClasses = [[self allClassNameSet] mutableCopy];
  }
  return _unUseClasses;
}

- (NSMutableSet *)usedClasses {
  if (!_usedClasses) {
    _usedClasses = [NSMutableSet set];
  }
  return _usedClasses;
}

- (NSSet *)allClassNameSet {
  if (!_allClassNameSet) {
    unsigned int count;
    const char **classes;
    Dl_info info;
    dladdr(&_mh_execute_header, &info);
    classes = objc_copyClassNamesForImage(info.dli_fname, &count);
    NSMutableSet *set = [NSMutableSet setWithCapacity:count];
    for (int i = 0; i < count; i++) {
      NSString *className = [NSString stringWithCString:classes[i] encoding:NSUTF8StringEncoding];
      [set addObject:className];
    }
    _allClassNameSet = [set copy];
  }
  return _allClassNameSet;
}
@end
