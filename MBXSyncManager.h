//
//  MBXSyncManager.h
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBXSyncing.h"
#import "MBXSyncServer.h"

/** A response model can be a new model or one that already exists but has been updated */
typedef void(^MBXSyncCompletionBlock)(NSArray *responseModels, NSArray *errors);

@interface MBXSyncManager : NSObject

+ (instancetype)sharedInstance;

/** Required. 
    A server is any object that can perform HTTP methods. 
    Check the MBXSyncServer protocol for the required methods a server must implement. */
@property (nonatomic) id<MBXSyncServer> server;

/** Performs a full sync
    Sends any models needingSync to the server,
    and retreives any models from the server where modifiedDate is greater than the latest modifiedDate of any local object */
- (void)syncModelsOfClass:(Class<MBXSyncing>)modelClass completion:(MBXSyncCompletionBlock)completion;

@end
