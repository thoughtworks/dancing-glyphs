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

class InfoView : NSView
{
    let textAttr: [String: AnyObject]
    
    var lastCheckpoint: Double = 0
    var frames: Int = 0
    
    override init(frame: NSRect)
    {
        textAttr = [ NSFontAttributeName: NSFont.userFixedPitchFontOfSize(10)!, NSForegroundColorAttributeName: NSColor.whiteColor() ]
        super.init(frame: NSRect(origin: frame.origin, size: NSMakeSize(100, 14)))
        wantsLayer = true
        self.layer = createLayer()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLayer() -> CALayer
    {
        let layer = CALayer()
        layer.bounds = self.bounds
        layer.opacity = 1
        layer.actions = [ "contents": NSNull() ]
        return layer
    }
    
    func renderFrame()
    {
        frames += 1
        let now = NSDate().timeIntervalSinceReferenceDate
        if (now - lastCheckpoint) >= 1.0 {
            updateFrameCount()
            lastCheckpoint = now
            frames = 0
        }
    }
    
    private func updateFrameCount()
    {
        if frames > 1 && frames < 100 {
            let image = NSImage(size: self.bounds.size)
            image.lockFocus()
            NSAttributedString(string: String(format:"%d fps", frames), attributes:textAttr).drawAtPoint(NSMakePoint(1, 1))
            image.unlockFocus()

            let scale = image.recommendedLayerContentsScale(window!.backingScaleFactor)
            layer?.contentsScale = scale
            layer?.contents = image.layerContentsForContentsScale(scale)
        }
        else {
            layer?.contents = nil
        }
    }
    
}

