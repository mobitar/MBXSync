//
//  MBXSyncOperation.m
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import "MBXSyncOperation.h"

@implementation MBXSyncOperation

+ (instancetype)operationWithServer:(id<MBXSyncServer>)server
                         methodType:(MBXMethodType)methodType
                               path:(NSString *)path
                             params:(NSDictionary *)params
                         modelClass:(Class<MBXSyncing>)modelClass
                           delegate:(id<MBXSyncOperationDelegate>)delegate
{
    MBXSyncOperation *op = [MBXSyncOperation new];
    op.server = server;
    op.methodType = methodType;
    op.path = path;
    op.params = params;
    op.modelClass = modelClass;
    op.delegate = delegate;
    return op;
}

- (void)start
{
    [self.server performMethod:self.methodType path:self.path parameters:self.params completionBlock:^(id responseObject, NSError *error) {
        _responseObject = responseObject;
        _error = error;
        [self.delegate syncOperationDidComplete:self];
    }];
}

@end
