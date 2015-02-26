//
//  CopyDeeplyImmutable.h
//  SafeDataStructureKit
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

@import Foundation;


@interface NSArray (CopyDeeplyImmutable)

/**
 *  Recurses into the receiver's contents and makes an immutable copy of each value it encounters.
 *  Throws an exception if any interior value objects aren't copyable in some way. This method
 *  only ensuring there are no mutable copies of objects.
 *
 *  @param throwsExceptions Conditionally throw exceptions if an interior object isn't copyable,
 *                          otherwise it merely omits that object from the new collection.
 *
 *  @return A deeply immutable copy of the receiver's contents.
 */
- (NSArray *)copyAsDeeplyImmutableWithExceptions:(BOOL)throwsExceptions;

@end


@interface NSDictionary (CopyDeeplyImmutable)

/**
 *  Recurses into the receiver's contents and makes an immutable copy of each value it encounters.
 *  Throws an exception if any interior value objects aren't copyable in some way. This method
 *  ensures there are no mutable objects in the copy.
 *
 *  @param throwsExceptions Conditionally throw exceptions if an interior object isn't mutable or copyable,
 *                          otherwise it merely omits that object from the new collection.
 *
 *  @return A deeply immutable copy of the receiver's contents.
 */
- (NSDictionary *)copyAsDeeplyImmutableWithExceptions:(BOOL)throwsExceptions;

@end



@interface CopyDeeplyImmutable : NSObject

+ (id)copyAsDeeplyImmutableValue:(id)oldValue throwsExceptions:(BOOL)throwsExceptions;

@end

