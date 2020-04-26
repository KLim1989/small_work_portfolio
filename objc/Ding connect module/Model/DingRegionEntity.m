//
//  DingRegion.m
//  ePayService
//
//  Created by Valera Voroshilov on 03.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingRegionEntity.h"

@implementation DingRegionEntity
+ (DingRegionEntity*)fromDictionary:(NSDictionary*)params{
    DingRegionEntity *region = [DingRegionEntity new];
    region.regionCode = params[@"region_code"];
    region.regionName = params[@"region_name"];
    return region;
}
@end
