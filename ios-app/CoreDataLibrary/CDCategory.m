//
//  CDCategory.m
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "CDCategory.h"

@implementation CDCategory

+ (CDCategory *)categoryWithName:(NSString *)name
          inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDCategory *nCategory = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDCategory");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Category: %@", name);
        nCategory = [matches firstObject];
    } else {
        NSLog(@"Core Data didn't find Category, inserting Category: %@", name);
        nCategory = [NSEntityDescription insertNewObjectForEntityForName:@"CDCategory" inManagedObjectContext:context];
        nCategory.name = name;
    }
    
    return nCategory;
}

+ (void)deleteCategoryWithName:(NSString *)name
      fromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDCategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDCategory");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Category to delete: %@", name);
        NSManagedObject *object = [matches firstObject];
        [context deleteObject:object];
    } else {
        NSLog(@"Core Data didn't find Category: %@", name);
    }
}

@end
