//
//  DingConnectPresenter+PresenterProtocol.m
//  ePayService
//
//  Created by Valera Voroshilov on 28.11.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingConnectPresenter+PresenterProtocol.h"
#import "PagingListPickerViewController.h"
#import "NSString+Localisation.h"
#import "CatalogCountryModel.h"
#import "DingConnectProductItem.h"
#import "DingConnectProducValue.h"
#import "DingConnectCountryEntity.h"
#import "DingRegionEntity.h"
#import "DingProviderEntity.h"
#import "InputViewPicker.h"
#import "AmountController.h"
#import "FormFooter.h"
#import "DingDataProvider.h"
#import "DingConnectAPI.h"
#import "ErrorHandler.h"
#import "NSString+BalanceFormatter.h"
#import "CheckLikePopupVC+DetailTransaction.h"
#import "PaymentEntity.h"
#import "FavoriteEntity.h"
#import "NSString+BalanceFormatter.h"
#import "FeeResponseV3.h"
@import Firebase;
@interface DingConnectPresenter()

@end

@implementation DingConnectPresenter (PresenterProtocol)

- (nonnull NSArray<AccoutList *> *)getListWallets {
    return self.listWallets;
}

- (void)didSelectWallet:(AccountEntity*)wallet{
    self.selectedWallet = wallet;
}

- (void)didSelectRegion:(DingRegionEntity*)region{
    [self refreshProvidersFor:self.selectedRegion];
}

- (void)didSelectProvider:(DingProviderEntity*)provider{
    [self refreshProductsFor:provider];
}

- (void)didSelectProduct:(DingConnectProductItem*)product{
    self.selectedProduct = product;
    [self refreshApperanceForProduct:product];
}

- (void)didEnterPhone:(NSString*)phone{
    self.view.countryField.hidden = NO;
    [self.view.countryField setIsCommonActivity:YES];
    [FIRAnalytics logEventWithName:@"ding_connect_did_enter_phone" parameters:nil];
    __weak typeof (self) weakSelf = self;
    [self.provider getPhoneInfo:phone com:^(DingConnectCountryEntity *country, DingRegionEntity *region, DingProviderEntity *provider, NSError * _Nonnull error) {
        [self.view.countryField setIsCommonActivity:NO];
        
        if (error != nil){
            [weakSelf.view setCountryByPhoneNotFound];
            return;
        }
        
        weakSelf.selectedPhone = phone;
        weakSelf.selectedCountry  = country;
        weakSelf.selectedRegion   = region;
        weakSelf.selectedProvider = provider;
        
        weakSelf.regionsData    = weakSelf.provider.regionsData;
        weakSelf.providersData  = weakSelf.provider.providersData;
        [weakSelf refreshProductsFor:weakSelf.selectedProvider];
        
        weakSelf.view.countryField.field.text  = weakSelf.selectedCountry.countryName;
        weakSelf.view.regionField.field.text   = weakSelf.selectedRegion.regionName;
        weakSelf.view.providerField.field.text = weakSelf.selectedProvider.name;
        [weakSelf.view.amountContr clearAmount];
        

        weakSelf.view.regionField.hidden       = weakSelf.regionsData.count<=1;
        weakSelf.view.providerField.hidden     = NO;
        weakSelf.view.countryField.isEnabled   = NO;
    }];
}

- (void)refreshRegionsFor:(DingConnectCountryEntity*)country{
    __weak typeof (self) weakSelf = self;
    self.selectedCountry = country;
    self.view.regionField.isActivity = YES;
    [self.provider refreshRegionsFor:country com:^(NSError * _Nonnull error) {
        weakSelf.regionsData = weakSelf.provider.regionsData;
        weakSelf.view.regionField.isActivity = NO;
        [weakSelf.view.regionPicker.picker reloadAllComponents];
    }];
}

- (void)refreshProvidersFor:(DingRegionEntity*)region{
    self.view.providerField.isActivity = YES;
    self.selectedRegion = region;
    __weak typeof (self) weakSelf = self;
    [self.provider refreshProvidersFor:region com:^(NSError * _Nonnull error) {
        weakSelf.providersData  = weakSelf.provider.providersData;
        [weakSelf.view.providerPicker.picker reloadAllComponents];
        weakSelf.view.providerField.isActivity = NO;
    }];
}

