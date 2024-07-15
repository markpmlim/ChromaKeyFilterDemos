//
//  GSChromaKeyFilter.swift
//  GSChromaKeyFilter_Metal
//
//  Created by Mark Lim Pak Mun on 23/03/2023.
//  Copyright © 2023 Mark Lim Pak Mun. All rights reserved.
//

import Foundation
import CoreImage

class GSChromaKeyFilter: CIFilter
{
    private lazy var kernel: CIKernel = {
        guard let url = Bundle.main.url(forResource: "default",
                                        withExtension: "metallib"),
              let data = try? Data(contentsOf: url) else {
            fatalError("Unable to load metallib")
        }

        let name = "apply"
        // Requires 10.13 or later
        guard let kernel = try? CIKernel(functionName: name,
                                         fromMetalLibraryData: data)
        else {
            fatalError("Unable to create the CIColorKernel for filter \(name)")
        }

        return kernel
    }()

    var inputImage: CIImage?
    var inputColor = CIVector(x: 0.0, y: 1.0, z: 0.0, w: 1.0)
    var inputBackgroundImage: CIImage?
    var inputThreshold: NSNumber = 0.7

    override var outputImage: CIImage? {
        guard
            let inputImage = self.inputImage,
            let inputBackgroundImage = self.inputBackgroundImage
        else {
            return .none
        }
        let inputSampler = CISampler(image: inputImage)
        let backGroundSampler = CISampler(image: inputBackgroundImage)
        let imageExtent = inputImage.extent

        return kernel.apply(extent: inputImage.extent,
                            roiCallback: {
                (index, rect) -> CGRect in
                return rect},
                            arguments: [inputSampler, backGroundSampler, inputColor, inputThreshold]
        )
    }
}
