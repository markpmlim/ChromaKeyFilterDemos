import AppKit
import CoreImage


extension CIImage
{
    convenience init?(nsImage: NSImage)
    {
        var proposeRect = NSZeroRect
        guard let cgImage = nsImage.cgImage(forProposedRect: &proposeRect,
                                            context: nil,
                                            hints: nil)
            else {
                return nil
        }
        self.init(cgImage: cgImage)
    }
}

extension NSImage
{
    convenience init?(ciImage: CIImage)
    {
        // First, we create an NSCIImageRep object from the CIImage object.
        // The class NSCIImageRep is a sub-class of NSImageRep.
        let imageRep = NSCIImageRep(ciImage: ciImage)
        let size = imageRep.size
        //Create an initialized NSImage object with no rendered content.
        self.init(size: size)
        self.addRepresentation(imageRep)
    }
}

/*
 Where all the code is
 KIV. To add a slider to input the radius
 */
public class ViewController: NSViewController
{

    private lazy var sourceImage: NSImage = {
        let image = NSImage(named: "JetFighter.png")!
        return image
    }()

    private lazy var backgroundImage: NSImage = {
        let image = NSImage(named: "Background.jpg")!
        return image
    }()

    private lazy var imageView: NSImageView = {
        let viewWidth = self.view.frame.width
        let viewHeight = self.view.frame.height
        print(viewWidth)
        let frameRect = NSRect(x: 0, y: 30,
                               width: viewWidth, height: viewHeight-20)
        let imageView = NSImageView(frame: frameRect)
        imageView.image = self.sourceImage
        return imageView
    }()

    var ciContext: CIContext!
    var inputImage: CIImage!
    var inputRadius = NSNumber(value: 10.0)

    // Appear to be unnecessary.
    override public var acceptsFirstResponder: Bool {
        return true
    }

    // Overriding this function is neccessary for playgrounds
    override public func loadView()
    {
        let frameRect = NSRect(x: 0, y: 0, width: 480, height: 270)
        // Every view controller has a built-in view.
        self.view = NSView(frame: frameRect)
        // Not used.
        ciContext = CIContext()
    }
    
    override public func viewDidLoad()
    {
        prepareView()
        inputImage = CIImage(nsImage: sourceImage)
        applyFilters()
    }

    // Add more UI controls here if necessary.
    func prepareView()
    {
        self.view.addSubview(imageView)
    }

    func applyFilters()
    {
        let startAngle = 108.0
        let endAngle = 144.0
        let filter = chromaKeyFilter(fromHue: CGFloat(startAngle/360.0),
                                     toHue: CGFloat(endAngle/360.0))
        filter?.setValue(inputImage, forKey: kCIInputImageKey)

        let sourceCIImageWithoutBackground = filter?.outputImage
        let backgroundCIImage = CIImage(nsImage: backgroundImage)

        let compositor = CIFilter(name:"CISourceOverCompositing")
        compositor?.setValue(sourceCIImageWithoutBackground,
                             forKey: kCIInputImageKey)
        compositor?.setValue(backgroundCIImage,
                             forKey: kCIInputBackgroundImageKey)
        let compositedCIImage = compositor?.outputImage
        imageView.image = NSImage(ciImage: compositedCIImage!)
    }

    // Get hue function
    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat
    {
        let color = NSColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }

    // Create Chroma Key Filter function
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter?
    {
        // 1
        let size = 64
        var cubeRGB = [Float]()

        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)

                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1

                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }

        // The following method does not work.
        // init(bytesNoCopy:count:deallocator:)
        // The method init(bytes:count:) works.
        // The method below is not documented on macOS 10.12
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB,
                                                    count: cubeRGB.count))
        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube",
                                       withInputParameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
}
