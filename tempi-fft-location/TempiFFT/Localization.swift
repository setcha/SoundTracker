//
//  Localization.swift
//  TempiFFT
//
//  Created by Seth Chatterton on 5/5/19.
//  Copyright © 2019 John Scalo. All rights reserved.
//

import Foundation
import Accelerate

class Localization: NSObject {
    
    let numSignals = 4
    
    let timePerPoint:Float = 0.00289    //346 times per second, but this is an estimate
    let speedOfSound:Float = 343.01       //meters per second
    
    //basically the origin, unless you want the origin in the middle of the room
    private var roomXMin = 0.0
    private var roomYMin = 0.0
    private var roomZMin = 0.0
    
    //maximum dimensions of the room
    private var roomXMax = 7.24
    private var roomYMax = 15.5
    private var roomZMax = 2.0
    
    //input the locations of the speakers here
    private var x0:Float = 7.0
    private var y0:Float = 14.0
    private var z0:Float = 0.25
    
    private var x1:Float = 7.0
    private var y1:Float = 1.5
    private var z1:Float = 2.0
    
    private var x2:Float = 0.3
    private var y2:Float = 0.3
    private var z2:Float = 0.05
    
    private var x3:Float = 0.3
    private var y3:Float = 14.5
    private var z3:Float = 0.05
    
    
    
    private var xs:[Float]
    private var ys:[Float]
    private var zs:[Float]
    
    private var signals: [SignalVector]
    
    init(numSignals: Int = 4){
        
        var signalInitializer: [SignalVector]
        signalInitializer = []
        for i in 0..<numSignals{
            signalInitializer.append(SignalVector())
        }
        self.signals = signalInitializer
        
        self.xs = [x0, x1, x2, x3]
        self.ys = [y0, y1, y2, y3]
        self.zs = [z0, z1, z2, z3]
        
    }
    
    //Will be 4 values, which get added to the 4 vectors
    func updateVectors(newValues: [Float]) {
        for i in 0..<numSignals{
            signals[i].addValue(value: newValues[i]) // is this how you actually add newValues?
        }
    }
    
    func getLocation() -> [Float] {
        var t1 = Float(signals[0].risingEdge())
        var t2 = Float(signals[1].risingEdge())
        var t3 = Float(signals[2].risingEdge())
        var t4 = Float(signals[3].risingEdge())
        
        var times = [t1, t2, t3, t4]
        //these arent real ditances. You can only compare them by looking at their differences
        var distances = [t1, t2, t3, t4]
        
        for i in 0..<numSignals{
            distances[i] = timePerPoint * speedOfSound * distances[i]
        }
        
        //precalculate all the distances
        var d01 = distances[0]-distances[1]
        var d02 = distances[0]-distances[2]
        var d03 = distances[0]-distances[3]
        var d12 = distances[1]-distances[2]
        var d13 = distances[1]-distances[3]
        var d23 = distances[2]-distances[3]
        
        var p01:Float = 0
        var p02:Float = 0
        var p03:Float = 0
        var p12:Float = 0
        var p13:Float = 0
        var p23:Float = 0
        
        var SSE:Float = pow(10,20) //big number
        var SSEBest:Float = pow(10,20)
        
        var bestX:Float = 0
        var bestY:Float = 0
        var bestZ:Float = 0
        
        //Sum of Squared Errors
        var testZ:Float = 1.0
        for testXi in 0..<Int((roomXMax - roomXMin)/0.5){
            for testYi in 0..<Int((roomYMax - roomYMin)/0.5){
                var testX = 0.5*Float(testXi)
                var testY = 0.5*Float(testYi)
                
                p01 = distanceDiff(x: testX,y: testY,z: testZ, xs1: x0, ys1: y0, zs1: z0, xs2: x1, ys2: y1, zs2: z1)
                p02 = distanceDiff(x: testX,y: testY,z: testZ, xs1: x0, ys1: y0, zs1: z0, xs2: x2, ys2: y2, zs2: z2)
                p03 = distanceDiff(x: testX,y: testY,z: testZ, xs1: x0, ys1: y0, zs1: z0, xs2: x3, ys2: y3, zs2: z3)
                p12 = distanceDiff(x: testX,y: testY,z: testZ, xs1: x1, ys1: y1, zs1: z1, xs2: x2, ys2: y2, zs2: z2)
                p13 = distanceDiff(x: testX,y: testY,z: testZ, xs1: x1, ys1: y1, zs1: z1, xs2: x3, ys2: y3, zs2: z3)
                p23 = distanceDiff(x: testX,y: testY,z: testZ, xs1: x2, ys1: y2, zs1: z2, xs2: x3, ys2: y3, zs2: z3)
                
                //calculate the sum of squared errors, which we are looking to minimize
                SSE = pow(d01 - p01,2)+pow(d02 - p02,2)+pow(d03 - p03,2)+pow(d12 - p12,2)+pow(d13 - p13,2)+pow(d23 - p23,2)
                
                //if the SSE is low, it is closer to the actual position
                if SSE < SSEBest {
                
                    bestX = testX
                    bestY = testX
                    bestZ = testZ
                    SSEBest = SSE
                }
            }
        }
        return [bestX, bestY, bestZ]
    }
    
    
}


//return d1 - d2 with test position (x,y,z)
func distanceDiff(x:Float,y:Float,z:Float,xs1:Float,ys1:Float,zs1:Float,xs2:Float,ys2:Float,zs2:Float) -> Float {
    return sqrt(pow(x-xs1,2)+pow(y-ys1,2)+pow(z-zs1,2)) - sqrt(pow(x-xs2,2)+pow(y-ys2,2)+pow(z-zs2,2))
}
