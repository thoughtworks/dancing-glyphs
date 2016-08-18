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

// configuration (at some point we should add a configure sheet)

// whether to draw on a light or dark background
let DARKMODE = false

// the size of the glyphs in relation to the screen
// at a certain size, depending on resolution and CPU, the framerate will
// drop below 30 (and will be shown in the lower left corner)
let SIZE: Double = 0.32

// the centre points of the glyphs are set on an equilateral triangle
// GRTSPEED is the speed with which the triangle revolves around its centre
// for the speed x/60 means x rotations per minute
let GRTSPEED: Double = 2*M_PI * 1/60

// the glyphs move away from the centre
// MVMID is the middle distance, MVAMP the amplitude
let MVMID: Double = 0.08
let MVAMP: Double = 0.06
let MVSPEED: Double = 2*M_PI * 11/60

// the glyphs travel on a circle around their individual "ideal" centre point
// CRRAD is the radius of that circle
let CRRAD: Double = 0.04
let CRSPEED: Double = 2*M_PI * 17/60

// the glyphs each rotate around their centre point
// RTMAX is the maximum angle to either side they rotate
// if the rotation is too big (approx 12 degrees) the glyph will get clipped
let RTMAX: Double = 2*M_PI * 8/360
let RTSPEED1: Double = 2*M_PI * 8/60
let RTSPEED2: Double = 2*M_PI * 7/60
let RTSPEED3: Double = 2*M_PI * 6/60


class DancingGlyphsView : ScreenSaverView
{
    var now: Double = 1
    var lastCheckpoint: Double = 0
    var frames: Int = 0
    var fps: Int = 0
    
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
        animateOneFrame()
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
        needsDisplay = true
    }
    
    override func stopAnimation()
    {
        super.stopAnimation()
    }
    

    override func animateOneFrame()
    {
        window!.disableFlushWindow()

        frames += 1
        now = NSDate().timeIntervalSinceReferenceDate

        let p1 = position(phaseOffset: 4/3*M_PI)
        let p2 = position(phaseOffset: 0/3*M_PI)
        let p3 = position(phaseOffset: 2/3*M_PI)

        let r1 = rotation(glyphRotationSpeed: RTSPEED1, phaseOffset: -1/2*M_PI)
        let r2 = rotation(glyphRotationSpeed: RTSPEED2, phaseOffset: +1/2*M_PI)
        let r3 = rotation(glyphRotationSpeed: RTSPEED3, phaseOffset:  0/2*M_PI)

        drawBackground()
        drawGlyph(position: p1, rotation: r1, color: NSColor.TWLightGreenColor())
        drawGlyph(position: p2, rotation: r2, color: NSColor.TWHotPinkColor())
        drawGlyph(position: p3, rotation: r3, color: NSColor.TWTurquoiseColor())
        showFrameCount()
        
        window!.enableFlushWindow()
    }
    
    func position(phaseOffset phaseOffset: Double) -> (x: Double, y: Double)
    {
        let dist = (MVMID + sin(now*MVSPEED) * MVAMP)
        let xpos = dist * cos(now*GRTSPEED + phaseOffset) + (sin(now*CRSPEED + phaseOffset) * CRRAD)
        let ypos = dist * sin(now*GRTSPEED + phaseOffset) + (cos(now*CRSPEED + phaseOffset) * CRRAD)
        return (xpos, ypos)
    }

    func rotation(glyphRotationSpeed grt: Double, phaseOffset: Double) -> Double
    {
        return sin(now*grt + phaseOffset) * RTMAX
    }


    func drawBackground()
    {
        let path = NSBezierPath(rect: bounds)
        if DARKMODE {
            NSColor.blackColor().set()
        } else {
            NSColor.TWGrayColor().lighter(0.3).set()
        }
        path.fill()
    }
    
    func drawGlyph(position p: (x: Double, y: Double), rotation: Double, color: NSColor)
    {
        let glyphSize = min(bounds.width, bounds.height) * CGFloat(SIZE)
        let imageSize = glyphSize * 1.1

        let image = NSImage(size: NSMakeSize(imageSize, imageSize))
        image.lockFocus()

#if true
        let glyph = NSBezierPath.TWSquareGlyphPath()
        let transform = NSAffineTransform()
        transform.scaleXBy(glyphSize, yBy: glyphSize)
        transform.translateXBy(0.55, yBy: 0.55)
        transform.rotateByRadians(CGFloat(rotation))
        transform.scaleXBy(1, yBy: -1)
        glyph.transformUsingAffineTransform(transform)
        color.set()
        glyph.fill()
#endif

#if false
        let center = NSBezierPath(ovalInRect: NSMakeRect(-3, -3, 6, 6))
        let transform2 = NSAffineTransform()
        transform2.translateXBy(imageSize/2, yBy: imageSize/2)
        center.transformUsingAffineTransform(transform2)
        NSColor.lightGrayColor().set()
        center.fill()
#endif

#if false
        let frame = NSBezierPath(rect: NSMakeRect(0,0, imageSize, imageSize))
        NSColor.lightGrayColor().set()
        frame.stroke()
#endif
        
        image.unlockFocus()

        let x = bounds.size.width/2  - image.size.width/2  + CGFloat(p.x)*glyphSize
        let y = bounds.size.height/2 - image.size.height/2 + CGFloat(p.y)*glyphSize
        if DARKMODE {
            image.drawAtPoint(NSMakePoint(x, y), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositeScreen, fraction: 1)
        } else {
            image.drawAtPoint(NSMakePoint(x, y), fromRect: NSZeroRect, operation: NSCompositingOperation.CompositePlusDarker, fraction: 0.6)
        }
    }
    
    func showFrameCount()
    {
        if (now - lastCheckpoint) > 1.0 {
            fps = frames
            lastCheckpoint = now
            frames = 0
        }
        if fps < 30 || true { // { NSEvent.modifierFlags().contains(.ShiftKeyMask) {
            let attr = [ NSFontAttributeName: NSFont.userFixedPitchFontOfSize(0)!, NSForegroundColorAttributeName: NSColor.whiteColor() ]
            NSAttributedString(string: String(format:"%d fps", fps), attributes:attr).drawAtPoint(NSMakePoint(0, 0))
        }
    }
    
}

