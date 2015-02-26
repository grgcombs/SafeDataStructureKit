//
//  SafeArray.h
//  SafeDataStructureKit
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

@import Foundation;

@protocol SafeMutableArray;

/**
 *  he block which allows guarded access to the mutable interface of an
 *  immutable array.
 *
 *  @param array A momentarily mutable array (copy).
 */
typedef void (^SafeArrayModifyBlock)(id<SafeMutableArray> array);

/**
 *  The immutable interface to an array.
 */
@protocol SafeArray <NSFastEnumeration>

/**
 *  Returns the object at the provided key.
 *
 *  @param index An array index.
 *
 *  @return A corresponding array value, or nil.
 */
- (id)objectAtIndex:(NSUInteger)index;

/**
 *  Returns the object at the provided key.
 *
 *  @param index An index to the array.
 *
 *  @return A corresponding array value, or nil.
 */
- (id)objectAtIndexedSubscript:(NSUInteger)index;

/**
 *  Returns an array of all the objects in the safe array.
 *
 *  @return The array of objects.
 */
- (NSArray *)allObjects;

/**
 *  Returns the number of entries in the array.
 *
 *  @return An integer of the count.
 */
- (NSUInteger)count;

/**
 *  Non-destructive update for an ordered dictionary.
 *
 *  @param block The destructive operations to be performed on the copy; within the
 *               block's scope, access is granted statically to the mutable interface of
 *               the ordered dictionary.
 *
 *  @return Returns a modified version of the ordered dictionary.
 */
- (instancetype)modify:(SafeArrayModifyBlock)block;
@end



/**
 *  The mutable interface to the array.
 */
@protocol SafeMutableArray <SafeArray>

/**
 *  Destructively updates the array at a certain index; if the index is
 *  larger than the size of the array, the value is appended to the end.
 *
 *  @param object The value with which to update the array.
 *  @param index  The index at which to update the array.
 */
- (void)setObject:(id)object atIndex:(NSUInteger)index;

/**
 *  Destructively updates the array at a certain index; if the index is
 *  larger than the size of the array, the value is appended to the end.
 *
 *  @param object The value with which to update the array.
 *  @param index  The index at which to update the array.
 */
- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index;

@end


/**
 *  This is an (optionally) mutable associative collection.
 */
@interface SafeArray : NSObject <SafeArray, NSCopying, NSMutableCopying>

/**
 *  Initializes with an existing safe array.
 *
 *  @param array An instance of a safe array.
 *
 *  @return A newly initialized safe array.
 */
- (id)initWithSafeArray:(SafeArray *)array;

@end

#ifdef REACTIVE_COCOA

@class RACSequence;

@interface SafeArray (RACSequence)

/**
 *  Returns a sequence of the array objects.
 *
 *  @return The sequence.
 */
- (RACSequence *)sequence;

@end

#endif
