//
//  ViewController.swift
//  project7
//
//  Created by Ivan Pavic on 14.1.22..
//

import UIKit

class ViewController: UITableViewController {

    var petitions = [Petition]()
    var filteredItems = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Reset filter", style: .plain, target: self, action: #selector(resetFilter)) ,UIBarButtonItem (title: "Filter", style: .plain, target: self, action: #selector(filterItems))]
        
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
                [weak self] in
                if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    self?.parse(json: data)
                    return
                }
            }
            self?.performSelector(onMainThread: #selector(self?.showError), with: nil, waitUntilDone: false)
        }

    }
    
    @objc func resetFilter () {
        filteredItems = petitions
        tableView.reloadData()
    }
    
    @objc func filterItems () {
        let ac = UIAlertController(title: "Filter by keywords", message: "Enter keywords to search through data", preferredStyle: .alert)
        ac.addTextField()
        
        let submitKeyword = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let stringOfKeywords = ac?.textFields?[0].text else {return}
            let keywords = stringOfKeywords.lowercased().stringToArray()
            self?.filter(keywords)
        }
        ac.addAction(submitKeyword)
        present (ac, animated: true)
        filteredItems = petitions
    }
    
    func filter (_ keywords: [String]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.filteredItems.removeAll(where: {$0.title.lowercased().containsNot(array: keywords) && $0.body.lowercased().containsNot(array: keywords)})
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    @objc func showCredits () {
        let ac = UIAlertController(title:nil, message: "This data comes from the We The People API of the White House", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        present (ac, animated: true)
    }
    
    @objc func showError () {
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading this feed. Please check you internet connection.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default))
            present (ac, animated: true)
    }
    
    func parse (json: Data) {
        let decoder = JSONDecoder ()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredItems = petitions
            DispatchQueue.main.async {
                [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredItems[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = DetailViewController()
        vc.detailItem = filteredItems[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }


}

