//
//  DingProviderEntity.m
//  ePayService
//
//  Created by Valera Voroshilov on 03.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingProviderEntity.h"

@implementation DingProviderEntity
+ (DingProviderEntity*)fromDictionary:(NSDictionary*)params{
    DingProviderEntity *region = [DingProviderEntity new];
    region.name = params[@"name"];
    region.providerCode = params[@"provider_code"];
    return region;
}
@end
