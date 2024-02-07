# COMP 8051 Assignment 1

This README provides an overview of the features and functionality of the iOS Cube App. The app displays a rotating cube with customizable colors, touch interactions, and additional enhancements.
## Features:

    1. Single Cube Display:
        * The app showcases a single cube rendered in perspective projection.
        * Each side of the cube has a distinct color, as demonstrated in class.

    2. Rotation Toggle:
        * Double-tapping the cube toggles continuous rotation about the y-axis.
        * When rotation is disabled, users can interact with the cube using touch gestures.

    3. Touch Interaction:
        * When the cube is stationary:
            * Single-finger drag allows users to rotate the cube about two axes.
            * Pinching (two-finger gesture) zooms in and out of the cube.
            * Two-finger dragging moves the cube within the view.

    4. Reset Button:
        * A dedicated button resets the cube to its default position: (0, 0, 0) with the default orientation.

    5. Position and Rotation Label:
        * A continuously updating label displays the cube’s current position (x, y, z) and rotation angles.

    6. Second Rotating Cube:
        * An additional cube, separate from the first one, is included.
        * This second cube has distinct textures applied to each side.
        * It continuously rotates, even when the first cube is not auto-rotating.

    7. Lighting Effects:
        * The app features three types of lighting:
            * Flashlight: Provides directional illumination.
            * Ambient Light: Creates overall scene brightness.
            * Diffuse Light: Enhances surface details.
        * Toggle buttons allow users to control each light source individually.

## Requirements:

    * iOS device running at least iOS 14.0.

## Getting Started:

    1. Clone this repository.
    2. Open the Xcode project.
    3. Build and run the app on your iOS device.
