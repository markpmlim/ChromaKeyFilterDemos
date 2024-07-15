//
//  ViewController.swift
//  ChromaKeyFilter
//
//  Created by mark lim pak mun on 13/02/2024.
//  Copyright © 2024 Incremental Innovations. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{
    var imageView: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageView = self.view as! NSImageView
        //Swift.print(imageView)
        // Load the image
        guard let image = NSImage(named: "JetFighter.png")
        else {
            fatalError("Can't load background image")
        }
        // Step 1: Create a Core Image image object for the input image.
        // First, we create a Core Graphics object (aka Quartz 2D image)
        guard let cgImage = image.cgImage(forProposedRect: nil,
                                          context: nil,
                                          hints: nil)
        else {
            fatalError("Can't create foreground CIImage")
        }
        // Then, we create an instance of CIImage from the Core Graphics object.
        let inputImage = CIImage(cgImage: cgImage)

        guard let backGroundImage = NSImage(named: "BackGround.tga")
        else {
            fatalError("Can't load background image")
        }

        guard let cgImage2 = backGroundImage.cgImage(forProposedRect: nil,
                                                     context: nil,
                                                     hints: nil)
        else {
            fatalError("Can't create background CIImage")
        }
        let inputBackGroundImage = CIImage(cgImage: cgImage2)

        // Create and setup the Chroma Key Filter
        let chromaKeyFilter = ChromaKeyFilter()
        chromaKeyFilter.setDefaults()
        chromaKeyFilter.inputImage = inputImage
        chromaKeyFilter.inputBackgroundImage = inputBackGroundImage
        // The defaults
        //chromaKeyFilter.inputCubeDimension = NSNumber(value: 64)
        //chromaKeyFilter.inputCenterAngle = NSNumber(value: 126.0)
        //chromaKeyFilter.inputAngleWidth = NSNumber(value: 36.0)
        //Swift.print(chromaKeyFilter)      // debugging

        // Apply the filter to the image and instantiate an
        // instance of NSImage.
        let imageRep = NSCIImageRep(ciImage: chromaKeyFilter.outputImage!)
        let nsImage = NSImage(size: imageRep.size)
        nsImage.addRepresentation(imageRep)
        imageView.image = nsImage
    }

    override var representedObject: Any? {
        didSet {
        }
    }

}

