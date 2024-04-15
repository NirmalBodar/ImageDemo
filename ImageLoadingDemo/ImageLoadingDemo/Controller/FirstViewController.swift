

import UIKit

class FirstViewController: UIViewController {
    
    //MARK: - Properties
    
    let firstView = FirstView()
    
    //MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBtnFuc()
        view = firstView
    }
    
    //MARK: - Functions
    
    func addBtnFuc() {
        firstView.myBtn.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
    }
    
    @objc func nextPage() {
        navigationController?.pushViewController(SecondViewController(), animated: true)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
}

