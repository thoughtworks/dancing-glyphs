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

// see https://www.raywenderlich.com/77488/ios-8-metal-tutorial-swift-getting-started
// see https://www.raywenderlich.com/90592/liquidfun-tutorial-2
// see http://stackoverflow.com/questions/27967170/rendering-quads-performance-with-metal
// see https://github.com/nickzman/rainingcubes

import ScreenSaver
import Metal


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

    var settings: Settings!
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    
    var uniformsBuffer: MTLBuffer!
    var vertexBuffer: MTLBuffer!
    var textureCoordBuffer: MTLBuffer!
    var textures: [MTLTexture]!
   
    var displayLink: CVDisplayLink?

    var animation: Animation!
    var statistics: Statistics!

    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)

        setupMetal()

        wantsLayer = true;
        layer = createMetalLayer()

        animationTimeInterval = 1/60
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    // screen saver api
    
    override class func backingStoreType() -> NSBackingStoreType
    {
        return NSBackingStoreType.nonretained
    }
    
    override class func performGammaFade() -> Bool
    {
        return false
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
    

    override func startAnimation()
    {
        // we're not calling super because we need to set up our own timer for the animation
        
        let configuration = Configuration()
        settings = configuration.viewSettings
 
        animation = Animation()
        animation.settings = configuration.animationSettings
        animation.moveToTime(CACurrentMediaTime())

        statistics = Statistics()

        createVertexBuffer()
        createUniformsBuffer()
        createTextures()
 
        // must be done here and not in initFrame because it requires this view to be in a view hierarchy
        if displayLink == nil {
            createDisplayLink()
        }
        CVDisplayLinkStart(displayLink!)
    }
    
    override func stopAnimation()
    {
        // we're not calling super because we didn't do it in startAnimation()
        
        animation = nil
        statistics = nil

        CVDisplayLinkStop(displayLink!)
    }
    
    
    override func animateOneFrame()
    {
        autoreleasepool {
            statistics.viewWillStartRenderingFrame()
            let now = CACurrentMediaTime()
            animation.moveToTime(now * (self.isPreview ? 1.5 : 1))
            updateVertexBuffer()
            renderFrame()
            statistics.viewDidFinishRenderingFrame()
        }
    }
    
    
    // functions called once
    
    func setupMetal()
    {
        device = selectMetalDevice(MTLCopyAllDevices(), preferLowPower: true) // TODO: make low power preference a user default?
        
        let myBundle = Bundle(for: Configuration.self)
        let libraryPath = myBundle.path(forResource: "default", ofType: "metallib")!
        let library = try! self.device.makeLibrary(filepath: libraryPath) // TODO: do something
       
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        pipelineStateDescriptor.fragmentFunction = library.makeFunction(name: "texturedQuadFragmentShader")
        let a = pipelineStateDescriptor.colorAttachments[0]!
        a.pixelFormat = .bgra8Unorm
        a.isBlendingEnabled = true
        a.rgbBlendOperation = MTLBlendOperation.add
        a.alphaBlendOperation = MTLBlendOperation.add
        a.sourceRGBBlendFactor = .sourceAlpha
        a.sourceAlphaBlendFactor = .sourceAlpha
        a.destinationRGBBlendFactor = .oneMinusSourceColor
        a.destinationAlphaBlendFactor = .oneMinusSourceAlpha
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()
    }

    func selectMetalDevice(_ deviceList: [MTLDevice], preferLowPower: Bool) -> MTLDevice
    {
        var device: MTLDevice?
        if !preferLowPower {
            device = MTLCreateSystemDefaultDevice()!
        } else {
            for d in deviceList {
                device = d
                if(d.isLowPower) {
                    break
                }
            }
        }
        if let name = device?.name {
            NSLog("Using device '\(name)'")
        } else {
            NSLog("No or unknown device")
        }
        return device! // TODO: can we assume there will always be a device?
    }
    
    func createMetalLayer() -> CAMetalLayer
    {
        let metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm;
        metalLayer.framebufferOnly = true
        return metalLayer
    }
    
    
    // functions called when animation starts

    func createDisplayLink()
    {
        func displayLinkOutputCallback(_ displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutableRawPointer?) -> CVReturn {
            unsafeBitCast(displayLinkContext, to: DancingGlyphsView.self).animateOneFrame()
            return kCVReturnSuccess
        }
        
        let screensID = UInt32(window!.screen!.deviceDescription["NSScreenNumber"] as! Int)
        CVDisplayLinkCreateWithCGDisplay(screensID, &displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
    }
    
    
    func createVertexBuffer()
    {
        vertexBuffer = device.makeBuffer(length: MemoryLayout<Float>.size*36, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
    }

    func createUniformsBuffer()
    {
        let width = Float(bounds.size.width)
        let height = Float(bounds.size.height)
        let ndcMatrix = makeOrthographicMatrix(left: 0, right: width, bottom: 0, top: height, near: -1, far: 1)
        let floatSize = MemoryLayout<Float>.size
        // let float4x4ByteAlignment = floatSize * 4
        let float4x4Size = floatSize * 16
        //        let paddingBytesSize = 0 // float4x4ByteAlignment - floatSize * 2
        //        let uniformsStructSize = float4x4Size + paddingBytesSize
        
        uniformsBuffer = device.makeBuffer(length: float4x4Size, options:.storageModeManaged)
        let bufferPointer = uniformsBuffer.contents()
        memcpy(bufferPointer, ndcMatrix, float4x4Size)
        uniformsBuffer.didModifyRange(NSMakeRange(0, float4x4Size))
    }
    
    func makeOrthographicMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> [Float]
    {
        let ral = right + left
        let rsl = right - left
        let tab = top + bottom
        let tsb = top - bottom
        let fan = far + near
        let fsn = far - near
        
        return [2.0 / rsl, 0.0, 0.0, 0.0,
                0.0, 2.0 / tsb, 0.0, 0.0,
                0.0, 0.0, -2.0 / fsn, 0.0,
                -ral / rsl, -tab / tsb, -fan / fsn, 1.0
        ]
    }
    
    func createTextures()
    {
        let textureCoordData: [Float] = [
            0.0, 0.0, //a
            0.0, 1.0, //b
            1.0, 1.0, //c
            0.0, 0.0, //a
            1.0, 1.0, //c
            1.0, 0.0  //d
        ]
        let numGlyphs = settings.glyphColors.count
        textureCoordBuffer = device.makeBuffer(length: sizeofArray(textureCoordData) * numGlyphs, options:.storageModeManaged)
        var bufferPointer = textureCoordBuffer.contents()
        for _ in 0..<numGlyphs {
            memcpy(bufferPointer, textureCoordData, sizeofArray(textureCoordData))
            bufferPointer += sizeofArray(textureCoordData)
        }
        textureCoordBuffer.didModifyRange(NSMakeRange(0, sizeofArray(textureCoordData) * numGlyphs))
    
        textures = []
        for color in settings.glyphColors {
            let image = createBitmapImageRepForGlyph(settings.glyph, color:color)
            let texture = createTextureForBitmapImageRep(image)
            textures.append(texture)
        }
    }
    
    fileprivate func sizeofArray<T>(_ array: [T]) -> Int
    {
        return array.count * MemoryLayout<T>.size
    }

    func createBitmapImageRepForGlyph(_ glyph: NSBezierPath, color: NSColor) -> NSBitmapImageRep
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.size))
        let overscan = CGFloat(0.05) // the glyph is a little bigger than 1x1
        let imageSize = Int(floor(glyphSize * (1 + overscan)))
        
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: imageSize, pixelsHigh: imageSize, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bytesPerRow: imageSize*4, bitsPerPixel:32)!
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: imageRep))
#if false
        let p0 = NSBezierPath()
        p0.appendRect(NSMakeRect(0, 0, CGFloat(imageSize), CGFloat(imageSize)))
        NSColor(red: 1, green: 1, blue: 1, alpha: 0.8).set()
        p0.stroke()
