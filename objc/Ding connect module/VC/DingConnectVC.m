//
//  DingConnectVCViewController.m
//  ePayService
//
//  Created by Valera Voroshilov on 27.11.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingConnectVC.h"
#import "UIElementsKit.h"
#import "FormTemplateViewController+FormElemetsHighlight.h"
#import "AccountEntityCaller.h"
#import "AccountsListSelector.h"
#import "ViewControllersFactory.h"
#import "NSString+Localisation.h"
#import "AccountsFilter.h"
#import "InputViewPicker.h"
#import "FormTapableLabel.h"
#import "PreCheckVC.h"
#import "NSString+BalanceFormatter.h"
#import "DingConnectAPI.h"
#import "ErrorHandler.h"
#import "UITextField+FormFieldSelection.h"
#import "FavoriteTitleFormComponent.h"
#import "MBProgressHUD.h"
#import "DingRegionEntity.h"
#import "DingProviderEntity.h"
#import "DingConnectProductItem.h"

@interface DingConnectVC ()<FormFieldSelectionProtocol>
@property (nonatomic) FormTemplateViewController  *formTemplateVC;
@property (nonatomic) AccountEntityCaller *callerWallet;
@end

@implementation DingConnectVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [UIElementsKit setDefaultAppearenceViewControllerTranslucent:self];
    
    self.navigationItem.leftBarButtonItem = [UIElementsKit navigationControllerBackBtnTarget:self.navigationController action:@selector(popViewControllerAnimated:)];
    
    [self createForm];
    [self attachBlocks];
    [self initAccountsData];
    self.title = [PaymentEntity titleByType:self.transactionType];
    [self.formTemplateVC registerAllNotifications];
    [self.formTemplateVC registerSelectionControls];
    
    [self fillFavoriteData:self.favoriteEntity];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fieldDidEndEditing:) name:UITextFieldTextDidEndEditingNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fieldDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification
                                               object:nil];
}

- (void)fillFavoriteData:(FavoriteEntity*)entity{
    if (entity != nil){
        [self.presenter processFavoriteEntity:entity];
    }
}

- (void)initAccountsData{
    [self.callerWallet setEntity:[self.presenter getListWallets].firstObject.accounts.firstObject];
    [self.presenter didSelectWallet:self.callerWallet.entity];
}

- (void)attachBlocks{
    CardSelectorAnimationDelegate *del = [CardSelectorAnimationDelegate new];
    __weak typeof(self) weakSelf = self;
    self.callerWallet.onTap = ^{
        AccountsListSelector* accountSelector = [[ViewControllersFactory new] accountSelector];
        accountSelector.onSelect = ^(AccountEntity *entity) {
            [weakSelf.callerWallet setEntity:entity];
            [weakSelf.presenter didSelectWallet:entity];
            [weakSelf.amountView recalculateFee];
        };
        
        accountSelector.lists = [weakSelf.presenter getListWallets];
        accountSelector.viewFromAppear = weakSelf.callerWallet.accountEntityContainer;
        
        accountSelector.titleText = weakSelf.callerWallet.title.text;
        accountSelector.transitioningDelegate = del;
        [weakSelf presentViewController:accountSelector animated:YES completion:nil];
    };
    
    
    [self.formFooter setOnBtnClick:^{
        [[weakSelf.view findFirstResponder] resignFirstResponder];
        if ([weakSelf checkComplete:YES] != nil){
            [weakSelf showConfirmation:nil];
        }
    }];
    
    [self.amountView setAmountDidChangeBlock:^{
        [weakSelf.presenter didEnterAmount:weakSelf.amountView.amount];
    }];
    
    
    [self.amountView setCalculateFeeBlock:^(CGFloat amount) {
        [weakSelf.presenter didEnterAmount:amount];
    }];
}

