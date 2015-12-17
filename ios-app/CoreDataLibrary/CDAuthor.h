//
//  CDAuthor.h
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author;

NS_ASSUME_NONNULL_BEGIN

@interface CDAuthor : NSManagedObject

+ (CDAuthor *)authorWithAuthor:(Author *)author
        inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)deleteAuthorWithID:(NSString *)identity
  fromManagedObjectContext:(NSManagedObjectContext *)context;

@end

NS_ASSUME_NONNULL_END

#import "CDAuthor+CoreDataProperties.h"
