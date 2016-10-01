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
    var numSprites = 0
    var textureIds: [Int?]
    var backgroundColor: MTLClearColor!

    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!

    private var uniformsBuffer: MTLBuffer!

    private let VERTEX_BUFFER_COUNT = 2
    private var vertexBufferIndex = 0
    private var vertexBuffers: [MTLBuffer?]

    private var textureCoordBuffer: MTLBuffer!
    private var textures: [MTLTexture?]

    
    init(device: MTLDevice, numGlyphs: Int, numSprites: Int)
    {
        self.numGlyphs = numGlyphs
        self.numSprites = numSprites
        self.textureIds = [Int!](repeating:nil, count:numSprites)
        self.vertexBuffers = [MTLBuffer!](repeating: nil, count: VERTEX_BUFFER_COUNT)
        self.textures = [MTLTexture!](repeating: nil, count: numGlyphs)

        self.device = device
        self.setUpMetal()
        self.makeVertexBuffers()
        self.setUpTextureCoordinateBuffer()
    }


    private func setUpMetal()
    {
        let libraryPath = Bundle(for: Renderer.self).path(forResource: "default", ofType: "metallib")!
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
            vertexBuffers[i] = device.makeBuffer(length: MemoryLayout<Float>.size * 12 * numSprites, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
            vertexBuffers[i]!.label = "vertexBuffer\(i)"
        }

        uniformsBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 16, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
        uniformsBuffer.label = "uniformsBuffer"

        textureCoordBuffer = device.makeBuffer(length: MemoryLayout<Float>.size * 12, options:.storageModeManaged) // TODO: fix hardcoded buffer size?
        textureCoordBuffer.label = "textureCoordBuffer"
    }

    private func setUpTextureCoordinateBuffer()
    {
        let textureCoordData: [Float] = [
            0.0, 0.0, //a
            0.0, 1.0, //b
            1.0, 1.0, //c
            0.0, 0.0, //a
            1.0, 1.0, //c
            1.0, 0.0  //d
        ]
        let arraySize = Util.sizeofArray(textureCoordData)
        let bufferPointer = textureCoordBuffer.contents()
        memcpy(bufferPointer, textureCoordData, arraySize)
        textureCoordBuffer.didModifyRange(NSMakeRange(0, arraySize))
    }


    func setOutputSize(_ size: NSSize)
    {
        let l: Float = 0                  // left
        let r: Float = Float(size.width)  // right
        let b: Float = 0                  // bottom
        let t: Float = Float(size.height) // top
        let n: Float = -1                 // near
        let f: Float = 1                  // far

        // orthographic matrix for normalized device coordinate calculation
        let ndcMatrix: [Float] = [
            2/(r-l)       , 0             , 0             , 0,
            0             , 2/(t-b)       , 0             , 0,
            0             , 0             , -2/(f-n)      , 0,
            -((r+l)/(r-l)), -((t+b)/(t-b)), -((f+n)/(f-n)), 1
        ]
        let arraySize = Util.sizeofArray(ndcMatrix)
        let bufferPointer = uniformsBuffer.contents()
        memcpy(bufferPointer, ndcMatrix, arraySize)
        uniformsBuffer.didModifyRange(NSMakeRange(0, arraySize))
    }


    func setTexture(image: NSBitmapImageRep, at index: Int)
    {
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: Int(image.size.width), height: Int(image.size.height), mipmapped: false)
        descriptor.usage = MTLTextureUsage.shaderRead
        descriptor.storageMode = MTLStorageMode.managed
        let texture = device.makeTexture(descriptor: descriptor)
        texture.label = "glyph\(index)"

        let region = MTLRegionMake2D(0, 0, Int(image.size.width), Int(image.size.height))
        texture.replace(region: region, mipmapLevel: 0, slice: 0, withBytes: image.bitmapData!, bytesPerRow: image.bytesPerRow, bytesPerImage: image.bytesPerRow * Int(image.size.height))

        textures[index] = texture // TODO: does this orphan the existing texture on the device?
    }


    func beginUpdatingQuads()
    {
        vertexBufferIndex = (vertexBufferIndex + 1) % VERTEX_BUFFER_COUNT
    }

    func updateQuad(_ corners: (Vector2, Vector2, Vector2, Vector2), textureId: Int, at index: Int)
    {
        let (a, b, c, d) = corners
        let vertexData: [Float] = [
            a.x, a.y, //a
            b.x, b.y, //b
            c.x, c.y, //c
            a.x, a.y, //a
            c.x, c.y, //c
            d.x, d.y  //d
        ]
        let currentVertextBuffer = vertexBuffers[vertexBufferIndex]!
        let arraySize = Util.sizeofArray(vertexData)
        let bufferPointer = currentVertextBuffer.contents() + arraySize * index
        memcpy(bufferPointer, vertexData, arraySize)
        textureIds[index] = textureId
    }

    func finishUpdatingQuads()
    {
        let currentVertextBuffer = vertexBuffers[vertexBufferIndex]!
        currentVertextBuffer.didModifyRange(NSMakeRange(0, MemoryLayout<Float>.size * 12 * numSprites))
    }

    func renderFrame(drawable: CAMetalDrawable)
    {
        let commandBuffer = commandQueue.makeCommandBuffer()

        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].texture?.label = "drawable"
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = backgroundColor
        descriptor.colorAttachments[0].storeAction = .store

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffers[vertexBufferIndex], offset: 0, at: 0)
        encoder.setVertexBuffer(textureCoordBuffer, offset: 0, at: 1)
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 2)

        // when the quads' textureIds are collated, we can minimise draw calls
        var i = 0
        while i < numSprites {
            encoder.setFragmentTexture(textures[textureIds[i]!], at: 0)
            let s = i
            while (i < numSprites) && (textureIds[i]! == textureIds[s]!) {
                i += 1
            }
            encoder.drawPrimitives(type: .triangle, vertexStart: s * 6, vertexCount: (i - s) * 6, instanceCount: 1)
        }

        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
//         commandBuffer.waitUntilCompleted() // only doing this to get accurate statistics
    }



}

