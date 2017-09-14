//
//  ViewController.swift
//  Chapter1_Starting
//
//  Created by FB on 2017/9/14.
//  Copyright © 2017年 FB. All rights reserved.
//

import UIKit
import Metal


class ViewController: UIViewController {
    
    // MTLDevice
    var device: MTLDevice!
    // Metal layer
    var metalLayer: CAMetalLayer!
    // vertex data
    let vertexData: [Float] = [
        0.0, 1.0, 0.0, //
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    //
    var vertexBuffer: MTLBuffer!
    
    //-- pipeline
    var renderPipelineState: MTLRenderPipelineState!
    
    // command queue
    var commandQueue: MTLCommandQueue!
    
    // timer
    var timer: CADisplayLink!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        //device init
        device = MTLCreateSystemDefaultDevice()
        
        // add metal layer
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .bgra8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame
        view.layer.addSublayer(metalLayer)
        
        // vertex buffer
        let bufferSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
        vertexBuffer = device.makeBuffer(bytes: vertexData, length: bufferSize, options: [])
        
        
        // create render pipeline
        // 1. retrive shader
        let defaultLibray = device.newDefaultLibrary()!
        let vertexProgram = defaultLibray.makeFunction(name: "basic_vertex")
        let fragmentProgram = defaultLibray.makeFunction(name: "basic_fragment")

        // 2. 
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

        // 3
        renderPipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // create command queue
        commandQueue = device.makeCommandQueue()
        
        // timer
        timer = CADisplayLink(target: self, selector: #selector(renderLoop))
        timer.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    }
    
    private func render() {
        
        // MTLRenderPassDescriptor
        guard let drawable = metalLayer?.nextDrawable() else { return }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 104.0/255.0, 5.0/255.0, 1.0)
        
        // command buffer
        let commandBuffer = commandQueue.makeCommandBuffer()
        
        // command encoder
        let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder.setRenderPipelineState(renderPipelineState)
        commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, at: 0)
        commandEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        commandEncoder.endEncoding()
        
        // commit command buffer
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    @objc private func renderLoop() -> Void {
        autoreleasepool {
            render()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

