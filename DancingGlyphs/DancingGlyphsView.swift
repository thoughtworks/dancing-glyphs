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
// see https://www.raywenderlich.com/77488/ios-8-metal-tutorial-swift-getting-started
// see http://stackoverflow.com/questions/27967170/rendering-quads-performance-with-metal

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

    var backgroundColor: NSColor?
    
    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!
    var vertexBuffer: MTLBuffer!
    var textureCoordBuffer: MTLBuffer!
    var texture: MTLTexture!
    
    var metalLayer: CAMetalLayer!
    
    var layerView: GlyphLayerView!
    var infoView: InfoView!
    var animation: Animation!
    
    override init?(frame: NSRect, isPreview: Bool)
    {
        super.init(frame: frame, isPreview: isPreview)

        setupMetal()
        
        self.layer = self.metalLayer;
        self.wantsLayer = true;

        self.animationTimeInterval = 1/60
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    
    override func startAnimation()
    {
        super.startAnimation()
        
        let configuration = Configuration()
        let viewSettings = configuration.viewSettings
        backgroundColor = viewSettings.backgroundColor
        
        animation = Animation()
        animation.settings = configuration.animationSettings
        animation.moveToTime(NSDate().timeIntervalSinceReferenceDate)
        
        infoView = InfoView(frame: frame)
        addSubview(infoView)
        
        renderFrame()
    }
    
    override func stopAnimation()
    {
        infoView.removeFromSuperview()
        infoView = nil
        animation = nil
        
        super.stopAnimation()
    }
    
    
    override func animateOneFrame()
    {
        autoreleasepool {
            infoView.startFrame()
            let now = NSDate().timeIntervalSinceReferenceDate
            animation.moveToTime(now * (self.preview ? 1.5 : 1))
            renderFrame()
            infoView.renderFrame()
        }
    }
    
    
    func setupMetal()
    {
        device = selectMetalDevice(MTLCopyAllDevices(), preferLowPower: true) // TODO: make low power preference a user default?
        
        let myBundle = NSBundle(forClass: Configuration.self)
        let libraryPath = myBundle.pathForResource("default", ofType: "metallib")!
        let library = try! self.device.newLibraryWithFile(libraryPath) // TODO: do something
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = library.newFunctionWithName("vertexShader")
        pipelineStateDescriptor.fragmentFunction = library.newFunctionWithName("texturedQuadFragmentShader")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        pipelineState = try! device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)

        commandQueue = device.newCommandQueue()

        createResources()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm;
        metalLayer.framebufferOnly = true    // TODO: probably change when we begin sampling textures
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
    
    func createResources()
    {
        let x = Float(bounds.size.height / bounds.size.width) * 0.7
        let y = Float(0.7)
        
        let vertexData: [Float] = [
            -x,  y, 0, 1, //a
            -x, -y, 0, 1, //b
             x, -y, 0, 1, //c
            -x,  y, 0, 1, //a
             x, -y, 0, 1, //c
             x,  y, 0, 1  //d
        ]

        let textureCoordData: [Float] = [
            0.0, 0.0, //a
            0.0, 1.0, //b
            1.0, 1.0, //c
            0.0, 0.0, //a
            1.0, 1.0, //c
            1.0, 0.0  //d
        ]

        vertexBuffer = device.newBufferWithBytes(vertexData, length: sizeofArray(vertexData), options:MTLResourceOptions())
        textureCoordBuffer = device.newBufferWithBytes(textureCoordData, length: sizeofArray(textureCoordData), options:MTLResourceOptions())

        let image = createBitmapImageRepForGlyph(NSBezierPath.TWSquareGlyphPath(), color: NSColor.TWTurquoiseColor())
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptorWithPixelFormat(.RGBA8Unorm, width: Int(image.size.width), height: Int(image.size.height), mipmapped: false)
        texture = device.newTextureWithDescriptor(textureDescriptor)
        let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.height))
        texture.replaceRegion(region, mipmapLevel: 0, slice: 0, withBytes: image.bitmapData, bytesPerRow: image.bytesPerRow, bytesPerImage: image.bytesPerRow * Int(image.size.height))
    }
    
    private func sizeofArray<T>(array: [T]) -> Int
    {
        return array.count * sizeof(T)
    }
    
    
    func createBitmapImageRepForGlyph(glyph: NSBezierPath, color: NSColor) -> NSBitmapImageRep
    {
        let glyphSize = floor(min(bounds.width, bounds.height) * 0.7) // TODO: CGFloat(config.size))
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

    
    func renderFrame()
    {
        let drawable = metalLayer.nextDrawable()!
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = backgroundColor!.toMTLClearColor() // TODO: conversion is expensive; cache somewhere?
        
        let commandBuffer = commandQueue.commandBuffer()
        
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.setVertexBuffer(textureCoordBuffer, offset: 0, atIndex: 1)
        renderEncoder.setFragmentTexture(texture, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 6, instanceCount: 1)
        renderEncoder.endEncoding()
        
        commandBuffer.presentDrawable(drawable)
        commandBuffer.commit()
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

 
 
