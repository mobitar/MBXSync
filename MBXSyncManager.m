//
//  MBXSyncManager.m
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import "MBXSyncManager.h"
#import "MBXSyncOperation.h"
#import "MBXSyncTransaction.h"

@interface MBXSyncManager () <MBXSyncOperationDelegate, MBXSyncTransactionDelegate>
@property (nonatomic) NSMutableArray *transactions;
@end

@implementation MBXSyncManager

+ (instancetype)sharedInstance
{
    static MBXSyncManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [MBXSyncManager new];
    });
    return instance;
}

- (instancetype)init
{
    if(self = [super init]) {
        _transactions = [NSMutableArray new];
    }
    return self;
}

- (void)syncModelsOfClass:(Class<MBXSyncing>)modelClass completion:(MBXSyncCompletionBlock)completion
{
    NSAssert(self.server, @"Server cannot be nil");
    
    NSArray *allModels = [modelClass allModels];
    NSArray *modelsNeedingSync = [allModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"modelNeedsSync == YES"]];
    id<MBXSyncing> latestModel = [[allModels sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastSyncDate" ascending:NO]]] firstObject];
    NSDate *latestModelDate = [latestModel lastSyncDate];
    
    NSArray *modelsNeedingCreation = [modelsNeedingSync filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"lastSyncDate == nil"]];
    NSMutableArray *modelsNeedingUpdate = [modelsNeedingSync mutableCopy];
    [modelsNeedingUpdate removeObjectsInArray:modelsNeedingCreation];
    
    NSArray *modelsNeedingDelete = [allModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"modelNeedsDelete == YES"]];

    NSString *generalPath = [modelClass RESTPathForModel:nil];
    NSTimeInterval latestModelDateInSeconds = [latestModelDate timeIntervalSince1970];
    
    id<MBXSyncServer> server = self.server;
    
    MBXSyncTransaction *transaction = [MBXSyncTransaction new];
    transaction.delegate = self;
    
    [transaction addOperation:[MBXSyncOperation operationWithServer:server methodType:MBXMethodTypeGET path:generalPath params:@{@"modified_since" : @(latestModelDateInSeconds)} modelClass:modelClass delegate:self]];
    
    for(id<MBXSyncing> model in modelsNeedingCreation) {
        MBXSyncOperation *op = [MBXSyncOperation operationWithServer:server methodType:MBXMethodTypePOST path:generalPath params:[model JSONDictionaryRepresentation] modelClass:modelClass delegate:self];
        op.originalModel = model;
        [transaction addOperation:op];
    }
    
    for(id<MBXSyncing> model in modelsNeedingUpdate) {
        NSString *modelPath = [modelClass RESTPathForModel:model];
        MBXSyncOperation *op = [MBXSyncOperation operationWithServer:server methodType:MBXMethodTypePATCH path:modelPath params:[model JSONDictionaryRepresentation] modelClass:modelClass  delegate:self];
        op.originalModel = model;
        [transaction addOperation:op];
    }
    
    for(id<MBXSyncing> model in modelsNeedingDelete) {
        NSString *modelPath = [modelClass RESTPathForModel:model];
        MBXSyncOperation *op = [MBXSyncOperation operationWithServer:server methodType:MBXMethodTypeDELETE path:modelPath params:[model JSONDictionaryRepresentation] modelClass:modelClass  delegate:self];
        op.originalModel = model;
        [transaction addOperation:op];
    }
    
    transaction.completionBlock = completion;
    
    [self.transactions addObject:transaction];
    
    [transaction run];
}

#pragma mark - MBXSyncOperation Delegate

- (void)syncOperationDidComplete:(MBXSyncOperation *)operation
{
    MBXSyncTransaction *transaction = [operation transaction];
    [transaction registerOperationAsCompleted:operation];
}

#pragma mark - MBXSyncTransaction Delegate

- (void)transactionDidCompleteAllOperations:(MBXSyncTransaction *)transaction
{
    MBXSyncCompletionBlock completionBlock = transaction.completionBlock;
    
    NSDate *completionDate = [NSDate date];
    
    NSMutableArray *models = [NSMutableArray new];
    NSMutableArray *errors = [NSMutableArray new];
    for(MBXSyncOperation *op in transaction.operations) {
        if(op.responseObject) {
            NSMutableArray *submodels = [NSMutableArray new];
           
            if(op.originalModel) {
                [op.originalModel updateModelFromJSONResponse:op.responseObject];
                [submodels addObject:op.originalModel];
            } else {
                BOOL isResponseArray = [op.modelClass JSONResponseIsArray:op.responseObject];
                
                if(isResponseArray) {
                    NSArray *modelsFromResponse = [op.modelClass arrayOfModelsFromJSONResponse:op.responseObject];
                    [submodels addObjectsFromArray:modelsFromResponse];
                } else {
                    id<MBXSyncing> model = [op.modelClass modelFromJSONResponse:op.responseObject];
                    [submodels addObject:model];
                }
            }
            
            
            [models addObjectsFromArray:submodels];
        } else if(op.error) {
            [errors addObject:op.error];
        } else {
            // some operations, like DELETE, might not have a responseObject if successful, but rather just a 204 status code.
            if(op.originalModel) {
                // add the originModel to the models so we can iterate on it in the for loop below
                [models addObject:op.originalModel];
            }
        }
    }
    
    for(id<MBXSyncing> model in models) {
        
        if([model modelNeedsDelete]) {
            [model deleteModel];
        }
        
        [model setModelNeedsSync:NO];
        [model setLastSyncDate:completionDate];
    }
    
    completionBlock(models, errors);
}

@end
