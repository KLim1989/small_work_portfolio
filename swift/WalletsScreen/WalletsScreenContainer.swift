//
//  WalletsScreenContainer.swift
//  TBot
//
//  Created by Valera Voroshilov on 14/11/2018.
//  Copyright © 2018 Valera Voroshilov. All rights reserved.
//

import UIKit

final class WalletsScreenContainer {
	let viewController: UIViewController
	private(set) weak var router: WalletsScreenRouterInput!

	class func assemble(with input: WalletsScreenModuleInput) -> WalletsScreenContainer {
        let viewController:WalletsScreenViewController = WalletsScreenViewController.create(moduleName: "WalletsScreen")
		let presenter = WalletsScreenPresenter()
		let router       = WalletsScreenRouter()
		let interactor = WalletsScreenInteractor()

		viewController.output =  presenter

		presenter.view = viewController
		presenter.router = router
		presenter.interactor = interactor

		interactor.output = presenter
    
		return WalletsScreenContainer(view: viewController, router: router)
	}

	private init(view: UIViewController, router: WalletsScreenRouterInput) {
		viewController = view
		self.router    = router
	}
}

struct WalletsScreenInput: WalletsScreenModuleInput {

}
