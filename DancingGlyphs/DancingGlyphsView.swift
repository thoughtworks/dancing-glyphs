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
    var animationState: AnimationState!
    
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
        BGCOLOR.setFill()
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

        animationState = AnimationState()
        animationState.moveToTime(NSDate().timeIntervalSinceReferenceDate)

        // make view a bit smaller so we don't overlap the fps display (performance issues)
        layerView = GlyphLayerView(frame: NSMakeRect(frame.origin.x, frame.origin.y + 12, frame.size.width, frame.size.height - 24))
        layerView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        addSubview(layerView)
        layerView.addLayers()
        layerView.applyAnimationState(animationState)

        needsDisplay = true
    }
    
    override func stopAnimation()
    {
        self.subviews[0].removeFromSuperview()
        
        super.stopAnimation()
    }
    
    
    override func animateOneFrame()
    {
        let now = NSDate().timeIntervalSinceReferenceDate

        animationState.moveToTime(now * (self.preview ? 1.5 : 1))
        layerView.applyAnimationState(animationState)

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
            BGCOLOR.setFill()
            NSRectFill(NSMakeRect(0, 0, 100, 14))
            let attr = [ NSFontAttributeName: NSFont.userFixedPitchFontOfSize(10)!, NSForegroundColorAttributeName: NSColor.whiteColor() ]
            NSAttributedString(string: String(format:"%d fps", frames), attributes:attr).drawAtPoint(NSMakePoint(1, 1))
        }
    }


}

