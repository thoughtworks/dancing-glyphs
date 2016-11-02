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
    var numQuads = 0
    var textureIds: [Int]
    var backgroundColor: MTLClearColor!

    private var device: MTLDevice
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!

    private var textures: [MTLTexture?]

    private let VALUES_PER_QUAD = 12
    private var vertexData: [Float]

    private var vertexBuffer: MTLBuffer!
    private var uniformsBuffer: MTLBuffer!
    private var textureCoordBuffer: MTLBuffer!

    
    init(device: MTLDevice, numTextures: Int, numQuads: Int)
    {
        self.device = device
        self.numQuads = numQuads

        self.textureIds = [Int](repeating:0, count:numQuads)
        self.vertexData = [Float](repeating: 0, count: VALUES_PER_QUAD)
        self.textures = [MTLTexture!](repeating: nil, count: numTextures)

        self.pipelineState = makePipelineState()
        self.commandQueue = device.makeCommandQueue()

        makeVertexBuffers()
        setUpTextureCoordinateBuffer()
    }


    private func makePipelineState() -> MTLRenderPipelineState
    {
        let libraryPath = Bundle(for: Renderer.self).path(forResource: "default", ofType: "metallib")!
        let library = try! device.makeLibrary(filepath: libraryPath) // TODO: do something

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

        return try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
    }


    private func makeVertexBuffers()
    {
        let vertexBufferSize = numQuads * VALUES_PER_QUAD * MemoryLayout<Float>.size
        vertexBuffer = device.makeBuffer(length: vertexBufferSize, options:.storageModeManaged)
        vertexBuffer.label = "vertexBuffer"

        let uniformsBufferSize = 4 * 4 /* 4x4 matrix */ * MemoryLayout<Float>.size
        uniformsBuffer = device.makeBuffer(length: uniformsBufferSize, options:.storageModeManaged)
        uniformsBuffer.label = "uniformsBuffer"

        let textureCoordBufferSize = VALUES_PER_QUAD * MemoryLayout<Float>.size
        textureCoordBuffer = device.makeBuffer(length: textureCoordBufferSize, options:.storageModeManaged)
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

        textures[index] = texture
    }


    func beginUpdatingQuads()
    {
    }

    func updateQuad(_ corners: (Vector2, Vector2, Vector2, Vector2), textureId: Int, at index: Int)
    {
        let (a, b, c, d) = corners
        vertexData[ 0] = a.x; vertexData[ 1] = a.y;
        vertexData[ 2] = b.x; vertexData[ 3] = b.y;
        vertexData[ 4] = c.x; vertexData[ 5] = c.y;
        vertexData[ 6] = a.x; vertexData[ 7] = a.y;
        vertexData[ 8] = c.x; vertexData[ 9] = c.y;
        vertexData[10] = d.x; vertexData[11] = d.y;

        let arraySize = VALUES_PER_QUAD * MemoryLayout<Float>.size
        let bufferPointer = vertexBuffer.contents() + arraySize * index
        memcpy(bufferPointer, vertexData, arraySize)
        textureIds[index] = textureId
    }

    func finishUpdatingQuads()
    {
        vertexBuffer.didModifyRange(NSMakeRange(0, numQuads * VALUES_PER_QUAD * MemoryLayout<Float>.size))
    }


    func renderFrame(drawable: CAMetalDrawable)
    {
        let commandBuffer = commandQueue.makeCommandBuffer()

        let descriptor = MTLRenderPassDescriptor()
        descriptor.colorAttachments[0].texture = drawable.texture
        descriptor.colorAttachments[0].texture?.label = "drawable"
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].clearColor = backgroundColor
        descriptor.colorAttachments[0].storeAction = .dontCare

        let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        encoder.setVertexBuffer(textureCoordBuffer, offset: 0, at: 1)
        encoder.setVertexBuffer(uniformsBuffer, offset: 0, at: 2)

        var i = 0
        while i < numQuads {
            encoder.setFragmentTexture(textures[textureIds[i]], at: 0)
            // when the quads' textureIds are collated, we can minimise draw calls
            let s = i
            while (i < numQuads) && (textureIds[i] == textureIds[s]) {
                i += 1
            }
            encoder.drawPrimitives(type: .triangle, vertexStart: s * 6, vertexCount: (i - s) * 6, instanceCount: 1)
        }

        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
#if false
        // wait to get accurate statistics, can cause stutter when render time is close to 16ms
        commandBuffer.waitUntilCompleted()
#endif
    }



}

