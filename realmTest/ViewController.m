//
//  ViewController.m
//  realmTest
//
//  Created by 崔小舟 on 2018/4/17.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "ViewController.h"
#import <Realm.h>
#import "PersonModel.h"
#import "DogModel.h"

#define MkdirInDirectory(dir) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent: dir];

static NSString * const CONFIG_REALM_FILE_PATH = @"config.realm";
static NSString * const REALM_IN_MEMORY_IDEF = @"realm_in_momery_idef";

@interface ViewController ()

//default config for realm
@property (nonatomic, strong) RLMRealm *d_realm;

//realm with config
@property (nonatomic, strong) RLMRealm *realm;

//realm in memory
@property (nonatomic, strong) RLMRealm *memRealm;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self deleteRealmFiles];
    
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"default config realm file path == %@", self.d_realm.configuration.fileURL.absoluteString);
    
    NSLog(@"manual config realm file path == %@", self.realm.configuration.fileURL.absoluteString);
#endif
    
    //TODO: 数据库迁移
    //TODO: 数据库耗时操作async操作
    //TODO: realm官网 ：https://realm.io/docs/objc/latest/  -- command + F =  Asynchronously opening Realms  数据库耗时操作的lock与异步
    
//    for (int i = 0; i < 10; i++) {
//        PersonModel *p = [[PersonModel alloc] init];
//        p.uId = i + 1;
//        p.name = [NSString stringWithFormat: @"张三%d", i];
//        p.age = arc4random() % 10 + 10;
//        p.childCount = [NSNumber numberWithInteger: (arc4random() % 3 + 1)];
//        [self addOrUpdateObject: p];
//    }
    
    
    
    
    
    
    
}


#pragma mark - 数据库迁移
//在对已经存在的realm db model 进行 新增属性，修改属性，删除属性，属性重命名时需要进行数据库迁移
//正常情况下下面代码放在appdelete里
//这里对 defaultRealm 进行数据库迁移
//对personModel新增property firstName
- (void)migrationRealm {
    
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    config.schemaVersion = 1;   //db current version
    
    config.migrationBlock = ^(RLMMigration * _Nonnull migration, uint64_t oldSchemaVersion) {
        //假设config.schemaVersion == 5
        //用户有可能存在 schemaVersion == 1 || == 2 || == 3 || == 4，因为用户appVersion不同，有些用户可能喜欢保持最新版本，用些用户则很久更新一次
        //根据实际情况对不同版本进行兼容，这里只对 schemaVersion == 0 进行迁移
        
        if (oldSchemaVersion < 1) {
            [migration enumerateObjects: PersonModel.className block:^(RLMObject * _Nullable oldObject, RLMObject * _Nullable newObject) {
                newObject[@"firstName"] = @"schemaVersion1";
            }];
        }
    };
    
    [RLMRealmConfiguration setDefaultConfiguration: config];
    [RLMRealm defaultRealm];
}

#pragma mark - 删除realm文件

/**
 1.删除.realm时同时要删除配置文件，包括
 .realm.lock - A lock file for resource locks.
 .realm.management - Directory of interprocess lock files.
 .realm.note - A named pipe for notifications.
 2.删除.realm时不能有打开的realm db ，不能有从数据库中读取到内存中的对象包括 RLMArray, RLMResults, RLMThreadSafeReference etc，所以建议在AppDelegate didFinishLaunchingWithOptions中删除
 */
- (void)deleteRealmFiles {
    NSFileManager *manager = [NSFileManager defaultManager];
    RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
    NSArray<NSURL *> *realmFileURLs = @[
                                        config.fileURL,
                                        [config.fileURL URLByAppendingPathExtension:@"lock"],
                                        [config.fileURL URLByAppendingPathExtension:@"note"],
                                        [config.fileURL URLByAppendingPathExtension:@"management"]
                                        ];
    for (NSURL *URL in realmFileURLs) {
        NSError *error = nil;
        [manager removeItemAtURL:URL error:&error];
        if (error) {
            // handle error
        }
    }
}

#pragma mark - 数据库 "增删改查"
#pragma mark - 使用 [RLMRealm defaultRealm]
- (void)addObject:(PersonModel *)p {

    [self.d_realm transactionWithBlock:^{
        [self.d_realm addObject: p];
    }];
    
    /*
         [rlm beginWriteTransaction];
         [realm addObject: p];
         [rlm commitWriteTransaction];
     */
    
    /*
         //异步线程操作数据库
         dispatch_async(dispatch_queue_create("queue", 0), ^{
         PersonModel *p2 = [PersonModel objectsWhere: @"name = '张三'"].firstObject;
         [self.d_realm beginWriteTransaction];
         p2.age = 23;
         [self.d_realm commitWriteTransaction];
         });
     */
    
}

- (void)deleteObject:(PersonModel *)p {
    [self.d_realm transactionWithBlock:^{
        [self.d_realm deleteObject: p];
    }];
}

- (void)addOrUpdateObject:(PersonModel *)p {
    [self.d_realm transactionWithBlock:^{
        //realm 根据RLMObject的Primary key 自动判断是新增还是更新
        //这里在判断primary key 时要注意判断是在memory中的还是数据库中的
        [self.d_realm addOrUpdateObject: p];
    }];
}

- (RLMResults *)getObject {
    RLMResults <PersonModel *> *result = [[PersonModel objectsWhere: @"name = '张三'"] sortedResultsUsingKeyPath: @"uId" ascending: false];
    
    return result;
    
    /*
     
     //fetch all objects in default realm db
     RLMResults *result = [PersonModel allObjects];
     
     //fetch all objects in specific realm db
     RLMResults *result = [PersonModel allObjectsInRealm: self.realm];
     
     //fetch objects using sql in sepcific realm db
     RLMResults *result = [[PersonModel objectsInRealm: self.realm where: @"name = '李四'"] sortedResultsUsingKeyPath: @"createDate" ascending: false];
     
     */

}

#pragma mark - lazyloading
- (RLMRealm *)d_realm {
    if (!_d_realm) {
        _d_realm = [RLMRealm defaultRealm];
        //在其他异步线程中操作数据库自动更新  default is true
        [_d_realm setAutorefresh: true];
        
        //使用config初始化另一个realm对象
        /*
         NSError *error;
         RLMRealm *rm = [RLMRealm realmWithConfiguration: config error: &error];
         */
    }
    return _d_realm;
}

- (RLMRealm *)realm {
    if (!_realm) {
        RLMRealmConfiguration *config = [[RLMRealmConfiguration alloc] init];
        NSString *filePath = MkdirInDirectory(CONFIG_REALM_FILE_PATH);
        //配置realm路径
        //可以配置本地数据库或者远端数据库
        config.fileURL = [NSURL URLWithString: filePath];
        //只读数据库
        //If a Realm has read-only permissions, then you must use the asyncOpen API as described in Asynchronously opening Realms. Opening a read-only Realm without asyncOpen will cause an error.
//        config.readOnly = true;
        
        // limit which classes can be stored in a specific Realm
        config.objectClasses = @[[PersonModel class]];
        
        _realm = [RLMRealm realmWithConfiguration: config error: nil];
    }
    return _realm;
}

- (RLMRealm *)memRealm {
    if (!_memRealm) {
        RLMRealmConfiguration *config = [RLMRealmConfiguration defaultConfiguration];
        config.inMemoryIdentifier = REALM_IN_MEMORY_IDEF;
        _memRealm = [RLMRealm realmWithConfiguration: config error: nil];
    }
    return _memRealm;
}


@end
