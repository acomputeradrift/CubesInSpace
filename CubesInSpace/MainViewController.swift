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
import simd

class MainViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    var buttonDown = false
    var addPointButton : UIButton!
    var frameIdx = 0
    var splitLine = false
    var lineRadius : Float = 0.001
    var lastSpawn = CFAbsoluteTimeGetCurrent()
    var gravityField = SCNPhysicsField.linearGravity()
    var gravityActivated = false
    var planeArray = [SCNNode]()
    var phoneNode: SCNNode!
    var ground: SCNNode!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // This tends to conflict with the rendering
        //sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/world.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        addButton()
        
        //self.view.addGestureRecognizer(UIGestureRecognizer.)
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.minimumPressDuration = 0
        tap.cancelsTouchesInView = false
        tap.delegate = self
        self.sceneView.addGestureRecognizer(tap)
        
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
        
        
        setupPhoneNode()
        /*
        var light = SCNLight()
        
        var lightNode = SCNNode();
        
        lightNode.light = light;
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.yellow
        
        lightNode.position = getPointerPosition().pos
        lightNode.orientation = getPointerPosition().camPos*/
        
        //sceneView.scene.rootNode.addChildNode (lightNode);
        sceneView.automaticallyUpdatesLighting = true
        
        gravityField.direction = SCNVector3(0,0,0);
        gravityField.strength = 0.0
        
        sceneView.scene.rootNode.addChildNode(ground)
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
    
    // called by gesture recognizer
    @objc func tapHandler(gesture: UITapGestureRecognizer) {
        
        // handle touch down and touch up events separately
        if gesture.state == .began {
            // do something...
            buttonTouchDown()
        } else if gesture.state == .ended { // optional for touch up event catching
            // do something else...
            buttonTouchUp()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()
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
    
    func addButton() {
        
        let sw = self.view.bounds.size.width
        let sh = self.view.bounds.size.height
        
        // red
        let c1 = UIColor(red: 246.0/255.0, green: 205.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        let c2 = UIColor(red: 230.0/255.0, green: 98.0/255.0, blue: 87.0/255.0, alpha: 1.0)
        
        // greenish
        //let c1 = UIColor(red: 112.0/255.0, green: 219.0/255.0, blue: 155.0/255.0, alpha: 1.0)
        //let c2 = UIColor(red: 86.0/255.0, green: 197.0/255.0, blue: 238.0/255.0, alpha: 1.0)
        
        addPointButton = getRoundyButton(size: 60, imageName: "plus", c1, c2)
        //addPointButton.setTitle("+", for: UIControlState.normal)
        
        self.view.addSubview(addPointButton)
        
        let buttonXPosition = CGFloat(40.0)
        let buttonYPosition = sh - 40
        addPointButton.center = CGPoint.init(x: buttonXPosition, y: buttonYPosition )
        addPointButton.addTarget(self, action:#selector(self.toggleGravity), for: .touchUpInside)
        
    }
    
    
    @objc func toggleGravity() {
        
        if gravityActivated {
            gravityField.direction = SCNVector3(0,-1,0);
            gravityField.strength = 0.005
            gravityActivated = false
            addPointButton.setBackgroundImage(UIImage.init(named: "stop" ), for: .normal)
            
            
        }   else {
            gravityField.direction = SCNVector3(0,0,0);
            gravityField.strength = 0.0
            gravityActivated = true
            addPointButton.setBackgroundImage(UIImage.init(named: "plus" ), for: .normal)
            
            
        }
        
    }
    
    
    @objc func buttonTouchDown() {
        splitLine = true
        buttonDown = true
    }
    @objc func buttonTouchUp() {
        buttonDown = false
    }
    
    func spawnShape(point: SCNVector3, size: CGFloat) {
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        if  currentTime - lastSpawn > 0.1 {
            // 1
            /*var geometry:SCNGeometry
             // 2
             switch ShapeType.random() {
             default:
             // 3
             geometry = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
             }*/
            // 4
            
            
            let shape = SCNPhysicsShape(geometry: SCNBox(width: size, height: size, length: size, chamferRadius: 0), options: nil)
            let cubeBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            cubeBody.restitution = 0
            //SCNNode(geometry: geometry)
            
            let cubeGeometry = SCNBox(width: size, height: size, length: size, chamferRadius: 0)
            let boxMaterial = SCNMaterial()
            boxMaterial.diffuse.contents = UIImage(named: "crate")
            boxMaterial.locksAmbientWithDiffuse = true;
            
            cubeGeometry.materials = [boxMaterial]
            
            let geometryNode = SCNNode(geometry: cubeGeometry)
            
            
            geometryNode.position = getPositionRelativeToCameraView(distance: 0.201)
            geometryNode.physicsBody = cubeBody
            
            
                //Toggle this to shoot cubes out of the screen
            geometryNode.physicsBody!.velocity = self.getUserVector()
            
            geometryNode.physicsBody!.angularVelocity = SCNVector4Make(-1, 0, 0, Float(Double.pi/16));
            geometryNode.physicsField = gravityField
            geometryNode.physicsBody?.isAffectedByGravity = false
            
            sceneView.scene.rootNode.addChildNode(geometryNode)
            // 5
            
            //sceneView!.node
            
            lastSpawn = currentTime
        }
        
        
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
        let cubeBody = SCNPhysicsBody(type: .kinematic, shape: shape)
        cubeBody.restitution = 0
        
        let cubeGeometry = SCNBox(width: 0.04, height: 0.1, length: 0.01, chamferRadius: 0)
        let boxMaterial = SCNMaterial()
        boxMaterial.diffuse.contents = UIColor.clear
        boxMaterial.locksAmbientWithDiffuse = true;
        
        cubeGeometry.materials = [boxMaterial]
        
        phoneNode = SCNNode(geometry: cubeGeometry)
        
        var phoneLocation = getPointerPosition().pos
        
        //Move in front of screen
        phoneNode.position = getPositionRelativeToCameraView(distance: 0.0)
        phoneNode.position = phoneLocation
        phoneNode.physicsBody = cubeBody
        
        sceneView.scene.rootNode.addChildNode(phoneNode)
        
        
    }
    
    func updatePhoneNode() {
        
        let phonePositionInformation = getPointerPosition()
        //Move in front of screen
        phoneNode.position = getPositionRelativeToCameraView(distance: 0.1)
        
        phoneNode.rotation = phonePositionInformation.camPos
        
    }
    
    func getUserVector() -> (SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            
            let vMult = 0.01
            let dir = SCNVector3(-Float(vMult) * mat.m31, -Float(vMult) * mat.m32, -Float(vMult) * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            
            return (dir)
        }
        return (SCNVector3(0, 0, -1))
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
        
        frameIdx = frameIdx + 1
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
        
        // Remove existing plane nodes
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
        
        // Remove existing plane nodes
        for plane in planeArray {
            plane.removeFromParentNode()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        /*
         if let commandQueue = self.sceneView?.commandQueue {
         if let encoder = self.sceneView.currentRenderCommandEncoder {
         
         let projMat = float4x4.init((self.sceneView.pointOfView?.camera?.projectionTransform)!)
         let modelViewMat = float4x4.init((self.sceneView.pointOfView?.worldTransform)!).inverse
         
         //vertBrush.render(commandQueue, encoder, parentModelViewMatrix: modelViewMat, projectionMatrix: projMat)
         
         }
         }*/
        
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
    
    // MARK: stuff
    
    func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector4 ) {
        
        guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector4Zero) }
        guard let currentFrame = sceneView.session.currentFrame else { return (SCNVector3Zero, false, SCNVector4Zero) }
        
        
        let mat = SCNMatrix4.init(currentFrame.camera.transform)
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        
        let currentPosition = pointOfView.position + (dir * 0.12)
        
        return (currentPosition, true, pointOfView.rotation)
        
    }
    
    func getPositionRelativeToCameraView(distance: Float) -> SCNVector3 {
        var x = Float()
        var y = Float()
        var z = Float()
        
        let cameraLocation = self.sceneView.pointOfView!.position //else { return (SCNVector3Zero) }
        let rotation = self.sceneView.pointOfView!.rotation //else { return (SCNVector3Zero) }
        let direction = calculateCameraDirection(cameraNode: rotation)
        
        x = cameraLocation.x + distance * direction.x
        y = cameraLocation.y + distance * direction.y
        z = cameraLocation.z + distance * direction.z
        
        let result = SCNVector3Make(x, y, z)
        return result
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

