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
// see https://github.com/MetalKit/metal
// see https://github.com/nickzman/rainingcubes

import ScreenSaver


@objc(DancingGlyphsView) class DancingGlyphsView : MetalScreenSaverView
{
    struct Settings
    {
        var backgroundColor: NSColor
        var glyph: NSBezierPath
        var glyphColors: [NSColor]
        var glyphSize: Double
    }

    var configuration: Configuration!
    var settings: Settings!
    var renderer: Renderer!
    var animation: Animation!
    var statistics: Statistics!


    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        configuration = Configuration.sharedInstance
        renderer = Renderer(device: device, numTextures: 3, numQuads: 3)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }

 
    override func resize(withOldSuperviewSize oldSuperviewSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSuperviewSize)
        updateSizeAndTextures()
    }
    
    
    // screen saver api
    
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
        settings = configuration.viewSettings

        renderer.backgroundColor = settings.backgroundColor.toMTLClearColor()
        updateSizeAndTextures()

        animation = Animation()
        animation.settings = configuration.animationSettings
        animation.moveToTime(CACurrentMediaTime())

        statistics = Statistics()

        super.startAnimation()
    }
    
    override func stopAnimation()
    {
        super.stopAnimation()

        animation = nil
        statistics = nil
    }

    private func updateSizeAndTextures()
    {
        renderer.setOutputSize(bounds.size)
        for (index, color) in settings.glyphColors.enumerated() {
            let image = makeBitmapImageRepForGlyph(settings.glyph, color:color)
            renderer.setTexture(image: image, at: index)
        }
    }

    private func makeBitmapImageRepForGlyph(_ glyph: NSBezierPath, color: NSColor) -> NSBitmapImageRep
    {
        let imageScale = layer!.contentsScale
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.glyphSize))
        let imageSize = glyphSize * imageScale

        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(imageSize), pixelsHigh: Int(imageSize), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: Int(imageSize)*4, bitsPerPixel:32)!

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: imageRep))

#if false
        let framePath = NSBezierPath()
        framePath.appendRect(NSMakeRect(0, 0, CGFloat(imageSize), CGFloat(imageSize)))
        framePath.appendRect(NSMakeRect(1, 1, CGFloat(imageSize)-2, CGFloat(imageSize)-2))
        NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1).set()
        framePath.stroke()
#endif
        let safety: CGFloat = 0.018
        let glyphPath = glyph.copy() as! NSBezierPath
        glyphPath.transform(using: AffineTransform(scaleByX: (1 - 2 * safety), byY: (1 - 2 * safety)))
        glyphPath.transform(using: AffineTransform(translationByX: safety, byY: safety))
        glyphPath.transform(using: AffineTransform(scaleByX: 1, byY: -1))
        glyphPath.transform(using: AffineTransform(translationByX: 0, byY: 1))
        glyphPath.transform(using: AffineTransform(scaleByX: imageSize, byY: imageSize))
        color.set()
        glyphPath.fill()

        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }


    override func animateOneFrame()
    {
        autoreleasepool {
            statistics.viewWillStartRenderingFrame()

            animation.moveToTime(CACurrentMediaTime() * (self.isPreview ? 1.5 : 1))

            renderer.beginUpdatingQuads()
            updateQuads()
            renderer.finishUpdatingQuads()

            let metalLayer = layer as! CAMetalLayer
            if let drawable = metalLayer.nextDrawable() { // TODO: can this really happen?
                renderer.renderFrame(drawable: drawable)
            }

            statistics.viewDidFinishRenderingFrame()
        }
    }

    private func updateQuads()
    {
        let screenCenter = Vector2(Float(bounds.size.width/2), Float(bounds.size.height/2))
        let glyphSize = Float(floor(min(bounds.width, bounds.height) * CGFloat(settings.glyphSize)))
        let w = glyphSize
        let h = glyphSize

        let animationState = animation.currentState!
        let positions = [animationState.p0, animationState.p1, animationState.p2]
        let rotations = [animationState.r0, animationState.r1, animationState.r2]

        for i in 0...2 {
            let glyphCenter = Vector2(Float(positions[i].x), Float(positions[i].y)) * glyphSize + screenCenter
            let rotationMatrix = Matrix2x2(rotation: Float(rotations[i]))

            let a = glyphCenter + Vector2(-w/2, +h/2) * rotationMatrix
            let b = glyphCenter + Vector2(-w/2, -h/2) * rotationMatrix
            let c = glyphCenter + Vector2(+w/2, -h/2) * rotationMatrix
            let d = glyphCenter + Vector2(+w/2, +h/2) * rotationMatrix

            renderer.updateQuad((a, b, c, d), textureId: i, at:i)
        }
    }

}

