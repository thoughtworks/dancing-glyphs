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
    fileprivate let textAttr: [String: AnyObject]

    fileprivate var lastCheckpoint: Double = 0
    fileprivate var frameStart: Double = 0
    fileprivate var renderTime: Double = 0
    fileprivate var frames: Int = 0
    
    override init(frame: NSRect)
    {
        textAttr = [ NSFontAttributeName: NSFont.userFixedPitchFont(ofSize: 10)!, NSForegroundColorAttributeName: NSColor.white ]
        super.init(frame: NSRect(origin: frame.origin, size: NSMakeSize(200, 14)))
        wantsLayer = true
        self.layer = createLayer()
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func createLayer() -> CALayer
    {
        let layer = CALayer()
        layer.bounds = self.bounds
        layer.opacity = 1
        layer.isOpaque = true
        layer.actions = [ "contents": NSNull() ]
        return layer
    }
    
    func startFrame()
    {
        frameStart = Date().timeIntervalSinceReferenceDate
    }
    
    func renderFrame()
    {
        frames += 1
        let now = Date().timeIntervalSinceReferenceDate
        renderTime += (now - frameStart)
        if (now - lastCheckpoint) >= 1.0 {
            updateFrameCount()
            lastCheckpoint = now
            frames = 0
            renderTime = 0
        }
    }
    
    fileprivate func updateFrameCount()
    {
        if frames > 1 { // && frames < 59 {
            let image = NSImage(size: self.bounds.size)
            image.lockFocus()
            let path = NSBezierPath()
            path.appendRect(bounds)
            NSColor.black.setFill() // TODO: use background color configured in main view
            path.fill()
            let text = String(format:"%d fps, %.2f ms/f", frames, renderTime / Double(frames) * 1000)
            NSAttributedString(string: text, attributes:textAttr).draw(at: NSMakePoint(2, 1))
            image.unlockFocus()

            let scale = image.recommendedLayerContentsScale(window!.backingScaleFactor)
            layer?.contentsScale = scale
            layer?.contents = image.layerContents(forContentsScale: scale)
        }
        else {
            layer?.contents = nil
        }
    }
    
}

