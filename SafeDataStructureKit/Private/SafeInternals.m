//
//  SafeInternals.m
//  SafeDataStructureKit
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import "SafeInternals.h"

#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))

NSUInteger SafeValueHashForHashIndex(NSUInteger hash, NSUInteger hashIndex)
{
    if (hash == 0)
    {
        // accounts for nil objects
        hash = 31;
    }
    return NSUINTROTATE(hash, NSUINT_BIT / (hashIndex + 1));
}
