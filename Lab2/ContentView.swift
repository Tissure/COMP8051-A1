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
        let velocity = recognizer.velocity(in: self)
        switch (recognizer.numberOfTouches) {
        case 1:
            mainScene?.handleDrag(velocity)
            break
        case 2:
            mainScene?.handleDoubleDrag(velocity)
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
                                Text("Position: " + mainScene.positionText)
                                    .foregroundStyle(.red).font(.system(size: 20))
                                Text("Rotation: " + mainScene.rotationText)
                                    .foregroundStyle(.red).font(.system(size: 20))
                            }
                            HStack{
                                Button(action: {
                                    mainScene.toggleLights(1)
                                }){
                                    Text("Ambient").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    mainScene.toggleLights(2)
                                }){
                                    Text("Diffuse").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    mainScene.toggleLights(3)
                                }){
                                    Text("Spot").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                
                            }
                            Button(action: {
                                mainScene.resetCube()
                            }){
                                Text("Reset Cube").font(.system(size: 24))
                            }.buttonStyle(.bordered)
                        }
                        
                    }
                } label: { Text("Assignment 1") }
            }.navigationTitle("COMP8051")
        }
    }
    
}

#Preview {
    ContentView()
}
