import UIKit

struct Gist: Decodable {
    let comments: Int64
    let date: String
    let name: String
    let gistType: Bool
    
    enum CodingKeys: String, CodingKey {
        case comments = "comments"
        case date = "created_at"
        case name  = "description"
        case gistType = "public"
    }
}

let token: String = ""
let githubUrl: String = "https://api.github.com/users/:username/gists"

class ViewController: UIViewController {
    
    var gistsArr: [Gist] = []

    @IBOutlet weak var tableView: UITableView! {
        didSet{
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let components = URLComponents(string: githubUrl)
        guard let url = components?.url else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self](data, response, error) in
            guard let _ = self,
                  let data = data else { return }
            
            guard let gistsArr = try? JSONDecoder().decode([Gist].self, from: data) else {
                return }
            
                
            self?.gistsArr = gistsArr
                
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.refreshControl?.endRefreshing()
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gistsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "gistCell", for: indexPath) as! TableViewCell
    
        cell.commentsLabel.text = "Кол-во комментариев: \(gistsArr[indexPath.row].comments)"
        cell.dateLabel.text = "Дата создания: \(gistsArr[indexPath.row].date)"
        cell.nameLabel.text = "Название: \(gistsArr[indexPath.row].name)"
        cell.typeLabel.text = gistsArr[indexPath.row].gistType == true ? "Тип: public" : "Тип: secret"
        return cell
    }
}
