//
//  ArticleTableViewController.swift
//  CovidNotes
//
//  Created by Ian Pruett on 4/26/20.
//  Copyright © 2020 Ian Pruett. All rights reserved.
//

import UIKit
import SafariServices

class ArticleTableViewController: UITableViewController {
    
    let apiUrl: String = "https://newsapi.org/v2/top-headlines?country=us&q=coronavirus"
    var articles: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        getNewsArticles()
    }

    func getApiKey() -> String {
        // https://stackoverflow.com/questions/30803244/how-to-hide-api-keys-in-github-for-ios-swift-projects
        var keys: NSDictionary?
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        return keys!["newsApiKey"] as! String
    }

    func getNewsArticles() {
        // May not know exactly what's in the URL, so replace special characters with % encoding
        let newsUrl = apiUrl + "&apiKey=\(getApiKey())"
        if let urlStr = newsUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
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
            let articlesList = jsonDict["articles"] as? [[String: Any]],
            articlesList.count > 0 else {
                print("error: invalid JSON data")
                return
            }
        DispatchQueue.main.async {
            self.articles = articlesList
            self.tableView.reloadData()
        }
    }
    
    func showArticleWebPage(for urlString: String) {
        guard let url = URL(string: urlString) else {
            let alert = UIAlertController(title: "Invalid URL", message: "The link to article is invalid", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(okAction)
            alert.preferredAction = okAction
            present(alert, animated: true)
            return
        }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "articleCell", for: indexPath) as! ArticleCell

        // Configure the cell...
        let indexRow = indexPath.row
        let article = articles[indexRow]
        cell.articleTitle.text = article["title"] as? String
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexRow = indexPath.row
        let article = articles[indexRow]
        let urlString = article["url"] as? String
        showArticleWebPage(for: urlString!)
    }
    
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
