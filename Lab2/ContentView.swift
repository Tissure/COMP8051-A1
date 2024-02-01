//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab01: Draw red square using SceneKit
// Lab02: Make an auto-rotating cube with different colours on each side
// Lab03: Make a rotating cube with a crate texture that can be toggled
//
//====================================================================

import UIKit
import SwiftUI
import SceneKit

class CustomImageView: UIView, UIGestureRecognizerDelegate {
    
    var mainScene:DraggableRotatingCube?
    private let initialWidth: CGFloat = 300
    
    override init(frame: CGRect) {
        super.init(frame: frame)
           
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 2
        tapGesture.delegate = self
        addGestureRecognizer(tapGesture)
        
        let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(handleDrag(_:)))
        dragGesture.minimumNumberOfTouches = 1
        dragGesture.maximumNumberOfTouches = 2
        dragGesture.delegate = self
        addGestureRecognizer(dragGesture)
        
//        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
//        panGesture.minimumNumberOfTouches = 2
//        panGesture.maximumNumberOfTouches = 2
//        panGesture.delegate = self
//        addGestureRecognizer(panGesture)
//        
//        dragGesture.require(toFail: panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        pinchGesture.delegate = self
        addGestureRecognizer(pinchGesture)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func handleTap(_ recognizer: UITapGestureRecognizer){
        mainScene?.handleDoubleTap()
    }
    
    @objc func handleDrag(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        switch (recognizer.numberOfTouches) {
        case 1:
            mainScene?.handleDrag(translation)
            break
        case 2:
            mainScene?.handleDoubleDrag(translation)
            break
        default: break
            //
        }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer){
        let translation = recognizer.translation(in: self)
        mainScene?.handleDoubleDrag(translation)
    }
    
    @objc func handlePinch(_ recognizer: UIPinchGestureRecognizer){
        mainScene?.handlePinch(recognizer.scale)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

struct ZoomAndPanAndRotationView: UIViewRepresentable {
    var mainScene:DraggableRotatingCube
    func makeUIView(context: Context) -> CustomImageView {
        let customImageView = CustomImageView()
        customImageView.mainScene = mainScene
        return customImageView
    }
    func updateUIView(_ uiView: CustomImageView, context: Context) {
        //
    }
    
}

struct ContentView: View {
    @ObservedObject var mainScene = DraggableRotatingCube()
    var body: some View {
        NavigationStack {
            List {
                NavigationLink{
                    ZStack{
                        
                        SceneView(scene: mainScene, pointOfView: mainScene.cameraNode)
                            .ignoresSafeArea()
                    
                        ZoomAndPanAndRotationView(mainScene: mainScene)
                            .ignoresSafeArea()
                        
                        VStack{
                            Spacer()
                            Group{
                                Text(mainScene.positionText)
                                    .foregroundStyle(.red).font(.system(size: 20))
//                                Text(mainScene.rotationText)
//                                    .foregroundStyle(.red).font(.system(size: 20))
                            }
                            HStack{
                                Button(action: {
                                    mainScene.toggleLights(1)
                                }){
                                    Text("1").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    mainScene.toggleLights(2)
                                }){
                                    Text("2").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    mainScene.toggleLights(3)
                                }){
                                    Text("3").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    mainScene.resetCube()
                                }){
                                    Text("Reset Cube").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                            }
                        }
                        
                    }
                } label: { Text("Assignment 1") }
//                NavigationLink{
//                    let scene = RedSquare()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                } label: { Text("Lab 1: Red square") }
//                NavigationLink{
//                    let scene = RotatingColouredCube()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                        .onTapGesture(count: 2) {
//                            scene.handleDoubleTap()
//                        }
//                } label: { Text("Lab 2: Rotating cube") }
//                NavigationLink{
//                    let scene = RotatingCrate()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                        .onTapGesture(count: 2) {
//                            scene.handleDoubleTap()
//                        }
//                } label: { Text("Lab 3: Textured cube") }
//                NavigationLink{
//                    let scene = ControlableRotatingCrate()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                        .onTapGesture(count: 2) {
//                            scene.handleDoubleTap()
//                        }
//                        .gesture(
//                            DragGesture()
//                                .onChanged{ gesture in
//                                    scene.handleDrag(offset: gesture.translation)
//                                }
//                        )
//                } label: { Text("Lab 4: Rotatable cube") }
//                NavigationLink{
//                    let scene = ControlableRotatingCrateWithText()
//                    ZStack {
//                        SceneView(scene: scene, pointOfView: scene.cameraNode)
//                            .ignoresSafeArea()
//                            .onTapGesture(count: 2) {
//                                scene.handleDoubleTap()
//                            }
//                            .gesture(
//                                DragGesture()
//                                    .onChanged{ gesture in
//                                        scene.handleDrag(offset: gesture.translation)
//                                    }
//                            )
//                        Text("Hello World")
//                            .foregroundStyle(.white)
//                    }
//                } label: { Text("Lab 5: Text examples") }
//                NavigationLink{
//                    let scene = RotatingCrateLight()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                        .onTapGesture(count: 2) {
//                            scene.handleDoubleTap()
//                        }
//                        .gesture(
//                            DragGesture()
//                                .onChanged{ gesture in
//                                    scene.handleDrag(offset: gesture.translation)
//                                }
//                        )
//                } label: { Text("Lab 6: Diffuse lighting") }
//                NavigationLink{
//                    let scene = RotatingCrateFlashlight()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                        .onTapGesture(count: 2) {
//                            scene.handleDoubleTap()
//                        }
//                        .gesture(
//                            DragGesture()
//                                .onChanged{ gesture in
//                                    scene.handleDrag(offset: gesture.translation)
//                                }
//                        )
//                } label: { Text("Lab 7: Spotlight (flashlight)") }
//                NavigationLink{
//                    let scene = RotatingCrateFog()
//                    SceneView(scene: scene, pointOfView: scene.cameraNode)
//                        .ignoresSafeArea()
//                        .onTapGesture(count: 2) {
//                            scene.handleDoubleTap()
//                        }
//                        .gesture(
//                            DragGesture()
//                                .onChanged{ gesture in
//                                    scene.handleDrag(offset: gesture.translation)
//                                }
//                        )
//                } label: { Text("Lab 8: Fog") }
            }.navigationTitle("COMP8051")
        }
    }
    
}

#Preview {
    ContentView()
}