#endif
        let path = glyph.copy() as! NSBezierPath
        var transform = AffineTransform.identity
        transform.scale(x: glyphSize, y: glyphSize)
        transform.translate(x: 0.5 + overscan/2, y: 0.5 + overscan/2)
        path.transform(using: transform)
        color.set()
        path.fill()
    
        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }
    
    func createTextureForBitmapImageRep(_ image: NSBitmapImageRep) -> MTLTexture
    {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(image.size.width), height: Int(image.size.height), mipmapped: false)
        descriptor.usage = MTLTextureUsage.shaderRead
        descriptor.storageMode = MTLStorageMode.managed
        let texture = device.makeTexture(descriptor: descriptor)
        
        let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.height))
        texture.replace(region: region, mipmapLevel: 0, slice: 0, withBytes: image.bitmapData!, bytesPerRow: image.bytesPerRow, bytesPerImage: image.bytesPerRow * Int(image.size.height))
        
        return texture
    }


    // functions called for every frame

    func updateVertexBuffer()
    {
        updateVertextBufferWithTextureQuad(position: screenpos(animation.currentState!.p0), at:0)
        updateVertextBufferWithTextureQuad(position: screenpos(animation.currentState!.p1), at:1)
        updateVertextBufferWithTextureQuad(position: screenpos(animation.currentState!.p2), at:2)
    }
    
    func updateVertextBufferWithTextureQuad(position p: (x: Float, y: Float), at index: Int)
    {
        let x = Float(p.x)
        let y = Float(p.y)
        let w = Float(textures[0].width)
        let h = Float(textures[0].height)
        let vertexData: [Float] = [
            x-w/2, y+h/2, //a
            x-w/2, y-h/2, //b
            x+w/2, y-h/2, //c
            x-w/2, y+h/2, //a
            x+w/2, y-h/2, //c
            x+w/2, y+h/2  //d
        ]
        let arraySize = sizeofArray(vertexData)
        let bufferPointer = vertexBuffer.contents() + arraySize * index
        memcpy(bufferPointer, vertexData, arraySize)
        vertexBuffer.didModifyRange(NSMakeRange(arraySize * index, sizeofArray(vertexData)))
    }

    func screenpos(_ p: (x: Double, y: Double)) -> (x: Float, y: Float)
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.size))
        let x = bounds.size.width/2  + CGFloat(p.x)*glyphSize
        let y = bounds.size.height/2 + CGFloat(p.y)*glyphSize
        return (Float(x), Float(y))
    }

    
    func renderFrame()
    {
        let commandBuffer = commandQueue.makeCommandBuffer()

        let metalLayer = layer as! CAMetalLayer
        let drawable = metalLayer.nextDrawable()! // TODO: add guard to skip frame if we dont get a drawable
        
        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = settings.backgroundColor.toMTLClearColor() // TODO: conversion is expensive; cache somewhere?
        descriptor.colorAttachments[0].storeAction = .dontCare

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        encoder.setVertexBuffer(textureCoordBuffer, offset: 0, at: 1)
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 2)
        for (index, texture) in textures.enumerated() {
            encoder.setFragmentTexture(texture, at: index)
        }
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 18, instanceCount: 1)
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        }

}

 
 
