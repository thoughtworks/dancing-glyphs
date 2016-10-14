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

import ScreenSaver


@objc(GlyphWaveView) class GlyphWaveView : MetalScreenSaverView
{
    var glyphs: [Glyph]!
    var sprites: [Sprite]!

    var configuration: Configuration!
    var renderer: Renderer!
    var statistics: Statistics!


    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        configuration = Configuration.sharedInstance
        glyphs = Glyph.makeAllGlyphs()
        sprites = nil
        renderer = Renderer(device: device, numGlyphs: glyphs.count, numSprites: configuration.numSprites)
        renderer.backgroundColor = configuration.backgroundColor
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func resize(withOldSuperviewSize oldSuperviewSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSuperviewSize)
        updateSizeAndTextures()
    }


    // screen saver api

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


    override func startAnimation()
    {
        updateSizeAndTextures()

        var maxSpriteSize = configuration.glyphSize
        // size is given as fraction of smaller dimension; must compensate for scaling up that happens with fill scale mode
        if configuration.wave.scaleMode == .fill {
            maxSpriteSize *= Double(min(bounds.size.width, bounds.size.height) / max(bounds.size.width, bounds.size.height))
        }

        let list = configuration.wave.makeSprites(configuration.numSprites, glyphs: glyphs, size: maxSpriteSize)
        // the list should be sorted by glyph to help the renderer optimise draw calls
        sprites = list.sorted(by: { $0.glyph > $1.glyph })

        statistics = Statistics()

        super.startAnimation()
    }

    override func stopAnimation()
    {
        super.stopAnimation()

        sprites = nil
        statistics = nil
    }

    private func updateSizeAndTextures()
    {
        let factor = configuration.wave.scaleMode == .fit ? min(bounds.size.width, bounds.size.height) : max(bounds.size.width, bounds.size.height)
        renderer.setOutputSize(NSMakeSize(bounds.size.width / factor, bounds.size.height / factor))

        let screenSize = floor(min(bounds.width, bounds.height) * CGFloat(configuration.glyphSize))
        let scale = (window?.backingScaleFactor)!
        let bitmapSize = NSMakeSize(screenSize * scale, screenSize * scale)

        for (i, g) in glyphs.enumerated() {
            let bitmap = g.makeBitmap(size: bitmapSize)
            renderer.setTexture(image: bitmap, at: i)
        }
    }

    override func animateOneFrame()
    {
        autoreleasepool {
            statistics.viewWillStartRenderingFrame()

            let now = CACurrentMediaTime() * (self.isPreview ? 1.5 : 1)
            sprites.forEach({ $0.move(to: now) })
            
            updateQuadsForSprites()

            let metalLayer = layer as! CAMetalLayer
            if let drawable = metalLayer.nextDrawable() { // TODO: can this really happen?
                renderer.renderFrame(drawable: drawable)
            }
            
            statistics.viewDidFinishRenderingFrame()
        }
    }
    
    private func updateQuadsForSprites()
    {
        renderer.beginUpdatingQuads()

        let factor = configuration.wave.scaleMode == .fit ? min(bounds.size.width, bounds.size.height) : max(bounds.size.width, bounds.size.height)
        let offset = Vector2(Float((bounds.size.width/factor - 1) / 2), Float((bounds.size.height/factor - 1) / 2))

        for (i, sprite) in sprites.enumerated() {
            let (a, b, c, d) = sprite.corners
            let corners = (a + offset, b + offset, c + offset, d + offset)
            renderer.updateQuad(corners, textureId: sprite.glyph, at:i)
        }

        renderer.finishUpdatingQuads()
    }

}



