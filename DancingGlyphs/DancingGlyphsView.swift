/*
 *  Copyright 2016 Erik Doernenburg
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */

// see https://www.raywenderlich.com/77488/ios-8-metal-tutorial-swift-getting-started
// see https://www.raywenderlich.com/90592/liquidfun-tutorial-2
// see http://stackoverflow.com/questions/27967170/rendering-quads-performance-with-metal
// see https://github.com/nickzman/rainingcubes

import ScreenSaver


@objc(DancingGlyphsView) class DancingGlyphsView : ScreenSaverView
{
    struct Settings
    {
        var glyph: NSBezierPath
        var glyphColors: [NSColor]
        var backgroundColor: NSColor
        var filter: String
        var size: Double
    }

    var settings: Settings!
    var renderer: Renderer!
    var displayLink: CVDisplayLink!
    var animation: Animation!
    var statistics: Statistics!

    var glyphSizeScreen: Float = 0


    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        renderer = Renderer(numGlyphs: 3)
        wantsLayer = true;
        animationTimeInterval = 1/60
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

    override func viewDidMoveToSuperview()
    {
        // deferred initialisations that require access to the window
        super.viewDidMoveToSuperview()
        if let window = superview?.window {
            layer = createMetalLayer(window: window)
            displayLink = createDisplayLink(window: window)
        }
    }
    
    
    // screen saver api
    
    override class func backingStoreType() -> NSBackingStoreType
    {
        return NSBackingStoreType.retained
    }
    
    override class func performGammaFade() -> Bool
    {
        return false
    }
    
    
    override func hasConfigureSheet() -> Bool
    {
        return true
    }
    
    override func configureSheet() -> NSWindow?
    {
        let controller = ConfigureSheetController.sharedInstance
        controller.loadConfiguration()
        return controller.window
    }
    

    override func startAnimation()
    {
        // we're not calling super because we need to set up our own timer for the animation
        
        let configuration = Configuration()
        settings = configuration.viewSettings

        renderer.setOutputSize(bounds.size)
        renderer.backgroundColor = settings.backgroundColor.toMTLClearColor()
        for (index, color) in settings.glyphColors.enumerated() {
            let image = makeBitmapImageRepForGlyph(settings.glyph, color:color)
            renderer.setTexture(image: image, at: index)
        }

        animation = Animation()
        animation.settings = configuration.animationSettings
        animation.moveToTime(CACurrentMediaTime())

        statistics = Statistics()

        CVDisplayLinkStart(displayLink!)
    }
    
    override func stopAnimation()
    {
        // we're not calling super because we didn't do it in startAnimation()

        CVDisplayLinkStop(displayLink!)

        animation = nil
        statistics = nil
    }
    
    
    override func animateOneFrame()
    {
        autoreleasepool {
            statistics.viewWillStartRenderingFrame()

            let now = CACurrentMediaTime()
            animation.moveToTime(now * (self.isPreview ? 1.5 : 1))

            updateQuadPositions()

            let metalLayer = layer as! CAMetalLayer
            if let drawable = metalLayer.nextDrawable() { // TODO: can this really happen?
                renderer.renderFrame(drawable: drawable)
            }

            statistics.viewDidFinishRenderingFrame()
        }
    }
    

    // functions called when view is added to view hierarchy

    func createMetalLayer(window: NSWindow) -> CAMetalLayer
    {
        let metalLayer = CAMetalLayer()
        metalLayer.device = renderer.device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.contentsScale = window.backingScaleFactor
        metalLayer.isOpaque = true
        return metalLayer
    }
    

    func createDisplayLink(window: NSWindow) -> CVDisplayLink
    {
        func displayLinkOutputCallback(_ displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            unsafeBitCast(displayLinkContext, to: DancingGlyphsView.self).animateOneFrame()
            return kCVReturnSuccess
        }

        var link: CVDisplayLink?
        let screensID = UInt32(window.screen!.deviceDescription["NSScreenNumber"] as! Int)
        CVDisplayLinkCreateWithCGDisplay(screensID, &link)
        CVDisplayLinkSetOutputCallback(link!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        return link!
    }


    // functions called when animation starts
    
    func makeBitmapImageRepForGlyph(_ glyph: NSBezierPath, color: NSColor) -> NSBitmapImageRep
    {
        let imageScale = layer!.contentsScale
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.size))
        let overscan = CGFloat(0.05) // the glyph is a little bigger than 1x1
        let imageSize = Int(floor(glyphSize * (1 + overscan)) * imageScale)
        glyphSizeScreen = Float(imageSize) / Float(imageScale) // TODO: it's a bit odd to set this here...
        
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: imageSize, pixelsHigh: imageSize, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: imageSize*4, bitsPerPixel:32)!
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: imageRep))
#if false
        let framePath = NSBezierPath()
        framePath.appendRect(NSMakeRect(0, 0, CGFloat(imageSize), CGFloat(imageSize)))
        framePath.appendRect(NSMakeRect(1, 1, CGFloat(imageSize)-2, CGFloat(imageSize)-2))
        NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).set()
        framePath.stroke()
#endif
        let glyphPath = glyph.copy() as! NSBezierPath
        var transform = AffineTransform.identity
        transform.scale(x: glyphSize * CGFloat(imageScale), y: glyphSize * CGFloat(imageScale))
        transform.translate(x: 0.5 + overscan/2, y: 0.5 + overscan/2)
        glyphPath.transform(using: transform)
        color.set()
        glyphPath.fill()
        
        NSGraphicsContext.restoreGraphicsState()

        return imageRep
    }
    

    // functions called for every frame

    func updateQuadPositions()
    {
        renderer.beginFrame()
        let animationState = animation.currentState!
        
        renderer.updateQuad(corners: corners(screenpos(animationState.p0)), at:0)
        renderer.updateQuad(corners: corners(screenpos(animationState.p1)), at:1)
        renderer.updateQuad(corners: corners(screenpos(animationState.p2)), at:2)
    }

    func screenpos(_ p: (x: Double, y: Double)) -> (Float, Float)
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.size))
        let x = bounds.size.width/2  + CGFloat(p.x)*glyphSize
        let y = bounds.size.height/2 + CGFloat(p.y)*glyphSize
        return (Float(x), Float(y))
    }

    func corners(_ p: (Float, Float)) -> ((Float, Float), (Float, Float))
    {
        let (x, y) = p
        let w = glyphSizeScreen
        let h = glyphSizeScreen
        return ((x-w/2, y-h/2), (x+w/2, y+h/2))
    }

}

 
 
