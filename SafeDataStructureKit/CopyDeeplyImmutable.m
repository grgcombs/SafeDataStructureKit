//
//  CopyDeeplyImmutable.m
//  SafeDataStructureKit
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import "CopyDeeplyImmutable.h"

@implementation NSArray (CopyDeeplyImmutable)

- (NSArray *)copyAsDeeplyImmutableWithExceptions:(BOOL)throwsExceptions
{
    NSMutableArray* ret = [[NSMutableArray alloc] init];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id newCopy = [CopyDeeplyImmutable copyAsDeeplyImmutableValue:obj throwsExceptions:throwsExceptions];
        if (newCopy)
        {
            [ret addObject:newCopy];
        }
    }];
    return [ret copy];
}

@end



@implementation NSDictionary (CopyDeeplyImmutable)

- (NSDictionary *)copyAsDeeplyImmutableWithExceptions:(BOOL)throwsExceptions
{
    NSMutableDictionary * ret = [[NSMutableDictionary alloc] init];

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id newCopy = [CopyDeeplyImmutable copyAsDeeplyImmutableValue:obj throwsExceptions:throwsExceptions];
        if (newCopy)
        {
            ret[key] = newCopy;
        }
    }];

    return [ret copy];
}

@end



@implementation CopyDeeplyImmutable

+ (id)copyAsDeeplyImmutableValue:(id)oldValue throwsExceptions:(BOOL)throwsExceptions
{
    id newCopy = nil;

    if ([oldValue respondsToSelector: @selector(copyAsDeeplyImmutableWithExceptions:)])
    {
        newCopy = [oldValue copyAsDeeplyImmutableWithExceptions:throwsExceptions];
    }
    else if ([oldValue conformsToProtocol:@protocol(NSCopying)])
    {
        newCopy = [oldValue copy];
    }

    if (!newCopy && throwsExceptions)
    {
        [NSException raise:NSDestinationInvalidException format:@"Object is not copyable: %@", oldValue];
    }

    return newCopy;
}

@end
