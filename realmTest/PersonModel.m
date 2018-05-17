//
//  PersonModel.m
//  realmTest
//
//  Created by 崔小舟 on 2018/5/9.
//  Copyright © 2018年 personal. All rights reserved.
//

#import "PersonModel.h"

@implementation PersonModel


+ (NSDictionary *)defaultPropertyValues {
    //为新建对象的某些属性提供默认值
    //在设置属性时不要设置为nil
    return @{};
}

+ (NSString *)primaryKey {
    return @"uId";
}

+ (NSArray<NSString *> *)ignoredProperties {
    //不存储的属性值
    return @[@"dogs"];
}

@end
