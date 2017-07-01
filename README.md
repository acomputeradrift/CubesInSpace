# CubesInSpace
This  demo allows the user to place cubes in space by tapping on screen. The cubes are physical bodies and respond to gravity if you go ahead and increate the gravitational acceleration above zero. You 

This project borrows heavily from the ARBrush for SCNVector 3 extensions and inital AR Setup. See that here: https://github.com/laanlabs/ARBrush

Changed to fit the purpose of including SceneKit Content


![CubesInSpace Demo](./paddleDemo.gif)



## Creating a box that follows the phone position

This function should be thrown in with all of your other initialization code in 'viewDidLoad()' 


'''swift
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
'''

Update that code within your 'renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)'

First you need to get the position and orientation of your device. Here's a function to do just that. 

'''swift 

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

'''


For usability reasons, I traced a vector normal from the phones screen by about 10 cm. 

Next apply that to your phone node during your regular update cycle. 

'''swift
func updatePhoneNode() {
        
        //Move in front of screen
        phoneNode.position = getPositionRelativeToCameraView(distance: 0.1)
        
        phoneNode.rotation = getPointerPosition().camPos
      
    }
'''



