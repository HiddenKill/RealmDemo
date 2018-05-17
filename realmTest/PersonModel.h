//
//  PersonModel.h
//  realmTest
//
//  Created by 崔小舟 on 2018/5/9.
//  Copyright © 2018年 personal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Realm.h>
#import "DogModel.h"

RLM_ARRAY_TYPE(DogModel)

@interface PersonModel : RLMObject

//支持的类型 BOOL, bool, int, NSInteger, long, long long, float, double, NSString, NSDate, NSData, and NSNumber
@property NSInteger uId;    //primary key
@property NSString *name;
@property NSInteger age;
@property NSInteger gender; // 1 == male 2 == female
@property long long createDate;
@property RLMArray <DogModel *> <DogModel> *dogs;

//注意在使用NSNumber时 要指明类型 <RLMInt> <RLMFloat> <RLMDouble> <RLMBool>
@property NSNumber <RLMInt> *childCount;

@property NSString *firstName;  //config.schemaVersion = 1 新增 property

/**
 不支持CGFloat
 */
//@property CGFloat height;

@end
