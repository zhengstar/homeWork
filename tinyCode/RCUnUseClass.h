//
//  RCUnUseClass.h
//  R360Credit
//
//  Created by zmx on 2019/8/28.
//  Copyright © 2019 Winner. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCUnUseClass : NSObject
DEC_SINGLETON(RCUnUseClass)
@property (nonatomic, strong, readonly) NSSet *allClassNameSet;
- (void)addUsedClassName:(NSString *)name;

@end

