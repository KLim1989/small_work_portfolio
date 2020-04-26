//
//  DingConnectProductResponse.h
//  ePayService
//
//  Created by Valera Voroshilov on 05.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DingConnectProducValue;

NS_ASSUME_NONNULL_BEGIN




@interface DingConnectProductItem : NSObject
+(DingConnectProductItem*)fromDictionary:(NSDictionary*)params;
@property (nonatomic) NSString *defaultDisplayText;
@property (nonatomic) NSString *validityPeriodISO;
@property (nonatomic) NSString *skuСode;
@property (nonatomic) DingConnectProducValue *minimum;
@property (nonatomic) DingConnectProducValue *maximum;
@property (nonatomic, readonly, assign) BOOL isMaxMinEqual;
@property (nonatomic, readonly) NSString *fieldString;
@end

NS_ASSUME_NONNULL_END
