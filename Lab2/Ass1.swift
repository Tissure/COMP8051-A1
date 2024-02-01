//====================================================================
//
//[DONE] Create an app that runs on an iOS device (you can assume at least iOS 14.0) with a single cube shown in perspective projection. Each side of the cube should have a separate colour, as shown in class.
//[DONE] Modify the app so a double-tap toggles whether the cube continuously rotates about the y-axis.
//[DONE] Modify the app so when the cube is not rotating the user can rotate the cube about two axes using the touch interface (single finger drag).
//[DONE] Modify the app so when the cube is not rotating a “pinch” (two fingers moving closer or farther away from each other) zooms in and out of the cube.
//[DONE] Modify the app so when the cube is not rotating dragging with two fingers moves the cube around.
//[DONE] Add to the app a button that, when pressed, resets the cube to a default position of (0,0,0) with a default orientation.
//[DONE] Add to the app a label that continuously reports the position (x,y,z) and rotation (3 angles) of the cube.
//[DONE] Add a second cube with a separate texture applied to each side, spaced far enough from the first one so the two are fully visible and close enough that both are in the camera's view. This second cube should continuously rotate, even when the first one is not auto-rotating.
//[DONE] Add a flashlight, ambient and diffuse light, and include toggle buttons to turn each one on and off. The effects of each of the three lights should be clearly visible.

//====================================================================

import SwiftUI
import SceneKit

struct CubeInstance {
    var rot = CGSize.zero
    var cube:SCNNode =  SCNNode()
    var initPos:SCNVector3 = SCNVector3Zero
}


public class DraggableRotatingCube: SCNScene, ObservableObject {
    @Published var positionText:String = "a"
    
    var TheCube:CubeInstance = CubeInstance()
    var TheOtherCube:CubeInstance = CubeInstance()
    
    var rotAngle = CGSize.zero
    var rotationSpeed = 0.05
    let dragSpeed = 0.0005
    let panSpeed = 0.01
    var scale = SCNVector3(1,1,1)
    var translation = CGPoint.zero
    var isRotating = true // Keep track of if rotation is toggled
    
    var cameraNode = SCNNode() // Initialize camera node
    var diffuseLightPos = SCNVector4(0, 0, 0, Double.pi/2) // Keep track of flashlight position
    var flashlightPos = 3.0
    var flashlightAngle = 10.0
    
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
        setupLighting()
        
