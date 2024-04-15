

import UIKit
import SystemConfiguration

class SecondViewController: UIViewController {
    
    
    //MARK: - Properties
    
    let secondView = SecondView()
    var pictureInfo = [ImageInfo]() {
        didSet{
            DispatchQueue.main.async {
                self.secondView.myCollectionView.reloadData()
                print(self.pictureInfo[0].urls)
            }
        }
    }
    
    var currentPage = 1
    var isLoading = false
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = secondView
        secondView.myCollectionView.dataSource = self
        secondView.myCollectionView.delegate = self
        fetchImages(page: currentPage)
    }
    
    //MARK: - Functions
    
    func fetchImages(page:Int) {
        //  $ curl https://api.unsplash.com/photos/random?count=5 █
        
        if isConnectedToNetwork() {
            print("Internet connection available")
        } else {
            print("Internet connection not available")
            
            let alert = UIAlertController(title: "Alert", message: "Internet connection not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    self.fetchImages(page: self.currentPage)
                case .cancel:
                    print("cancel")
                case .destructive:
                    print("destructive")
                @unknown default: break
                    
                }
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        let addressURL = "https://api.unsplash.com/photos?page=\(page)&client_id=DLK95F_AzDhimjlsEz2mdw-0jHpnSpTOhdpGhMqXWz4&order_by=ORDER&per_page=30"
        if let url = URL(string: addressURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Error: \(error)")
                }else if let response = response as? HTTPURLResponse, let data = data {
                    print("Response: \(response)")
                    print("Status Code: \(response.statusCode)")
                    do{
                        let decoder = JSONDecoder()
                        let picInfo = try decoder.decode([ImageInfo].self, from: data)
                        self.pictureInfo.append(contentsOf: picInfo)
                        
                        self.currentPage += 1
                        self.isLoading = false
                    }catch{
                        print(error)
                    }
                }
            }.resume()
        }
        
    }
    
    //MARK: - Network Check
    
    func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    
}

//MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension SecondViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pictureInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.collectionViewId, for: indexPath) as? CollectionViewCell else { return UICollectionViewCell() }
        
        DispatchQueue.main.async {
            cell.myImageView.loadImages(from: self.pictureInfo[indexPath.row].urls.regularUrl)
            if (cell.myImageView.image == nil)
            {
                DispatchQueue.main.async {
                    cell.myImageView.image = UIImage(named: "placeholder")
                }
            }
        }
        
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height * 2 && !isLoading {
            isLoading = true
            fetchImages(page: currentPage)
        }
    }
    
    
}


