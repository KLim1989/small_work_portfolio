//
//  DingDataProvider.h
//  ePayService
//
//  Created by Valera Voroshilov on 06.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DingConnectCountryEntity;
@class DingProviderEntity;
@class DingRegionEntity;
@class DingConnectProductItem;

NS_ASSUME_NONNULL_BEGIN

@interface DingDataProvider : NSObject
@property (nonatomic) NSArray <DingProviderEntity*>     *providersData;
@property (nonatomic) NSArray <DingRegionEntity*>       *regionsData;
@property (nonatomic) NSArray <DingConnectProductItem*> *productData;

- (void)getPhoneInfo:(NSString*)phone
                 com:(void (^)(DingConnectCountryEntity* countrySel,
                               DingRegionEntity* regionSel,
                               DingProviderEntity* providerSel,
                               NSError *error)) comBlock;

- (void)getTemplateInfo:(NSString*)templateUID
                    com:(void (^)(DingConnectCountryEntity* __nullable countrySel,
                                  DingRegionEntity* __nullable regionSel,
                                  DingProviderEntity* __nullable providerSel,
                                  DingConnectProductItem* __nullable productSel,
                                  NSError * __nullable error)) comBlock;

- (void)refreshRegionsFor:(DingConnectCountryEntity*)country com:(void (^)( NSError *error))comBlock;
- (void)refreshProvidersFor:(DingRegionEntity*)region com:(void (^)( NSError *error))comBlock;
- (void)refreshProductsFor:(DingProviderEntity*)provider com:(void (^)( NSError *error))comBlock;
@end

NS_ASSUME_NONNULL_END
