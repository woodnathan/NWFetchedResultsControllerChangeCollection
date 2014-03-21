//
//  NWFetchedResultsControllerChangeCollection.m
//
//  Copyright (c) 2014 Nathan Wood (http://www.woodnathan.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "NWFetchedResultsControllerChangeCollection.h"

@interface NWFetchedResultsControllerChange : NSObject

- (id)initWithType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath nextIndexPath:(NSIndexPath *)nextIndexPath;

@property (nonatomic, readonly) NSFetchedResultsChangeType type;

@property (nonatomic, readonly) NSIndexPath *indexPath;
@property (nonatomic, readonly) NSIndexPath *nextIndexPath;

@end

@interface NWFetchedResultsControllerChangeCollection ()

@property (nonatomic, strong) NSMutableArray *array;

@end

@implementation NWFetchedResultsControllerChangeCollection

- (id)init
{
    return [self initWithCapacity:0];
}

- (id)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self)
    {
        self.array = [[NSMutableArray alloc] initWithCapacity:capacity];
        
        self.insertedSections = [[NSMutableIndexSet alloc] init];
        self.deletedSections = [[NSMutableIndexSet alloc] init];
        self.updatedSections = [[NSMutableIndexSet alloc] init];
    }
    return self;
}

- (NSArray *)valuesForKey:(NSString *)key type:(NSFetchedResultsChangeType)type
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", @(type)];
    NSArray *subarray = [self.array filteredArrayUsingPredicate:predicate];
    return [subarray valueForKey:key];
}

- (void)enumerateMoveChangesUsingBlock:(void (^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block
{
    if (block == nil)
        return;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", @(NSFetchedResultsChangeMove)];
    NSArray *subarray = [self.array filteredArrayUsingPredicate:predicate];
    [subarray enumerateObjectsUsingBlock:^(VLFetchedResultsControllerChange *change, NSUInteger idx, BOOL *stop) {
        block(change.indexPath, change.nextIndexPath);
    }];
}

- (void)addChangeWithType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)newIndexPath
{
    NWFetchedResultsControllerChange *change = [[NWFetchedResultsControllerChange alloc] initWithType:type
                                                                                            indexPath:indexPath
                                                                                        nextIndexPath:newIndexPath];
    [self.array addObject:change];
}

- (void)addChangeWithType:(NSFetchedResultsChangeType)type section:(NSUInteger)sectionIndex
{
    switch (type)
    {
        case NSFetchedResultsChangeInsert:
            [self.insertedSections addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeDelete:
            [self.deletedSections addIndex:sectionIndex];
            break;
        case NSFetchedResultsChangeUpdate:
            [self.updatedSections addIndex:sectionIndex];
            break;
        default:
            break;
    }
}

- (void)beginUpdates
{
    [self removeAllObjects];
}

- (void)endUpdates:(void (^)(NWFetchedResultsControllerChangeCollectionUpdateBlock))block
{
    if (block)
    {
        static NSString *key = @"indexPath";
        NSArray *insertIndexPaths = [self valuesForKey:@"nextIndexPath" type:NSFetchedResultsChangeInsert];
        NSArray *deleteIndexPaths = [self valuesForKey:key type:NSFetchedResultsChangeDelete];
        NSArray *updateIndexPaths = [self valuesForKey:key type:NSFetchedResultsChangeUpdate];
        NSIndexSet *insertedSections = self.insertedSections;
        NSIndexSet *deletedSections = self.deletedSections;
        NSIndexSet *updatedSections = self.updatedSections;
        
        UICollectionViewBatchUpdateBlock(^changeBlock)(UICollectionView *) = ^(UICollectionView *collectionView) {
            void(^updateBlock)(void) = ^(void) {
                
                NSLog(@"Performing updates");
                
                if (insertedSections.count > 0)
                    [collectionView insertSections:insertedSections];
                if (deletedSections.count > 0)
                    [collectionView deleteSections:deletedSections];
                if (updatedSections.count > 0)
                    [collectionView reloadSections:updatedSections];
                
                if (insertIndexPaths.count > 0)
                    [collectionView insertItemsAtIndexPaths:insertIndexPaths];
                if (deleteIndexPaths.count > 0)
                    [collectionView deleteItemsAtIndexPaths:deleteIndexPaths];
                if (updateIndexPaths.count > 0)
                    [collectionView reloadItemsAtIndexPaths:updateIndexPaths];
                
                [self enumerateMoveChangesUsingBlock:^(NSIndexPath *indexPath, NSIndexPath *newIndexPath) {
                    [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
                }];
            };
            
            return updateBlock;
        };
        
        block(changeBlock);
        
        [self removeAllObjects];
    }
}

#pragma mark - Array

- (NSUInteger)count
{
    return [self.array count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [self.array objectAtIndex:index];
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    [self.array insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [self.array removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject
{
    [self.array addObject:anObject];
}

- (void)removeLastObject
{
    [self.array removeLastObject];
}

- (void)removeAllObjects
{
    [self.array removeAllObjects];
    
    [self.insertedSections removeAllIndexes];
    [self.deletedSections removeAllIndexes];
    [self.updatedSections removeAllIndexes];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    [self.array replaceObjectAtIndex:index withObject:anObject];
}

@end

@implementation NWFetchedResultsControllerChange

- (id)initWithType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath nextIndexPath:(NSIndexPath *)nextIndexPath
{
    self = [super init];
    if (self)
    {
        self->_type = type;
        self->_indexPath = indexPath;
        self->_nextIndexPath = nextIndexPath;
    }
    return self;
}

@end
