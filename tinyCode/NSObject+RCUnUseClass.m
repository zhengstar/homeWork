//
//  NSObject+RCUnUseClass.m
//  R360Credit
//
//  Created by zmx on 2019/8/28.
//  Copyright © 2019 Winner. All rights reserved.
//

#import "NSObject+RCUnUseClass.h"
#import "RCUnUseClass.h"
#import <objc/runtime.h>

@implementation NSObject (RCUnUseClass)

+ (void)cus_initialize {
  NSString *className = NSStringFromClass(self);
  if ([[RCUnUseClass sharedInstance].allClassNameSet containsObject:className]) {
    [[RCUnUseClass sharedInstance] addUsedClassName:className];
  }
}

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    Class class = [self class];
    SEL originalSEL = @selector(initialize);
    SEL swizzledSEL = @selector(cus_initialize);
    
    Method originalMethod = class_getClassMethod(class, originalSEL);
    Method swizzledMethod = class_getClassMethod(class, swizzledSEL);
    
    Class metaClass = object_getClass(class);
    
    BOOL didAddMethod =
    class_addMethod(metaClass,
                    originalSEL,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
      class_replaceMethod(metaClass,
                          swizzledSEL,
                          method_getImplementation(originalMethod),
                          method_getTypeEncoding(originalMethod));
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod);
    }
  });
}
@end
