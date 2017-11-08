//
//  MainController.swift
//  CubesInSpace
//
//  Created by Ryan Pasecky on 6/29/17.
//  Copyright © 2017 Ryan Pasecky. All rights reserved.
//

//
//  ViewController.swift
//  ARBrush
//

import UIKit
import SceneKit
import ARKit
//import simd

class MainViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
  
  
  @IBOutlet var sceneView: ARSCNView!
  
  
  // MARK: - Properties
  var buttonDown = false
  var modeToggleButton : UIButton!
  var lastSpawn = CFAbsoluteTimeGetCurrent()
  var gravityField = SCNPhysicsField.linearGravity()
  var gravityActivated = false
  var phoneNode: SCNNode!
  var drawNode: SCNNode!
  var previousSize: CGFloat?
  var ground: SCNNode!
  var planeArray = [SCNNode]()
  var cubes = [SCNNode]()
  var currentMode: PlayMode = .drawing
  var screenSize = UIScreen.main.bounds.size
  
  enum PlayMode {
    case drawing, cubes
    
    
  }
  
  // MARK: - View life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSceneView()
    setupModeToggleButton()
    setupGestureRecognizers()
    setupGroundNode()
    setupLightNode()
    setupPhoneNode()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    
    // Create a session configuration
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    
    
    // Run the view's session
    sceneView.session.run(configuration)
    
    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    // Pause the view's session
    sceneView.session.pause()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Release any cached data, images, etc that aren't in use.
  }
  
  
  //MARK: - Initialization
  private func setupSceneView() {
    // Set the view's delegate
    sceneView.delegate = self
    
    // Show statistics such as fps and timing information
    // This can conflict with rendering
    sceneView.showsStatistics = true
    
    // Create a new scene
    let scene = SCNScene(named: "art.scnassets/world.scn")!
    
    // Set the scene to the view
    sceneView.scene = scene
    //sceneView.automaticallyUpdatesLighting = true
    setupGravityField()
  }
  
  private func setupGravityField() {
    gravityField.direction = SCNVector3(0,0,0);
    gravityField.strength = 0.0
  }

  
  private func setupGroundNode() {
    let groundGeometry = SCNFloor()
    groundGeometry.reflectivity = 0
    let groundMaterial = SCNMaterial()
    groundMaterial.diffuse.contents = UIColor.clear
    groundGeometry.materials = [groundMaterial]
    ground = SCNNode(geometry: groundGeometry)
    ground.position = sceneView.scene.rootNode.position - SCNVector3(0,1.5,0)
    
    let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
    let groundBody = SCNPhysicsBody(type: .kinematic, shape: groundShape)
    groundBody.restitution = 0
    groundBody.isAffectedByGravity = false
    ground.physicsBody = groundBody
    sceneView.scene.rootNode.addChildNode(ground)
  }
  
  private func setupLightNode() {
    
    let frontLight = SCNLight()
    frontLight.type = .omni
    frontLight.intensity = 800
    frontLight.castsShadow = true
    
    
    let lightNode = SCNNode()
    let lightGeometry = SCNSphere(radius: 0.1)
    lightGeometry.firstMaterial?.diffuse.contents = UIColor.clear
    lightNode.light = frontLight
    
    var lightPosition = getPositionRelativeToCameraView(distance:  2).position
    lightPosition = SCNVector3(x: lightPosition.x,
                               y: lightPosition.y + 1,
                               z: lightPosition.z)
    
    
    lightNode.position = lightPosition//getPositionRelativeToCameraView(distance:  340).position
    lightNode.geometry = lightGeometry
    lightNode.opacity = 0
    
    let backLight = SCNLight()
    backLight.type = .omni
    backLight.intensity = 800
    backLight.castsShadow = true
    
    
    let lightNode2 = SCNNode()
    let lightGeometry2 = SCNSphere(radius: 0.1)
    lightGeometry2.firstMaterial?.diffuse.contents = UIColor.clear
    lightNode2.light = backLight
    
    var lightPosition2 = getPositionRelativeToCameraView(distance:  -1).position
    lightPosition2 = SCNVector3(x: lightPosition2.x,
                               y: lightPosition2.y + 1,
                               z: lightPosition2.z)
    
    
    lightNode2.position = lightPosition2//getPositionRelativeToCameraView(distance:  340).position
    lightNode2.geometry = lightGeometry2
    lightNode2.opacity = 0
    
    self.sceneView.scene.rootNode.addChildNode(lightNode)
    self.sceneView.scene.rootNode.addChildNode(lightNode2)

  }
  private func setupGestureRecognizers() {
    //self.view.addGestureRecognizer(UIGestureRecognizer.)
    let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
    tap.minimumPressDuration = 0
    tap.cancelsTouchesInView = false
    tap.delegate = self
    self.sceneView.addGestureRecognizer(tap)
  }
  
  func setupModeToggleButton() {
    
    // red
    let c1 = UIColor(red: 246.0/255.0, green: 205.0/255.0, blue: 73.0/255.0, alpha: 1.0)
    let c2 = UIColor(red: 230.0/255.0, green: 98.0/255.0, blue: 87.0/255.0, alpha: 1.0)
    
    // greenish
    //let c1 = UIColor(red: 112.0/255.0, green: 219.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    //let c2 = UIColor(red: 86.0/255.0, green: 197.0/255.0, blue: 238.0/255.0, alpha: 1.0)
    
    modeToggleButton = getRoundyButton(size: 60, imageName: "stop", c1, c2)
    //addPointButton.setTitle("+", for: UIControlState.normal)
    
    self.view.addSubview(modeToggleButton)
    
    let buttonXPosition = CGFloat(40.0)
    let buttonYPosition = self.screenSize.height - 40
    modeToggleButton.center = CGPoint.init(x: buttonXPosition, y: buttonYPosition )
    modeToggleButton.addTarget(self, action:#selector(self.toggleMode), for: .touchUpInside)
    
  }
  
  func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode? {
    // Create a SceneKit plane to visualize the node using its position and extent.
    // Create the geometry and its materials
    let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
    
    let gridImage = UIImage(named: "grid")
    let gridMaterial = SCNMaterial()
    gridMaterial.diffuse.contents = gridImage
    gridMaterial.isDoubleSided = true
    
    plane.materials = [gridMaterial]
    
    // Create a node with the plane geometry we created
    let planeNode = SCNNode(geometry: plane)
    planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z)
    
    //Create a physics body so that our particles can interact with the plane
    let planeBody = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape.init(node: planeNode))
    planeBody.restitution = 0
    planeNode.physicsBody = planeBody
    planeNode.physicsBody!.isAffectedByGravity = false
    
    
    // SCNPlanes are vertically oriented in their local coordinate space.
    // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    
    return planeNode
  }
  
  func setupPhoneNode() {
    
    
    let shape = SCNPhysicsShape(geometry: SCNBox(width: 0.0485, height: 0.1, length: 0.0049, chamferRadius: 0), options: nil)
    let cubeBody = SCNPhysicsBody(type: .kinematic , shape: shape)
    cubeBody.restitution = 0
    
    let cubeGeometry = SCNBox(width: 0.04, height: 0.1, length: 0.01, chamferRadius: 0)
    let boxMaterial = SCNMaterial()
    boxMaterial.diffuse.contents = UIColor.clear
    boxMaterial.locksAmbientWithDiffuse = true;
    
    cubeGeometry.materials = [boxMaterial]
    
    phoneNode = SCNNode(geometry: cubeGeometry)
    
    
    //Move in front of screen
    
    phoneNode.position = getPositionRelativeToCameraView(distance: 1).position
    phoneNode.physicsBody = cubeBody
    
    sceneView.scene.rootNode.addChildNode(phoneNode)
  }
  
  
  
  
  // MARK: - Controls
  
  
  @objc func toggleMode() {
      switch currentMode {
      case .drawing:
        self.modeToggleButton.setBackgroundImage(UIImage.init(named: "plus" ), for: .normal)
        self.currentMode = .cubes
      case .cubes:
        self.modeToggleButton.setBackgroundImage(UIImage.init(named: "stop" ), for: .normal)
        self.currentMode = .drawing
      }
  }
  
  @objc func tapHandler(gesture: UITapGestureRecognizer) {
    if gesture.state == .began {
      userTouchingScreen()
    } else if gesture.state == .ended {
      userTouchEnded()
    }
  }
  
  @objc func userTouchingScreen() {
    buttonDown = true
  }
  
  @objc func userTouchEnded() {
    buttonDown = false
    self.drawNode = nil
    self.previousSize = nil
  }
  
  
  func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
    return touch.view == gestureRecognizer.view
  }
  
  
  // MARK: - Actions
  
  func spawnShape(point: SCNVector3, size: CGFloat) {
    let currentTime = CFAbsoluteTimeGetCurrent()
    if  currentTime - lastSpawn > 0.1 {

    switch currentMode {
    case .drawing:
        placeNewDrawingNode()
    case .cubes:
        placeNewCube(size, currentTime) //using this timer to throttle the amount of cubes created
      }
    }
  }
  
  func placeNewDrawingNode() {
    
    let positionOfNextNode = getPositionRelativeToCameraView(distance: 0.5).position
    var nodeSize: CGFloat = 0
    
    
    //Extra calcs to ensure that the node smoothly changes size relative to velocity
    if let previousNode = drawNode {
      let distanceFromPreviousNode = previousNode.position.distance(vector: positionOfNextNode) * 200
      let logisticDistance = 1 / (1 + pow(2.71828, -(distanceFromPreviousNode - 0.0005)))
      
      if let lastSize = self.previousSize {
        let newCalculatedSize = CGFloat(0.5 * logisticDistance)
        var sizeDelta = (newCalculatedSize - lastSize) / 1000
        if sizeDelta.magnitude > 0.005 {
          sizeDelta = 0.005 * CGFloat(sizeDelta.magnitude/sizeDelta)
          print("oldSize: \(lastSize), logDist \(logisticDistance), delta: \(sizeDelta)")
        }
        nodeSize = lastSize + sizeDelta
      } else {
        nodeSize = 0.005
      }
      if nodeSize > 0.025 { nodeSize = 0.025}
      self.previousSize = nodeSize
      
    }
    
    let drawGeometry = SCNSphere(radius: nodeSize)
    drawGeometry.firstMaterial?.diffuse.contents = UIColor.red
    self.drawNode = SCNNode(geometry: drawGeometry)
    self.drawNode.position = positionOfNextNode
    
    
    //let shape = SCNPhysicsShape(geometry: SCNSphere(radius: nodeSize) , options: nil)
    //let sphereBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    //sphereBody.restitution = 0
    
    //Optional initial values for the motion of the node
    //sphereBody.isAffectedByGravity = false //using custom gravity field
    //drawNode.physicsBody = sphereBody
    
    //    drawNode.physicsField = gravityField
    
    
    sceneView.scene.rootNode.addChildNode(self.drawNode)
  }
  
  fileprivate func placeNewCube(_ size: CGFloat, _ currentTime: CFAbsoluteTime) {
    //Initialize cube shape and appearance
    let cubeGeometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
    let boxMaterial = SCNMaterial()
    boxMaterial.diffuse.contents = UIImage(named: "crate")
    boxMaterial.locksAmbientWithDiffuse = true;
    cubeGeometry.materials = [boxMaterial]
    
    //Create Node and add to parent node
    let geometryNode = SCNNode(geometry: cubeGeometry)
    geometryNode.position = getPositionRelativeToCameraView(distance: 0.2).position
    sceneView.scene.rootNode.addChildNode(geometryNode)
    self.cubes.insert(geometryNode, at: 0)
    self.checkCubeLimit()
    
    //Adding physics to shape, in this case, the cube will have the exact same shape as the node
    let shape = SCNPhysicsShape(geometry: SCNBox(width: size, height: size, length: size, chamferRadius: 0), options: nil)
    let cubeBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    cubeBody.restitution = 0
    geometryNode.physicsBody = cubeBody
    
    //Optional initial values for the motion of the node
    geometryNode.physicsBody!.velocity = self.getUserVector()
    geometryNode.physicsBody!.angularVelocity = SCNVector4Make(1, 0, 0, Float(Double.pi/16));
    geometryNode.physicsField = gravityField
    geometryNode.physicsBody?.isAffectedByGravity = false //using custom gravity field
    
    lastSpawn = currentTime
  }
  
  func checkCubeLimit() {
    if cubes.count > 25 {
      //cubes.last!.removeFromParentNode()
      //cubes.popLast()
    }
  }
  
  
  // MARK: - ARSCNViewDelegate
  
  /*
   // Override to create and configure nodes for anchors added to the view's session.
   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
   let node = SCNNode()
   
   return node
   }
   */
  
  //var prevTime : TimeInterval = -1
  
  
  func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
    
    if ( buttonDown ) {
      
      let pointer = getPointerPosition()
      spawnShape(point: pointer.pos,size: 0.1)
      
    }
    updatePhoneNode()
  }
  
  func updatePhoneNode() {
    
    
    //Move in front of screen
    let phonePositioningInfo = getPositionRelativeToCameraView(distance: 0.1)
    
    
    phoneNode.position = phonePositioningInfo.position
    
    phoneNode.rotation = phonePositioningInfo.rotation
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    
    
    if let planeNode = createPlaneNode(anchor: planeAnchor) {
      // ARKit owns the node corresponding to the anchor, so make the plane a child node.
   
      node.addChildNode(planeNode)
      planeArray.append(planeNode)

    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    
    guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
    
    for plane in planeArray {
      plane.removeFromParentNode()
    }
    if let planeNode = createPlaneNode(anchor: planeAnchor) {
      node.addChildNode(planeNode)
      planeArray.append(planeNode)

    }
    
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard anchor is ARPlaneAnchor else { return }
    
    for plane in planeArray {
      plane.removeFromParentNode()
    }

  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
    
  }
  
  func session(_ session: ARSession, didFailWithError error: Error) {
    // Present an error message to the user
    
  }
  
  func sessionWasInterrupted(_ session: ARSession) {
    // Inform the user that the session has been interrupted, for examee, by presenting an overlay
    
  }
  
  func sessionInterruptionEnded(_ session: ARSession) {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
  }
  
  // MARK: - Linear Algebra Helpers
  
  func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector4 ) {
    
    guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector4Zero) }
    guard let currentFrame = sceneView.session.currentFrame else { return (SCNVector3Zero, false, SCNVector4Zero) }
    
    
    let mat = SCNMatrix4.init(currentFrame.camera.transform)
    _ = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
    
    let currentPosition = pointOfView.position
    
    return (currentPosition, true, pointOfView.rotation)
    
  }
  
  func getUserVector() -> (SCNVector3) { // (direction, position)
    if let frame = self.sceneView.session.currentFrame {
      let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
      
      let vMult = 0.01
      let dir = SCNVector3(-Float(vMult) * mat.m31, -Float(vMult) * mat.m32, -Float(vMult) * mat.m33) // orientation of camera in world space
      _ = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
      
      return (dir)
    }
    return (SCNVector3(0, 0, -1))
  }
  
  func getPositionRelativeToCameraView(distance: Float) -> (position: SCNVector3, rotation: SCNVector4) {
    var x = Float()
    var y = Float()
    var z = Float()
    
    let cameraLocation = self.sceneView.pointOfView!.position   //else { return (SCNVector3Zero) }
    let rotation = self.sceneView.pointOfView!.rotation //else { return (SCNVector3Zero) }
    let direction = calculateCameraDirection(cameraNode: rotation)
    
    x = cameraLocation.x + distance * direction.x
    y = cameraLocation.y + distance * direction.y
    z = cameraLocation.z + distance * direction.z
    
    let position = SCNVector3Make(x, y, z)
    return (position, rotation)
  }
  
  func calculateCameraDirection(cameraNode: SCNVector4) -> SCNVector3 {
    let x = -cameraNode.x
    let y = -cameraNode.y
    let z = -cameraNode.z
    let w = cameraNode.w
    let cameraRotationMatrix = GLKMatrix3Make(cos(w) + pow(x, 2) * (1 - cos(w)),
                                              x * y * (1 - cos(w)) - z * sin(w),
                                              x * z * (1 - cos(w)) + y*sin(w),
                                              
                                              y*x*(1-cos(w)) + z*sin(w),
                                              cos(w) + pow(y, 2) * (1 - cos(w)),
                                              y*z*(1-cos(w)) - x*sin(w),
                                              
                                              z*x*(1 - cos(w)) - y*sin(w),
                                              z*y*(1 - cos(w)) + x*sin(w),
                                              cos(w) + pow(z, 2) * ( 1 - cos(w)))
    
    let cameraDirection = GLKMatrix3MultiplyVector3(cameraRotationMatrix, GLKVector3Make(0.0, 0.0, -1.0))
    return SCNVector3FromGLKVector3(cameraDirection)
  }
  
}

func getRoundyButton(size: CGFloat = 100,
                     imageName : String,
                     _ colorTop : UIColor ,
                     _ colorBottom : UIColor ) -> UIButton {
  
  let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: size, height: size))
  button.clipsToBounds = true
  
  let image = UIImage.init(named: imageName )
  let imgView = UIImageView.init(image: image)
  imgView.center = CGPoint.init(x: button.bounds.size.width / 2.0, y: button.bounds.size.height / 2.0 )
  button.setBackgroundImage(image, for: .normal)
  
  return button
  
}

