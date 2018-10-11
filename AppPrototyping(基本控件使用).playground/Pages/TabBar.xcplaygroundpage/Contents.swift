//: [Previous](@previous)

import UIKit
import PlaygroundSupport

let device = Device.iPhone6Plus
let frame = device.frame()
let appearance = Appearance(theme: .Custom, textColor: .yellow, labelColor: .purple)
let tabBar = TabBar(frame: frame, appearance: appearance)

PlaygroundPage.current.liveView = tabBar.view
//outlineViews([tabBar.view], outlineColor: .blueColor())

tabBar.view.frame

//: [Next](@next)
