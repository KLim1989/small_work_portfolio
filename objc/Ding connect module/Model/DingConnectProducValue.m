//
//  DingConnectProducValue.m
//  ePayService
//
//  Created by Valera Voroshilov on 05.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingConnectProducValue.h"

@implementation DingConnectProducValue
+ (DingConnectProducValue*)fromDictionary:(NSDictionary*)params{
    DingConnectProducValue *result = [DingConnectProducValue new];
    result.receiveCurrencyISO = params[@"receive_currency_iso"];
    result.receiveValue = params[@"receive_currency_iso"];
    result.sendCurrencyISO = params[@"send_currency_iso"];
    result.sendValue = params[@"send_value"];
    return result;
}

- (BOOL)isEqualValue:(DingConnectProducValue*) obj2{
    return fabs([self.sendValue floatValue] - [obj2.sendValue floatValue]) < 0.01;
}

- (NSString*)valueAsString{
   return [NSString stringWithFormat:@"%.2f %@", self.sendValue.floatValue, self.sendCurrencyISO];
}




@end
