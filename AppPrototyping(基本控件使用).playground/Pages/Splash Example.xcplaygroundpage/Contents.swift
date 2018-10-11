//: [Previous](@previous)

import UIKit
import PlaygroundSupport

let device = Device.iPhone6SPlus
let appearance = Appearance(theme: .LightTransparent, textColor: nil, labelColor: nil)
let screen = Screen(device: device, type: .splash, imageName: "splash", appearance: appearance)
PlaygroundPage.current.liveView = screen.view
//outlineViews([screen.view], outlineColor: .whiteColor())

//: [Next](@next)
