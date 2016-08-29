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

    var backgroundColor: NSColor?
    var layerView: GlyphLayerView!
    var animation: Animation!

    var lastCheckpoint: Double = 0
    var frames: Int = 0
    
    override class func backingStoreType() -> NSBackingStoreType
    {
        return NSBackingStoreType.Nonretained
    }
    
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
        backgroundColor?.setFill()
        NSRectFill(bounds)
    }
    
    
    override func startAnimation()
    {
        super.startAnimation()

        let configuration = Configuration()
        backgroundColor = configuration.viewSettings.backgroundColor

        animation = Animation()
        animation.settings = configuration.animationSettings
        animation.moveToTime(NSDate().timeIntervalSinceReferenceDate)

        // make view a bit smaller so we don't overlap the fps display (performance issues)
        layerView = GlyphLayerView(frame: NSMakeRect(frame.origin.x, frame.origin.y + 12, frame.size.width, frame.size.height - 24))
        layerView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        // layers can only be created when view is in hierarchy, because layers need scale info from window
        addSubview(layerView)
        layerView.addLayers(configuration.viewSettings)
        layerView.applyAnimationState(animation.currentState!)
        
        self.needsDisplay = true
    }
    
    override func stopAnimation()
    {
        self.subviews[0].removeFromSuperview()
        
        super.stopAnimation()
    }
    
    
    override func animateOneFrame()
    {
        let now = NSDate().timeIntervalSinceReferenceDate

        animation.moveToTime(now * (self.preview ? 1.5 : 1))
        layerView.applyAnimationState(animation.currentState!)

        frames += 1
        if (now - lastCheckpoint) > 1.0 {
            displayFrameCount()
            lastCheckpoint = now
            frames = 0
        }
    }
    
    func displayFrameCount()
    {
        if frames < 30 && false {
            backgroundColor?.setFill()
            NSRectFill(NSMakeRect(0, 0, 100, 14))
            let attr = [ NSFontAttributeName: NSFont.userFixedPitchFontOfSize(10)!, NSForegroundColorAttributeName: NSColor.whiteColor() ]
            NSAttributedString(string: String(format:"%d fps", frames), attributes:attr).drawAtPoint(NSMakePoint(1, 1))
        }
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


}

 
 
