//
//  WalletsScreenProtocols.swift
//  TBot
//
//  Created by Valera Voroshilov on 14/11/2018.
//  Copyright © 2018 Valera Voroshilov. All rights reserved.
//

import UIKit
import PromiseKit

protocol WalletsScreenModuleInput {
}

protocol WalletsScreenModuleOutput: AnyObject {
}

protocol WalletsScreenViewInput: AnyObject {
    func setWallets(wallets:[WalletEntityResponse])
    var tableView:UITableView {get}
    func showActivity()
    func hideActivity()
    func hideRefreshControl()
}

protocol WalletsScreenViewOutput: AnyObject {
     func viewDidLoad()
     func depositBtnPressed()
     func didPullToRefresh()
}

protocol WalletsScreenInteractorInput: AnyObject {
    func getWallets()  -> Promise<[WalletEntityResponse]>
    func getWalletsHistory()  -> Promise<[WalletHistoryEntityResponse]>
}

protocol WalletsScreenInteractorOutput: AnyObject {
}

protocol WalletsScreenRouterInput: AnyObject {
    func showDepScreen(from:UIViewController)
}
