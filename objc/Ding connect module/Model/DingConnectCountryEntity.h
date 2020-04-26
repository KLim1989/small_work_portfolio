//
//  DingConnectCountryEntity.h
//  ePayService
//
//  Created by Valera Voroshilov on 06.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface DingConnectCountryEntity : NSObject
+ (DingConnectCountryEntity*)fromDictionary:(NSDictionary*)params;
@property (nonatomic) NSString *countryISO;
@property (nonatomic) NSString *countryName;
@property (nonatomic) NSArray<NSString*> *regionCodes;
@end
NS_ASSUME_NONNULL_END
