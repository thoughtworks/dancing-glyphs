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
    var texture: MTLTexture!
   
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
    
    
    override class func backingStoreType() -> NSBackingStoreType
    {
        return NSBackingStoreType.Nonretained
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
//        super.startAnimation()

        let configuration = Configuration()
        settings = configuration.viewSettings
 
        animation = Animation()
        animation.settings = configuration.animationSettings
        animation.moveToTime(CACurrentMediaTime())

        statistics = Statistics()

//        infoView = InfoView(frame: frame)
//        addSubview(infoView)
        
        createBuffer()
        createTextures()
        updateUniformsBuffer()
 
        func displayLinkOutputCallback(displayLink: CVDisplayLink, _ inNow: UnsafePointer<CVTimeStamp>, _ inOutputTime: UnsafePointer<CVTimeStamp>, _ flagsIn: CVOptionFlags, _ flagsOut: UnsafeMutablePointer<CVOptionFlags>, _ displayLinkContext: UnsafeMutablePointer<Void>) -> CVReturn {
            unsafeBitCast(displayLinkContext, DancingGlyphsView.self).animateOneFrameCV()
            return kCVReturnSuccess
        }
        
        let screensID = UInt32(window!.screen!.deviceDescription["NSScreenNumber"] as! Int)
        CVDisplayLinkCreateWithCGDisplay(screensID, &displayLink)
        CVDisplayLinkSetOutputCallback(displayLink!, displayLinkOutputCallback, UnsafeMutablePointer<Void>(unsafeAddressOf(self)))
        CVDisplayLinkStart(displayLink!)
    }
    
    override func stopAnimation()
    {
//        infoView.removeFromSuperview()
//        infoView = nil
        animation = nil
        statistics = nil

        CVDisplayLinkStop(displayLink!)

//        super.stopAnimation()
    }
    
    
    func animateOneFrameCV()
    {
        autoreleasepool {
            statistics.viewWillStartRenderingFrame()
            let now = CACurrentMediaTime()
            animation.moveToTime(now * (self.preview ? 1 : 1))
            updateVertexBuffer()
            renderFrame()
            statistics.viewDidFinishRenderingFrame()
        }
    }
    
    
    func setupMetal()
    {
        device = selectMetalDevice(MTLCopyAllDevices(), preferLowPower: true) // TODO: make low power preference a user default?
        
        let myBundle = NSBundle(forClass: Configuration.self)
        let libraryPath = myBundle.pathForResource("default", ofType: "metallib")!
        let library = try! self.device.newLibraryWithFile(libraryPath) // TODO: do something
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.sampleCount = 1
        pipelineStateDescriptor.vertexFunction = library.newFunctionWithName("vertexShader")
        pipelineStateDescriptor.fragmentFunction = library.newFunctionWithName("texturedQuadFragmentShader")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        pipelineState = try! device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)

        commandQueue = device.newCommandQueue()
    }

    func selectMetalDevice(deviceList: [MTLDevice], preferLowPower: Bool) -> MTLDevice
    {
        var device: MTLDevice?
        if !preferLowPower {
            device = MTLCreateSystemDefaultDevice()!
        } else {
            for d in deviceList {
                device = d
                if(d.lowPower) {
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
        metalLayer.pixelFormat = .BGRA8Unorm;
        metalLayer.framebufferOnly = true    // TODO: probably change when we begin sampling textures
        return metalLayer
    }
    
    func createBuffer()
    {
        uniformsBuffer = device.newBufferWithLength(sizeof(Float)*16, options:.StorageModeManaged) // TODO: fix hardcoded buffer size?
        vertexBuffer = device.newBufferWithLength(sizeof(Float)*12, options:.StorageModeManaged) // TODO: fix hardcoded buffer size?
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

        textureCoordBuffer = device.newBufferWithBytes(textureCoordData, length: sizeofArray(textureCoordData), options:MTLResourceOptions.StorageModeManaged)

        let image = createBitmapImageRepForGlyph(settings.glyph, color: NSColor.TWTurquoiseColor())
        let descriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: Int(image.size.width), height: Int(image.size.height), mipmapped: false)
        descriptor.usage = MTLTextureUsage.ShaderRead
        descriptor.storageMode = MTLStorageMode.Managed
        texture = device.newTextureWithDescriptor(descriptor)
        let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.height))
        texture.replaceRegion(region, mipmapLevel: 0, slice: 0, withBytes: image.bitmapData, bytesPerRow: image.bytesPerRow, bytesPerImage: image.bytesPerRow * Int(image.size.height))
    }
    
    private func sizeofArray<T>(array: [T]) -> Int
    {
        return array.count * sizeof(T)
    }

    func createBitmapImageRepForGlyph(glyph: NSBezierPath, color: NSColor) -> NSBitmapImageRep
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.size))
        let overscan = CGFloat(0.05) // the glyph is a little bigger than 1x1
        let imageSize = Int(floor(glyphSize * (1 + overscan)))
        
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: imageSize, pixelsHigh: imageSize, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSDeviceRGBColorSpace, bytesPerRow: imageSize*4, bitsPerPixel:32)!
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrentContext(NSGraphicsContext(bitmapImageRep: imageRep))
        
        let path = glyph.copy()
        let transform = NSAffineTransform()
        transform.scaleXBy(glyphSize, yBy: glyphSize)
        transform.translateXBy(0.5 + overscan/2, yBy: 0.5 + overscan/2)
        path.transformUsingAffineTransform(transform)
        color.set()
        path.fill()
    
        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }


    func updateUniformsBuffer()
    {
        let width = Float(bounds.size.width)
        let height = Float(bounds.size.height)
        let ndcMatrix = makeOrthographicMatrix(left: 0, right: width, bottom: 0, top: height, near: -1, far: 1)
        let floatSize = sizeof(Float)
        // let float4x4ByteAlignment = floatSize * 4
        let float4x4Size = floatSize * 16
//        let paddingBytesSize = 0 // float4x4ByteAlignment - floatSize * 2
//        let uniformsStructSize = float4x4Size + paddingBytesSize

        //uniformsBuffer = device.newBufferWithLength(uniformsStructSize, options: MTLResourceOptions())
        let bufferPointer = uniformsBuffer.contents()
        memcpy(bufferPointer, ndcMatrix, float4x4Size)
        uniformsBuffer.didModifyRange(NSMakeRange(0, float4x4Size))
    }


    func makeOrthographicMatrix(left left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> [Float]
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


    func updateVertexBuffer()
    {
        let (x, y) = screenpos(animation.currentState!.p0)
        let (w, h) = (Float(texture.width), Float(texture.height))
        
        let vertexData: [Float] = [
                x-w/2, y+h/2, //a
                x-w/2, y-h/2, //b
                x+w/2, y-h/2, //c
                x-w/2, y+h/2, //a
                x+w/2, y-h/2, //c
                x+w/2, y+h/2  //d
        ]
        let bufferPointer = vertexBuffer.contents()
        memcpy(bufferPointer, vertexData, sizeofArray(vertexData))
        vertexBuffer.didModifyRange(NSMakeRange(0, sizeofArray(vertexData)))
    }

    func screenpos(p: (x: Double, y: Double)) -> (x: Float, y: Float)
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * CGFloat(settings.size))
        let x = bounds.size.width/2  + CGFloat(p.x)*glyphSize
        let y = bounds.size.height/2 + CGFloat(p.y)*glyphSize
        return (Float(x), Float(y))
    }

    
    func renderFrame()
    {
        let commandBuffer = commandQueue.commandBuffer()

        let metalLayer = layer as! CAMetalLayer
        let drawable = metalLayer.nextDrawable()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = settings.backgroundColor.toMTLClearColor() // TODO: conversion is expensive; cache somewhere?
        renderPassDescriptor.colorAttachments[0].storeAction = .DontCare
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.setVertexBuffer(textureCoordBuffer, offset: 0, atIndex: 1)
        renderEncoder.setVertexBuffer(uniformsBuffer, offset: 0, atIndex: 2)
        renderEncoder.setFragmentTexture(texture, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        }

    
    
}

 
 
