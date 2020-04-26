//
//  FormTextField+DingFieldProtocol.m
//  ePayService
//
//  Created by Valera Voroshilov on 03.12.2019.
//  Copyright © 2019 Valera Voroshilov. All rights reserved.
//

#import "FormTextField+DingFieldProtocol.h"

#import <UIKit/UIKit.h>
#import "InputViewPicker.h"


@implementation FormTextField (DingFieldProtocol)
- (void)setIsActivity:(BOOL)isActivity{
    InputViewPicker* picker = (InputViewPicker*)self.field.inputView;
    if (isActivity) {
         [picker.activity startAnimating];
    } else {
         [picker.activity stopAnimating];
    }
   
    picker.picker.hidden = isActivity;
}
@end
