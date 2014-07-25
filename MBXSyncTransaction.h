//
//  MBXSyncTransaction.h
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MBXSyncTransaction;

@protocol MBXSyncTransactionDelegate <NSObject>

- (void)transactionDidCompleteAllOperations:(MBXSyncTransaction *)transaction;

@end

@class MBXSyncOperation;

@interface MBXSyncTransaction : NSObject

@property (nonatomic, weak) id<MBXSyncTransactionDelegate> delegate;

/** Note: This is for client use only, to register a custom completion block that they can refer back to later. This will not be called by the transaction */
@property (nonatomic, copy) id completionBlock;

- (NSArray *)operations;

/** Registers the operation. Operations do not begin until -run is called */
- (void)addOperation:(MBXSyncOperation *)operation;

/** It is the responsibliy of the client to call this method upon completion of an operation, during success and failure */
- (void)registerOperationAsCompleted:(MBXSyncOperation *)operation;

- (void)run;

/** Returns any operation that resulted in an error */
- (NSArray *)operationsResultingInErrors;

- (NSArray *)allOperationErrors;

@end
