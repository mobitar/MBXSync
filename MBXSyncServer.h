//
//  MBXSyncServer.h
//  MBXSync
//
//  Created by Mo Bitar on 4/22/14.
//  Copyright (c) 2014 Progenius. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MBXMethodType)
{
    MBXMethodTypeGET,
    MBXMethodTypePOST,
    MBXMethodTypePATCH,
    MBXMethodTypeDELETE
};

typedef void(^MBXServerBlock)(id responseObject, NSError *error);

@protocol MBXSyncServer <NSObject>

@required

- (void)performMethod:(MBXMethodType)method path:(NSString *)path parameters:(NSDictionary *)params completionBlock:(MBXServerBlock)completionBlock;

@end
