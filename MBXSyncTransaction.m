//
//  MBXSyncTransaction.m
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import "MBXSyncTransaction.h"
#import "MBXSyncOperation.h"

@interface MBXSyncTransaction ()

@end

@implementation MBXSyncTransaction
{
    NSMutableArray *_operations;
    NSMutableArray *_completedOperations;
}

- (instancetype)init
{
    if(self = [super init]) {
        _operations = [NSMutableArray new];
    }
    return self;
}

- (NSArray *)operations
{
    return _operations;
}

- (void)addOperation:(MBXSyncOperation *)operation
{
    [_operations addObject:operation];
    operation.transaction = self;
}

- (void)run
{
    for(MBXSyncOperation *operation in _operations) {
        [operation start];
    }
}

- (void)registerOperationAsCompleted:(MBXSyncOperation *)operation
{
    if(!_completedOperations) {
        _completedOperations = [NSMutableArray new];
    }
    
    [_completedOperations addObject:operation];
    
    if(_completedOperations.count == _operations.count) {
        [self.delegate transactionDidCompleteAllOperations:self];
    }
}

- (NSArray *)operationsResultingInErrors
{
    NSMutableArray *failedOps = [NSMutableArray new];
    for(MBXSyncOperation *op in _operations) {
        if(op.error) {
            [failedOps addObject:op];
        }
    }
    
    return failedOps;
}

- (NSArray *)allOperationErrors
{
    NSMutableArray *erros = [NSMutableArray new];
    for(MBXSyncOperation *op in _operations) {
        if(op.error) {
            [erros addObject:op.error];
        }
    }
    return erros;
}

@end
