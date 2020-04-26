//
//  DingDataProvider.m
//  ePayService
//
//  Created by Valera Voroshilov on 06.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingDataProvider.h"

#import "DingConnectAPI.h"
#import "DingConnectProductItem.h"
#import "DingConnectProducValue.h"
#import "DingConnectCountryEntity.h"
#import "DingRegionEntity.h"
#import "DingProviderEntity.h"


@interface DingDataProvider()
@property (nonatomic) NSString                 *lastPhone;
@property (nonatomic) DingConnectCountryEntity *lastCountry;
@property (nonatomic) DingRegionEntity         *lastRegion;
@property (nonatomic) DingProviderEntity       *lastProvider;
@property (nonatomic) DingConnectProductItem   *lastProduct;
@end

@implementation DingDataProvider

- (void)getPhoneInfo:(NSString*)phone
                 com:(void (^)(DingConnectCountryEntity*countrySel,
                               DingRegionEntity* regionSel,
                               DingProviderEntity* providerSel,
                               NSError *error)) comBlock{
    
    if ([_lastPhone isEqualToString:phone]) {
        comBlock(self.lastCountry, self.lastRegion, self.lastProvider, nil);
        return;
    }
    
    [DingConnectAPI getCountriesFor:phone com:^(NSDictionary * _Nonnull response, NSError * _Nonnull error){
        
        if (error != nil) {
            comBlock(nil, nil, nil, error);
            return;
        }
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            ///!!!
            [self parseResponseWithSelectedData:response comBlock:^(DingConnectCountryEntity *countrySel, DingRegionEntity *regionSel, DingProviderEntity *providerSel, NSError *error) {
                ///!!!!
                self.lastPhone     = phone;
                self.lastCountry   = countrySel;
                self.lastRegion    = regionSel;
                self.lastProvider  = providerSel;
                      
                dispatch_async(dispatch_get_main_queue(), ^(void){
                    comBlock(countrySel, regionSel, providerSel, nil);
                });
            }];
        });
    }];
}

- (void)getTemplateInfo:(NSString *)templateUID
                    com:(void (^)(DingConnectCountryEntity *__nullable,
                                  DingRegionEntity *__nullable,
                                  DingProviderEntity *__nullable,
                                  DingConnectProductItem* __nullable productSel,
                                  NSError *__nullable))comBlock {
    [DingConnectAPI getTemplateInfo:templateUID com:^(NSDictionary * _Nonnull response, NSError * _Nonnull error) {
          
            if (error != nil) {
                comBlock(nil, nil, nil, nil, error);
                return;
            }
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                [self parseResponseWithSelectedData:response comBlock:^(DingConnectCountryEntity *countrySel,
                                                        DingRegionEntity *regionSel,
                                                        DingProviderEntity *providerSel,
                                                        NSError *error) {
                    
                    NSArray *filProducts = [response[@"products"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
                        return [object[@"sku_code"] isEqualToString:response[@"selected_sku"]];
                    }]];
                    
                    ///!!!!
                    self.lastCountry   = countrySel;
                    self.lastRegion    = regionSel;
                    self.lastProvider  = providerSel;
                    self.lastProduct   = [DingConnectProductItem fromDictionary:filProducts.firstObject];
                          
                    dispatch_async(dispatch_get_main_queue(), ^(void){
                        comBlock(countrySel, regionSel, providerSel, self.lastProduct, nil);
                    });
                }];
            });
      }];
}

