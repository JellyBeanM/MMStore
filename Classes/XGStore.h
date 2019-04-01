//
//  XGStore.h
//  KeyValueStore
//
//  Created by Vajra on 2018/1/22.
//  Copyright © 2018年 Vajra. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XGStore: NSObject

+ (instancetype)shareInstance;

- (BOOL)putObject:(NSDictionary *)object withEncrypted:(BOOL)isEncrypted;
- (id)getObjectForKey:(NSString *)key;
- (NSArray *)allKeys;
- (BOOL)clear;
- (BOOL)removeObjectForKey:(NSString *)key;
- (BOOL)removeObjectsForKeys:(NSArray *)keys;


@end
