/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    This class manages most of the game logic.
*/

import simd
import SceneKit
import SpriteKit
import QuartzCore
import AVFoundation
import GameController

import PlaygroundSupport



#if os(iOS) || os(tvOS)
    typealias ViewController = UIViewController
#elseif os(OSX)
    typealias ViewController = NSViewController
#endif
//: character.swift
enum GroundType: Int {
    case grass
    case rock
    case water
    case inTheAir
    case count
}

// Collision bit masks
let BitmaskCollision        = Int(1 << 2)
let BitmaskCollectable      = Int(1 << 3)
let BitmaskEnemy            = Int(1 << 4)
let BitmaskSuperCollectable = Int(1 << 5)
let BitmaskWater            = Int(1 << 6)

private typealias ParticleEmitter = (node: SCNNode, particleSystem: SCNParticleSystem, birthRate: CGFloat)

class Character {
    
    // MARK: Initialization
    
    init() {
        
        // MARK: Load character from external file
        
        // The character is loaded from a .scn file and stored in an intermediate
        // node that will be used as a handle to manipulate the whole group at once
        
        let characterScene = SCNScene(named: "game.scnassets/panda.scn")!
        let characterTopLevelNode = characterScene.rootNode.childNodes[0]
        node.addChildNode(characterTopLevelNode)
        
        
        // MARK: Configure collision capsule
        
        // Collisions are handled by the physics engine. The character is approximated by
        // a capsule that is configured to collide with collectables, enemies and walls
        
        let (min, max) = node.boundingBox
        let collisionCapsuleRadius = CGFloat((max.x - min.x) * 0.4)
        let collisionCapsuleHeight = CGFloat(max.y - min.y)
        
        let characterCollisionNode = SCNNode()
        characterCollisionNode.name = "collider"
        characterCollisionNode.position = SCNVector3(0.0, collisionCapsuleHeight * 0.51, 0.0) // a bit too high so that the capsule does not hit the floor
        characterCollisionNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape:SCNPhysicsShape(geometry: SCNCapsule(capRadius: collisionCapsuleRadius, height: collisionCapsuleHeight), options:nil))
        characterCollisionNode.physicsBody!.contactTestBitMask = BitmaskSuperCollectable | BitmaskCollectable | BitmaskCollision | BitmaskEnemy
        node.addChildNode(characterCollisionNode)
        
        
        // MARK: Load particle systems
        
        // Particle systems were configured in the SceneKit Scene Editor
        // They are retrieved from the scene and their birth rate are stored for later use
        
        func particleEmitterWithName(_ name: String) -> ParticleEmitter {
            let emitter: ParticleEmitter
            emitter.node = characterTopLevelNode.childNode(withName: name, recursively:true)!
            emitter.particleSystem = emitter.node.particleSystems![0]
            emitter.birthRate = emitter.particleSystem.birthRate
            emitter.particleSystem.birthRate = 0
            emitter.node.isHidden = false
            return emitter
        }
        
        fireEmitter = particleEmitterWithName("fire")
        smokeEmitter = particleEmitterWithName("smoke")
        whiteSmokeEmitter = particleEmitterWithName("whiteSmoke")
        
        
        // MARK: Load sound effects
        
        reliefSound = SCNAudioSource(name: "aah_extinction.mp3", volume: 2.0)
        haltFireSound = SCNAudioSource(name: "fire_extinction.mp3", volume: 2.0)
        catchFireSound = SCNAudioSource(name: "ouch_firehit.mp3", volume: 2.0)
        
        for i in 0..<10 {
            if let grassSound = SCNAudioSource(named: "game.scnassets/sounds/Step_grass_0\(i).mp3") {
                grassSound.volume = 0.5
                grassSound.load()
                steps[GroundType.grass.rawValue].append(grassSound)
            }
            
            if let rockSound = SCNAudioSource(named: "game.scnassets/sounds/Step_rock_0\(i).mp3") {
                rockSound.load()
                steps[GroundType.rock.rawValue].append(rockSound)
            }
            
            if let waterSound = SCNAudioSource(named: "game.scnassets/sounds/Step_splash_0\(i).mp3") {
                waterSound.load()
                steps[GroundType.water.rawValue].append(waterSound)
            }
        }
        
        
        // MARK: Configure animations
        
        // Some animations are already there and can be retrieved from the scene
        // The "walk" animation is loaded from a file, it is configured to play foot steps at specific times during the animation
        
        characterTopLevelNode.enumerateChildNodes { (child, _) in
            for key in child.animationKeys {                  // for every animation key
                let animation = child.animation(forKey: key)! // get the animation
                animation.usesSceneTimeBase = false           // make it system time based
                animation.repeatCount = Float.infinity        // make it repeat forever
                child.addAnimation(animation, forKey: key)             // animations are copied upon addition, so we have to replace the previous animation
            }
        }
        
