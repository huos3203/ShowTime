//: [Previous](@previous)

import UIKit
import PlaygroundSupport

let device = Device.iPhone6Plus
let frame = device.frame()
let appearance = Appearance(theme: .Custom, textColor: .yellow, labelColor: .purple)
var navBar = NavigationBar(frame: frame, appearance: appearance, title: "Title")
navBar.containerView?.view?.frame = CGRect(x:0, y:0, width:frame.width, height:44)
PlaygroundPage.current.liveView = navBar.containerView?.view
//outlineViews([navBar.containerView!.view!], outlineColor: .blueColor())


//: [Next](@next)
