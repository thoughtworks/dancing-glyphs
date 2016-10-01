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
    struct Settings
    {
        var backgroundColor: NSColor
        var glyphSize: Float
    }

    let NUM_SPRITES = 800

    var glyphs: [Glyph]!
    var sprites: [Sprite?]!

    var settings: Settings!
    var renderer: Renderer!
    var statistics: Statistics!


    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)
        glyphs = GlyphFactory().makeAllGlyphs()
        sprites = [Sprite!](repeating:nil, count:NUM_SPRITES)
        renderer = Renderer(device: device, numGlyphs: glyphs.count, numSprites: NUM_SPRITES)
    }

    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }


    override func resize(withOldSuperviewSize oldSuperviewSize: NSSize) {
        super.resize(withOldSuperviewSize: oldSuperviewSize)
        renderer.setOutputSize(bounds.size)
        updateSizeAndTextures()
    }


    // screen saver api

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
        settings = Settings(backgroundColor: NSColor.black, glyphSize: 0.1)

        renderer.backgroundColor = settings.backgroundColor.toMTLClearColor()
        updateSizeAndTextures()

        sprites = makeSprites()

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
        renderer.setOutputSize(bounds.size)

        let glyphSizeScreen = floor(min(bounds.width, bounds.height) * CGFloat(settings.glyphSize))
        let scale = (window?.backingScaleFactor)!
        let bitmapSize = NSMakeSize(glyphSizeScreen * scale, glyphSizeScreen * scale)

        for (i, g) in glyphs.enumerated() {
            let bitmap = g.makeBitmap(size: bitmapSize)
            renderer.setTexture(image: bitmap, at: i)
        }
    }

    private func makeSprites() -> [Sprite]
    {
        var list: [Sprite] = []
        let xstep = 1 / Double(NUM_SPRITES)
        for i in 0..<NUM_SPRITES {
            let size = settings.glyphSize * Float((0.7 + Util.randomDouble() * 0.3))
            let sprite = Sprite(glyph: Util.randomInt(glyphs.count), size: size, r0: Util.randomDouble(), r1: Util.randomDouble())
            sprite.pos.x = Float(xstep * Double(i))
            list.append(sprite)
        }
        // the list should be sorted by glyph to help the renderer optimise draw calls
        return list.sorted(by: { $0.glyph < $1.glyph })
    }

    override func animateOneFrame()
    {
        autoreleasepool {
            statistics.viewWillStartRenderingFrame()

            let now = CACurrentMediaTime() * (self.isPreview ? 1.5 : 1)
            for s in sprites {
                s?.move(now)
            }

            updateQuadPositions()

            let metalLayer = layer as! CAMetalLayer
            if let drawable = metalLayer.nextDrawable() { // TODO: can this really happen?
                renderer.renderFrame(drawable: drawable)
            }
            
            statistics.viewDidFinishRenderingFrame()
        }
    }
    
    private func updateQuadPositions()
    {
        renderer.beginUpdatingQuads()
        let screenSize = Vector2(Float(bounds.size.width), Float(bounds.size.height))
        for (i, sprite) in sprites.enumerated() {
            let (a, b, c, d) = sprite!.corners(screenSize: screenSize)
            renderer.updateQuad((a, b, c, d), textureId: sprite!.glyph, at:i)
        }
        renderer.finishUpdatingQuads()
    }
    
}



