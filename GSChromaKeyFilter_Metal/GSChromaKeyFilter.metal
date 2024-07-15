//
//  GSChromaKeyFilter.metal
//
//  Created by mark lim pak mun on 26/12/2023.
//  Copyright © 2023 Apple Inc. All rights reserved.


#include <metal_stdlib>
using namespace metal;

// Port of Chromakey kernel from Apple's GreenScreen Player.
#include <CoreImage/CoreImage.h>
extern "C"
{
    namespace coreimage
    {
        float3 normalizeColor(float3 color, float meanr)
        {
            return (color * float3(0.75 + meanr, 1.0, 1.0 - meanr));
        }

        float4 apply(sampler inputImage,
                     sampler inputBackgroundImage,
                     float4 inputColor,
                     float inputThreshold)
        {
            float4 outputColor;

            float4 foregroundColor = inputImage.sample(inputImage.coord());

            float4 backgroundColor = inputBackgroundImage.sample(inputBackgroundImage.coord());

            float meanr = ((foregroundColor.r + inputColor.r) / 8.0);

            float dist = distance(normalizeColor(foregroundColor.rgb, meanr),
                                  normalizeColor(inputColor.rgb, meanr));

            outputColor = (dist > inputThreshold ? foregroundColor : backgroundColor);

            return outputColor;
        }
    }
}


