//
//  DingConnectProductResponse.m
//  ePayService
//
//  Created by Valera Voroshilov on 05.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingConnectProductItem.h"
#import "DingConnectProducValue.h"

@implementation DingConnectProductItem
+ (DingConnectProductItem*)fromDictionary:(NSDictionary*)d{
    DingConnectProductItem *item = [DingConnectProductItem new];
    item.defaultDisplayText = d[@"default_display_text"];
    item.validityPeriodISO  = d[@"validity_period_iso"];
    item.skuСode = d[@"sku_code"];
    item.minimum = [DingConnectProducValue fromDictionary:d[@"minimum"]];
    item.maximum = [DingConnectProducValue fromDictionary:d[@"maximum"]];
    return item;
}

- (BOOL)isMaxMinEqual{
    return [self.minimum isEqualValue:self.maximum];
}

- (NSString*)fieldString{
    if (self.isMaxMinEqual){
        return self.maximum.valueAsString;
    } else {
        return [NSString stringWithFormat:@"%@-%@",self.minimum.valueAsString, self.maximum.valueAsString];
    }
}
@end
