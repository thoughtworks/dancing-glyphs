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

import Cocoa

class GlyphLayerView : NSView
{
    var glyphSize: CGFloat = 0

    override init(frame: NSRect)
    {
        super.init(frame: frame)
        wantsLayer = true
        layerUsesCoreImageFilters = true
        glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(SIZE)) // TODO: recalc when size changes
        addLayers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func addLayers()
    {
        let glyph = NSBezierPath.TWSquareGlyphPath()
        let colors = [ NSColor.TWLightGreenColor(), NSColor.TWHotPinkColor(), NSColor.TWTurquoiseColor() ]

        let backgroundLayer = createBackgroundLayer()
        for color in colors {
            let image = createImageForGlyph(glyph, color: color)
            let layer = createLayerForImage(image)
            backgroundLayer.addSublayer(layer)
        }
        self.layer = backgroundLayer
    }

    func createBackgroundLayer() -> CALayer
    {
        let layer = CALayer()
        layer.bounds = self.bounds
        layer.opacity = 1
//        layer.contents = createBackgroundImage(BGCOLOR)
//        layer.opaque = true
        return layer
    }

    func createLayerForImage(image: NSImage) -> CALayer
    {
        let layer = CALayer()

        layer.bounds = NSRect(origin:NSMakePoint(0,0), size:image.size)
        layer.contents = image
        layer.contentsScale = 1  // TODO: how do we get retina config in here?
        layer.contentsGravity = kCAGravityBottomLeft
        layer.opacity = DARKMODE ? 0.80 : 0.94
        layer.compositingFilter = DARKMODE ? CIFilter(name: "CILinearDodgeBlendMode") : CIFilter(name: "CIColorBurnBlendMode")!

        return layer
    }

    func createImageForGlyph(glyph: NSBezierPath, color: NSColor) -> NSImage
    {
        let overscan = CGFloat(0.05) // the glyph is a little bigger than 1x1
        let imageSize = floor(glyphSize * (1 + overscan))

        let image = NSImage(size: NSMakeSize(imageSize, imageSize))
        image.lockFocus()

        let path = glyph.copy()
        let transform = NSAffineTransform()
        transform.scaleXBy(glyphSize, yBy: glyphSize)
        transform.translateXBy(0.5 + overscan/2, yBy: 0.5 + overscan/2)
        transform.scaleXBy(1, yBy: -1) // must be flipped on x axis
        path.transformUsingAffineTransform(transform)
        color.set()
        path.fill()

        image.unlockFocus()

        return image
    }

    func createBackgroundImage(color: NSColor) -> NSImage
    {
        let image = NSImage(size: self.bounds.size) // TODO: check whether image without alpha channel is faster than no image
        image.lockFocus()

        let path = NSBezierPath()
        path.appendBezierPathWithRect(bounds)
        color.set()
        path.fill()

        image.unlockFocus()

        return image
    }


    func applyAnimationState(state: AnimationState)
    {
        let sublayers = self.layer!.sublayers!

        CATransaction.begin()  // TODO: check whether permanently disabling animations is more efficient
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)

        sublayers[0].position = screenpos(state.p0)
        sublayers[1].position = screenpos(state.p1)
        sublayers[2].position = screenpos(state.p2)

        sublayers[0].transform = CATransform3DMakeRotation(CGFloat(state.r0), 0.0, 0.0, 1.0)
        sublayers[1].transform = CATransform3DMakeRotation(CGFloat(state.r1), 0.0, 0.0, 1.0)
        sublayers[2].transform = CATransform3DMakeRotation(CGFloat(state.r2), 0.0, 0.0, 1.0)

        CATransaction.commit()
    }

    func screenpos(p: (x: Double, y: Double)) -> NSPoint
    {
        let x = bounds.size.width/2  + CGFloat(p.x)*glyphSize
        let y = bounds.size.height/2 + CGFloat(p.y)*glyphSize
        return NSMakePoint(CGFloat(x), CGFloat(y))
    }

    
    
}