- (void)setMakeBtnEnabled:(BOOL)isEnabled{
    [self.formTemplateVC allowMakeBtnPress:isEnabled];
    [self.formFooter setMakeBtnEnabled: isEnabled];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)createForm{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.formTemplateVC = [storyboard instantiateViewControllerWithIdentifier:@"FormTemplateViewController"];
    
    [self addChildViewController:self.formTemplateVC ];
    self.formTemplateVC.view.frame = self.view.bounds;
    [self.view addSubviewConstrait:self.formTemplateVC.view];
    [self.formTemplateVC didMoveToParentViewController:self];
    
    self.formTemplateVC.stackView.spacing = 20.0;
    self.formTemplateVC.selectionDelegate = self;
    
    if (self.favoriteEntity != nil) {
        FavoriteTitleFormComponent
        *favoriteFormComponent = [[FavoriteTitleFormComponent alloc] initWithFrame:CGRectZero];
        favoriteFormComponent.titleName = self.favoriteEntity.name;
        __weak FavoriteTitleFormComponent *formComponentWeak = favoriteFormComponent;
        __weak typeof(self) weakSelf = self;
        favoriteFormComponent.onEditBlock = ^{
            [FavoriteTitleFormComponent showDefaultDialogOn:weakSelf forEntity:weakSelf.favoriteEntity didRename:^(NSString* newName){
                formComponentWeak.titleName = newName;
            } didRemove:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
        };
        [self.formTemplateVC.stackView addArrangedSubview:favoriteFormComponent];
    }
    
    //!!
    self.callerWallet = [[AccountEntityCaller alloc] initWithFrame:CGRectZero];
    self.callerWallet.title.text = @"wallet".localized.uppercaseString;
    [self.formTemplateVC.stackView addArrangedSubview:self.callerWallet];
    self.callerWallet.keyForm = @"external_card_transaction[account_id]";
    
    UIStackView *fieldsStack = [[UIStackView alloc] init];
    fieldsStack.axis = UILayoutConstraintAxisVertical;
    fieldsStack.spacing = 15.0;
    
    //!!!
    UIStackView *cardNumberStack = [[UIStackView alloc] init];
    cardNumberStack.axis = UILayoutConstraintAxisHorizontal;
    cardNumberStack.alignment = UIStackViewAlignmentBottom;
    self.numberPhoneField = [[FormTextField alloc] initWithFrame:CGRectZero];
    self.numberPhoneField.config = FormTextFieldPhone;
    [fieldsStack addArrangedSubview:self.numberPhoneField];
    
    self.countryField = [[FormTextField alloc] initWithFrame:CGRectZero];
    self.countryField.validator.config = FormTextFieldNotEmpty;
    [self.countryField setPlaceHolder:@"country".localized];
    self.countryField.title.text    = @"country".localized;
    self.countryField.keyForm       = @"user[nowcountry]";
    self.countryField.hidden        = YES;
    self.countryField.isEnabled     = NO;
    [fieldsStack addArrangedSubview:self.countryField];
    
    //!!!
    self.regionField = [[FormTextField alloc] initWithFrame:CGRectZero];
    [self.regionField setConfig:FormTextFieldNotEmpty];
    [self.regionField setPlaceHolder:@"region".localized];
    self.regionField.title.text = @"region".localized;
    self.regionField.hidden  = YES;
    
    self.regionPicker = [[InputViewPicker alloc] initWithTarget:nil];
    self.regionPicker.toolBar.hidden = YES;
    self.regionPicker.picker.dataSource = self;
    self.regionPicker.picker.delegate   = self;
    self.regionField.field.inputView    = self.regionPicker;
    self.regionField.isEnabledActions   = NO;
    [fieldsStack addArrangedSubview:self.regionField];
    
    //!!!
    self.providerField = [[FormTextField alloc] initWithFrame:CGRectZero];
    [self.providerField setConfig:FormTextFieldNotEmpty];
    [self.providerField setPlaceHolder:@"provider".localized];
    self.providerField.title.text = @"provider".localized;
    self.providerField.hidden = YES;
    
    self.providerPicker = [[InputViewPicker alloc] initWithTarget:nil];
    self.providerPicker.toolBar.hidden = YES;
    self.providerPicker.picker.dataSource = self;
    self.providerPicker.picker.delegate   = self;
    self.providerField.field.inputView    = self.providerPicker;
    self.providerField.isEnabledActions = NO;
    [fieldsStack addArrangedSubview:self.providerField];
    
    //!!
    self.productField = [[FormTextField alloc] initWithFrame:CGRectZero];
    [self.productField setConfig:FormTextFieldNotEmpty];
    [self.productField setPlaceHolder:@"product".localized];
    self.productField.title.text = @"product".localized;
    self.productField.hidden = YES;
    [fieldsStack addArrangedSubview:self.productField];
    
    self.productPicker = [[InputViewPicker alloc] initWithTarget:nil];
    self.productPicker.toolBar.hidden = YES;
    self.productPicker.picker.dataSource  = self;
    self.productPicker.picker.delegate    = self;
    self.productField.field.inputView     = self.productPicker;
    self.productField.isEnabledActions = NO;
    //self.product.field.text = [self.presenter getPickerData][0];
    //!!
    [self.formTemplateVC.stackView addArrangedSubview:fieldsStack];
    
    ///!
    UIStackView *stackMinMax = [[UIStackView alloc] init];
    stackMinMax.axis = UILayoutConstraintAxisVertical;
    stackMinMax.spacing = 0.0;
    
    UILabel *minlbl = [self createMinMaxLabel];
    [minlbl sizeToFit];
    [stackMinMax  addArrangedSubview:minlbl];
    self.minProductLbl = minlbl;
    
    UILabel *maxlbl = [self createMinMaxLabel];
    [maxlbl sizeToFit];
    [stackMinMax addArrangedSubview:maxlbl];
    self.maxProductLbl = maxlbl;
    
    [self.formTemplateVC.stackView addArrangedSubview:stackMinMax];
    stackMinMax.hidden = YES;
    
    //!!
    UIStackView *stackBottom = [[UIStackView alloc] init];
    stackBottom.axis = UILayoutConstraintAxisVertical;
    stackBottom.spacing = 15.0;
    
    //!!!
    self.amountView = [[AmountController alloc] initWithFrame:CGRectZero];
    self.amountView.keyForm = @"external_card_transaction[amount]";
    [self.amountView setCurrencyField:@"EUR"];
    [stackBottom addArrangedSubview:self.amountView];
    self.amountView.hidden = YES;
    
    //!!!
    self.formFooter = [[FormFooter alloc] initWithFrame:CGRectZero];
    self.formFooter.timeLbl.text = @"transaction_mobile_operator_time_depends".localized;
    [stackBottom addArrangedSubview:self.formFooter];
    
    self.formFooter.hidden = YES;
    [self.formTemplateVC.stackView addArrangedSubview:stackBottom];
}

- (UILabel*)createMinMaxLabel {
    UILabel *lbl  = [[UILabel alloc] initWithFrame:CGRectZero];
    lbl.textColor = [UIColor whiteColor];
    lbl.font = [UIFont systemFontOfSize:12];
    return lbl;
}

- (void)showConfirmation:(NSDictionary*) data{
    PreCheckVC * vc  =  [PreCheckVC instance];
    vc.feeResponse   = self.amountView.lastFeeResponse;
    [vc view];
    
    vc.operationTypeTitleLbl.text = [PaymentEntity titleByType:self.transactionType];
    vc.amountBigLbl.text = [NSString stringFrom: self.amountView.amount];
    vc.currencyBigLbl. text = self.amountView.currencyField;
    
    vc.fromTitleLbl.text    = self.callerWallet.entity.name;
    vc.fromAmountLbl.text   = [NSString stringFrom: self.callerWallet.entity.balance.doubleValue];
    vc.fromCyrrencyLbl.text = self.callerWallet.entity.currencyLabel;
    vc.toTitleLbl.text      = self.numberPhoneField.valueForm;
    [vc hideDescriptionLbl];
    
    [vc setOnConfirmPassed:^{
        [self.navigationController popViewControllerAnimated:YES];
        [self makeTransfer:nil];
    }];
    
    [self.navigationController showViewController:vc sender:self];
}


- (NSDictionary *)checkComplete:(BOOL)isRefreshApperance{
    BOOL isError = NO;
    
    NSMutableDictionary *values = [NSMutableDictionary new];
    [FormDataApiHelper fillValuesFromView:self.view error:&isError resultDictionary:values refreshApperance:isRefreshApperance];
    
    if (isError) {
        [ErrorHandler showMessage:@"check_fields".localized  inController:self];
        return nil;
    }
    
    float amountTotal = self.amountView.totalStr.floatValueEPS;
    float balance     = self.callerWallet.entity.balance.floatValueEPS;
    
    if (amountTotal > balance) {
        [ErrorHandler showMessage:@"balance_less_amount_message".localized];
        [self.amountView setCorrectApperance:NO];
        return nil;
    }
    
    NSString *errorRangeMessage = [self.presenter checkRangeErrorFor:self.amountView.amount];
    
    if (errorRangeMessage!= nil){
        [ErrorHandler showMessage:errorRangeMessage];
        [self.amountView setCorrectApperance:NO];
        return nil;
    }
    
    return values;
}

- (void)makeTransfer:(NSMutableDictionary*)values {
    [self.presenter  makeTransaction];
}


///// field notifications
- (void)fieldDidBeginEditing:(NSNotification*)notify{
    UITextField *fromField = (UITextField *)notify.object;
    if ([fromField.parentControl isEqual:self.numberPhoneField]) {
        self.countryField.hidden  = YES;
        self.regionField.hidden   = YES;
        self.providerField.hidden = YES;
        self.productField.hidden  = YES;
        self.amountView.hidden    = YES;
        self.formFooter.hidden    = YES;
        self.maxProductLbl.superview.hidden = YES;
    }
}


- (void)fieldDidEndEditing:(NSNotification*)notify{
    
}

#pragma mark FormFieldSelectionProtocol
- (void)didDoneOnTextField{
    [[self.view findFirstResponder] resignFirstResponder];
    if ([self checkComplete:YES] != nil){
        [self showConfirmation:nil];
    }
}

- (void)didNextPressedOn:(nullable UITextField *)fromField {
    if ([fromField.parentControl isEqual:self.numberPhoneField]) {
        [self.presenter didEnterPhone:self.numberPhoneField.field.text];
    }
    
    if ([fromField.parentControl isEqual:self.regionField]) {
        DingRegionEntity *region = self.presenter.regionsData[[self.regionPicker.picker selectedRowInComponent:0]];
        self.regionField.field.text = region.regionName;
        [self.presenter didSelectRegion:region];
    }
    
    if ([fromField.parentControl isEqual:self.providerField]) {
        DingProviderEntity *provider = self.presenter.providersData[[self.providerPicker.picker selectedRowInComponent:0]];
        self.providerField.field.text = provider.name;
        [self.presenter didSelectProvider:provider];
    }
    
    if ([fromField.parentControl isEqual:self.productField]) {
        DingConnectProductItem *product = self.presenter.productData[[self.productPicker.picker selectedRowInComponent:0]];
        self.productField.field.text = product.fieldString;
        [self.presenter didSelectProduct:product];
    }
}

- (nullable NSNumber *)shouldGoFrom:(nullable UITextField *)fromField to:(nullable UITextField *)toField {
    if ([fromField.parentControl isEqual:self.numberPhoneField] &&
        [toField.parentControl isEqual:self.countryField]) {
        return @(YES);
    }
    return nil;
}


- (void)setCountryByPhoneNotFound {
    self.countryField.field.text = @"Country not found";
    self.countryField.isEnabled  = NO;
}

- (void)isCommonActivity:(BOOL)isActivity{
    if (isActivity){
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
}


#pragma mark pickers stuff
- (NSInteger)numberOfComponentsInPickerView:(nonnull UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(nonnull UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if ([pickerView isEqual:self.regionPicker.picker]){
        return self.presenter.regionsData.count;
    } else if ([pickerView isEqual:self.providerPicker.picker]){
        return self.presenter.providersData.count;
    } else if ([pickerView isEqual:self.productPicker.picker]){
        return self.presenter.productData.count;
    } else return 0;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if ([pickerView isEqual:self.regionPicker.picker]){
        return self.presenter.regionsData[row].regionName;
    } else if ([pickerView isEqual:self.providerPicker.picker]){
        return self.presenter.providersData[row].name;
    } else if ([pickerView isEqual:self.productPicker.picker]){
        return self.presenter.productData[row].fieldString;
    } else return 0;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
}

///other
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
