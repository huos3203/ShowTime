import Foundation
import UIKit
let html:String
let htmlurl = URL.init(string: "http://www.95kp.cc/?m=vod-play-id-7396-src-1-num-1.html")
html = try NSString.init(contentsOf: htmlurl!, encoding:0) as String
//正则过滤

func check(str: String) {
    // 使用正则表达式一定要加try语句
    do {
        // - 1、创建规则
        let pattern = "http.*m3u8"
        // - 2、创建正则表达式对象
        let regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
        // - 3、开始匹配
        let res = regex.matches(in: str, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, str.characters.count))
        // 输出结果
        for checkingRes in res {
            let hh = (str as NSString).substring(with: checkingRes.range)
            print(hh)
            let dd = hh.replacingOccurrences(of: "%2F", with: "/")
            let ddd = dd.replacingOccurrences(of: "%3A", with: ":")
            let rrr = UITextField.init(frame: CGRect.init(x: 0, y: 0, width: 24, height: 23))
            rrr.text = ddd
            print(ddd)
        }
    }
    catch {
        print(error)
    }
}       
check(str: html)
