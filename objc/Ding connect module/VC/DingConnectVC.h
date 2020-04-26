//
//  DingConnectVCViewController.h
//  ePayService
//
//  Created by Valera Voroshilov on 27.11.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaymentEntity.h"
#import "DingConnectProtocols.h"

@class FormTextField;
@class FormTapableLabel;
@class InputViewPicker;
@class AmountController;
@class FormFooter;

NS_ASSUME_NONNULL_BEGIN

@interface DingConnectVC : UIViewController <TransactionViewController, UIPickerViewDataSource, UIPickerViewDelegate>
@property (assign, nonatomic) TransactionTypes transactionType;
@property (nonatomic, strong) id<DingConnectPresenterProtocol> presenter;

@property (nonatomic) FormTextField    *numberPhoneField;
@property (nonatomic) FormTextField    *countryField;
@property (nonatomic) FormTextField    *regionField;
@property (nonatomic) FormTextField    *providerField;
@property (nonatomic) FormTextField    *productField;

@property (nonatomic) UILabel          *minProductLbl;
@property (nonatomic) UILabel          *maxProductLbl;

@property (nonatomic) InputViewPicker  *regionPicker;
@property (nonatomic) InputViewPicker  *providerPicker;
@property (nonatomic) InputViewPicker  *productPicker;

@property (nonatomic) AmountController *amountView;
@property (nonatomic) FormFooter       *formFooter;
@property (nonatomic) FavoriteEntity   *favoriteEntity;

- (void)setCountryByPhoneNotFound;
- (void)setMakeBtnEnabled:(BOOL)isEnabled;
- (void)isCommonActivity:(BOOL)isActivity;
@end

NS_ASSUME_NONNULL_END