        Task(priority: .userInitiated) {
            await firstUpdate()
        }
        
    }
    
    func setupLighting(){
        setupDudLight() // Disable Default lighting
        setupAmbientLight()
        setupDirectionalLight()
        setupFlashlight()
    }
    
    // Function to setup the camera node
    func setupCamera() {
        let camera = SCNCamera() // Create Camera object
        cameraNode.camera = camera // Give the cameraNode a camera
        cameraNode.position = SCNVector3(0,1,15) // Set the position to (0, 0, 2)
        cameraNode.eulerAngles = SCNVector3(-Float.pi/16, 0, 0) // Set the pitch, yaw, and roll to 0
        rootNode.addChildNode(cameraNode) // Add the cameraNode to the scene
    }
    
    func addCube() {
        let theCube = SCNNode(geometry: SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)) // Create a object node of box shape with width of 1 and height of 1
        theCube.name = "The Cube" // Name the node so we can reference it later
        let materials = [UIColor.red, UIColor.green, UIColor.blue, UIColor.yellow, UIColor.cyan, UIColor.magenta] // List of materials for each side
        assignMaterials(theCube: theCube, materials: materials)
        
        theCube.position = SCNVector3(0,0,0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
        
        self.TheCube.initPos = theCube.position
        self.TheCube.cube = theCube
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
        
        theCube.position = SCNVector3(0, -2, 0) // Put the cube at position (0, 0, 0)
        rootNode.addChildNode(theCube) // Add the cube node to the scene
        
        self.TheOtherCube.cube = theCube
    }
    
    func assignMaterials(theCube:SCNNode, materials:[NSObject?]){
        theCube.geometry?.firstMaterial?.diffuse.contents = materials[0] // Diffuse the red colour material across the whole cube
        var nextMaterial: SCNMaterial // Initialize temporary variable to store each texture
        for i in 1..<materials.count{
            nextMaterial = SCNMaterial() // Empty the variable
            nextMaterial.diffuse.contents = materials[i] // Set the material of the temporary variable to the material at index 1 in the list
            theCube.geometry?.insertMaterial(nextMaterial, at: i) // Set the side of the cube at index 1 to the material stored in the temporary variable
        }
    }
    
    // Sets up a dud light
    func setupDudLight() {
        let dudLight = SCNNode() // Create a SCNNode for the lamp
        dudLight.light = SCNLight() // Add a new light to the lamp
        dudLight.light!.type = .directional // Set the light type to ambient
        dudLight.light!.color = UIColor.white // Set the light color to white
        dudLight.light!.intensity = 0 // Set the light intensity to 5000 lumins (1000 is default)
        rootNode.addChildNode(dudLight) // Add the lamp node to the scene
    }
    
    // Sets up an ambient light (all around)
    func setupAmbientLight() {
        let ambientLight = SCNNode() // Create a SCNNode for the lamp
        ambientLight.name = "Ambient Light"
        ambientLight.light = SCNLight() // Add a new light to the lamp
        ambientLight.light!.type = .ambient // Set the light type to ambient
        ambientLight.light!.color = UIColor.white // Set the light color to white
        ambientLight.light!.intensity = 500 // Set the light intensity to 5000 lumins (1000 is default)
        rootNode.addChildNode(ambientLight) // Add the lamp node to the scene
    }
    
    // Sets up a directional light (flashlight)
    func setupDirectionalLight() {
        let directionalLight = SCNNode() // Create a SCNNode for the lamp
        directionalLight.name = "Directional Light" // Name the node so we can reference it later
        directionalLight.light = SCNLight() // Add a new light to the lamp
        directionalLight.light!.type = .directional // Set the light type to directional
        directionalLight.light!.color = UIColor.green // Set the light color to white
        directionalLight.light!.intensity = 20000 // Set the light intensity to 20000 lumins (1000 is default)
        directionalLight.rotation = diffuseLightPos // Set the rotation of the light from the flashlight to the flashlight position variable
        rootNode.addChildNode(directionalLight) // Add the lamp node to the scene
    }
    
    // Sets up a directional light (flashlight)
    func setupFlashlight() {
        let lightNode = SCNNode()
        lightNode.name = "Flashlight"
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLight.LightType.spot
        lightNode.light!.castsShadow = true
        lightNode.light!.color = UIColor.red
        lightNode.light!.intensity = 5000
        lightNode.position = SCNVector3(0, 5, flashlightPos)
        lightNode.rotation = SCNVector4(1, 0, 0, -Double.pi/3)
        lightNode.light!.spotInnerAngle = 10
        lightNode.light!.spotOuterAngle = flashlightAngle
        lightNode.light!.shadowColor = UIColor.black
        lightNode.light!.zFar = 500
        lightNode.light!.zNear = 50
        rootNode.addChildNode(lightNode)
    }
    
    @MainActor
    func resetCube(){
        TheCube.cube.position = TheCube.initPos
        translation = CGPoint(x: CGFloat(TheCube.initPos.x) / panSpeed, y: CGFloat(TheCube.initPos.y) / panSpeed)
        rotAngle = CGSize.zero
        scale = SCNVector3(1,1,1)
        cameraNode.camera?.fieldOfView = 60
    }
    
    @MainActor
    func firstUpdate() {
        resetCube()
        reanimate() // Call reanimate on the first graphics update frame
        updateUI()
    }
    
    @MainActor
    func reanimate() {
        
        animateCube()
        animateOtherCube()
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 1000)
            reanimate()
        }
    }
    
    @MainActor
    func updateUI(){
        
        DispatchQueue.main.async{
            self.positionText = "\(self.TheCube.cube.position.x), \(self.TheCube.cube.position.y), \(self.TheCube.cube.position.z)"
        }
        // Repeat increment of rotation every 10000 nanoseconds
        Task { try! await Task.sleep(nanoseconds: 320000000)
            updateUI()
        }
    }
    
    @MainActor
    func animateCube(){
        
        if(isRotating){
            self.TheCube.rot.width += rotationSpeed
            rotAngle = self.TheCube.rot
        }else{
            self.TheCube.cube.position = SCNVector3(translation.x * panSpeed, translation.y * panSpeed, 0)
            self.TheCube.rot = rotAngle
            self.TheCube.cube.scale = scale
        }
        self.TheCube.cube.eulerAngles = SCNVector3(self.TheCube.rot.height, self.TheCube.rot.width, 0)
    }
    
    @MainActor
    func animateOtherCube(){
        self.TheOtherCube.rot.width += rotationSpeed
        self.TheOtherCube.rot.height += rotationSpeed
        self.TheOtherCube.cube.eulerAngles = SCNVector3(self.TheOtherCube.rot.height, self.TheOtherCube.rot.width, 0)
    }
    
    @MainActor
    func handleDoubleTap() {
        isRotating = !isRotating // Toggle rotation
    }
    
    @MainActor
    func handleDrag(_ offset: CGPoint){
        if(isRotating){return}
        rotAngle = CGSize(width: rotAngle.width + offset.x * dragSpeed, height: rotAngle.height + offset.y * dragSpeed)
    }
    
    @MainActor
    func handlePinch(_ magnification:CGFloat){
        if(isRotating){return}
        scale = SCNVector3(magnification, magnification, magnification)
    }
    
    @MainActor
    func handleDoubleDrag(_ offset:CGPoint){
        if(isRotating){return}
        translation = CGPoint(x: translation.x + offset.x * panSpeed, y: translation.y - offset.y * panSpeed)
    }
    
    @MainActor
    func toggleLights(_ id:Int){
        let ambientLight = rootNode.childNode(withName: "Ambient Light", recursively: true)
        let directionalLight = rootNode.childNode(withName: "Directional Light", recursively: true)
        let flashLight = rootNode.childNode(withName: "Flashlight", recursively: true)
        
        switch id{
        case 1:
            ambientLight?.isHidden = !(ambientLight?.isHidden ?? true)
            break
        case 2:
            directionalLight?.isHidden = !(directionalLight?.isHidden ?? true)
            break
        case 3:
            flashLight?.isHidden = !(flashLight?.isHidden ?? true)
            break
        default: break
        }
    }
}
