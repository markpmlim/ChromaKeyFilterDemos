## Chroma Key Filter Recipe

<br />
<br />


The source code of this demo is based on Apple's available documentation, online or distributed with XCode 8.x.

<br />
<br />

**Expected Output:**

![](Documentation/ChromaKeyFilter.png)

<br />
<br />

Added a Swift playground to this repository. Its source code is based on Apple's online ChromaKey Effect article.

<br />
<br />

![](Documentation/PlaygroundOutput.png)

Added a Quartz Composition to this repository.

<br />
<br />

![](Documentation/QuartzOutput.png)

Added a macOS application implementing CIFilter to this repository. The source code of the kernel is a modified version of GSChromaFilter.cikernel from Apple's AVGreenScreenPlayer.

<br />
<br />

![](Documentation/GreenScreenFilter.png)

Added a macOS application implementing CIFilter in a metal shader to this repository. 

![](Documentation/ChromaKeyFIlterMetal.png)

<br />
<br />

**Requirements:**

XCode 8.x, Swift 3.0

Deployment Target: macOS 10.12.

The Metal demo requires 

XCode 9.x, Swift 4.1

<br />
<br />

**References:**

1) Core Image Programming Guide.

https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/CoreImaging/ci_filer_recipes/ci_filter_recipes.html#/

<br />
<br />

2) Latest online documentation on Chroma Key Effect:

https://developer.apple.com/documentation/coreimage/applying_a_chroma_key_effect

<br />
<br />

3) CIFunHouse - ChromaKey module.

https://developer.apple.com/library/etc/redirect/xcode/content/1189/samplecode/CIFunHouse/Introduction/Intro.html

<br />
<br />


**Acknowledgements** due to whoever had made the 2 graphic files available.