        walkAnimation = CAAnimation.animationWithSceneNamed("game.scnassets/walk.scn")
        walkAnimation.usesSceneTimeBase = false
        walkAnimation.fadeInDuration = 0.3
        walkAnimation.fadeOutDuration = 0.3
        walkAnimation.repeatCount = Float.infinity
        walkAnimation.speed = Character.speedFactor
        walkAnimation.animationEvents = [
            SCNAnimationEvent(keyTime: 0.1) { (_, _, _) in self.playFootStep() },
            SCNAnimationEvent(keyTime: 0.6) { (_, _, _) in self.playFootStep() }]
    }
    
    // MARK: Retrieving nodes
    
    let node = SCNNode()
    
    // MARK: Controlling the character
    
    static let speedFactor = Float(1.538)
    
    private var groundType = GroundType.inTheAir
    private var previousUpdateTime = TimeInterval(0.0)
    private var accelerationY = SCNFloat(0.0) // Simulate gravity
    
    private var directionAngle: SCNFloat = 0.0 {
        didSet {
            if directionAngle != oldValue {
                node.runAction(SCNAction.rotateTo(x: 0.0, y: CGFloat(directionAngle), z: 0.0, duration: 0.1, usesShortestUnitArc: true))
            }
        }
    }
    
    func walkInDirection(_ direction: float3, time: TimeInterval, scene: SCNScene, groundTypeFromMaterial: (SCNMaterial) -> GroundType) -> SCNNode? {
        // delta time since last update
        if previousUpdateTime == 0.0 {
            previousUpdateTime = time
        }
        
        let deltaTime = Float(min(time - previousUpdateTime, 1.0 / 60.0))
        let characterSpeed = deltaTime * Character.speedFactor * 0.84
        previousUpdateTime = time
        
        let initialPosition = node.position
        
        // move
        if direction.x != 0.0 && direction.z != 0.0 {
            // move character
            let position = float3(node.position)
            node.position = SCNVector3(position + direction * characterSpeed)
            
            // update orientation
            directionAngle = SCNFloat(atan2(direction.x, direction.z))
            
            isWalking = true
        }
        else {
            isWalking = false
        }
        
        // Update the altitude of the character
        
        var position = node.position
        var p0 = position
        var p1 = position
        
        let maxRise = SCNFloat(0.08)
        let maxJump = SCNFloat(10.0)
        p0.y -= maxJump
        p1.y += maxRise
        
        // Do a vertical ray intersection
        var groundNode: SCNNode?
        let results = scene.physicsWorld.rayTestWithSegment(from: p1, to: p0, options:[.collisionBitMask: BitmaskCollision | BitmaskWater, .searchMode: SCNPhysicsWorld.TestSearchMode.closest])
        
        if let result = results.first {
            var groundAltitude = result.worldCoordinates.y
            groundNode = result.node
            
            let groundMaterial = result.node.childNodes[0].geometry!.firstMaterial!
            groundType = groundTypeFromMaterial(groundMaterial)
            
            if groundType == .water {
                if isBurning {
                    haltFire()
                }
                
                // do a new ray test without the water to get the altitude of the ground (under the water).
                let results = scene.physicsWorld.rayTestWithSegment(from: p1, to: p0, options:[.collisionBitMask: BitmaskCollision, .searchMode: SCNPhysicsWorld.TestSearchMode.closest])
                
                let result = results[0]
                groundAltitude = result.worldCoordinates.y
            }
            
            let threshold = SCNFloat(1e-5)
            let gravityAcceleration = SCNFloat(0.18)
            
            if groundAltitude < position.y - threshold {
                accelerationY += SCNFloat(deltaTime) * gravityAcceleration // approximation of acceleration for a delta time.
                if groundAltitude < position.y - 0.2 {
                    groundType = .inTheAir
                }
            }
            else {
                accelerationY = 0
            }
            
            position.y -= accelerationY
            
            // reset acceleration if we touch the ground
            if groundAltitude > position.y {
                accelerationY = 0
                position.y = groundAltitude
            }
            
            // Finally, update the position of the character.
            node.position = position
            
        }
        else {
            // no result, we are probably out the bounds of the level -> revert the position of the character.
            node.position = initialPosition
        }
        
        return groundNode
    }
    
    // MARK: Animating the character
    
    private var walkAnimation: CAAnimation!
    
    private var isWalking: Bool = false {
        didSet {
            if oldValue != isWalking {
                // Update node animation.
                if isWalking {
                    node.addAnimation(walkAnimation, forKey: "walk")
                } else {
                    node.removeAnimation(forKey: "walk", fadeOutDuration: 0.2)
                }
            }
        }
    }
    
    private var walkSpeed: Float = 1.0 {
        didSet {
            // remove current walk animation if any.
            let wasWalking = isWalking
            if wasWalking {
                isWalking = false
            }
            
            walkAnimation.speed = Character.speedFactor * walkSpeed
            
            // restore walk animation if needed.
            isWalking = wasWalking
        }
    }
    
    // MARK: Dealing with fire
    
    private var isBurning = false
    private var isInvincible = false
    
    private var fireEmitter: ParticleEmitter! = nil
    private var smokeEmitter: ParticleEmitter! = nil
    private var whiteSmokeEmitter: ParticleEmitter! = nil
    
    func catchFire() {
        if isInvincible == false {
            isInvincible = true
            node.runAction(SCNAction.sequence([
                SCNAction.playAudio(catchFireSound, waitForCompletion: false),
                SCNAction.repeat(SCNAction.sequence([
                    SCNAction.fadeOpacity(to: 0.01, duration: 0.1),
                    SCNAction.fadeOpacity(to: 1.0, duration: 0.1)
                    ]), count: 7),
                SCNAction.run { _ in self.isInvincible = false } ]))
        }
        
        isBurning = true
        
        // start fire + smoke
        fireEmitter.particleSystem.birthRate = fireEmitter.birthRate
        smokeEmitter.particleSystem.birthRate = smokeEmitter.birthRate
        
        // walk faster
        walkSpeed = 2.3
    }
    
    func haltFire() {
        if isBurning {
            isBurning = false
            
            node.runAction(SCNAction.sequence([
                SCNAction.playAudio(haltFireSound, waitForCompletion: true),
                SCNAction.playAudio(reliefSound, waitForCompletion: false)])
            )
            
            // stop fire and smoke
            fireEmitter.particleSystem.birthRate = 0
            SCNTransaction.animateWithDuration(1.0) {
                self.smokeEmitter.particleSystem.birthRate = 0
            }
            
            // start white smoke
            whiteSmokeEmitter.particleSystem.birthRate = whiteSmokeEmitter.birthRate
            
            // progressively stop white smoke
            SCNTransaction.animateWithDuration(5.0) {
                self.whiteSmokeEmitter.particleSystem.birthRate = 0
            }
            
            // walk normally
            walkSpeed = 1.0
        }
    }
    
    // MARK: Dealing with sound
    
    private var reliefSound: SCNAudioSource
    private var haltFireSound: SCNAudioSource
    private var catchFireSound: SCNAudioSource
    
    private var steps = [[SCNAudioSource]](repeating: [], count: GroundType.count.rawValue)
    
    private func playFootStep() {
        if groundType != .inTheAir { // We are in the air, no sound to play.
            // Play a random step sound.
            let soundsCount = steps[groundType.rawValue].count
            let stepSoundIndex = Int(arc4random_uniform(UInt32(soundsCount)))
            node.runAction(SCNAction.playAudio(steps[groundType.rawValue][stepSoundIndex], waitForCompletion: false))
        }
    }
}


