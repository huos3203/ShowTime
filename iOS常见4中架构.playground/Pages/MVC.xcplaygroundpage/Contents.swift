/**
 * MVC iOS Design Pattern
 *使用MVC设计模式
 * 1. 定义数据model为结构体
 * 2. 在Controller中处理View和model之间的业务
 */
//: ![MVC模式](IMG_0524.PNG)
//:![nnn](https://www.objccn.io/images/issues/issue-13/intermediate.png)



import UIKit
import PlaygroundSupport

struct Person { // Model
    let firstName: String
    let lastName: String
}

class GreetingViewController : UIViewController {   // View + Controller
    var person: Person!
    var showGreetingButton: UIButton!
    var greetingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("load")
        self.view.frame = CGRect(x: 0, y: 0, width: 320, height: 640)
        self.setupUIElements()
        print("zzzz")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        self.layout()
    }
    
    func setupUIElements() {
        self.title = "Test"
        self._setupButton()
        self._setupLabel()
    }
    
    private func _setupButton() {
        self.showGreetingButton = UIButton()
        self.showGreetingButton.setTitle("Click me", for: .normal)
        self.showGreetingButton.setTitle("You badass", for: .highlighted)
        self.showGreetingButton.setTitleColor(UIColor.white, for: .normal)
        self.showGreetingButton.setTitleColor(UIColor.red, for: .highlighted)
        self.showGreetingButton.translatesAutoresizingMaskIntoConstraints = false
        self.showGreetingButton.addTarget(self,
                                          action: #selector(didTapButton(sender:)), 
                                          for: .touchUpInside)
        self.view.addSubview(self.showGreetingButton)
    }
    
    private func _setupLabel() {
        self.greetingLabel = UILabel()
        self.greetingLabel.textColor = UIColor.white
        self.greetingLabel.textAlignment = .center
        self.greetingLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.greetingLabel)
    }
    
    func layout() {
        self._layoutButton()
        self._layoutLabel()
        self.view.layoutIfNeeded()
    }
    
    private func _layoutButton() {
        // layout button at the center of the screen
        let cs1 = NSLayoutConstraint(item: self.showGreetingButton, 
                                     attribute: .centerX,
                                     relatedBy: .equal,
                                     toItem: self.view, 
                                     attribute: .centerX, 
                                     multiplier: 1.0,
                                     constant: 1.0)
        let cs2 = NSLayoutConstraint(item: self.showGreetingButton, 
                                     attribute: .centerY,
                                     relatedBy: .equal,
                                     toItem: self.view, 
                                     attribute: .centerY, 
                                     multiplier: 1.0, 
                                     constant: 1.0)
        self.view.addConstraints([cs1, cs2])
    }
    
    private func _layoutLabel() {
        // layout label at the center, bottom of the screen
        let cs1 = NSLayoutConstraint(item: self.greetingLabel, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 1.0)
        let cs2 = NSLayoutConstraint(item: self.greetingLabel, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        let cs3 = NSLayoutConstraint(item: self.greetingLabel, attribute: .width, relatedBy: .equal, toItem: self.view, attribute: .width, multiplier: 0.70, constant: 0)
        
        self.view.addConstraints([cs1, cs2, cs3])
    }
    
    @objc func didTapButton(sender: UIButton) {
        self.greetingLabel.text = "Hello " + self.person.firstName + " " + self.person.lastName
    }
}

let model = Person(firstName: "Wasin", lastName: "Thonkaew")
let vc = GreetingViewController()
vc.person = model

PlaygroundPage.current.liveView = vc
