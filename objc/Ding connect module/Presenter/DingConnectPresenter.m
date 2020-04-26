//
//  DingConnectPresenter.m
//  ePayService
//
//  Created by Valera Voroshilov on 28.11.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "DingConnectPresenter.h"
#import "AccoutList.h"
#import "AccountsFilter.h"
#import "DingConnectAPI.h"
#import "DingDataProvider.h"

@interface DingConnectPresenter()

@end

@implementation DingConnectPresenter

- (instancetype)init{
    self = [super init];
    if (self) {
        self.listWallets = [[AccountsFilter walletsDingConnect] grouped];;
        self.provider    = [[DingDataProvider alloc] init];
    }
    return self;
}
@end
