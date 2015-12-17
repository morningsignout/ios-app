//
//  CDTag.h
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDTag : NSManagedObject

+ (CDTag *)tagWithName:(NSString *)name
inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteTagWithName:(NSString *)name
 fromManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "CDTag+CoreDataProperties.h"
