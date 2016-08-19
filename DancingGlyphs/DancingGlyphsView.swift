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

// see http://www.raywenderlich.com/74438/swift-tutorial-a-quick-start
// see http://stackoverflow.com/questions/27852616/do-swift-screensavers-work-in-mac-os-x-before-yosemite

import ScreenSaver

class DancingGlyphsView : ScreenSaverView
{
    var layerView: GlyphLayerView!
    
    var now: Double = 1
    var lastCheckpoint: Double = 0
    var frames: Int = 0
    
    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        animationTimeInterval = 1/60
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override func drawRect(rect: NSRect)
    {
        super.drawRect(rect)
        //        NSColor.blackColor().setFill()
        NSColor.TWGrayColor().lighter(0.1).setFill()
        NSRectFill(bounds)
    }
    
    
    override func hasConfigureSheet() -> Bool
    {
        return false
    }
    
    override func configureSheet() -> NSWindow?
    {
        return nil
    }
    
    
    override func startAnimation()
    {
        super.startAnimation()
        
        // make view a bit smaller so we don't overlap the fps display (performance issues)
        layerView = GlyphLayerView(frame: NSMakeRect(frame.origin.x, frame.origin.y + 16, frame.size.width, frame.size.height - 32))
        layerView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        addSubview(layerView)
        
        let i1 = createGlyphImage(NSColor.TWLightGreenColor())
        let i2 = createGlyphImage(NSColor.TWHotPinkColor())
        let i3 = createGlyphImage(NSColor.TWTurquoiseColor())
        
        //        let filter = CIFilter(name: "CILinearDodgeBlendMode")
        //        let filter = CIFilter(name: "CIColorDodgeBlendMode")
        let filter = CIFilter(name: "CIColorBurnBlendMode")
        //        let filter = CIFilter(name: "CILinearBurnBlendMode")
        //        let filter = CIFilter(name: "CISubtractBlendMode")
        //        let filter = CIFilter(name: "CIAdditionCompositing")
        
        layerView.addLayersForGlyphs([i1, i2, i3], compositingFilter: filter!)
        
        needsDisplay = true
    }
    
    override func stopAnimation()
    {
        self.subviews[0].removeFromSuperview()
        
        super.stopAnimation()
    }
    
    
    override func animateOneFrame()
    {
        frames += 1
        now = NSDate().timeIntervalSinceReferenceDate
        
        let p1 = position(phaseOffset: 4/3*M_PI)
        let p2 = position(phaseOffset: 0/3*M_PI)
        let p3 = position(phaseOffset: 2/3*M_PI)
        
        let r1 = rotation(glyphRotationSpeed: RTSPEED1, phaseOffset: -1/2*M_PI)
        let r2 = rotation(glyphRotationSpeed: RTSPEED2, phaseOffset: +1/2*M_PI)
        let r3 = rotation(glyphRotationSpeed: RTSPEED3, phaseOffset:  0/2*M_PI)
        
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        layerView.glyphLayers[0].position = screenpos(p1)
        layerView.glyphLayers[1].position = screenpos(p2)
        layerView.glyphLayers[2].position = screenpos(p3)
        
        layerView.glyphLayers[0].transform = CATransform3DMakeRotation(CGFloat(r1), 0.0, 0.0, 1.0)
        layerView.glyphLayers[1].transform = CATransform3DMakeRotation(CGFloat(r2), 0.0, 0.0, 1.0)
        layerView.glyphLayers[2].transform = CATransform3DMakeRotation(CGFloat(r3), 0.0, 0.0, 1.0)
        
        CATransaction.commit()
        
        showFrameCount()
    }
    
    func position(phaseOffset phaseOffset: Double) -> (x: Double, y: Double)
    {
        let dist = (MVMID + sin(now*MVSPEED) * MVAMP)
        let xpos = dist * cos(now*GRTSPEED + phaseOffset) + (sin(now*CRSPEED + phaseOffset) * CRRAD)
        let ypos = dist * sin(now*GRTSPEED + phaseOffset) + (cos(now*CRSPEED + phaseOffset) * CRRAD)
        return (xpos, ypos)
    }
    
    func screenpos(p: (x: Double, y: Double)) -> NSPoint
    {
        let glyphSize = min(bounds.width, bounds.height) * CGFloat(SIZE)
        let x = layerView.bounds.size.width/2  + CGFloat(p.x)*glyphSize
        let y = layerView.bounds.size.height/2 + CGFloat(p.y)*glyphSize
        return NSMakePoint(CGFloat(x), CGFloat(y))
    }
    
    func rotation(glyphRotationSpeed grt: Double, phaseOffset: Double) -> Double
    {
        return sin(now*grt + phaseOffset) * RTMAX
    }
    
    
    func showFrameCount()
    {
        var fps = 0
        if (now - lastCheckpoint) > 1.0 {
            fps = frames
            lastCheckpoint = now
            frames = 0
        }
        if fps < 30 || true { // { NSEvent.modifierFlags().contains(.ShiftKeyMask) {
            NSColor.TWGrayColor().lighter(0.1).setFill()
            NSRectFill(NSMakeRect(0, 0, 100, 14))
            let attr = [ NSFontAttributeName: NSFont.userFixedPitchFontOfSize(0)!, NSForegroundColorAttributeName: NSColor.whiteColor() ]
            NSAttributedString(string: String(format:"%d fps", fps), attributes:attr).drawAtPoint(NSMakePoint(0, 0))
        }
    }
    
    
    func createGlyphImage(color: NSColor) -> NSImage
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(SIZE))
        let overscan = CGFloat(0.05) // the glyph is a little bigger than 1x1
        let imageSize = floor(glyphSize * (1 + overscan))
        
        let image = NSImage(size: NSMakeSize(imageSize, imageSize))
        image.lockFocus()
        
        let glyph = NSBezierPath.TWSquareGlyphPath()
        let transform = NSAffineTransform()
        transform.scaleXBy(glyphSize, yBy: glyphSize)
        transform.translateXBy(0.5 + overscan/2, yBy: 0.5 + overscan/2)
        transform.scaleXBy(1, yBy: -1) // must be flipped on x axis
        glyph.transformUsingAffineTransform(transform)
        color.set()
        glyph.fill()
        
        image.unlockFocus()
        
        return image
    }
    
    func createBackgroundImage(color: NSColor) -> NSImage
    {
        let image = NSImage(size: self.bounds.size)
        image.lockFocus()
        
        let path = NSBezierPath()
        path.appendBezierPathWithRect(bounds)
        color.set()
        path.fill()
        
        image.unlockFocus()
        
        return image
    }
    
}

