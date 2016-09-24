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
import Metal

class Renderer
{
    var numGlyphs = 0

    var backgroundColor: MTLClearColor!

    var device: MTLDevice!
    var commandQueue: MTLCommandQueue!
    var pipelineState: MTLRenderPipelineState!

    var uniformsBuffer: MTLBuffer!

    let VERTEX_BUFFER_COUNT = 2
    var vertexBufferIndex = 0
    var vertexBuffers: [MTLBuffer?]

    var textureCoordBuffer: MTLBuffer!
    var textures: [MTLTexture?]

    
    init(numGlyphs: Int)
    {
        self.numGlyphs = numGlyphs
        self.vertexBuffers = [MTLBuffer!](repeating: nil, count: VERTEX_BUFFER_COUNT)
        self.textures = [MTLTexture!](repeating: nil, count: numGlyphs)

        self.device = selectMetalDevice(MTLCopyAllDevices(), preferLowPower: true) // TODO: make low power preference a user default?
        self.setupMetal()
        self.makeUniformsBuffer()
        self.makeVertexBuffers()
        self.makeTextureCoordinateBuffer()
    }
    

    private func selectMetalDevice(_ deviceList: [MTLDevice], preferLowPower: Bool) -> MTLDevice
    {
        var device: MTLDevice?
        if !preferLowPower {
            device = MTLCreateSystemDefaultDevice()!
        } else {
            for d in deviceList {
                device = d
                if d.isLowPower && !d.isHeadless {
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

    private func setupMetal()
    {
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
        a.rgbBlendOperation = .add
        a.alphaBlendOperation = .add
        a.sourceRGBBlendFactor = .one
        a.sourceAlphaBlendFactor = .zero
        a.destinationRGBBlendFactor = .oneMinusSourceColor
        a.destinationAlphaBlendFactor = .zero
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)

        commandQueue = device.makeCommandQueue()
    }


    private func makeVertexBuffers()
    {
        for i in 0..<VERTEX_BUFFER_COUNT {
            vertexBuffers[i] = device.makeBuffer(length: MemoryLayout<Float>.size * 12 * numGlyphs, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
        }
    }

    private func makeUniformsBuffer()
    {
        uniformsBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 16, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
    }

    private func makeTextureCoordinateBuffer()
    {
        textureCoordBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 12 * numGlyphs, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
    }


    func setOutputSize(_ size: NSSize)
    {
        let ndcMatrix = makeOrthographicMatrix(left: 0, right: Float(size.width), bottom: 0, top: Float(size.height), near: -1, far: 1)
        let bufferPointer = uniformsBuffer.contents()
        memcpy(bufferPointer, ndcMatrix, MemoryLayout<Float>.size * 16)
        uniformsBuffer.didModifyRange(NSMakeRange(0, MemoryLayout<Float>.size * 16))
    }

    private func makeOrthographicMatrix(left: Float, right: Float, bottom: Float, top: Float, near: Float, far: Float) -> [Float]
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


    func setTexture(image: NSBitmapImageRep, at index: Int)
    {
        let textureCoordData: [Float] = [
            0.0, 0.0, //a
            0.0, 1.0, //b
            1.0, 1.0, //c
            0.0, 0.0, //a
            1.0, 1.0, //c
            1.0, 0.0  //d
        ]
        let bufferPointer = textureCoordBuffer.contents()
        memcpy(bufferPointer + index * sizeofArray(textureCoordData), textureCoordData, sizeofArray(textureCoordData))
        textureCoordBuffer.didModifyRange(NSMakeRange(index * sizeofArray(textureCoordData), sizeofArray(textureCoordData)))

        let texture = createTextureForBitmapImageRep(image)
        textures[index] = texture // TODO: this orphans existing textures on the device..
    }

    private func sizeofArray<T>(_ array: [T]) -> Int
    {
        return array.count * MemoryLayout<T>.size
    }

    private func createTextureForBitmapImageRep(_ image: NSBitmapImageRep) -> MTLTexture
    {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(image.size.width), height: Int(image.size.height), mipmapped: false)
        descriptor.usage = MTLTextureUsage.shaderRead
        descriptor.storageMode = MTLStorageMode.managed
        let texture = device.makeTexture(descriptor: descriptor)

        let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.height))
        texture.replace(region: region, mipmapLevel: 0, slice: 0, withBytes: image.bitmapData!, bytesPerRow: image.bytesPerRow, bytesPerImage: image.bytesPerRow * Int(image.size.height))

        return texture
    }


    func beginFrame()
    {
        vertexBufferIndex = (vertexBufferIndex + 1) % VERTEX_BUFFER_COUNT
    }

    func updateQuad(corners: ((Float, Float), (Float, Float)), at index: Int)
    {
        let (p0, p1) = corners
        let vertexData: [Float] = [
            p0.0, p1.1, //a
            p0.0, p0.1, //b
            p1.0, p0.1, //c
            p0.0, p1.1, //a
            p1.0, p0.1, //c
            p1.0, p1.1  //d
        ]
        let currentVertextBuffer = vertexBuffers[vertexBufferIndex]!
        let arraySize = sizeofArray(vertexData)
        let bufferPointer = currentVertextBuffer.contents() + arraySize * index
        memcpy(bufferPointer, vertexData, arraySize)
        currentVertextBuffer.didModifyRange(NSMakeRange(arraySize * index, sizeofArray(vertexData)))
    }

    func renderFrame(drawable: CAMetalDrawable)
    {
        let commandBuffer = commandQueue.makeCommandBuffer()

        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = backgroundColor
        descriptor.colorAttachments[0].storeAction = .dontCare

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffers[vertexBufferIndex], offset: 0, at: 0)
        encoder.setVertexBuffer(textureCoordBuffer, offset: 0, at: 1)
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 2)
        for (index, texture) in textures.enumerated() {
            encoder.setFragmentTexture(texture, at: index)
        }
        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 18, instanceCount: 1)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted() // only doing this to get accurate statistics
    }

}

