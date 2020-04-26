//
//  WalletsScreenViewController.swift
//  TBot
//
//  Created by Valera Voroshilov on 14/11/2018.
//  Copyright © 2018 Valera Voroshilov. All rights reserved.
//

import UIKit
import SVProgressHUD


final class WalletsScreenViewController: UIViewController {

    var output: WalletsScreenViewOutput!
    var wallet:WalletView!
    
    @IBOutlet weak var walletContainer: UIView!
    @IBOutlet weak private var tableViewPrivate: UITableView!
    
    var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for:.valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.wallet = WalletView.init(frame:CGRect.zero)
        self.wallet.backgroundColor = UIColor.init(hex: 0xECEFF7)
        self.wallet.cornerRadius = 8
        self.walletContainer.addAndSprawl(child: self.wallet )
        
        self.tableView.refreshControl = self.refreshControl
        self.output.viewDidLoad()
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.output.didPullToRefresh()
    }
    
    @IBAction func depositBtnPressed(_ sender: Any) {
        self.output.depositBtnPressed()
    }
}

extension WalletsScreenViewController: WalletsScreenViewInput {
    var tableView: UITableView {
        return self.tableViewPrivate
    }
    
    func setWallets(wallets: [WalletEntityResponse]) {
        if  let w = wallets.first {
            self.wallet.entity = w
        }
    }
    
    func hideRefreshControl() {
        self.refreshControl.endRefreshing()
    }
    
    func showActivity() {
        SVProgressHUD.show()
    }
    
    func hideActivity() {
        SVProgressHUD.dismiss()
    }
    
}


