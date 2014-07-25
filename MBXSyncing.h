//
//  MBXSyncing.h
//  MBXSync
//
//  Created by Mo Bitar on 4/21/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MBXSyncing <NSObject>

@required

/** The RESTful path for the model, i.e "/user/1/items. This will be used for all resource methods: GET, POST, PATCH, DELETE */
+ (NSString *)RESTPathForModel:(id<MBXSyncing>)model;

/** Whether the model needs to be synced upstream to the server. Once synced, the server will update the value of this key to NO */
@property (nonatomic) BOOL modelNeedsSync;

/** Whether the model needs to be deleted upon next sync. You should not completely destroy an object locally when wishing to delete it. 
    First delete it from the server, then delete it locally */
@property (nonatomic) BOOL modelNeedsDelete;

/** Usually the ID of the object, i.e @"1842123" */
- (id)modelResourceIdentifier;

/** once a model with modelNeedsDelete = YES is done syncing, deleteModel will be called, in which case the the receiver should perform the logic neccessary to delete the model */
- (void)deleteModel;

/** The date the object was last synced. Should be nil for newly created objects. Once the new objects are sent to the server, their last sync date is set at completion */
@property (nonatomic) NSDate *lastSyncDate;

/** Should return all models for the class */
+ (NSArray *)allModels;


#pragma mark - JSON

/** Used to serialize an object before sending it to the server */
- (NSDictionary *)JSONDictionaryRepresentation;

/** The receiver should analyize the response and determine if it contains multiple items. If it does, +arrayOfModelsFromJSONResponse: will be called, else +modelFromJSONResponse: */
+ (BOOL)JSONResponseIsArray:(id)response;

+ (NSArray *)arrayOfModelsFromJSONResponse:(id)response;

+ (id<MBXSyncing>)modelFromJSONResponse:(id)response;

- (void)updateModelFromJSONResponse:(id)response;

@end
