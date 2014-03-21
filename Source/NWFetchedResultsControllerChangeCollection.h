//
//  NWFetchedResultsControllerChangeCollection.h
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

#import <Foundation/Foundation.h>
#import <CoreData/NSFetchedResultsController.h>

typedef void(^UICollectionViewBatchUpdateBlock)(void);
typedef UICollectionViewBatchUpdateBlock(^NWFetchedResultsControllerChangeCollectionUpdateBlock)(UICollectionView *collectionView);

@interface NWFetchedResultsControllerChangeCollection : NSMutableArray

- (void)addChangeWithType:(NSFetchedResultsChangeType)type indexPath:(NSIndexPath *)indexPath newIndexPath:(NSIndexPath *)indexPath;
- (void)addChangeWithType:(NSFetchedResultsChangeType)type section:(NSUInteger)sectionIndex;

@property (nonatomic, strong) NSMutableIndexSet *insertedSections;
@property (nonatomic, strong) NSMutableIndexSet *deletedSections;
@property (nonatomic, strong) NSMutableIndexSet *updatedSections;

- (NSArray *)valuesForKey:(NSString *)key type:(NSFetchedResultsChangeType)type;
- (void)enumerateMoveChangesUsingBlock:(void (^)(NSIndexPath *indexPath, NSIndexPath *newIndexPath))block;

- (void)beginUpdates;

/**
 *  My apologies if you try to understand what happens here,
 *  I realised later that there was a better way to do this halfway through but
 *  by that point it had become a challenge to make it work
 *
 *  This method takes a block that has an argument of a block, you should call the
 *  argument block with a UICollectionView and pass the result to performBatchUpdates:
 *
 *  [self.changeCollection endUpdates:^(VLFetchedResultsControllerChangeCollectionUpdateBlock block) {
 *      [self.collectionView performBatchUpdates:block(self.collectionView) completion:nil];
 *  }];
 */
- (void)endUpdates:(void (^)(NWFetchedResultsControllerChangeCollectionUpdateBlock updateBlock))block;

@end
