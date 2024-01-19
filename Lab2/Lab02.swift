//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab02: Make an auto-rotating cube with different colours on each side
//
//====================================================================

import SwiftUI
import SceneKit

class RotatingColouredCube: SCNScene {    
    var rotAngle = 0.0 // Keep track of rotation angle
    var rotationSpeed = 0.1
    var distZ = 1.0
    var isRotating = true // Keep track of if rotation is toggled
    var isFreeCam = false // Keep track of if free cam is toggled
    var cameraNode = SCNNode() // Initialize camera node
    
    // Catch if initializer in init() fails
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Initializer
    override init() {
        super.init() // Implement the superclass' initializer
        
        background.contents = UIColor.black // Set the background colour to black
        
        setupCamera()
        addCube()
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(5, 5, 5) // Set the position to (0, 0, 2)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/4, Float.pi/4, 0) // Set the pitch, yaw, and roll to 0
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
    }
    
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        let materials = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.magenta] // List of materials for each side
        theCube.geometry?.firstMaterial?.diffuse.contents = materials[0] // Diffuse the red colour material across the whole cube
        //Note: At this point, the cube is completely red. Try commenting lines 45-69 and running to see it!
        
        /// Comment **v
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        
        nextMaterial = SCNMaterial() // Empty the variable
        nextMaterial.diffuse.contents = materials[1] // Set the material of the temporary variable to the material at index 1 in the list
        theCube.geometry?.insertMaterial(nextMaterial, at: 1) // Set the side of the cube at index 1 to the material stored in the temporary variable
        
        //Repeat for side at index 2
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[2]
        theCube.geometry?.insertMaterial(nextMaterial, at: 2)
        
        //Repeat for side at index 3
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[3]
        theCube.geometry?.insertMaterial(nextMaterial, at: 3)
        
        //Repeat for side at index 4
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[4]
        theCube.geometry?.insertMaterial(nextMaterial, at: 4)
        
        //Repeat for side at index 5
        nextMaterial = SCNMaterial()
        nextMaterial.diffuse.contents = materials[5]
        theCube.geometry?.insertMaterial(nextMaterial, at: 5)
        /// Comment **^
        
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 39 comes in)
        if(isRotating){
            rotAngle += 0.0005 // Rotate the cube by 0.0005 radians
            // Keep the rotation angle in the range of 0 and pi
            let tau = Double.pi * 2
            if rotAngle > tau {
                rotAngle -= tau
            }
            theCube?.eulerAngles = SCNVector3(0, rotAngle, 0) // Rotate cube by the final amount
        }
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    @MainActor
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
        isFreeCam = !isFreeCam // Toggle free cam
    }
    
    @MainActor
    func handleDrag(geometry: GeometryProxy) -> some Gesture{
        let frame = geometry.frame(in: .local)
        let center = vector_float2(x: Float(frame.midX), y: Float(frame.midY))
        print(center)
        return DragGesture()
            .onChanged{value in
                if(!self.isFreeCam){
                    return
                }
                let theCube = self.rootNode.childNode(withName: "The Cube", recursively: true)
                print(value.startLocation, value.location)
                let relative: SCNVector3 = SCNVector3(value.startLocation.x, value.location.y, self.distZ)
                
                let angleAboutX :Float = atan2(center.y - Float(value.startLocation.y), 0 - Float(self.distZ)) + atan2(relative.y - center.y, Float(self.distZ) - 0)
                
//                let angleA = atan2( center.y - relative.y, center.x - relative.x)
//                let angleB = atan2(Float(value.location.y) - center.y, Float(value.location.x) - center.x)
//                let angleAboutY :Float =  angleA + angleB
//                print(angleAboutX, angleAboutY)
                
                let oldWorldTransform :SCNMatrix4 = theCube!.worldTransform
                let rotateAboutX: SCNMatrix4 = SCNMatrix4Rotate(oldWorldTransform, angleAboutX, 1, 0, 0)
//                let rotateAboutY: SCNMatrix4 = SCNMatrix4Rotate(rotateAboutX, angleAboutY, 0, 1, 0)
                theCube?.setWorldTransform(rotateAboutX)
                
            }
    }
}

