//
//  DingConnectProtocols.h
//  ePayService
//
//  Created by Valera Voroshilov on 28.11.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class AccoutList;
@class AccountEntity;
@class DingRegionEntity;
@class DingProviderEntity;
@class InputViewPicker;
@class AmountController;
@class FormFooter;
@class FavoriteEntity;
@class DingConnectProductItem;


@protocol DingVCFieldProtocol <NSObject>
@property UITextField * _Nonnull field;
@property BOOL isEnabled;
@property BOOL isActivity;
@property BOOL hidden;
- (void)setIsCommonActivity:(BOOL)isCommonActivity;
@end

NS_ASSUME_NONNULL_BEGIN

@protocol WalletsProvider <NSObject>
- (NSArray<AccoutList*>*)getListWallets;
@end

@protocol CommonPresenterProtocol <NSObject>
@property (nonatomic, weak) UIViewController* view;
- (void)viewOnVCDidLoad;
@end

@protocol DingConnectPresenterProtocol <WalletsProvider, CommonPresenterProtocol>
@property (nonatomic) NSArray <DingRegionEntity*> *regionsData;
@property (nonatomic) NSArray <DingProviderEntity*> *providersData;
@property (nonatomic) NSArray <DingConnectProductItem*> *productData;

- (void)didSelectWallet:(AccountEntity*)wallet;
- (void)didEnterPhone:(NSString*)phone;
- (void)didSelectRegion:(DingRegionEntity*)region;
- (void)didSelectProvider:(DingProviderEntity*)provider;
- (void)didSelectProduct:(DingConnectProductItem*)product;
- (void)didEnterAmount:(CGFloat)amount;

- (NSString*)checkRangeErrorFor:(CGFloat)amount;
- (void)processFavoriteEntity:(FavoriteEntity*)amount;
- (void)makeTransaction;
@end

@protocol DingConnectVCProtocol <NSObject>
@property (nonatomic) id<DingVCFieldProtocol> numberPhoneField;
@property (nonatomic) id<DingVCFieldProtocol> countryField;
@property (nonatomic) id<DingVCFieldProtocol> regionField;
@property (nonatomic) id<DingVCFieldProtocol> providerField;
@property (nonatomic) id<DingVCFieldProtocol> productField;

@property (nonatomic) UILabel *minProductLbl;
@property (nonatomic) UILabel *maxProductLbl;

@property (nonatomic) InputViewPicker  *regionPicker;
@property (nonatomic) InputViewPicker  *providerPicker;
@property (nonatomic) InputViewPicker  *productPicker;

@property (nonatomic) AmountController *amountContr;
@property (nonatomic) FormFooter       *formFooter;

- (void)setCountryByPhoneNotFound;
- (void)isCommonActivity:(BOOL)isActivity;
- (void)setMakeBtnEnabled:(BOOL)isEnabled;
@end

NS_ASSUME_NONNULL_END
