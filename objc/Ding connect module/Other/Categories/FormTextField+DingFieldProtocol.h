//
//  FormTextField+DingFieldProtocol.h
//  ePayService
//
//  Created by Valera Voroshilov on 03.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormTextField.h"
#import "DingConnectProtocols.h"

NS_ASSUME_NONNULL_BEGIN

@interface FormTextField (DingFieldProtocol)<DingVCFieldProtocol>
@property BOOL isActivity;
@end

NS_ASSUME_NONNULL_END