//: GameControls.swift
#if os(OSX)
    
    protocol KeyboardAndMouseEventsDelegate {
        func mouseDown(in view: NSView, with event: NSEvent) -> Bool
        func mouseDragged(in view: NSView, with event: NSEvent) -> Bool
        func mouseUp(in view: NSView, with event: NSEvent) -> Bool
        func keyDown(in view: NSView, with event: NSEvent) -> Bool
        func keyUp(in view: NSView, with event: NSEvent) -> Bool
    }
    
    private enum KeyboardDirection : UInt16 {
        case left   = 123
        case right  = 124
        case down   = 125
        case up     = 126
        
        var vector : float2 {
            switch self {
            case .up:    return float2( 0, -1)
            case .down:  return float2( 0,  1)
            case .left:  return float2(-1,  0)
            case .right: return float2( 1,  0)
            }
        }
    }
    
    extension GameViewController: KeyboardAndMouseEventsDelegate {
    }
    
#endif

extension GameViewController {
    
    // MARK: Controller orientation
    
    private static let controllerAcceleration = Float(1.0 / 10.0)
    private static let controllerDirectionLimit = float2(1.0)
    
    internal func controllerDirection() -> float2 {
        // Poll when using a game controller
        if let dpad = controllerDPad {
            if dpad.xAxis.value == 0.0 && dpad.yAxis.value == 0.0 {
                controllerStoredDirection = float2(0.0)
            } else {
                controllerStoredDirection = clamp(controllerStoredDirection + float2(dpad.xAxis.value, -dpad.yAxis.value) * GameViewController.controllerAcceleration, min: -GameViewController.controllerDirectionLimit, max: GameViewController.controllerDirectionLimit)
            }
        }
        
        return controllerStoredDirection
    }
    
