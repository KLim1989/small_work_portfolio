//
//  DingConnectCountryEntity.m
//  ePayService
//
//  Created by Valera Voroshilov on 06.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingConnectCountryEntity.h"


@implementation DingConnectCountryEntity
+ (DingConnectCountryEntity*)fromDictionary:(NSDictionary*)params{
    DingConnectCountryEntity *entity = [DingConnectCountryEntity new];
    entity.countryISO  = params[@"country_iso"];
    entity.countryName = params[@"country_name"];
    entity.regionCodes = params[@"region_codes"];
    return entity;
}
@end
