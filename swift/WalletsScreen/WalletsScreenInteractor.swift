//
//  WalletsScreenInteractor.swift
//  TBot
//
//  Created by Valera Voroshilov on 14/11/2018.
//  Copyright © 2018 Valera Voroshilov. All rights reserved.
//

import Foundation
import PromiseKit

final class WalletsScreenInteractor {
  	 weak var output: WalletsScreenInteractorOutput?
     let service = WalletsService ()
}

extension WalletsScreenInteractor: WalletsScreenInteractorInput {
    func getWallets() -> Promise<[WalletEntityResponse]> {
            return self.service.getWallets()
    }
    
    func getWalletsHistory()  -> Promise<[WalletHistoryEntityResponse]>{
           return self.service.getWalletsHistory()
    }
}


