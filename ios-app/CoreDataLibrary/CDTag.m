//
//  CDTag.m
//  ios-app
//
//  Created by Qingwei Lan on 11/8/15.
//  Copyright © 2015 Morning Sign Out Incorporated. All rights reserved.
//

#import "CDTag.h"

@implementation CDTag

+ (CDTag *)tagWithName:(NSString *)name
inManagedObjectContext:(NSManagedObjectContext *)context
{
    CDTag *nTag = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDTag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDTag");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Tag: %@", name);
        nTag = [matches firstObject];
    } else {
        NSLog(@"Core Data didn't find Tag, inserting Tag: %@", name);
        nTag = [NSEntityDescription insertNewObjectForEntityForName:@"CDTag" inManagedObjectContext:context];
        nTag.name = name;
    }
    
    return nTag;
}

+ (void)deleteTagWithName:(NSString *)name
 fromManagedObjectContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"CDTag"];
    request.predicate = [NSPredicate predicateWithFormat:@"name ==[c] %@", name];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || matches.count > 1) {
        NSLog(@"Error when fetching CDTag");
    } else if (matches.count == 1) {
        NSLog(@"Core Data found Tag to delete: %@", name);
        NSManagedObject *object = [matches firstObject];
        [context deleteObject:object];
    } else {
        NSLog(@"Core Data didn't find Tag: %@", name);
    }
}

@end
