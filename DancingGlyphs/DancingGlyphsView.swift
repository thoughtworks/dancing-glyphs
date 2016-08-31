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
    var infoView: InfoView!
    var animation: Animation!
    
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

        layerView = GlyphLayerView(frame: frame)
        layerView.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        // layers can only be created when view is in hierarchy, because layers need scale info from window
        addSubview(layerView)
        layerView.addLayers(configuration.viewSettings)
        layerView.applyAnimationState(animation.currentState!)
        
        infoView = InfoView(frame: frame)
        addSubview(infoView)
        
        self.needsDisplay = true
    }
    
    override func stopAnimation()
    {
        layerView.removeFromSuperview()
        layerView = nil
        infoView.removeFromSuperview()
        infoView = nil
        animation = nil
        
        super.stopAnimation()
    }
    
    
    override func animateOneFrame()
    {
        let now = NSDate().timeIntervalSinceReferenceDate
        animation.moveToTime(now * (self.preview ? 1.5 : 1))
        layerView.applyAnimationState(animation.currentState!)
        infoView.renderFrame()
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

 
 
