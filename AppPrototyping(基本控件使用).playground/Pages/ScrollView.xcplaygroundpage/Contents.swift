//: [Previous](@previous)

import UIKit
import PlaygroundSupport

let device = Device.iPhone6Plus
let frame = device.frame()
let view = UIView(frame: frame)
let sv = makeVerticalSV(view: view)
let appearance = Appearance(theme: .Light, textColor: nil, labelColor: nil)
let statusBar = StatusBar(frame: frame, appearance: appearance)
sv.addArrangedSubview(statusBar.view)
horizontalStrechToParentView(arr:statusBar.view)

let svc = ScrollView(device: device, imageName: "splash", scrollDirection: .Both, width: nil, height: 500)
sv.addArrangedSubview(svc.view)
svc.center()
svc.scroll(direction:.Left, amount: 100)

let tabbar = TabBar(frame: frame, appearance: appearance)
sv.addArrangedSubview(tabbar.view)

PlaygroundPage.current.liveView = view
PlaygroundPage.current.needsIndefiniteExecution = true
view.frame = device.frame()

//outlineViews([view], outlineColor: .whiteColor())
//: [Next](@next)
