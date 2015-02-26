//
//  SafeArray.m
//  SafeDataStructureKit
//
//  Copyright (C) 2015 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import "SafeArray.h"
#import "CopyDeeplyImmutable.h"
#import "SafeInternals.h"

#ifdef REACTIVE_COCOA

#import <ReactiveCocoa/RACSubject.h>
#import <ReactiveCocoa/RACSequence.h>
#import <ReactiveCocoa/RACTuple.h>
#import <ReactiveCocoa/NSArray+RACSequenceAdditions.h>

#endif

@interface SafeArray ()
- (void)performWithTemporaryMutability:(void (^)(id<SafeMutableArray> array))block;
@end

@interface SafeArray (SafeMutableArray) <SafeMutableArray>
@end

@implementation SafeArray {
    NSMutableArray* _backingArray;
    SafeMutabilityState _mutabilityState;
}

#pragma mark - Initializers

- (instancetype)init
{
    return [self initWithSafeArray:nil];
}

- (instancetype)initWithSafeArray:(SafeArray *)array
{
    if (self = [super init])
    {
        _backingArray = [NSMutableArray arrayWithArray:array.allObjects ?: @[]];
    }

    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] alloc] initWithSafeArray:self];
}

#pragma mark - NSMutableCopying

- (SafeArray<SafeMutableArray>*)mutableCopyWithZone:(NSZone*)zone
{
    SafeArray* copy = [self copyWithZone:zone];
    copy->_mutabilityState = SafeMutabilityPermanent;
    return copy;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(__unsafe_unretained id[])buffer
                                    count:(NSUInteger)len
{
    return [_backingArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Safe Update

- (void)performWithTemporaryMutability:(SafeArrayModifyBlock)block
{
    BOOL immutableByDefault = _mutabilityState != SafeMutabilityPermanent;
    if (immutableByDefault)
        _mutabilityState = SafeMutabilityTemporary;
    block(self);
    if (immutableByDefault)
        _mutabilityState = SafeMutabilityNone;
}

- (instancetype)modify:(SafeArrayModifyBlock)block
{
    BOOL immutableByDefault = _mutabilityState != SafeMutabilityPermanent;
    SafeArray* copy = immutableByDefault ? [self copy] : [self mutableCopy];
    [copy performWithTemporaryMutability:^(id<SafeMutableArray> dict){
        block(dict);
    }];
    return copy;
}

#pragma mark - Accessors

- (id)objectAtIndex:(NSUInteger)index
{
    if (_backingArray.count > index)
        return _backingArray[index];
    return nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)index
{
    return [self objectAtIndex:index];
}

- (NSUInteger)count
{
    return _backingArray.count;
}

- (NSArray*)allObjects
{
    NSMutableArray* objects = [NSMutableArray arrayWithCapacity:self.count];

    for (id object in self)
    {
        [objects addObject:object];
    }

    return [objects copy];
}

#pragma mark - Key Value Coding

- (id)valueForUndefinedKey:(NSString*)key
{
    return nil;
}

#pragma mark -

- (BOOL)isEqual:(id)obj
{
    if (!obj || ![obj isKindOfClass:[self class]])
        return NO;
    typeof(self) other = obj;
    return (self->_mutabilityState == other->_mutabilityState &&
            self.count == other.count &&
            [self->_backingArray isEqualToArray:other->_backingArray]);
}

- (NSUInteger)hash
{
    NSUInteger current = 31;
    NSUInteger hashIndex = 1;

    current = SafeValueHashForHashIndex(self.count, hashIndex) ^ current;
    hashIndex++;

    // For now I'll assume an immutable dictionary and a mutable dictionary can't be equal
    current = SafeValueHashForHashIndex(_mutabilityState, hashIndex) ^ current;
    hashIndex++;

    current = SafeValueHashForHashIndex([_backingArray hash], hashIndex) ^ current;
    hashIndex++;

    return current;
}

- (NSString *)description
{
    uint64_t count = (uint64_t)self.count;
    NSMutableString *desc = [[NSMutableString alloc] initWithFormat:@"%llu Objects: \n", count];

    uint64_t index = 0;
    for (id object in self)
    {
        [desc appendFormat:@"  [%llu]: %@\n", index, object];
        index++;
    }

    return desc;
}

@end

#ifdef REACTIVE_COCOA

@implementation SafeArray (RACSequence)

- (RACSequence*)sequence
{
    return self.allObjects.rac_sequence;
}

@end

#endif

@implementation SafeArray (SafeMutableArray)

- (void)assertMutableForSelector:(SEL)selector
{
    if (_mutabilityState != SafeMutabilityNone)
        return;

    NSString* reason = [NSString
                        stringWithFormat:@"Attempted to send -%@ to immutable object %@",
                        NSStringFromSelector(selector), self];
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:reason
                                 userInfo:nil];
}

- (void)setObject:(id)object atIndex:(NSUInteger)index
{
    [self assertMutableForSelector:_cmd];

    BOOL isOverBoundsIndex = index >= self.count;

    if (object == nil)
    {
        if (isOverBoundsIndex)
            return;  // nothing to do, no new object, no existing object

        [_backingArray removeObjectAtIndex:index];
    }
    else
    {
        if ([object isKindOfClass:[NSArray class]] ||
            [object isKindOfClass:[NSDictionary class]])
        {
            object = [object copyAsDeeplyImmutableWithExceptions:NO];
        }

        if (isOverBoundsIndex)
            [_backingArray addObject:object];
        else
            [_backingArray replaceObjectAtIndex:index withObject:object];
    }
}

- (void)setObject:(id)object atIndexedSubscript:(NSUInteger)index
{
    [self setObject:object atIndex:index];
}

@end
