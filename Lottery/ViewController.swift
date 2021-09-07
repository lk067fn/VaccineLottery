//
//  ViewController.swift
//  Lottery
//
//  Created by Lukáš Kubaliak on 07/09/2021.
//

import UIKit
import Alamofire

class PasswordObject: NSObject {
    var updated: String?
    var password: String?
    
    init(responseDict: [String: Any]) {
        if let updatedAt = responseDict["updated"] as? String {
            self.updated = updatedAt
        }
        if let pw = responseDict["heslo"] as? String {
            self.password = pw
        }
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordStatus: UILabel!
    @IBOutlet weak var countDownLabel: UILabel!
    
    private var url = "https://www.povedzheslo.sk/get_heslo.php"
    private var timerCountDown: Timer?
    private var password: PasswordObject?
    private var countDown: Int = 6

    override func viewDidLoad() {
        super.viewDidLoad()

        initialSetup()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        UserDefaults.standard.set("", forKey: "password")

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timerCountDown?.invalidate()
    }

    func initialSetup() {
        titleLabel?.text = "Aktuálne heslo je:"
        passwordLabel?.text = ">>>nedotupné<<<"
        passwordStatus?.text = ""
        countDownLabel?.text = ""
        passwordStatus?.textColor = UIColor.systemGray4
    }
    
    func setupPassword() {
        if let pw = password?.password {
            passwordLabel?.text = pw
        }
        else {
            passwordLabel?.text = ">>>nedotupné<<<"
        }
        if let pwStatus = password?.updated {
            passwordStatus?.text = "heslo bolo aktualizované: " + pwStatus
        }
        else {
            passwordStatus?.text = "heslo sa nepodarilo aktualizovať"
        }
    }
    
    func savePasswordToLocalStorage () {
        if let oldPw = UserDefaults.standard.string(forKey: "password") {
            if let newPw = password?.password {
                if oldPw != newPw {
                    UserDefaults.standard.set(newPw, forKey: "password")
                }
            }
        }
    }
    
    @objc func update() {
        if countDown >= 0 {
            countDown -= 1
            countDownLabel.text = "Aktualizujem o: " + String(countDown)
            
            if countDown == 0 {
                hackPassword()
            }
        }
    }
    
    @objc func hackPassword () {
        Alamofire.request(url, method: .get)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success:
                    if let responseDict = response.result.value as? [String: Any] {
                        self.password = PasswordObject(responseDict: responseDict)
                        self.setupPassword()
                        self.countDown = 6
                        self.savePasswordToLocalStorage()
                    }
                case .failure(let error):
                    print(error)
                }
            }
    }
    
}

