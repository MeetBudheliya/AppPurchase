//
//  ViewController.swift
//  FirebaseRemoteConfig
//
//  Created by Adsum MAC 1 on 02/08/21.
//

import UIKit
import Firebase
import StoreKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,SKProductsRequestDelegate,SKPaymentTransactionObserver {
    
    private var product = [SKProduct]()
    private let table : UITableView = {
        let tbl = UITableView()
        tbl.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tbl
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
//       remoteConfig = RemoteConfig.remoteConfig()
//        let settings = RemoteConfigSettings()
//        settings.minimumFetchInterval = 0
//        remoteConfig.configSettings = settings
        
        SKPaymentQueue.default().add(self)
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.frame = self.view.bounds
        fetchProducts()
        
    }

    //MARK:- Table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let pro = product[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = "\(pro.localizedTitle): \(pro.localizedDescription) - \(pro.priceLocale.currencySymbol ?? "₹")\(pro.price)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let payment = SKPayment(product: product[indexPath.row])
        SKPaymentQueue.default().add(payment)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    enum Product:String,CaseIterable {
        case removeAds = "com.myapp.removeads"
        case unlockEverthing = "com.myapp.unlockeverthing"
        case getGems = "com.myapp.getgems"
    }
    private func fetchProducts(){
        let request = SKProductsRequest(productIdentifiers: Set(Product.allCases.compactMap({$0.rawValue})))
        request.delegate = self
        request.start()
    }
    
    //MARK:- product request
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { [self] in
            print("***\(response.products)***")
            product = response.products
            table.reloadData()
        }
    }

    //MARK:- paymentQueue
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach { trans in
            switch trans.transactionState{
            case .purchasing:
                print("Purchasing")
            case .purchased:
                print("Purchased")
            case .failed:
                print("Did not purchase")
            case .restored:
                print("Restored")
                break
            case .deferred :
                print("Deferred")
                break
            @unknown default:
                break
            }
        }
    }
}

