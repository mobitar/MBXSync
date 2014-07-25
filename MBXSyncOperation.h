//
//  MBXSyncOperation.h
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBXSyncing.h"
#import "MBXSyncServer.h"

@class MBXSyncOperation;

@protocol MBXSyncOperationDelegate <NSObject>

- (void)syncOperationDidComplete:(MBXSyncOperation *)operation;

@end

@interface MBXSyncOperation : NSObject

@property (nonatomic) id<MBXSyncServer> server;
@property (nonatomic) MBXMethodType methodType;
@property (nonatomic, copy) NSString *path;
@property (nonatomic) NSDictionary *params;
@property (nonatomic) Class modelClass;

@property (nonatomic, weak) id<MBXSyncOperationDelegate> delegate;

/** For client use only */
@property (nonatomic) id transaction;
@property (nonatomic) id<MBXSyncing> originalModel;

@property (nonatomic, readonly) id responseObject;
@property (nonatomic, readonly) NSError *error;


- (void)start;

+ (instancetype)operationWithServer:(id<MBXSyncServer>)server
                         methodType:(MBXMethodType)methodType
                               path:(NSString *)path
                             params:(NSDictionary *)params
                         modelClass:(Class<MBXSyncing>)modelClass
                           delegate:(id<MBXSyncOperationDelegate>)delegate;

@end