- (void)parseResponseWithSelectedData:(NSDictionary*)response
             comBlock:(void (^)(DingConnectCountryEntity*countrySel,
                                    DingRegionEntity* regionSel,
                                    DingProviderEntity* providerSel,
                                    NSError *error)) comBlock{
        ///!!!
        NSMutableArray<DingRegionEntity*> *result = [NSMutableArray<DingRegionEntity*> new];
        for (NSDictionary *d in response[@"regions"]) {
            DingRegionEntity *entity = [DingRegionEntity fromDictionary:d];
            [result addObject:entity];
        }
        self.regionsData = result;
        
        ////!!!
        NSMutableArray<DingProviderEntity*> *resultProviders = [NSMutableArray<DingProviderEntity*> new];
        for (NSDictionary *d in response[@"providers"]) {
            DingProviderEntity *entity = [DingProviderEntity fromDictionary:d];
            [resultProviders addObject:entity];
        }
        self.providersData = resultProviders;
        
        ////!!!!
        NSMutableArray<DingConnectProductItem*> *resultProducts = [NSMutableArray<DingConnectProductItem*> new];
        for (NSDictionary *d in response[@"products"]) {
            DingConnectProductItem *item = [DingConnectProductItem fromDictionary:d];
            [resultProducts addObject:item];
        }
        self.productData  = resultProducts;
        
        
        ///!!!!
        NSString *country  = response[@"country_code"];
        NSString *region   = response[@"selected_region_code"];
        NSString *provider = response[@"selected_provider_code"];
        
        NSArray *filCountry = [response[@"countries"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [object[@"country_iso"] isEqualToString:country];
        }]];
        
        NSArray *filRegion = [response[@"regions"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [object[@"region_code"] isEqualToString:region];
        }]];
        
        NSArray *filProvider = [response[@"providers"] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id object, NSDictionary *bindings) {
            return [object[@"provider_code"] isEqualToString:provider];
        }]];
        
        DingConnectCountryEntity *countrySel  = [DingConnectCountryEntity fromDictionary:filCountry.firstObject];
        DingRegionEntity* regionSel     = [DingRegionEntity fromDictionary:filRegion.firstObject];
        DingProviderEntity* providerSel = [DingProviderEntity fromDictionary:filProvider.firstObject];
        
        comBlock(countrySel, regionSel, providerSel, nil);
}

- (void)refreshRegionsFor:(DingConnectCountryEntity*)country com:(void (^)( NSError *error))comBlock{
    if ([self.lastCountry.countryISO isEqualToString:country.countryISO]){
        comBlock(nil);
        return;
    }
    
    [DingConnectAPI getRegionFor:country.countryISO com:^(NSArray * _Nonnull response, NSError * _Nonnull error) {
        
        if (error != nil){
            comBlock(error);
        }
        
        self.lastCountry = country;
        NSMutableArray<DingRegionEntity*> *result = [NSMutableArray<DingRegionEntity*> new];
        
        for (NSDictionary *d in response) {
            DingRegionEntity *entity = [DingRegionEntity fromDictionary:d];
            [result addObject:entity];
        }
        
        self.regionsData = result;
        comBlock(nil);
    }];
}

- (void)refreshProvidersFor:(DingRegionEntity*)region com:(void (^)( NSError *error))comBlock {
    
    if ([self.lastRegion.regionCode isEqualToString:region.regionCode] ){
        comBlock(nil);
        return;
    }
    
    [DingConnectAPI getProvidersFor:region.regionCode com:^(NSArray * _Nonnull response, NSError * _Nonnull error) {
        NSMutableArray<DingProviderEntity*> *result = [NSMutableArray<DingProviderEntity*> new];
        
        if (error != nil){
            comBlock(error);
        }
        
        for (NSDictionary *d in response) {
            DingProviderEntity *entity = [DingProviderEntity fromDictionary:d];
            [result addObject:entity];
        }
        
        self.providersData = result;
        self.lastRegion    = region;
        comBlock(error);
    }];
}

- (void)refreshProductsFor:(DingProviderEntity*)provider com:(void (^)( NSError *error))comBlock{
    
    if ([self.lastProvider.providerCode isEqualToString:provider.providerCode]){
        comBlock(nil);
        return;
    }
    
    [DingConnectAPI getProductFor:provider.providerCode com:^(NSArray * _Nonnull response, NSError * _Nonnull error) {
        
        NSMutableArray<DingConnectProductItem*> *result = [NSMutableArray<DingConnectProductItem*> new];
        
        for (NSDictionary *d in response) {
            DingConnectProductItem *item = [DingConnectProductItem fromDictionary:d];
            [result addObject:item];
        }
        
        self.productData  = result;
        self.lastProvider = provider;
        comBlock(nil);
    }];
}

@end
