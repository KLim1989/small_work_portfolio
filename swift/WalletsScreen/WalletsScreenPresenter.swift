//
//  WalletsScreenPresenter.swift
//  TBot
//
//  Created by Valera Voroshilov on 14/11/2018.
//  Copyright © 2018 Valera Voroshilov. All rights reserved.
//

import UIKit

final class WalletsScreenPresenter {
	weak var view: WalletsScreenViewInput?
	var router: WalletsScreenRouterInput!
	var interactor: WalletsScreenInteractorInput!
	weak var moduleOutput: WalletsScreenModuleOutput?

    
    var tableDataSource: TableViewCommonDataSource<Array<WalletHistoryEntityResponse>, WalletHistoryCell>!
    
    init (){
        self.tableDataSource = TableViewCommonDataSource.init(data: [])
    }
    
    func refreshData() {
        _ = self.interactor.getWallets().done{ response in
            self.view?.setWallets(wallets: response)
        }
        
        _ = self.interactor.getWalletsHistory().done{ response in
            self.tableDataSource.data = response
            self.view?.tableView.reloadData()
            self.view?.hideActivity()
            self.view?.hideRefreshControl()
        }
    }
}





extension WalletsScreenPresenter: WalletsScreenInteractorOutput {
}

extension WalletsScreenPresenter: WalletsScreenViewOutput {
    func didPullToRefresh() {
        self.refreshData()
    }
    
    func depositBtnPressed() {
          let vc = self.view as! UIViewController
          self.router.showDepScreen(from: vc)
    }
    
    func viewDidLoad() {
        self.tableDataSource = TableViewCommonDataSource.init(data: [])
        self.view?.tableView.dataSource = self.tableDataSource
        
        self.view?.showActivity()
        self.refreshData()
    }
}