    // MARK: Game Controller Events
    
    open func setupGameControllers() {
        #if os(OSX)
            gameView.eventsDelegate = self
        #endif
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameViewController.handleControllerDidConnectNotification(_:)), name: .GCControllerDidConnect, object: nil)
    }
    
    @objc func handleControllerDidConnectNotification(_ notification: NSNotification) {
        let gameController = notification.object as! GCController
        registerCharacterMovementEvents(gameController)
    }
    
    private func registerCharacterMovementEvents(_ gameController: GCController) {
        
        // An analog movement handler for D-pads and thumbsticks.
        let movementHandler: GCControllerDirectionPadValueChangedHandler = { [unowned self] dpad, _, _ in
            self.controllerDPad = dpad
        }
        
        #if os(tvOS)
            
            // Apple TV remote
            if let microGamepad = gameController.microGamepad {
                // Allow the gamepad to handle transposing D-pad values when rotating the controller.
                microGamepad.allowsRotation = true
                microGamepad.dpad.valueChangedHandler = movementHandler
            }
            
        #endif
        
        // Gamepad D-pad
        if let gamepad = gameController.gamepad {
            gamepad.dpad.valueChangedHandler = movementHandler
        }
        
        // Extended gamepad left thumbstick
        if let extendedGamepad = gameController.extendedGamepad {
            extendedGamepad.leftThumbstick.valueChangedHandler = movementHandler
        }
    }
    
    // MARK: Touch Events
    
    #if os(iOS)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if gameView.virtualDPadBounds().contains(touch.location(in: gameView)) {
                // We're in the dpad
                if padTouch == nil {
                    padTouch = touch
                    controllerStoredDirection = float2(0.0)
                }
            } else if panningTouch == nil {
                // Start panning
                panningTouch = touches.first
            }
            
            if padTouch != nil && panningTouch != nil {
                break // We already have what we need
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = panningTouch {
            let displacement = (float2(touch.location(in: view)?) - float2(touch.previousLocation(in: view)))
            panCamera(displacement)
        }
        
        if let touch = padTouch {
            let displacement = (float2(touch.location(in: view)) - float2(touch.previousLocation(in: view)))
            controllerStoredDirection = clamp(mix(controllerStoredDirection, displacement, t: GameViewController.controllerAcceleration), min: -GameViewController.controllerDirectionLimit, max: GameViewController.controllerDirectionLimit)
        }
    }
    
    func commonTouchesEnded(_ touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = panningTouch {
            if touches.contains(touch) {
                panningTouch = nil
            }
        }
        
        if let touch = padTouch {
            if touches.contains(touch) || event?.touches(for: view)?.contains(touch) == false {
                padTouch = nil
                controllerStoredDirection = float2(0.0)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTouchesEnded(touches, withEvent: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        commonTouchesEnded(touches, withEvent: event)
    }
    
    #endif
    
    // MARK: Mouse and Keyboard Events
    
    #if os(OSX)
    
    func mouseDown(in view: NSView, with event: NSEvent) -> Bool {
    // Remember last mouse position for dragging.
    lastMousePosition = float2(view.convert(event.locationInWindow, from: nil))
    
    return true
    }
    
    func mouseDragged(in view: NSView, with event: NSEvent) -> Bool {
    let mousePosition = float2(view.convert(event.locationInWindow, from: nil))
    panCamera(mousePosition - lastMousePosition)
    lastMousePosition = mousePosition
    
    return true
    }
    
    func mouseUp(in view: NSView, with event: NSEvent) -> Bool {
    return true
    }
    
    func keyDown(in view: NSView, with event: NSEvent) -> Bool {
    if let direction = KeyboardDirection(rawValue: event.keyCode) {
    if !event.isARepeat {
    controllerStoredDirection += direction.vector
    }
    return true
    }
    
    return false
    }
    
    func keyUp(in view: NSView, with event: NSEvent) -> Bool {
    if let direction = KeyboardDirection(rawValue: event.keyCode) {
    if !event.isARepeat {
    controllerStoredDirection -= direction.vector
    }
    return true
    }
    
    return false
    }
    
    #endif
}

//: dddd
class GameViewController: ViewController, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    
    // Game view
    var gameView: GameView {
        return view as! GameView
    }
    
    // Nodes to manipulate the camera
    private let cameraYHandle = SCNNode()
    private let cameraXHandle = SCNNode()
    
    // The character
    private let character = Character()
    
    // Game states
    private var gameIsComplete = false
    private var lockCamera = false
    
    private var grassArea: SCNMaterial!
    private var waterArea: SCNMaterial!
    private var flames = [SCNNode]()
    private var enemies = [SCNNode]()
    
    // Sounds
    private var collectPearlSound: SCNAudioSource!
    private var collectFlowerSound: SCNAudioSource!
    private var flameThrowerSound: SCNAudioPlayer!
    private var victoryMusic: SCNAudioSource!
    
    // Particles
    private var confettiParticleSystem: SCNParticleSystem!
    private var collectFlowerParticleSystem: SCNParticleSystem!
    
    // For automatic camera animation
    private var currentGround: SCNNode!
    private var mainGround: SCNNode!
    private var groundToCameraPosition = [SCNNode: SCNVector3]()
    
    // Game controls
    internal var controllerDPad: GCControllerDirectionPad?
    internal var controllerStoredDirection = float2(0.0) // left/right up/down
    
    #if os(OSX)
    internal var lastMousePosition = float2(0)
    #elseif os(iOS)
    internal var padTouch: UITouch?
    internal var panningTouch: UITouch?
    #endif
    
    // MARK: Initialization
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a new scene.
        let scene = SCNScene(named: "game.scnassets/level.scn")!
        
        // Set the scene to the view and loop for the animation of the bamboos.
        self.gameView.scene = scene
        self.gameView.isPlaying = true
        self.gameView.loops = true
        
        // Various setup
        setupCamera()
        setupSounds()
        
        // Configure particle systems
        collectFlowerParticleSystem = SCNParticleSystem(named: "collect.scnp", inDirectory: nil)
        collectFlowerParticleSystem.loops = false
        confettiParticleSystem = SCNParticleSystem(named: "confetti.scnp", inDirectory: nil)
        
        // Add the character to the scene.
        scene.rootNode.addChildNode(character.node)
        
        let startPosition = scene.rootNode.childNode(withName: "startingPoint", recursively: true)!
        character.node.transform = startPosition.transform
        
        // Retrieve various game elements in one traversal
        var collisionNodes = [SCNNode]()
        scene.rootNode.enumerateChildNodes { (node, _) in
            switch node.name {
            case .some("flame"):
                node.physicsBody!.categoryBitMask = BitmaskEnemy
                self.flames.append(node)
                
            case .some("enemy"):
                self.enemies.append(node)
                
            case let .some(s) where s.range(of: "collision") != nil:
                collisionNodes.append(node)
                
            default:
                break
            }
        }
        
        for node in collisionNodes {
            node.isHidden = false
            setupCollisionNode(node)
        }
        
        // Setup delegates
        scene.physicsWorld.contactDelegate = self
        gameView.delegate = self
        
        setupAutomaticCameraPositions()
        setupGameControllers()
    }
    
    // MARK: Managing the Camera
    
    func panCamera(_ direction: float2) {
        if lockCamera {
            return
        }
        
        var directionToPan = direction
        
        #if os(iOS) || os(tvOS)
            directionToPan *= float2(1.0, -1.0)
        #endif
        
        let F = SCNFloat(0.005)
        
        // Make sure the camera handles are correctly reset (because automatic camera animations may have put the "rotation" in a weird state.
        SCNTransaction.animateWithDuration(0.0) {
            self.cameraYHandle.removeAllActions()
            self.cameraXHandle.removeAllActions()
            
            if self.cameraYHandle.rotation.y < 0 {
                self.cameraYHandle.rotation = SCNVector4(0, 1, 0, -self.cameraYHandle.rotation.w)
            }
            
            if self.cameraXHandle.rotation.x < 0 {
                self.cameraXHandle.rotation = SCNVector4(1, 0, 0, -self.cameraXHandle.rotation.w)
            }
        }
        
        // Update the camera position with some inertia.
        SCNTransaction.animateWithDuration(0.5, timingFunction: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)) {
            self.cameraYHandle.rotation = SCNVector4(0, 1, 0, self.cameraYHandle.rotation.y * (self.cameraYHandle.rotation.w - SCNFloat(directionToPan.x) * F))
            self.cameraXHandle.rotation = SCNVector4(1, 0, 0, (max(SCNFloat(-Double.pi / 2), min(0.13, self.cameraXHandle.rotation.w + SCNFloat(directionToPan.y) * F))))
        }
    }
    
    func updateCameraWithCurrentGround(_ node: SCNNode) {
        if gameIsComplete {
            return
        }
        
        if currentGround == nil {
            currentGround = node
            return
        }
        
        // Automatically update the position of the camera when we move to another block.
        if node != currentGround {
            currentGround = node
            
            if var position = groundToCameraPosition[node] {
                if node == mainGround && character.node.position.x < 2.5 {
                    position = SCNVector3(-0.098175, 3.926991, 0.0)
                }
                
                let actionY = SCNAction.rotateTo(x: 0, y: CGFloat(position.y), z: 0, duration: 3.0, usesShortestUnitArc: true)
                actionY.timingMode = .easeInEaseOut
                
                let actionX = SCNAction.rotateTo(x: CGFloat(position.x), y: 0, z: 0, duration: 3.0, usesShortestUnitArc: true)
                actionX.timingMode = .easeInEaseOut
                
                cameraYHandle.runAction(actionY)
                cameraXHandle.runAction(actionX)
            }
        }
    }
    
    // MARK: Moving the Character
    
    private func characterDirection() -> float3 {
        let controllerDirection = self.controllerDirection()
        var direction = float3(controllerDirection.x, 0.0, controllerDirection.y)
        
        if let pov = gameView.pointOfView {
            let p1 = pov.presentation.convertPosition(SCNVector3(direction), to: nil)
            let p0 = pov.presentation.convertPosition(SCNVector3Zero, to: nil)
            direction = float3(Float(p1.x - p0.x), 0.0, Float(p1.z - p0.z))
            
            if direction.x != 0.0 || direction.z != 0.0 {
                direction = normalize(direction)
            }
        }
        
        return direction
    }
    
    // MARK: SCNSceneRendererDelegate Conformance (Game Loop)
    
    // SceneKit calls this method exactly once per frame, so long as the SCNView object (or other SCNSceneRenderer object) displaying the scene is not paused.
    // Implement this method to add game logic to the rendering loop. Any changes you make to the scene graph during this method are immediately reflected in the displayed scene.
    
    func groundTypeFromMaterial(_ material: SCNMaterial) -> GroundType {
        if material == grassArea {
            return .grass
        }
        if material == waterArea {
            return .water
        }
        else {
            return .rock
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Reset some states every frame
        replacementPosition = nil
        maxPenetrationDistance = 0
        
        let scene = gameView.scene!
        let direction = characterDirection()
        
        let groundNode = character.walkInDirection(direction, time: time, scene: scene, groundTypeFromMaterial:groundTypeFromMaterial)
        if let groundNode = groundNode {
            updateCameraWithCurrentGround(groundNode)
        }
        
        // Flames are static physics bodies, but they are moved by an action - So we need to tell the physics engine that the transforms did change.
        for flame in flames {
            flame.physicsBody!.resetTransform()
        }
        
        // Adjust the volume of the enemy based on the distance to the character.
        var distanceToClosestEnemy = Float.infinity
        let characterPosition = float3(character.node.position)
        for enemy in enemies {
            //distance to enemy
            let enemyTransform = float4x4(enemy.worldTransform)
            let enemyPosition = float3(enemyTransform[3].x, enemyTransform[3].y, enemyTransform[3].z)
            let distance = simd.distance(characterPosition, enemyPosition)
            distanceToClosestEnemy = min(distanceToClosestEnemy, distance)
        }
        
        // Adjust sounds volumes based on distance with the enemy.
        if !gameIsComplete {
            if let mixer = flameThrowerSound!.audioNode as? AVAudioMixerNode {
                mixer.volume = 0.3 * max(0, min(1, 1 - ((distanceToClosestEnemy - 1.2) / 1.6)))
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didSimulatePhysicsAtTime time: TimeInterval) {
        // If we hit a wall, position needs to be adjusted
        if let position = replacementPosition {
            character.node.position = position
        }
    }
    
    // MARK: SCNPhysicsContactDelegate Conformance
    
    // To receive contact messages, you set the contactDelegate property of an SCNPhysicsWorld object.
    // SceneKit calls your delegate methods when a contact begins, when information about the contact changes, and when the contact ends.
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        contact.match(BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
        contact.match(BitmaskCollectable) { (matching, _) in
            self.collectPearl(matching)
        }
        contact.match(BitmaskSuperCollectable) { (matching, _) in
            self.collectFlower(matching)
        }
        contact.match(BitmaskEnemy) { (_, _) in
            self.character.catchFire()
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        contact.match(BitmaskCollision) { (matching, other) in
            self.characterNode(other, hitWall: matching, withContact: contact)
        }
    }
    
    private var maxPenetrationDistance = CGFloat(0.0)
    private var replacementPosition: SCNVector3?
    
    private func characterNode(_ characterNode: SCNNode, hitWall wall: SCNNode, withContact contact: SCNPhysicsContact) {
        if characterNode.parent != character.node {
            return
        }
        
        if maxPenetrationDistance > contact.penetrationDistance {
            return
        }
        
        maxPenetrationDistance = contact.penetrationDistance
        
        var characterPosition = float3(character.node.position)
        var positionOffset = float3(contact.contactNormal) * Float(contact.penetrationDistance)
        positionOffset.y = 0
        characterPosition += positionOffset
        
        replacementPosition = SCNVector3(characterPosition)
    }
    
    // MARK: Scene Setup
    
    private func setupCamera() {
        let ALTITUDE = 1.0
        let DISTANCE = 10.0
        
        // We create 2 nodes to manipulate the camera:
        // The first node "cameraXHandle" is at the center of the world (0, ALTITUDE, 0) and will only rotate on the X axis
        // The second node "cameraYHandle" is a child of the first one and will ony rotate on the Y axis
        // The camera node is a child of the "cameraYHandle" at a specific distance (DISTANCE).
        // So rotating cameraYHandle and cameraXHandle will update the camera position and the camera will always look at the center of the scene.
        
        let pov = self.gameView.pointOfView!
        pov.eulerAngles = SCNVector3Zero
        pov.position = SCNVector3(0.0, 0.0, DISTANCE)
        
        cameraXHandle.rotation = SCNVector4(1.0, 0.0, 0.0, -Double.pi / 4 * 0.125)
        cameraXHandle.addChildNode(pov)
        
        cameraYHandle.position = SCNVector3(0.0, ALTITUDE, 0.0)
        cameraYHandle.rotation = SCNVector4(0.0, 1.0, 0.0, Double.pi / 2 + Double.pi / 4 * 3.0)
        cameraYHandle.addChildNode(cameraXHandle)
        
        gameView.scene?.rootNode.addChildNode(cameraYHandle)
        
        // Animate camera on launch and prevent the user from manipulating the camera until the end of the animation.
        SCNTransaction.animateWithDuration(completionBlock: { self.lockCamera = false }) {
            self.lockCamera = true
            
            // Create 2 additive animations that converge to 0
            // That way at the end of the animation, the camera will be at its default position.
            let cameraYAnimation = CABasicAnimation(keyPath: "rotation.w")
            cameraYAnimation.fromValue = SCNFloat(Double.pi) * 2.0 - self.cameraYHandle.rotation.w as NSNumber
            cameraYAnimation.toValue = 0.0
            cameraYAnimation.isAdditive = true
            cameraYAnimation.beginTime = CACurrentMediaTime() + 3.0 // wait a little bit before stating
            cameraYAnimation.fillMode = kCAFillModeBoth
            cameraYAnimation.duration = 5.0
            cameraYAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            self.cameraYHandle.addAnimation(cameraYAnimation, forKey: nil)
            
            let cameraXAnimation = cameraYAnimation.copy() as! CABasicAnimation
            cameraXAnimation.fromValue = -SCNFloat(Double.pi / 2) + self.cameraXHandle.rotation.w as NSNumber
            self.cameraXHandle.addAnimation(cameraXAnimation, forKey: nil)
        }
    }
    
    private func setupAutomaticCameraPositions() {
        let rootNode = gameView.scene!.rootNode
        
        mainGround = rootNode.childNode(withName: "bloc05_collisionMesh_02", recursively: true)
        
        groundToCameraPosition[rootNode.childNode(withName: "bloc04_collisionMesh_02", recursively: true)!] = SCNVector3(-0.188683, 4.719608, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc03_collisionMesh", recursively: true)!] = SCNVector3(-0.435909, 6.297167, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc07_collisionMesh", recursively: true)!] = SCNVector3( -0.333663, 7.868592, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc08_collisionMesh", recursively: true)!] = SCNVector3(-0.575011, 8.739003, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc06_collisionMesh", recursively: true)!] = SCNVector3( -1.095519, 9.425292, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc05_collisionMesh_02", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
        groundToCameraPosition[rootNode.childNode(withName: "bloc05_collisionMesh_01", recursively: true)!] = SCNVector3(-0.072051, 8.202264, 0.0)
    }
    
    private func setupCollisionNode(_ node: SCNNode) {
        if let geometry = node.geometry {
            // Collision meshes must use a concave shape for intersection correctness.
            node.physicsBody = SCNPhysicsBody.static()
            node.physicsBody!.categoryBitMask = BitmaskCollision
            node.physicsBody!.physicsShape = SCNPhysicsShape(node: node, options: [.type: SCNPhysicsShape.ShapeType.concavePolyhedron as NSString])
            
            // Get grass area to play the right sound steps
            if geometry.firstMaterial!.name == "grass-area" {
                if grassArea != nil {
                    geometry.firstMaterial = grassArea
                } else {
                    grassArea = geometry.firstMaterial
                }
            }
            
            // Get the water area
            if geometry.firstMaterial!.name == "water" {
                waterArea = geometry.firstMaterial
            }
            
            // Temporary workaround because concave shape created from geometry instead of node fails
            let childNode = SCNNode()
            node.addChildNode(childNode)
            childNode.isHidden = true
            childNode.geometry = node.geometry
            node.geometry = nil
            node.isHidden = false
            
            if node.name == "water" {
                node.physicsBody!.categoryBitMask = BitmaskWater
            }
        }
        
        for childNode in node.childNodes {
            if childNode.isHidden == false {
                setupCollisionNode(childNode)
            }
        }
    }
    
    private func setupSounds() {
        // Get an arbitrary node to attach the sounds to.
        let node = self.gameView.scene!.rootNode
        
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: "music.m4a", volume: 0.25, positional: false, loops: true, shouldStream: true)))
        node.addAudioPlayer(SCNAudioPlayer(source: SCNAudioSource(name: "wind.m4a", volume: 0.3, positional: false, loops: true, shouldStream: true)))
        flameThrowerSound = SCNAudioPlayer(source: SCNAudioSource(name: "flamethrower.mp3", volume: 0, positional: false, loops: true))
        node.addAudioPlayer(flameThrowerSound)
        
        collectPearlSound = SCNAudioSource(name: "collect1.mp3", volume: 0.5)
        collectFlowerSound = SCNAudioSource(name: "collect2.mp3")
        victoryMusic = SCNAudioSource(name: "Music_victory.mp3", volume: 0.5, shouldLoad: false)
    }
    
    // MARK: Collecting Items
    
    private func removeNode(_ node: SCNNode, soundToPlay sound: SCNAudioSource) {
        if let parentNode = node.parent {
            let soundEmitter = SCNNode()
            soundEmitter.position = node.position
            parentNode.addChildNode(soundEmitter)
            
            soundEmitter.runAction(SCNAction.sequence([
                SCNAction.playAudio(sound, waitForCompletion: true),
                SCNAction.removeFromParentNode()]))
            
            node.removeFromParentNode()
        }
    }
    
    private var collectedPearlsCount = 0 {
        didSet {
            gameView.collectedPearlsCount = collectedPearlsCount
        }
    }
    
    private func collectPearl(_ pearlNode: SCNNode) {
        if pearlNode.parent != nil {
            removeNode(pearlNode, soundToPlay:collectPearlSound)
            collectedPearlsCount += 1
        }
    }
    
    private var collectedFlowersCount = 0 {
        didSet {
            gameView.collectedFlowersCount = collectedFlowersCount
            if (collectedFlowersCount == 3) {
                showEndScreen()
            }
        }
    }
    
    private func collectFlower(_ flowerNode: SCNNode) {
        if flowerNode.parent != nil {
            // Emit particles.
            var particleSystemPosition = flowerNode.worldTransform
            particleSystemPosition.m42 += 0.1
            #if os(iOS) || os(tvOS)
                gameView.scene!.addParticleSystem(collectFlowerParticleSystem, transform: particleSystemPosition)
            #elseif os(OSX)
                gameView.scene!.addParticleSystem(collectFlowerParticleSystem, transform: particleSystemPosition)
            #endif
            
            // Remove the flower from the scene.
            removeNode(flowerNode, soundToPlay:collectFlowerSound)
            collectedFlowersCount += 1
        }
    }
    
    // MARK: Congratulating the Player
    
    private func showEndScreen() {
        gameIsComplete = true
        
        // Add confettis
        let particleSystemPosition = SCNMatrix4MakeTranslation(0.0, 8.0, 0.0)
        #if os(iOS) || os(tvOS)
            gameView.scene!.addParticleSystem(confettiParticleSystem, transform: particleSystemPosition)
        #elseif os(OSX)
            gameView.scene!.addParticleSystem(confettiParticleSystem, transform: particleSystemPosition)
        #endif
        
        // Stop the music.
        gameView.scene!.rootNode.removeAllAudioPlayers()
        
        // Play the congrat sound.
        gameView.scene!.rootNode.addAudioPlayer(SCNAudioPlayer(source: victoryMusic))
        
        // Animate the camera forever
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.cameraYHandle.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y:-1, z: 0, duration: 3))!)
            self.cameraXHandle.runAction(SCNAction.rotateTo(x: CGFloat(-Double.pi / 4), y: 0, z: 0, duration: 5.0))
        }
        
        gameView.showEndScreen();
    }
    
}
PlaygroundPage.current.liveView = (GameViewController.init(coder:) as! PlaygroundLiveViewable)
