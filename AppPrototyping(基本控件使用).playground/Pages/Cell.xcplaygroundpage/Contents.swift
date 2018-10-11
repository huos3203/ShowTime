//: [Previous](@previous)

import UIKit
import PlaygroundSupport

let device = Device.iPhone4s; let frame = device.frame()
let appearance = Appearance(theme: .Dark, textColor: nil, labelColor: nil)
var cell1 = Cell(device: device, cellType: .Simple, appearance: appearance)
cell1.members

var otherLabel = UILabel(text: "Tim", font: Font.SmallText.create(), textColor: .white, labelColor: .black)

cell1.members["label"] // = otherLabel

cell1.containerView?.view?.frame = CGRect(x:0, y:0, width:frame.width, height:100)
cell1.containerView?.view?.layoutIfNeeded()

PlaygroundPage.current.liveView = cell1.containerView?.view
PlaygroundPage.current.needsIndefiniteExecution = true

outlineViews(views:[cell1.containerView!.view!], outlineColor: .darkGray)

//: [Next](@next)
