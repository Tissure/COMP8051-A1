//====================================================================
//
// (c) Borna Noureddin
// COMP 8051   British Columbia Institute of Technology
// Lab01: Draw red square using SceneKit
// Lab02: Make an auto-rotating cube with different colours on each side
// Lab03: Make a rotating cube with a crate texture that can be toggled
//
//====================================================================

import SwiftUI
import SceneKit
import SpriteKit

struct ContentView: View {
    @State var rotationOffset = CGSize.zero
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink{
                    @ObservedObject var scene = DraggableRotatingCube()
                    ZStack{
                        VStack{
                            SceneView(scene: scene, pointOfView: scene.cameraNode)
                                .ignoresSafeArea()
                                .onTapGesture(count: 2) {
                                    scene.handleDoubleTap()
                                }.gesture(
                                    DragGesture().onChanged{ value in
                                        scene.handleDrag(value.translation)
                                    }
                                )
                                .gesture(
                                    MagnifyGesture()
                                        .onChanged{value in
                                            scene.handlePinch(value.magnification)
                                            
                                        })
                                .gesture(
                                    DragGesture().simultaneously(
                                        with: MagnifyGesture())
                                        .onChanged{value in
                                            scene.handleDoubleDrag(value.first?.translation  ?? CGSize.zero)
                                            
                                        }
                                )
                                                            
                            Group{
                                Text(scene.positionText)
                                    .foregroundStyle(.red).font(.system(size: 20))
                                Text(scene.rotationText)
                                    .foregroundStyle(.red).font(.system(size: 20))
                            }
                            HStack{
                                Button(action: {
                                    scene.toggleLights(1)
                                }){
                                    Text("1").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    scene.toggleLights(2)
                                }){
                                    Text("2").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    scene.toggleLights(3)
                                }){
                                    Text("3").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                                Button(action: {
                                    scene.resetCube()
                                }){
                                    Text("Reset Cube").font(.system(size: 24))
                                }.buttonStyle(.bordered)
                            }
                        }
                        
                    }
                } label: { Text("Assignment 1") }
                NavigationLink{
                    let scene = RedSquare()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                } label: { Text("Lab 1: Red square") }
                NavigationLink{
                    let scene = RotatingColouredCube()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                } label: { Text("Lab 2: Rotating cube") }
                NavigationLink{
                    let scene = RotatingCrate()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                } label: { Text("Lab 3: Textured cube") }
                NavigationLink{
                    let scene = ControlableRotatingCrate()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 4: Rotatable cube") }
                NavigationLink{
                    let scene = ControlableRotatingCrateWithText()
                    ZStack {
                        SceneView(scene: scene, pointOfView: scene.cameraNode)
                            .ignoresSafeArea()
                            .onTapGesture(count: 2) {
                                scene.handleDoubleTap()
                            }
                            .gesture(
                                DragGesture()
                                    .onChanged{ gesture in
                                        scene.handleDrag(offset: gesture.translation)
                                    }
                            )
                        Text("Hello World")
                            .foregroundStyle(.white)
                    }
                } label: { Text("Lab 5: Text examples") }
                NavigationLink{
                    let scene = RotatingCrateLight()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 6: Diffuse lighting") }
                NavigationLink{
                    let scene = RotatingCrateFlashlight()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 7: Spotlight (flashlight)") }
                NavigationLink{
                    let scene = RotatingCrateFog()
                    SceneView(scene: scene, pointOfView: scene.cameraNode)
                        .ignoresSafeArea()
                        .onTapGesture(count: 2) {
                            scene.handleDoubleTap()
                        }
                        .gesture(
                            DragGesture()
                                .onChanged{ gesture in
                                    scene.handleDrag(offset: gesture.translation)
                                }
                        )
                } label: { Text("Lab 8: Fog") }
            }.navigationTitle("COMP8051")
        }
    }
    
}

#Preview {
    ContentView()
}
