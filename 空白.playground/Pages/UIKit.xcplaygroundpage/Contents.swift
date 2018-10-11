import PlaygroundSupport
import UIKit
class MyViewController:UIViewController
{
    var label = UILabel.init(frame:CGRect(x:0,y:0,width:100,height:30))
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        label.text = "hello world !"
        view.addSubview(label)
    }
}
let page = PlaygroundPage.current.liveView = MyViewController()

