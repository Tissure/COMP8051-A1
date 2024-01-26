//====================================================================
//
//[DONE] Create an app that runs on an iOS device (you can assume at least iOS 14.0) with a single cube shown in perspective projection. Each side of the cube should have a separate colour, as shown in class.
//[DONE] Modify the app so a double-tap toggles whether the cube continuously rotates about the y-axis.
//[DONE] Modify the app so when the cube is not rotating the user can rotate the cube about two axes using the touch interface (single finger drag).
//[DONE] Modify the app so when the cube is not rotating a “pinch” (two fingers moving closer or farther away from each other) zooms in and out of the cube.
//[] Modify the app so when the cube is not rotating dragging with two fingers moves the cube around.
//[DONE] Add to the app a button that, when pressed, resets the cube to a default position of (0,0,0) with a default orientation.
//[] Add to the app a label that continuously reports the position (x,y,z) and rotation (3 angles) of the cube.
//[DONE] Add a second cube with a separate texture applied to each side, spaced far enough from the first one so the two are fully visible and close enough that both are in the camera's view. This second cube should continuously rotate, even when the first one is not auto-rotating.
//[] Add a flashlight, ambient and diffuse light, and include toggle buttons to turn each one on and off. The effects of each of the three lights should be clearly visible.

//====================================================================

import SwiftUI
import SceneKit

public class DraggableRotatingCube: SCNScene, ObservableObject {
    @Published var positionText:String = "a"
    @Published var rotationText:String = "a"
    var rot1 = CGSize.zero
    var rot2 = CGSize.zero
    var rotAngle = CGSize.zero
    var rotationSpeed = 0.01
    var scale = SCNVector3(1,1,1)
    var translation = CGSize(width: 1, height: 1)
    var isRotating = true // Keep track of if rotation is toggled
    var isFreeCam = false // Keep track of if free cam is toggled
    var cameraNode = SCNNode() // Initialize camera node
    
    var initCubeTransform:SCNMatrix4 = SCNMatrix4Identity
    
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
        addSecondCube()
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
        assignMaterials(theCube: theCube, materials: materials)
        
        theCube.position = SCNVector3(0, 0, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
        initCubeTransform = theCube.transform
    }
    
    func addSecondCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Other Cube" // Name the node so we can reference it later
        let materials = [UIImage(named: "CubeTextures/cube1.jpg"),
                         UIImage(named: "CubeTextures/cube2.jpg"),
                         UIImage(named: "CubeTextures/cube3.jpg"),
                         UIImage(named: "CubeTextures/cube4.jpg"),
                         UIImage(named: "CubeTextures/cube5.jpg"),
                         UIImage(named: "CubeTextures/cube6.jpg")] // List of materials for each side
        assignMaterials(theCube:theCube, materials:materials)
        
        theCube.position = SCNVector3(0, -5, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
        initCubeTransform = theCube.transform
    }
    
    func assignMaterials(theCube:SCNNode, materials:[NSObject?]){
        theCube.geometry?.firstMaterial?.diffuse.contents = materials[0] // Diffuse the red colour material across the whole cube
        //Note: At this point, the cube is completely red. Try commenting lines 45-69 and running to see it!
        /// Comment **v
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        for i in 1..<materials.count{
            nextMaterial = SCNMaterial() // Empty the variable
            nextMaterial.diffuse.contents = materials[i] // Set the material of the temporary variable to the material at index 1 in the list
            theCube.geometry?.insertMaterial(nextMaterial, at: i) // Set the side of the cube at index 1 to the material stored in the temporary variable
        }
    }
    
    @MainActor
    func resetCube(){
        translation = CGSize(width:1,height:1)
        rotAngle = CGSize.zero
        scale = SCNVector3(1,1,1)
    }
    
    @MainActor
    func firstUpdate() {
        reanimate() // Call reanimate on the first graphics update frame
    }
    
    @MainActor
    func reanimate() {
        
        let theCube = rootNode.childNode(withName: "The Cube", recursively: true) // Get the cube object by its name (This is where line 39 comes in)
        animateCube(theCube)
        
        let theOtherCube = rootNode.childNode(withName: "The Other Cube", recursively: true)
        
        animateOtherCube(theOtherCube)
        //        updateText(pos: theCube?.position, rot: theCube?.eulerAngles)
        positionText = "\(String(describing: theCube?.position))"
        rotationText = "\(String(describing: theCube?.eulerAngles))"
        self.objectWillChange.send()
        
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 10000)
            reanimate()
        }
    }
    
    @MainActor
    func animateCube(_ theCube: SCNNode?){
        if(isRotating){
            rot1.width += 0.05
        }else{
            theCube?.position = SCNVector3(translation.width, translation.height, 1)
            rot1 = rotAngle
            theCube?.scale = scale
        }
        theCube?.eulerAngles = SCNVector3(rot1.height * rotationSpeed, rot1.width * rotationSpeed, 0)
    }
    
    @MainActor
    func animateOtherCube(_ theCube: SCNNode?){
        
        rot2.width += 0.05
        theCube?.eulerAngles = SCNVector3(rot2.height * rotationSpeed, rot2.width * rotationSpeed, 0)
    }
    
    func updateText(pos:SCNVector3?, rot:SCNVector3?){
        
    }
    
    @MainActor
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
        isFreeCam = !isFreeCam // Toggle free cam
    }
    
    @MainActor
    func handleDrag(_ offset: CGSize){
        rotAngle = offset
    }
    
    @MainActor
    func handlePinch(_ magnification:CGFloat){
        scale = SCNVector3(magnification, magnification, magnification)
    }
    
    @MainActor
    func handleDoubleDrag(_ offset: CGSize){
        translation = offset
        print(offset)
    }
    
    @MainActor
    func toggleFlashLight(_ id:Int){
        print(id)
    }
}