- (void)refreshProductsFor:(DingProviderEntity*)provider{
    
    self.selectedProvider = provider;
    self.view.productField.hidden = NO;
    self.view.maxProductLbl.superview.hidden = YES;
    
    [self.view.productField setIsCommonActivity:YES];
    __weak typeof (self) weakSelf = self;
    [self.provider refreshProductsFor:(DingProviderEntity *)provider com:^(NSError * _Nonnull error) {
        [weakSelf.view.productField setIsCommonActivity:NO];
        weakSelf.view.productField.isActivity = NO;
        [weakSelf setProductsDataWithRefreshingView: weakSelf.provider.productData];
        weakSelf.selectedProduct = weakSelf.productData.firstObject;
        weakSelf.view.formFooter.hidden = NO;
    }];
}

- (void)setProductsDataWithRefreshingView:(NSArray<DingConnectProductItem*>*) data{
    self.productData = data;
    if (data.count == 0) {
        self.view.amountContr.hidden       = YES;
        self.view.productField.hidden     = YES;
        self.view.formFooter.hidden       = YES;
        return ;
    } else if (data.count == 1){
        DingConnectProductItem *item          = data.firstObject;
        self.view.amountContr.hidden       = item.isMaxMinEqual;
        self.view.amountContr.isEnabled    = YES;
        self.view.productField.hidden     = !item.isMaxMinEqual;
        
        self.view.minProductLbl.superview.hidden = item.isMaxMinEqual;
        
        self.view.minProductLbl.text = [NSString stringWithFormat:@"%@: %@", @"minimum_amount".localized, item.minimum.valueAsString];
        self.view.maxProductLbl.text = [NSString stringWithFormat:@"%@: %@", @"maximum_amount".localized, item.maximum.valueAsString];
        
        self.view.productField.field.text = item.maximum.valueAsString;
        [self.view.productPicker.picker reloadAllComponents];
    } else if (data.count > 1){
        DingConnectProductItem *item = data.firstObject;
        self.view.productField.hidden     = NO;
        self.view.amountContr.hidden       = NO;
        self.view.minProductLbl.superview.hidden = item.isMaxMinEqual;
        [self refreshApperanceForProduct:item];
        [self.view.productPicker.picker reloadAllComponents];
    }
    
}

- (void)refreshApperanceForProduct:(DingConnectProductItem*) item{
    self.view.amountContr.isEnabled = !item.isMaxMinEqual;
    
    self.view.minProductLbl.text = [NSString stringWithFormat:@"%@: %@", @"minimum_amount".localized, item.minimum.valueAsString];
    self.view.maxProductLbl.text = [NSString stringWithFormat:@"%@: %@", @"maximum_amount".localized, item.maximum.valueAsString];
    
    self.view.productField.field.text = item.fieldString;
    [self.view.amountContr setAmount:item.maximum.sendValue.floatValue];
    self.view.amountContr.calculateFeeBlock(self.view.amountContr.amount);
}


#pragma mark pickers stuff end
- (void)didEnterAmount:(CGFloat)amount{
    if (amount < 0.0001){
        [self.view.amountContr setFee:@"0.00" total:@"0.00"];
        [self.view.amountContr setRateString:nil];
        [self.view.amountContr setRecivedAmount:nil];
        return;
    }
    
    NSDictionary *params = @{@"account_id":self.selectedWallet.uid,
                             @"amount":@(amount)
    };
    
    __weak typeof(self) weakSelf = self;
    [self.view.amountContr startActivity];
    [weakSelf.view setMakeBtnEnabled:NO];
    [DingConnectAPI getFee:params com:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
        
        if (error != nil){
            [ErrorHandler processError:error inController:weakSelf.view];
            return;
        }
        
        FeeResponseV3 *feeObj = [FeeResponseV3 fromDictionary:response];
        
        BOOL isRate = feeObj.rate != nil;
        NSString *amountKey = isRate? @"toAmount" : @"amount";
        if  ([response[amountKey][@"value"] floatValueEPS] != weakSelf.view.amountContr.amount){
            if (weakSelf.view.amountContr.amount == 0){
                [weakSelf.view.amountContr stopActivity];
            }
            return;
        }
        
        [weakSelf.view.amountContr stopActivity];
        weakSelf.view.amountContr.lastFeeResponse = feeObj.asDictionary;
        [weakSelf.view setMakeBtnEnabled:YES];
        [weakSelf.view.amountContr setFee:feeObj.fee.concatinated
                                   total:feeObj.total.concatinated];
        
        if (isRate) {
            [weakSelf.view.amountContr setRateString: feeObj.asDictionary[@"rate"]];
            [weakSelf.view.amountContr setRecivedAmount: feeObj.toAmount.concatinated];
        } else {
            [weakSelf.view.amountContr setRateString: nil];
            [weakSelf.view.amountContr setRecivedAmount: feeObj.amount.concatinated];
        }
     }];
}

