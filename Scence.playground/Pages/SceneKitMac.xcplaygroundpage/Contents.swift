import PlaygroundSupport
import QuartzCore
import SceneKit

// Scene
let scene = SCNScene()
let objectsNode = SCNNode()
scene.rootNode.addChildNode(objectsNode)

// Ambient light
let ambientLight = SCNLight()
let ambientLightNode = SCNNode()
ambientLight.type = SCNLight.LightType.ambient
ambientLight.color = UIColor.init(white: 0.1, alpha: 1.0) //NSColor(deviceWhite:0.1, alpha:1.0)
ambientLightNode.light = ambientLight
scene.rootNode.addChildNode(ambientLightNode)

// Diffuse light
let diffuseLight = SCNLight()
let diffuseLightNode = SCNNode()
diffuseLight.type = SCNLight.LightType.omni;
diffuseLightNode.light = diffuseLight;
diffuseLightNode.position = SCNVector3(x:0, y:300, z:0);
scene.rootNode.addChildNode(diffuseLightNode)

// Torus
let torusReflectiveMaterial = SCNMaterial()
torusReflectiveMaterial.diffuse.contents = UIColor.blue
torusReflectiveMaterial.specular.contents = UIColor.white
torusReflectiveMaterial.shininess = 5.0

let torus = SCNTorus(ringRadius:60, pipeRadius:20)
let torusNode = SCNNode(geometry:torus)
torusNode.position = SCNVector3(x:-50, y:0, z:-100)
torus.materials = [torusReflectiveMaterial]
objectsNode.addChildNode(torusNode)

let animation = CAKeyframeAnimation(keyPath:"transform")
let value1 = CATransform3DRotate(torusNode.transform,
                                 CGFloat((0.0 * Double.pi) / 2.0),
                                 CGFloat(1.0),
                                 CGFloat(0.5),
                                 CGFloat(0.0))
let value2 = CATransform3DRotate(torusNode.transform,
                                 CGFloat((1.0 * Double.pi) / 2.0),
                                 CGFloat(1.0),
                                 CGFloat(0.5),
                                 CGFloat(0.0))
let value3 = CATransform3DRotate(torusNode.transform,
                                 CGFloat((2.0 * Double.pi) / 2.0),
                                 CGFloat(1.0),
                                 CGFloat(0.5),
                                 CGFloat(0.0))
let value4 = CATransform3DRotate(torusNode.transform,
                                 CGFloat((3.0 * Double.pi) / 2.0),
                                 CGFloat(1.0),
                                 CGFloat(0.5),
                                 CGFloat(0.0))
let value5 = CATransform3DRotate(torusNode.transform,
                                 CGFloat((4.0 * Double.pi) / 2.0),
                                 CGFloat(1.0),
                                 CGFloat(0.5),
                                 CGFloat(0.0))
animation.values = [
    NSValue(value1),
    NSValue(value2),
    NSValue(value3),
    NSValue(value4),
    NSValue(value5)]

animation.duration = 3.0
animation.repeatCount = 100000
torusNode.addAnimation(animation, forKey:"transform")

// Display
let sceneKitView = SCNView(frame:CGRect(x:0.0, y:0.0, width:400.0, height:400.0), options:nil)
sceneKitView.scene = scene
sceneKitView.backgroundColor = UIColor.gray

//XCPShowView(identifier: "SceneKit view", view: sceneKitView)
PlaygroundPage.current.liveView = sceneKitView



