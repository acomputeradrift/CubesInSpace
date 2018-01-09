# CubesInSpace
This  demo allows the user to place cubes in space by tapping on screen. The cubes are physical bodies and respond to being 'hit' with the phone

This project borrows from a number of different repositories:

Thanks to ARBrush for SCNVector 3 extensions and inital AR Setup. See that [HERE](https://github.com/laanlabs/ARBrush)

Thanks to FloorIsLava for plane detection and configuration. See that [HERE]( https://github.com/arirawr/ARKit-FloorIsLava)

Thanks to RayWenderlich for some SceneKit Pointers. Check them out [HERE]( https://www.raywenderlich.com/128681/scene-kit-tutorial-swift-part-2-nodes)



![CubesInSpace Demo](./paddleDemo.gif)



## Creating a box that follows the phone position

This function should be thrown in with all of your other initialization code in 'viewDidLoad()' 


```swift
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
```

First you need to get the position and orientation of your device. Here's a function to do just that. 


```swift

func getPositionRelativeToCameraView(distance: Float) -> (position: SCNVector3, rotation: SCNVector4) {
        var x = Float()
        var y = Float()
        var z = Float()
        
        let cameraLocation = self.sceneView.pointOfView!.position 
        let rotation = self.sceneView.pointOfView!.rotation
        let direction = calculateCameraDirection(cameraNode: rotation)
        
        x = cameraLocation.x + distance * direction.x
        y = cameraLocation.y + distance * direction.y
        z = cameraLocation.z + distance * direction.z
        
        let position = SCNVector3Make(x, y, z)
        return (position, rotation)
    }

```


For usability reasons, I traced a vector normal from the phones screen by about 10 cm. 

Apply this code to your phone node during your regular update cycle. In my case: 'renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)'

```swift

func updatePhoneNode() {
        
        //Move in front of screen
        phoneNode.position = getPositionRelativeToCameraView(distance: 0.1)
        
        phoneNode.rotation = getPointerPosition().camPos
      
    }
```


## Create blocks in 3-D Space:
```swift
func spawnShape(point: SCNVector3, size: CGFloat) {
        
        let currentTime = CFAbsoluteTimeGetCurrent()
        if  currentTime - lastSpawn > 0.1 {
            
            
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
            
            //Adding physics to shape, in this case, the cube will have the exact same shape as the node
            let shape = SCNPhysicsShape(geometry: SCNBox(width: size, height: size, length: size, chamferRadius: 0), options: nil)
            let cubeBody = SCNPhysicsBody(type: .dynamic, shape: shape)
            cubeBody.restitution = 0
            geometryNode.physicsBody = cubeBody
            
            
            //Optional initial values for the motion of the node
            geometryNode.physicsBody!.velocity = self.getUserVector()
            geometryNode.physicsBody!.angularVelocity = SCNVector4Make(-1, 0, 0, Float(Double.pi/16));
            geometryNode.physicsField = gravityField
            geometryNode.physicsBody?.isAffectedByGravity = false //using custom gravity field
            
            lastSpawn = currentTime //using this timer to throttle the amount of cubes created
        }
        
        
    }
```


