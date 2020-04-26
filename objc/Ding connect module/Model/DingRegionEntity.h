//
//  DingRegion.h
//  ePayService
//
//  Created by Valera Voroshilov on 03.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DingRegionEntity : NSObject
+ (DingRegionEntity*)fromDictionary:(NSDictionary*)params;
@property (nonatomic) NSString *regionCode;
@property (nonatomic) NSString *regionName;
@end

NS_ASSUME_NONNULL_END
