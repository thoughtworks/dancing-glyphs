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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    func addLayers(config: DancingGlyphsView.Settings)
    {
        glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(config.size))
        let backgroundLayer = createBackgroundLayer()
        for color in config.glyphColors {
            let image = createImageForGlyph(config.glyph, color: color)
            let filter = CIFilter(name: config.filter)!
            let layer = createLayerForImage(image, filter: filter)
            backgroundLayer.addSublayer(layer)
        }
        self.layer = backgroundLayer
    }

    func createBackgroundLayer() -> CALayer
    {
        let layer = CALayer()
        layer.bounds = self.bounds
        layer.opacity = 1
        return layer
    }

    func createLayerForImage(image: NSImage, filter: CIFilter) -> CALayer
    {
        let layer = CALayer()
        
        layer.bounds = NSRect(origin:NSMakePoint(0,0), size:image.size)
        let scale = image.recommendedLayerContentsScale(window!.backingScaleFactor)
        layer.contents = image.layerContentsForContentsScale(scale)
        layer.contentsScale = scale
        layer.contentsGravity = kCAGravityBottomLeft
        layer.opacity = 0.94
        layer.compositingFilter = filter
        layer.actions = [ "position": NSNull(), "transform": NSNull() ]
        
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
        path.transformUsingAffineTransform(transform)
        color.set()
        path.fill()

        image.unlockFocus()

        return image
    }
    

    func applyAnimationState(state: Animation.State)
    {
        let sublayers = self.layer!.sublayers!

        sublayers[0].position = screenpos(state.p0)
        sublayers[1].position = screenpos(state.p1)
        sublayers[2].position = screenpos(state.p2)

        sublayers[0].transform = CATransform3DMakeRotation(CGFloat(state.r0), 0.0, 0.0, 1.0)
        sublayers[1].transform = CATransform3DMakeRotation(CGFloat(state.r1), 0.0, 0.0, 1.0)
        sublayers[2].transform = CATransform3DMakeRotation(CGFloat(state.r2), 0.0, 0.0, 1.0)
    }

    func screenpos(p: (x: Double, y: Double)) -> NSPoint
    {
        let x = bounds.size.width/2  + CGFloat(p.x)*glyphSize
        let y = bounds.size.height/2 + CGFloat(p.y)*glyphSize
        return NSMakePoint(CGFloat(x), CGFloat(y))
    }

}

