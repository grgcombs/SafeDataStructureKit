//
//  SafeOrderedDictionary.m
//  SafeDataStructureKit
//
//  Originally authored as RAFOrderedDictionary in Reactive Formlets
//  by Jon Sterling on 6/12/12.
//  Copyright (c) 2012 Jon Sterling. All rights reserved.
//

#import "SafeOrderedDictionary.h"
#import "CopyDeeplyImmutable.h"
#import "SafeInternals.h"

#ifdef REACTIVE_COCOA

#import <ReactiveCocoa/RACSubject.h>
#import <ReactiveCocoa/RACSequence.h>
#import <ReactiveCocoa/RACTuple.h>
#import <ReactiveCocoa/NSArray+RACSequenceAdditions.h>

#endif

@interface SafeOrderedDictionary ()
- (void)performWithTemporaryMutability:(void (^)(id<SafeMutableOrderedDictionary> dict))block;
@end

@interface SafeOrderedDictionary (SafeMutableOrderedDictionary) <SafeMutableOrderedDictionary>
@end

@implementation SafeOrderedDictionary {
    NSMutableArray* _backingKeys;
    NSMutableDictionary* _backingDictionary;
    SafeMutabilityState _mutabilityState;
}

#pragma mark - Initializers

- (id)init
{
    return [self initWithOrderedDictionary:nil];
}

- (id)initWithOrderedDictionary:(SafeOrderedDictionary*)dictionary
{
    if (self = [super init])
    {
        _backingKeys = [dictionary.allKeys ?: @[] mutableCopy];
        _backingDictionary = [NSMutableDictionary dictionaryWithObjects:dictionary.allValues ?: @[]
                                                         forKeys:dictionary.allKeys ?: @[]];
    }

    return self;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone*)zone
{
    return [[[self class] alloc] initWithOrderedDictionary:self];
}

#pragma mark - NSMutableCopying

- (SafeOrderedDictionary<SafeMutableOrderedDictionary>*)mutableCopyWithZone:(NSZone*)zone
{
    SafeOrderedDictionary* copy = [self copyWithZone:zone];
    copy->_mutabilityState = SafeMutabilityPermanent;
    return copy;
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state
                                  objects:(__unsafe_unretained id[])buffer
                                    count:(NSUInteger)len
{
    return [_backingKeys countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Safe Update

- (void)performWithTemporaryMutability:(SafeOrderedDictionaryModifyBlock)block
{
    BOOL immutableByDefault = _mutabilityState != SafeMutabilityPermanent;
    if (immutableByDefault)
        _mutabilityState = SafeMutabilityTemporary;
    block(self);
    if (immutableByDefault)
        _mutabilityState = SafeMutabilityNone;
}

- (instancetype)modify:(SafeOrderedDictionaryModifyBlock)block
{
    BOOL immutableByDefault = _mutabilityState != SafeMutabilityPermanent;
    SafeOrderedDictionary* copy = immutableByDefault ? [self copy] : [self mutableCopy];
    [copy performWithTemporaryMutability:^(id<SafeMutableOrderedDictionary> dict){
        block(dict);
    }];
    return copy;
}

#pragma mark - Accessors

- (id)objectForKey:(id<NSCopying>)key
{
    return [_backingDictionary objectForKey:key];
}

- (id)objectForKeyedSubscript:(id<NSCopying>)key
{
    return [self objectForKey:key];
}

- (NSUInteger)count
{
    return _backingKeys.count;
}

- (NSArray*)allKeys
{
    return [_backingKeys copy];
}

- (NSArray*)allValues
{
    NSMutableArray* values = [NSMutableArray arrayWithCapacity:self.count];
    for (id key in self)
    {
        [values addObject:self[key]];
    }

    return [values copy];
}

#pragma mark - Key Value Coding

- (id)valueForUndefinedKey:(NSString*)key
{
    return self[key];
}

#pragma mark -

- (BOOL)isEqual:(id)obj
{
    if (!obj || ![obj isKindOfClass:[self class]])
        return NO;
    typeof(self) other = obj;
    return (self->_mutabilityState == other->_mutabilityState &&
            self.count == other.count &&
            [self->_backingKeys isEqualToArray:other->_backingKeys] &&
            [self->_backingDictionary isEqualToDictionary:other->_backingDictionary]);
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

    current = SafeValueHashForHashIndex([_backingKeys hash], hashIndex) ^ current;
    hashIndex++;

    current = SafeValueHashForHashIndex([_backingDictionary hash], hashIndex) ^ current;
    hashIndex++;

    return current;
}

#ifdef REACTIVE_COCOA

- (NSString*)description
{
    return [self.sequence map:^(RACTuple* value) {
        return [NSString stringWithFormat:@"%@: %@", value.first, value.second];
    }].array.description;
}

#else

- (NSString *)description
{
    NSString *keys = [[self allKeys] componentsJoinedByString:@", "];
    NSMutableString *desc = [[NSMutableString alloc] initWithFormat:@"Keys: %@\n  Values:\n", keys];
    for (id key in self)
    {
        [desc appendFormat:@"  [%@]: %@\n", key, self[key]];
    }

    return desc;
}

#endif

@end

#ifdef REACTIVE_COCOA

@implementation SafeOrderedDictionary (RACSequence)

- (RACSequence*)sequence
{
    return [self.allKeys.rac_sequence map:^(id key) {
        id value = self[key];
        return [RACTuple tupleWithObjects:key, value, nil];
    }];
}

@end

#endif

@implementation SafeOrderedDictionary (SafeMutableOrderedDictionary)

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

- (void)setObject:(id)object forKey:(id<NSCopying>)key
{
    NSParameterAssert(key != nil);
    [self assertMutableForSelector:_cmd];

    if (object == nil)
    {
        [_backingKeys removeObject:key];
        [_backingDictionary removeObjectForKey:key];
    }
    else
    {
        if ([object isKindOfClass:[NSArray class]] ||
            [object isKindOfClass:[NSDictionary class]])
        {
            object = [object copyAsDeeplyImmutableWithExceptions:NO];
        }
        [_backingDictionary setObject:object forKey:key];
        if (![_backingKeys containsObject:key])
        {
            [_backingKeys addObject:key];
        }
    }
}

- (void)setObject:(id)object forKeyedSubscript:(id<NSCopying>)key
{
    [self setObject:object forKey:key];
}

@end
