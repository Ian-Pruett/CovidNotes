//
//  StatViewController.swift
//  CovidNotes
//
//  Created by Ian Pruett on 4/28/20.
//  Copyright © 2020 Ian Pruett. All rights reserved.
//

import UIKit

class StatViewController: UIViewController {
    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var totalCasesLabel: UILabel!
    @IBOutlet weak var totalDeathsLabel: UILabel!
    @IBOutlet weak var countryTextField: UITextField!
    
    var globalTotalConfirmed: Int?
    var globalTotalReccovered: Int?
    var globalTotalDeaths: Int?
    
    let apiUrl: String = "https://api.covid19api.com/summary"
    var countires: [[String: Any]]?
    
    @IBOutlet weak var totalRecoveredLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStats()
        // Do any additional setup after loading the view.
    }
    
    func getStats() {
        if let urlStr = apiUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            if let url = URL(string: urlStr) {
                let dataTask = URLSession.shared.dataTask(with: url, completionHandler: handleResponse)
                dataTask.resume()
            }
        }
    }
    
    func handleResponse(data: Data?, response: URLResponse?, error: Error?) {
        // 1. Check for error in request (e.g., no network connection)
        if let err = error {
            print("error: \(err.localizedDescription)")
            return
        }
        // 2. Check for improperly-formatted response
        guard let httpResponse = response as? HTTPURLResponse else {
            print("error: improperly-formatted response")
            return
        }
        let statusCode = httpResponse.statusCode
        // 3. Check for HTTP error
        guard statusCode == 200 else {
            let msg = HTTPURLResponse.localizedString(forStatusCode: statusCode)
            print("HTTP \(statusCode) error:\(msg)")
            return
        }
        // 4. Check for no data
        guard let somedata = data else {
            print("error: no data")
            return
        }
        // 5. Check for improperly-formatted data
        guard let json = try? JSONSerialization.jsonObject(with: somedata),
            let jsonDict = json as? [String: Any],
            let globalSummary = jsonDict["Global"] as? [String: Any],
            let totalConfirmed = globalSummary["TotalConfirmed"] as? Int,
            let totalRecovered = globalSummary["TotalRecovered"] as? Int,
            let totalDeaths = globalSummary["TotalDeaths"] as? Int,
            let countriesList = jsonDict["Countries"] as? [[String: Any]],
            countriesList.count > 0 else {
                print("error: invalid JSON data")
                return
            }
        DispatchQueue.main.async {
            self.globalTotalConfirmed = totalConfirmed
            self.globalTotalReccovered = totalRecovered
            self.globalTotalDeaths = totalDeaths
            self.totalCasesLabel.text = String(totalConfirmed)
            self.totalRecoveredLabel.text = String(totalRecovered)
            self.totalDeathsLabel.text = String(totalDeaths)
            self.countires = countriesList
        }
    }
    
    func resetGlobalStats() {
        countryLabel.text = "Global"
        totalCasesLabel.text = String(globalTotalConfirmed!)
        totalRecoveredLabel.text = String(globalTotalReccovered!)
        totalDeathsLabel.text = String(globalTotalDeaths!)
    }
    
    func updateStats(for country: [String: Any]) {
        let countryName = country["Country"] as? String
        let totalConfirmed = country["TotalConfirmed"] as? Int
        let totalRecovered = country["TotalRecovered"] as? Int
        let totalDeaths = country["TotalDeaths"] as? Int
        countryLabel.text = countryName
        totalCasesLabel.text = String(totalConfirmed!)
        totalRecoveredLabel.text = String(totalRecovered!)
        totalDeathsLabel.text = String(totalDeaths!)
    }
    
    func findCountry(for query: String) {
        for country in countires! {
            let countryName = country["Country"] as? String
            if countryName!.lowercased().contains(query.lowercased()) {
                updateStats(for: country)
                break
            }
        }
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        let country = countryTextField.text!
        findCountry(for: country)
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        resetGlobalStats()
    }
}
