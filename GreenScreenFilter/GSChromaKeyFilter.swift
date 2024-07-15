//
//  GSChromaKeyFilter.swift
//  GreenScreenFilter
//
//  Created by mark lim pak mun on 14/07/2024.
//  Copyright © 2024 Incremental Innovations. All rights reserved.
//

import CoreImage

class GSChromaKeyFilter: CIFilter
{
    var inputImage: CIImage?
    var inputBackgroundImage: CIImage?
    var inputColor = CIVector(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
    var inputThreshold: NSNumber = 0.7
    
    private lazy var greenScreenKernel: CIColorKernel? = {
        guard
            let path = Bundle.main.path(forResource: "GSChromaKeyFilter",
                                        ofType: "cikernel"),
            let code = try? String(contentsOfFile: path)
            else {
                fatalError("Failed to load GSChromaKeyFilter.cikernel from bundle")
        }
        guard let kernel = CIColorKernel(string: code)
        else {
            return nil
        }
        return kernel
    }()

    // In Objective-C, this method is named `customeAttributes`
    // Listing 9-4  The customAttributes method for the Haze filter
    override var attributes: [String : Any] {
        return [
            kCIAttributeFilterDisplayName: "chromaKey" as Any,
            
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image",
                           kCIAttributeType: kCIAttributeTypeImage],
            
            "inputBackgroundImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "BackgroundImage",
                           kCIAttributeType: kCIAttributeTypeImage],

            "inputColor": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIVector",
                           kCIAttributeDisplayName: "Chroma Color",
                           kCIAttributeDefault: CIVector(x: 0.0, y: 1.0, z: 0.0, w: 1.0),
                           kCIAttributeType: kCIAttributeTypeColor],
            
            "inputThreshold": [kCIAttributeIdentity: 0,
                               kCIAttributeClass: "NSNumber",
                               kCIAttributeDisplayName: "Threshold value",
                               kCIAttributeDefault: 0.0,
                               kCIAttributeMin: 0,
                               kCIAttributeSliderMin: 0.4,
                               kCIAttributeSliderMax: 0.8,
                               kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    override var outputImage: CIImage? {
        get {
            guard
                let inputImage = self.inputImage,
                let inputBackgroundImage = self.inputBackgroundImage
            else {
                return nil
            }
            // Set up a sampler to fetch pixels from the input image
            let src  = CISampler(image: inputImage)
            let background =  CISampler(image: inputBackgroundImage)
            return self.apply(greenScreenKernel!,
                              arguments: [src as Any,
                                          background as Any,
                                          inputColor,
                                          inputThreshold],
                              options: [kCIApplyOptionDefinition : src.definition])
        }
    }
}

