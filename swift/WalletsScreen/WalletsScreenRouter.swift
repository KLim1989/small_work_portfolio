//
//  WalletsScreenRouter.swift
//  TBot
//
//  Created by Valera Voroshilov on 14/11/2018.
//  Copyright © 2018 Valera Voroshilov. All rights reserved.
//

import UIKit

final class WalletsScreenRouter {
}

extension WalletsScreenRouter: WalletsScreenRouterInput {
    func showDepScreen(from: UIViewController) {
      
        let vcDepositInstructions:MakeDepInstructionsViewController = MakeDepInstructionsViewController.create(moduleName: "MakeDepInstructions")
        
        var input = ChecklikeSlideInput()
        input.childVC = vcDepositInstructions

        input.onCloseBlock = {
            from.navigationController?.setNavigationBarHidden(false, animated: true)
        }
        
        let vc = ChecklikeSlideContainer.assemble(with: input).viewController
        from.addChildVCToParentAndView(child:vc)
        from.navigationController?.setNavigationBarHidden(true, animated: true)
    }
}
