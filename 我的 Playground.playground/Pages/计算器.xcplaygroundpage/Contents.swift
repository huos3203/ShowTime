import Foundation
class opration:NSObject{
    var firstNum = 0
    var secondNum = 0
    func getResultNum() -> Double{
        return 0
    }
}
class addOpt:opration{
    override init() {
        super.init()
    }
    override func getResultNum() -> Double {
        var result = self.firstNum + self.secondNum
        return Double(result)
    }
}
class jianfaOpt:opration{
    override func getResultNum() -> Double {
        return self.firstNum - self.secondNum
    }
}
class factory
{
    var opt:opration!
    func createFunc(flag:String) -> opration{
        switch flag{
            case "+":
            opt = addOpt()
            case "-":
            opt = jianfaOpt()
            default:
            opt = nil
        }
    return opt
    }
}
factory().createFunc(flag: "+"). 


