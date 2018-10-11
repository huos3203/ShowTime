//: [Previous](@previous)

import UIKit
import PlaygroundSupport

let device = Device.iPhone6Plus
let frame = device.frame()
let appearance = Appearance(theme: .Custom, textColor: .yellow, labelColor: .purple)
let statusBar = StatusBar(frame: frame, appearance: appearance)
PlaygroundPage.current.liveView = statusBar.view
//outlineViews([statusBar.view], outlineColor: .blackColor())

//: [Next](@next)
