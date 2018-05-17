//
//  AppDelegate.h
//  realmTest
//
//  Created by 崔小舟 on 2018/4/17.
//  Copyright © 2018年 personal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

