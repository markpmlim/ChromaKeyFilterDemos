//
//  ViewController.swift
//  GSChromaKeyFilter_Metal
//
//  Created by Mark Lim Pak Mun on 15/07/2024.
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

        guard let image = NSImage(named: NSImage.Name(rawValue: "JetFighter"))
        else {
            fatalError("Can't load graphic")
        }
        let inputImage = CIImage(nsImage: image)

        guard let image2 = NSImage(named: NSImage.Name(rawValue: "BackGround"))
        else {
            fatalError("Can't load graphic")
        }
        let inputBackgroundImage = CIImage(nsImage: image2)

        let filter = GSChromaKeyFilter()
        filter.inputImage = inputImage
        filter.inputBackgroundImage = inputBackgroundImage
        let output = filter.outputImage!

        // Convert the output of the filter to an instance of NSImage
        let imageRep = NSCIImageRep(ciImage: output)
        let nsImage = NSImage(size: imageRep.size)
        nsImage.addRepresentation(imageRep)
        imageView.image = nsImage
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

}

extension CIImage
{
    convenience init?(nsImage: NSImage)
    {
        guard let cgImage = nsImage.cgImage(forProposedRect: nil,
                                            context: nil,
                                            hints: nil)
        else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
}
