//
//  ViewController.swift
//  GreenScreenFilter
//
//  Created by mark lim pak mun on 14/07/2024.
//  Copyright © 2024 Incremental Innovations. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{
    var imageView: NSImageView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        imageView = self.view as! NSImageView

        // Load the image
        guard let image = NSImage(named: "JetFighter.png")
        else {
            fatalError("Can't load foreground image")
        }
        // Create a Core Graphics object for the input image.
        // First, we create a Core Graphics object (aka Quartz 2D image)
        guard let cgImage = image.cgImage(forProposedRect: nil,
                                          context: nil,
                                          hints: nil)
        else {
            fatalError("Can't create foreground CGImage")
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
            fatalError("Can't create background CGImage")
        }
        let inputBackGroundImage = CIImage(cgImage: cgImage2)

        // Create and setup the Green Screen Chroma Key Filter
        let chromaKeyFilter = GSChromaKeyFilter()
        chromaKeyFilter.inputImage = inputImage
        chromaKeyFilter.inputBackgroundImage = inputBackGroundImage

        // Convert the output of the filter to an instance of NSImage
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

