//
//  SafeInternals.h
//  SafeDataStructureKit
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

@import Foundation;

typedef NS_ENUM(uint16_t, SafeMutabilityState) {
    SafeMutabilityNone,
    SafeMutabilityTemporary,
    SafeMutabilityPermanent
};

/**
 *  Calculate a new value hash derived from an existing one, plus a new hash index.
 *  This is most useful when implementing the `-(NSUInteger)hash` method on custom NSObject subclasses
 *
 *  @param hash      An unsigned integer hash, such as one returned from NSObject's built-in `hash` method
 *  @param hashIndex An index for the new hash.  The index must be unique for each hashed property.
 *
 *  @return A new hash calculation.
 */
NSUInteger SafeValueHashForHashIndex(NSUInteger hash, NSUInteger hashIndex);
