//
//  DingProviderEntity.h
//  ePayService
//
//  Created by Valera Voroshilov on 03.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DingProviderEntity : NSObject
+ (DingProviderEntity*)fromDictionary:(NSDictionary*)params;
@property (nonatomic) NSString *name;
@property (nonatomic) NSString *providerCode;
@end

NS_ASSUME_NONNULL_END
