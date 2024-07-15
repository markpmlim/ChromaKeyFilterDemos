// ChromaKeyFilter - based on Apple's code
/*
 Reference: Core Image Programming Guide: Chroma Key Filter Recipe
 https://developer.apple.com/documentation/coreimage/applying_a_chroma_key_effect
 */
import Cocoa
import PlaygroundSupport	// for the live preview


let vc = ViewController()
// Only view and view controllers are supported since their classes adopts the PlaygroundLiveViewable protocol
PlaygroundPage.current.liveView = vc


