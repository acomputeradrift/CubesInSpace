//
//  ARController.swift
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


func getRoundyButton(size: CGFloat = 100,
                     imageName : String,
                     _ colorTop : UIColor ,
                     _ colorBottom : UIColor ) -> UIButton {
    
    let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: size, height: size))
    button.clipsToBounds = true
    button.layer.cornerRadius = size / 2
    
    let gradient: CAGradientLayer = CAGradientLayer()
    
    gradient.colors = [colorTop.cgColor, colorBottom.cgColor]
    gradient.startPoint = CGPoint(x: 1.0, y: 1.0)
    gradient.endPoint = CGPoint(x: 0.0, y: 0.0)
    gradient.frame = button.bounds
    gradient.cornerRadius = size / 2
    
    button.layer.insertSublayer(gradient, at: 0)
    
    let image = UIImage.init(named: imageName )
    let imgView = UIImageView.init(image: image)
    imgView.center = CGPoint.init(x: button.bounds.size.width / 2.0, y: button.bounds.size.height / 2.0 )
    button.addSubview(imgView)
    
    return button
    
}



class MainViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    var ground: SCNNode!
    var buttonDown = false
    var addPointButton : UIButton!
    var frameIdx = 0
    var splitLine = false
    var lineRadius : Float = 0.001
    var lastSpawn = CFAbsoluteTimeGetCurrent()
    
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
        
        //addButton()
        
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
        ground.position = sceneView.scene.rootNode.position //- SCNVector3(0,1.5,0)
        
        let groundShape = SCNPhysicsShape(geometry: groundGeometry, options: nil)
        let groundBody = SCNPhysicsBody(type: .kinematic, shape: groundShape)
        ground.physicsBody = groundBody
        
        
        
        sceneView.scene.rootNode.addChildNode(ground)
        
        /*
         let cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
         cubeNode.position = SCNVector3(0, 0, -0.2) // SceneKit/AR coordinates are in meters
         sceneView.scene.rootNode.addChildNode(cubeNode)*/
        
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
        
        addPointButton = getRoundyButton(size: 60, imageName: "stop", c1, c2)
        //addPointButton.setTitle("+", for: UIControlState.normal)
        
        self.view.addSubview(addPointButton)
        addPointButton.center = CGPoint.init(x: sw / 2.0, y: 120 )
        //addPointButton.addTarget(self, action:#selector(self.buttonTouchDown), for: .touchDown)
        //addPointButton.addTarget(self, action:#selector(self.clearDrawing), for: .touchUpInside)
        //addPointButton.addTarget(self, action:#selector(self.buttonTouchUp), for: .touchUpOutside)
        
    }
    
    
    
    
    
    @objc func buttonTouchDown() {
        splitLine = true
        buttonDown = true
    }
    @objc func buttonTouchUp() {
        buttonDown = false
    }
    
    func spawnShape(point: SCNVector3) {
        
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
            
            
            let shape = SCNPhysicsShape(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0), options: nil)
            let cubeBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            let geometryNode = SCNNode(geometry: SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0))//SCNNode(geometry: geometry)
            geometryNode.position = point
            geometryNode.physicsBody = cubeBody
            //geometryNode.physicsBody!.velocity = self.getUserVector()
            geometryNode.physicsBody!.angularVelocity = SCNVector4Make(1, 1, 1, Float(Double.pi/4));
            /*let gravityField = SCNPhysicsField.linearGravity()
             gravityField.direction = SCNVector3(0,-1,0);
             gravityField.strength = 0.01
             geometryNode.physicsField = gravityField*/
            geometryNode.physicsBody?.isAffectedByGravity = false
            
            sceneView.scene.rootNode.addChildNode(geometryNode)
            // 5
            
            //sceneView!.node
            
            lastSpawn = currentTime
        }
        
        
    }
    
    func getUserVector() -> (SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            
            let vMult = 0.1
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
            spawnShape(point: pointer.pos)
            
        }
        
        frameIdx = frameIdx + 1
        
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
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    // MARK: stuff
    
    func getPointerPosition() -> (pos : SCNVector3, valid: Bool, camPos : SCNVector3 ) {
        
        guard let pointOfView = sceneView.pointOfView else { return (SCNVector3Zero, false, SCNVector3Zero) }
        guard let currentFrame = sceneView.session.currentFrame else { return (SCNVector3Zero, false, SCNVector3Zero) }
        
        
        let mat = SCNMatrix4.init(currentFrame.camera.transform)
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33)
        
        let currentPosition = pointOfView.position + (dir * 0.12)
        
        return (currentPosition, true, pointOfView.position)
        
    }
    
}

