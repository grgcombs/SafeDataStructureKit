//
//  SafeOrderedDictionary.h
//  SafeDataStructureKit
//
//  Originally authored as RAFOrderedDictionary in Reactive Formlets
//  by Jon Sterling on 6/12/12.
//  Copyright (c) 2012 Jon Sterling. All rights reserved.
//

@import Foundation;

@protocol SafeMutableOrderedDictionary;

/**
 *  he block which allows guarded access to the mutable interface of an
 *  immutable ordered dictionary.
 *
 *  @param dict A momentarily mutable dictionary (copy).
 */
typedef void (^SafeOrderedDictionaryModifyBlock)(id<SafeMutableOrderedDictionary> dict);

/**
 *  The immutable interface to an ordered dictionary.
 */
@protocol SafeOrderedDictionary <NSFastEnumeration>

/**
 *  Returns the object at the provided key.
 *
 *  @param key A dictionary key (like a string) -- must be copyable.
 *
 *  @return A corresponding dictionary value, or nil.
 */
- (id)objectForKey:(id<NSCopying>)key;

/**
 *  Returns the object at the provided key.
 *
 *  @param key A dictionary key (like a string) -- must be copyable.
 *
 *  @return A corresponding dictionary value, or nil.
 */
- (id)objectForKeyedSubscript:(id<NSCopying>)key;

/**
 *  Returns an array of all the keys in the ordered dictionary, in order.
 *
 *  @return The ordered array of keys.
 */
- (NSArray *)allKeys;

/**
 *  Returns an array of all the values in the ordered dictionary, in order.
 *
 *  @return The ordered array of values.
 */
- (NSArray *)allValues;

/**
 *  Returns the number of entries in the ordered dictionary.
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
- (instancetype)modify:(SafeOrderedDictionaryModifyBlock)block;
@end



/**
 *  The mutable interface to the ordered dictionary.
 */
@protocol SafeMutableOrderedDictionary <SafeOrderedDictionary>

/**
 *  Destructively updates the dictionary at a certain key; if the key does not
 *  yet exist in the dictionary, the key-value pair is appended to the end.
 *
 *  @param object The value with which to update the dictionary.
 *  @param key    The key at which to update the dictionary.
 */
- (void)setObject:(id)object forKey:(id<NSCopying>)key;

/**
 *  Destructively updates the dictionary at a certain key; if the key does not
 *  yet exist in the dictionary, the key-value pair is appended to the end.
 *
 *  @param object The value with which to update the dictionary.
 *  @param key    The key at which to update the dictionary.
 */
- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key;
@end


/**
 *  This is an (optionally) mutable associative collection.  It is almost
 *  exactly like an NSMutableDictionary, except that keys are always kept in
 *  the order they are inserted.
 */
@interface SafeOrderedDictionary : NSObject <SafeOrderedDictionary, NSCopying, NSMutableCopying>

/**
 *  Initializes with an existing ordered dictionary.
 *
 *  @param dictionary An ordered dictionary.
 *
 *  @return A newly initialized ordered dictionary.
 */
- (id)initWithOrderedDictionary:(SafeOrderedDictionary *)dictionary;

@end

#ifdef REACTIVE_COCOA

@class RACSequence;

@interface SafeOrderedDictionary (RACSequence)

/**
 *  Returns a sequence of (key,value) RACTuples.
 *
 *  @return The sequence.
 */
- (RACSequence *)sequence;

@end

#endif