- (void)processFavoriteEntity:(FavoriteEntity*)entity {
    
    self.view.numberPhoneField.field.text = [NSString stringWithFormat:@"+%@", entity.contentData[@"phone"]];
    
    self.selectedPhone = self.view.numberPhoneField.field.text;
    
    self.view.countryField.hidden = NO;
    [self.view.countryField setIsCommonActivity:YES];
    __weak typeof (self) weakSelf = self;
    [self.provider getTemplateInfo:entity.uid com:^(DingConnectCountryEntity * _Nullable countrySel,
                                                    DingRegionEntity * _Nullable regionSel,
                                                    DingProviderEntity * _Nullable providerSel,
                                                    DingConnectProductItem* productSel,
                                                    NSError * _Nullable error) {
        [weakSelf.view.countryField setIsCommonActivity:NO];
        
        weakSelf.selectedCountry  = countrySel;
        weakSelf.selectedRegion   = regionSel;
        weakSelf.selectedProvider = providerSel;
        weakSelf.selectedProduct  = productSel;
        
        weakSelf.regionsData    = weakSelf.provider.regionsData;
        weakSelf.providersData  = weakSelf.provider.providersData;
        
        [weakSelf setProductsDataWithRefreshingView:weakSelf.provider.productData];
        
        
        
        weakSelf.view.countryField.field.text  = weakSelf.selectedCountry.countryName;
        weakSelf.view.regionField.field.text   = weakSelf.selectedRegion.regionName;
        weakSelf.view.providerField.field.text = weakSelf.selectedProvider.name;
        weakSelf.view.productField.field.text  = weakSelf.selectedProduct.fieldString;
        
        [weakSelf.view.amountContr setAmount:[entity.contentData[@"amount"] floatValueEPS]];
        
        weakSelf.view.regionField.hidden       = weakSelf.provider.regionsData.count<=1;
        weakSelf.view.providerField.hidden     = NO;
        weakSelf.view.formFooter.hidden        = NO;
        
        weakSelf.view.countryField.isEnabled     = NO;
        weakSelf.view.regionField.isEnabled      = NO;
        weakSelf.view.providerField.isEnabled    = NO;
        weakSelf.view.numberPhoneField.isEnabled = NO;
        
        [weakSelf setProductsDataWithRefreshingView:weakSelf.provider.productData];
    }];
}

- (void)makeTransaction{
    NSDictionary *params = @{@"mobile_top_up[country_code]":self.selectedCountry.countryISO,
                             @"mobile_top_up[region_code]":self.selectedRegion.regionCode,
                             @"mobile_top_up[provider_code]":self.selectedProvider.providerCode,
                             @"mobile_top_up[sku]":self.selectedProduct.skuСode,
                             @"mobile_top_up[phone]":self.selectedPhone,
                             @"mobile_top_up[amount]":@(self.view.amountContr.amount).stringValue,
                             @"mobile_top_up[account_id]":self.selectedWallet.uid};
    
    [self.view isCommonActivity:YES];
    
    [FIRAnalytics logEventWithName:@"ding_connect_make_transactions" parameters:params];
    
    [DingConnectAPI postTransactions:params com:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
        [self.view isCommonActivity:NO];
        if (error != nil){
            [ErrorHandler processError:error];
        } else {
            NSMutableDictionary *mutable = [response mutableCopy];
            mutable[@"to"]   = self.selectedPhone;
            mutable[@"from"] = self.selectedWallet.number;
            mutable[@"currency"] = @"EUR";
            
            mutable[kTransactionTypeEpayMobile] = @(TransactionMobileTopUp);
            [CheckLikePopupVC showDoneBill:mutable inVC:self.view.tabBarController onClose:^(){
                [self.view.navigationController popViewControllerAnimated:YES];
            }];
        }
    }];
}


- (NSString*)checkRangeErrorFor:(CGFloat)amount{
    if (amount < self.selectedProduct.minimum.sendValue.floatValue){
        return @"amount_less_than_minimum".localized;
    }
    
    if (amount > self.selectedProduct.maximum.sendValue.floatValue){
        return @"amount_more_than_maximum".localized;
    }
    
    return nil;
}

- (void)viewOnVCDidLoad {
    
}

/////
- (NSString*)regionForPickerRow:(NSUInteger)row{
    return self.regionsData[row].regionName;
}

- (NSString*)providerForPickerRow:(NSUInteger)row{
    return self.providersData[row].name;
}

- (NSString*)productForPickerRow:(NSUInteger)row{
    return self.productData[row].fieldString;
}

@end
