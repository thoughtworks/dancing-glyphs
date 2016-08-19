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
    var glyphLayers: [CALayer]

    override init(frame: NSRect)
    {
        glyphLayers = []
        super.init(frame: frame)
        wantsLayer = true
        layerUsesCoreImageFilters = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func addLayersForGlyphs(glyphImages: [NSImage], compositingFilter: CIFilter)
    {
        glyphLayers = []
        let backgroundLayer = createBackgroundLayer()
        for image in glyphImages {
            let layer = createGlyphLayer(image, compositingFilter: compositingFilter)
            layer.position = NSMakePoint(bounds.size.width/2, bounds.size.height/2) // TODO: init with real position
            glyphLayers.append(layer)
            backgroundLayer.addSublayer(layer)
        }
        self.layer = backgroundLayer
    }

    func createBackgroundLayer() -> CALayer
    {
        let layer = CALayer()
        layer.bounds = self.bounds
        layer.opacity = 1
        layer.delegate = self
//        layer.opaque = true
        return layer
    }

    func createGlyphLayer(image: NSImage, compositingFilter: CIFilter) -> CALayer
    {
        let layer = CALayer()

        layer.bounds = NSRect(origin:NSMakePoint(0,0), size:image.size)
        layer.contents = image
        layer.contentsScale = 1  // TODO: how do we get retina config in here?
        layer.contentsGravity = kCAGravityBottomLeft
        layer.opacity = 0.98
        layer.compositingFilter = compositingFilter
//        layer.shouldRasterize = true

        return layer
    }

}

