//
//  DingConnectProducValue.h
//  ePayService
//
//  Created by Valera Voroshilov on 05.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//minimum =     {
//    "receive_currency_iso" = "<null>";
//    "receive_value" = "52.36";
//    "send_currency_iso" = EUR;
//    "send_value" = 1;
//}

@interface DingConnectProducValue : NSObject
+(DingConnectProducValue*)fromDictionary:(NSDictionary*)params;
@property (nonatomic) NSString *receiveCurrencyISO;
@property (nonatomic) NSString *receiveValue;
@property (nonatomic) NSString *sendCurrencyISO;
@property (nonatomic) NSNumber *sendValue;
- (BOOL)isEqualValue:(DingConnectProducValue*)obj2;
- (NSString*)valueAsString;
@end

NS_ASSUME_NONNULL_END
