//
//  ViewController.swift
//  iOS-Test
//
//  Created by Renhard SehatQ on 07/10/21.
//

import UIKit
import Alamofire
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfSearch: UITextField!
    private var searchTimer: Timer?
    
    var productByCategory = [ProductByCategory]()
    var responseData: ResponseModel?
    var selectedProduct: ProductModel?
    var urlAPI = "https://jxtestingmobile-default-rtdb.firebaseio.com/mobilewarung.json"
    var myCurrentLocaion = "-6.352034, 106.863358"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    @IBAction func searchTextChanged(_ sender: UITextField) {
        if let searchTimer = searchTimer {
            searchTimer.invalidate()
        }
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(onSearchApply), userInfo: nil, repeats: false)
    }
    
    @IBAction func onButtonClick(_ button: UIButton) {
        switch button.accessibilityIdentifier {
        case "btnPostage":
            calculatePostage()
            break
        case "btnVoucher":
            calculateVoucher()
            break
        default:
            break
        }
    }
    
    @objc func onSearchApply() {
        fetchData()
        if let filterBy = tfSearch.text?.lowercased(), !filterBy.isEmpty {
            let productCategory = productByCategory.filter { $0.category.lowercased().contains(filterBy) }
            if productCategory.isEmpty {
                for i in 0..<productByCategory.count {
                    productByCategory[i].products.removeAll(where: { !$0.name.lowercased().contains(filterBy) })
                }
                
                productByCategory.removeAll(where: { $0.products.isEmpty })
            } else {
                productByCategory = productCategory
            }
        }
        tableView.reloadData()
    }

    func loadData() {
        let request = AF.request(urlAPI).validate()
        request.responseJSON(completionHandler: { [weak self] response in
            switch response.result {
            case .success(let result):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: result, options: [])
                    self?.responseData = try JSONDecoder().decode(ResponseModel.self, from: jsonData)
                    self?.fetchData()
                    self?.tableView.reloadData()
                } catch {
                    print(error)
                }
                break
            case .failure(let error):
                print("Error Network: \(error)")
                break
            }
        })
    }
    
    private func fetchData() {
        var categories = [String: [ProductModel]]()
        responseData?.products.forEach { product in
            var productExist = categories[product.category] ?? []
            productExist.append(product)
            categories[product.category] = productExist
        }
        productByCategory = categories.sorted(by: { $0.0 < $1.0 }).map({ ProductByCategory(category: $0.key, products: $0.value) })
    }
    
    func getPostagePrice() -> Int {
        let myLatLong = myCurrentLocaion.components(separatedBy: CharacterSet(charactersIn: ", "))
        guard let destLatLong = responseData?.location.components(separatedBy: CharacterSet(charactersIn: ", ")) else { return 0 }
        let myCoordinate = CLLocation(latitude: Double(myLatLong[0]) ?? 0, longitude: Double(myLatLong[2]) ?? 0)
        let destCoordinate = CLLocation(latitude: Double(destLatLong[0]) ?? 0, longitude: Double(destLatLong[2]) ?? 0)
        let distanceUnitPerKm = myCoordinate.distance(from: destCoordinate) / 1000
        let postagePrice = Int(distanceUnitPerKm.rounded(.up) * 9000)
        
        return postagePrice
    }
    
    /* Calculate postage using radius from 2 coodinates */
    private func calculatePostage() {
        let postagePrice = getPostagePrice()
        
        let alert = UIAlertController(title: "Postage", message: "Postage from my location to Bu Dedi's shop is Rp \(postagePrice)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func calculateVoucher() {
        var title = "Voucher ongkir5 & disc35"
        var message = ""
        if let product = selectedProduct {
            var discShop = product.price * 35 / 100
            discShop = discShop > 30000 ? 30000 : discShop
            let postagePrice = getPostagePrice() - 5000
            let productPrice = product.price - discShop
            let totalPrice = productPrice + postagePrice
            
            message = "Product = Rp \(productPrice)\nPostage = Rp \(postagePrice)\nTotal = Rp \(totalPrice)"
        } else {
            title = "Oops"
            message = "You must select product first!"
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return productByCategory.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productByCategory[section].products.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return productByCategory[section].category
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath) as? ProductCell
        else { return UITableViewCell() }
        let data = productByCategory[indexPath.section].products[indexPath.row]
        cell.lbName.text = data.name
        cell.lbPrice.text = "Rp \(data.price)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProduct = productByCategory[indexPath.section].products[indexPath.row]
    }
}

