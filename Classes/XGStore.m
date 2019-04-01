//
//  XGStore.m
//  KeyValueStore
//
//  Created by Vajra on 2018/1/22.
//  Copyright © 2018年 Vajra. All rights reserved.
//

#import "XGStore.h"
#import "YTKKeyValueStore.h"

@interface XGStore()

@property (nonatomic, strong) YTKKeyValueStore *store;
@property (nonatomic, strong) YTKKeyValueStore *encryptedStore;

@end

@implementation XGStore

static XGStore * _instance = nil;
static NSString * tableName = @"XGStoreTable";

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
        _instance.store = [[YTKKeyValueStore alloc] initDBWithName:@"Storage.db"];
        [_instance.store createTableWithName:tableName];
        
        _instance.encryptedStore = [[YTKKeyValueStore alloc] initDBWithName:@"EncryptedStorage.db" byEncrypted:YES];
        [_instance.encryptedStore createTableWithName:tableName];
    }) ;
    
    return _instance ;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [XGStore shareInstance] ;
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return [XGStore shareInstance] ;
}

// MARK: - methods
/**
 存储数据

 @param object 需要将存储的数据及key包装成Dictionary进行存储
               例如要存储key为@"key"，value为[@"1", @"2"]的数组，则此参数需要封装成@{@"key": @[@"1", @"2"]}
 @param isEncrypted 是否需要加密存储
 @return 操作是否成功
 */
- (BOOL)putObject:(NSDictionary *)object withEncrypted:(BOOL)isEncrypted {
    NSString *key = (NSString *)object.allKeys.firstObject;
    [self removeObjectForKey:key];
    if (isEncrypted) {
        return [self.encryptedStore putObject:object withId:key intoTable:tableName];
    } else {
        return [self.store putObject:object withId:key intoTable:tableName];
    }
    
}

/**
 根据key获取对应存储的值

 @param key 存储时的key
 @return 获取的存储的对象
 */
- (id)getObjectForKey:(NSString *)key {
    NSDictionary *object = (NSDictionary *)[self.store getObjectById:key fromTable:tableName];
    if (!object) {
        object = (NSDictionary *)[self.encryptedStore getObjectById:key fromTable:tableName];
    }
    id value = object[key];
    return value;
}

/**
 获取所有存储的key

 @return 所有已经存储的key数组
 */
- (NSArray *)allKeys {
    NSArray *normalItems = [self.store getAllItemsFromTable:tableName];
    NSArray *encryptedItems = [self.encryptedStore getAllItemsFromTable:tableName];
    NSMutableArray *keys = [NSMutableArray array];
    for (YTKKeyValueItem *item in normalItems) {
        [keys addObject:item.itemId];
    }
    for (YTKKeyValueItem *item in encryptedItems) {
        [keys addObject:item.itemId];
    }
    return [keys copy];
}

/**
 清楚所有存储

 @return 操作是否成功
 */
- (BOOL)clear {
    BOOL clearNormal = [self.store clearTable:tableName];
    BOOL clearEncrypted = [self.encryptedStore clearTable:tableName];
    return clearNormal && clearEncrypted;
}

/**
 删除key对应的存储数据

 @param key 需要删除的数据的key
 @return 操作是否成功
 */
- (BOOL)removeObjectForKey:(NSString *)key {
    BOOL deleteNormal = [self.store deleteObjectById:key fromTable:tableName];
    BOOL deleteEncrypted = [self.encryptedStore deleteObjectById:key fromTable:tableName];
    return deleteNormal || deleteEncrypted;
}

/**
 批量删除存储数据

 @param keys 需要删除的数据的key的数组
 @return 操作是否成功
 */
- (BOOL)removeObjectsForKeys:(NSArray *)keys {
    BOOL deleteNormal = [self.store deleteObjectsByIdArray:keys fromTable:tableName];
    BOOL deleteEncrypted = [self.encryptedStore deleteObjectsByIdArray:keys fromTable:tableName];
    return deleteNormal || deleteEncrypted;
}

@end
