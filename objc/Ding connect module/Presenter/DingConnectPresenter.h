//
//  DingConnectPresenter.h
//  ePayService
//
//  Created by Valera Voroshilov on 28.11.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DingConnectProtocols.h"

@class AccoutList;
@class DingConnectProductItem;
@class DingConnectCountryEntity;
@class DingRegionEntity;
@class DingProviderEntity;
@class DingDataProvider;
#import "DingConnectProductItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface DingConnectPresenter : NSObject
@property (nonatomic) NSArray<AccoutList*>* listWallets;
@property (nonatomic) DingDataProvider* provider;

@property (nonatomic) NSArray <DingRegionEntity*> *regionsData;
@property (nonatomic) NSArray <DingProviderEntity*> *providersData;
@property (nonatomic) NSArray <DingConnectProductItem*> *productData;

@property (nonatomic) AccountEntity *selectedWallet;
@property (nonatomic) NSString *selectedPhone;
@property (nonatomic) DingConnectCountryEntity *selectedCountry;
@property (nonatomic) DingRegionEntity  *selectedRegion;
@property (nonatomic) DingProviderEntity  *selectedProvider;
@property (nonatomic) DingConnectProductItem  *selectedProduct;

@property (nonatomic, weak) UIViewController<DingConnectVCProtocol>* view;
@end

NS_ASSUME_NONNULL_END
