//
//  CIColorInvert.swift
//  FilterRecipes
//
//  Created by mark lim pak mun on 13/02/2024.
//  Copyright © 2024 Incremental Innovations. All rights reserved.
//
// Reference: Core Image Programming Guide - Chroma Key Filter Recipe

import AppKit
import CoreImage

// All inputs should be prefixed with "input"
class ChromaKeyFilter: CIFilter
{
    // CIColorCube
    var inputImage: CIImage!
    var inputBackgroundImage: CIImage!

    var inputCubeDimension: NSNumber!
    var inputCubeData: Data!

    var inputCenterAngle: NSNumber!         // Both are in degrees
    var inputAngleWidth: NSNumber!

    static let minCubeSize = 2
    static let maxCubeSize = 64
    static let defaultCubeSize = 32

    // There must be an `outputImage` (can be a method) returning an instance of CIImage
    override var outputImage: CIImage? {

        if inputCubeDimension.intValue < 0 {
            return inputImage
        }
        if inputBackgroundImage == nil {
            return inputImage
        }

        let cubeSize = max(min(inputCubeDimension.intValue,
                               ChromaKeyFilter.maxCubeSize),
                           ChromaKeyFilter.minCubeSize)
        var cubeData: [Float] = Array(repeating: 0.0,
                                      count: cubeSize * cubeSize * cubeSize * 4)

        if !buildCubeData(cubeData: &cubeData, cubeSize: cubeSize,
                          centerAngle: inputCenterAngle.floatValue,
                          angleWidth: inputAngleWidth.floatValue) {
            return inputImage
        }
 
        // Create memory with the cube data
/*
         // The call below seems to return the wrong data.
         let data = Data(bytesNoCopy: &cubeData,
                         count: cubeSize*cubeSize*cubeSize*4,
                         deallocator: .none)
 */
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeData,
                                                    count: cubeData.count))

        // Use the CIColorCube filter and the cube map to remove chroma-key color from the source image.
        let colorCubeFilter = CIFilter(name:"CIColorCube",
                                       withInputParameters: [
                "inputCubeDimension": cubeSize,
                "inputCubeData": data,
                kCIInputImageKey : inputImage
            ])

        // The output image will have the green pixels removed
        let coloredKeyedImage = colorCubeFilter?.value(forKey: kCIOutputImageKey)
        colorCubeFilter?.setValue(nil,
                                  forKey: "inputCubeData")
        colorCubeFilter?.setValue(nil,
                                  forKey: kCIInputImageKey)

        // Use the `CISourceOverCompositing` filter to blend the processed source image
        // (greenscreened output) over a background image.
        //  The transparency in the colorcube-filtered image allows the composited
        // background image to show through.
        let sourceOver = CIFilter(name:"CISourceOverCompositing")
        sourceOver?.setValue(coloredKeyedImage,
                             forKey: kCIInputImageKey)
        sourceOver?.setValue(inputBackgroundImage,
                             forKey: kCIInputBackgroundImageKey)
        let outputImage = sourceOver?.value(forKey: kCIOutputImageKey)

        sourceOver?.setValue(nil,
                             forKey: kCIInputImageKey)
        sourceOver?.setValue(nil,
                             forKey: kCIInputBackgroundImageKey)

        return outputImage as? CIImage
    }

    override init()
    {
        super.init()
    }

    // This function must be overridden
    override func setDefaults()
    {
        // The range of green colour values to exclude is 108-144 degrees.
        let centerAngle = 126.0     // Pure Green is 120 degrees
        let  angleWidth = 36.0
        inputCubeDimension = NSNumber(value: ChromaKeyFilter.defaultCubeSize)
        inputCenterAngle = NSNumber(value: centerAngle)
        inputAngleWidth = NSNumber(value: angleWidth)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    // Convert RGB to HSV
    func rgbToHSV(_ rgb: [Float], _ hsv: inout [Float])
    {
        let rgbMin = min(rgb[0], rgb[1], rgb[2])
        let rgbMax = max(rgb[0], rgb[1], rgb[2])
        let delta = rgbMax - rgbMin         // chroma

        let v = rgbMax
        let s = rgbMax == 0.0 ? 0.0 : delta/rgbMax
        var h: Float = 0.0      // h = 0.0 when s == 0.0 - actually h is indeterminate in this case

        if s != 0.0 {
            if rgb[0] == rgbMax {
                h = (rgb[1] - rgb[2])/delta
            }
            else if rgb[1] == rgbMax {
                h = 2.0 + (rgb[2] - rgb[0])/delta
            }
            else if rgb[2] == rgbMax {
                h = 4.0 + (rgb[0] - rgb[1])/delta
            }

            h /= 6.0
            if (h < 0.0) {
                h += 1.0
            }
        }
        hsv[0] = h; hsv[1] = s; hsv[2] = v;
    }

    // Create a cube map of data that maps the color values you want to remove so they are
    // transparent (alpha value is 0.0).
    // Can we call this once during initialization of the filter sub-class?
    func buildCubeData(cubeData: inout [Float],
                       cubeSize: Int,
                       centerAngle: Float,
                       angleWidth: Float) -> Bool
    {

        let minHueAngle: Float = (centerAngle - angleWidth/2.0)/360.0
        let maxHueAngle: Float = (centerAngle + angleWidth/2.0)/360.0
        //print(minHueAngle, maxHueAngle)
        //print(minHueAngle, maxHueAngle)
        var rgb: [Float] = Array(repeating: 0.0, count: 3)
        var hsv: [Float] = Array(repeating: 0.0, count: 3)

        var index = 0
        // Populate cube with a simple gradient going from 0.0 to 1.0
        for z in 0..<cubeSize {
            rgb[2] = Float(z)/(Float(cubeSize-1))           // Blue value
            for y in 0..<cubeSize {
                rgb[1] = Float(y)/(Float(cubeSize-1))       // Green value
                for x in 0..<cubeSize {
                    rgb[0] = Float(x)/(Float(cubeSize-1))   // Red value
                    // Convert RGB to HSV
                    rgbToHSV(rgb, &hsv)

                    // Should have decent HSV values now. (H goes from [0 .. 1])
                    // We should have the test for what colors we render as transparent
                    // based on some set of hue angles; this is not a chroma threshold.
 
                    // Use the hue value (`hueValue`) to determine which to make transparent.
                    // The minimum and maximum hue angle depends on the color you want to remove.
                    let hueValue = hsv[0]
                    let alpha: Float = (hueValue >= minHueAngle && hueValue <= maxHueAngle) ? 0.0 : 1.0
                    // Calculate premultiplied alpha values for the cube
                    cubeData[index] = rgb[0] * alpha; index += 1
                    cubeData[index] = rgb[1] * alpha; index += 1
                    cubeData[index] = rgb[2] * alpha; index += 1
                    cubeData[index] = alpha; index += 1
                }
            }
        }
        return true
    }
}
