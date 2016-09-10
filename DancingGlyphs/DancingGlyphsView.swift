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
    var colorBuffer: MTLBuffer!
    
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
    
    func setupMetal()
    {
        device = selectMetalDevice(MTLCopyAllDevices(), preferLowPower: true) // TODO: make low power preference a user default?
        
        commandQueue = device.newCommandQueue()
        
        let myBundle = NSBundle(forClass: Configuration.self)
        let libraryPath = myBundle.pathForResource("default", ofType: "metallib")!
        var library: MTLLibrary!
        do {
            library = try self.device.newLibraryWithFile(libraryPath)
        } catch {
            NSLog("Failed to load default Metal library") // TODO: do something
        }

        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = library.newFunctionWithName("vertexShader")
        pipelineStateDescriptor.fragmentFunction = library.newFunctionWithName("fragmentShader")
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        do {
            pipelineState = try device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        } catch {
            NSLog("Failed to create render pipeline state") // TODO: do something
        }

        createResources()
        
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm;
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
        let vertexArray:[Float] = [
            -0.7,  0.7, 0, 1,
            -0.7, -0.7, 0, 1,
             0.7, -0.7, 0, 1,
            -0.7,  0.7, 0, 1,
             0.7, -0.7, 0, 1,
             0.7,  0.7, 0, 1
        ]
       
        let colorArray:[Float] = [
            1.0, 0.5, 0.5, 1, //a
            0.5, 1.0, 0.5, 1, //b
            0.5, 0.5, 1.0, 1, //c
            1.0, 0.5, 0.5, 1, //a
            0.5, 0.5, 1.0, 1, //c
            1.0, 0.5, 1.0, 1, //d
        ]
        
        self.vertexBuffer = device.newBufferWithBytes(vertexArray, length: vertexArray.count*sizeofValue(vertexArray[0]), options:MTLResourceOptions())
        self.colorBuffer = device.newBufferWithBytes(colorArray, length: colorArray.count*sizeofValue(colorArray[0]), options:MTLResourceOptions())
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
        infoView.startFrame()
        let now = NSDate().timeIntervalSinceReferenceDate
        animation.moveToTime(now * (self.preview ? 1.5 : 1))
        renderFrame()
        infoView.renderFrame()
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
        renderEncoder.setVertexBuffer(colorBuffer, offset: 0, atIndex: 1)
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

 
 
