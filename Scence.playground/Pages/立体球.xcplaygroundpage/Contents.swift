//: Playground - noun: a place where people can play

import SceneKit
import PlaygroundSupport
#if os(iOS)
print("iOS系统")
#elseif os(OSX)
    print("OSX系统")
#endif
let materialPrefixes : [String] = ["gold-scuffed"]

let view = SCNView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))
view.allowsCameraControl = true
view.autoenablesDefaultLighting = true
let scene = SCNScene()
view.scene = scene

PlaygroundPage.current.liveView = view

let hello = SCNSphere(radius: 2)

let helloNode = SCNNode(geometry: hello)
let material = helloNode.geometry?.firstMaterial

// Declare that you intend to work in PBR shading mode
// Note that this requires iOS 10 and up
material?.lightingModel = SCNMaterial.LightingModel.physicallyBased

// Setup the material maps for your object
let materialFilePrefix = materialPrefixes[0]
//material?.diffuse.contents = UIImage(named: "\(materialFilePrefix)-albedo.png")!

material?.roughness.contents = UIImage(named: "\(materialFilePrefix)-roughness.png")
material?.metalness.contents = UIImage(named: "\(materialFilePrefix)-metal.png")
material?.normal.contents = UIImage(named: "\(materialFilePrefix)-normal.png")


scene.lightingEnvironment.contents = UIImage(named: "interior_hdri_29_20150416_1169368110.jpg")
scene.lightingEnvironment.intensity = 2.0
scene.background.contents = UIImage(named: "interior_hdri_29_20150416_1169368110.jpg")

scene.rootNode.addChildNode(helloNode)
