//
//  MainMetalView.swift
//  FirstComputeShader
//

import Foundation
import MetalKit

class MainMetalView: MTKView {
    
    var commandQueue: MTLCommandQueue!
    var compute: MTLComputePipelineState!
    var currentTime: Float = 0.0
    var timeBuffer: MTLBuffer!
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        self.framebufferOnly = false
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.commandQueue = device?.makeCommandQueue()
        
        let library = device?.makeDefaultLibrary()
        let computeFunc = library?.makeFunction(name: "compute")
        
        do{
            compute = try device?.makeComputePipelineState(function: computeFunc!)
        }catch let error as NSError{
            print(error)
        }
        
        timeBuffer = device!.makeBuffer(length: MemoryLayout<Float>.size, options: [])
    }
}

extension MainMetalView{
    
    override func draw(_ dirtyRect: NSRect) {
        guard let drawable = self.currentDrawable else {
            return
        }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let computeCommandEncoder = commandBuffer?.makeComputeCommandEncoder()
        
        computeCommandEncoder?.setComputePipelineState(compute)
        computeCommandEncoder?.setTexture(drawable.texture, index: 0)
        computeCommandEncoder?.setBuffer(timeBuffer, offset: 0, index: 0)
        
        currentTime += 1 / (Float)(self.preferredFramesPerSecond)
        let timeBufferPointer = timeBuffer.contents()
        memcpy(timeBufferPointer, &currentTime, MemoryLayout<Float>.size)
        
        let w = compute.threadExecutionWidth
        let h = compute.maxTotalThreadsPerThreadgroup / w
        
        let threadPerThreadGroup = MTLSize(width: w, height: h, depth: 1)
        let threadPerGrid = MTLSize(width: drawable.texture.width, height: drawable.texture.height, depth: 1)
        computeCommandEncoder?.dispatchThreads(threadPerGrid, threadsPerThreadgroup: threadPerThreadGroup)
        
        
        computeCommandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
    }
}
