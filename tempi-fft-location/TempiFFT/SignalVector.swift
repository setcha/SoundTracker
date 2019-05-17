//
//  SignalVector.swift
//  TempiFFT
//
//  Created by Seth Chatterton on 5/5/19.
//  Copyright © 2019 John Scalo. All rights reserved.
//

//A queue class that lets us find timestamps for when a signal occurred,
//so we can look at arrival time differences between signals
import Foundation
import Accelerate


class SignalVector: NSObject {

    private var Vector: [Float]
    private var size: Int
    
    
    //200 is about .5 sec
    init(size: Int = 400) {
        self.size = size
        self.Vector = Array(repeating: 0.0, count: size)
    }
    
    func get(position: Int) -> Float {
        return Vector[position]
    }
    
    func set(position: Int, value: Float) {
        Vector[position] = value
    }
    
    func addValue(value: Float){
        Vector.insert(value, at: 0)
        Vector.removeLast()
    }
    
    //func priorAverage(position:Int) -> Float{
    //    for i in 0..<(Vector.count-1) {
    //        if Vector[i] < Vector[i+1]{
    //
    //        }
    //   }
    //    return 0.00000001
    //}
    
    
    func toDB(_ inMagnitude: Float) -> Float {
        // ceil to 128db in order to avoid log10'ing 0
        let magnitude = max(inMagnitude, 0.000000000001)
        return 10 * log10f(magnitude)
    }

    
    private func fastAverage(_ array:[Float], _ startIdx: Int, _ stopIdx: Int) -> Float {
        var mean: Float = 0
        let ptr = UnsafePointer<Float>(array)
        vDSP_meanv(ptr + startIdx, 1, &mean, UInt(stopIdx - startIdx))
        
        return mean
    }
    
    //returns index in which the rising edge occurs
    func risingEdge() -> Int{
        var checkCount = 0
        var timeStart = 0
        
        //can't tell the start time if it is cut off/too noisy
        //could change if we double Vector length
        if Vector[0] > 0.1{
            return -1
        }
        
        for i in 0..<(Vector.count-1) {
            //This is where the magic happens, the rising edge detector
            //probably need to adjust these numbers
            if Vector[i+1] > 0.1 {   //Vector[i]>0.01  maybe?
                if Vector[i] < 0.01{
                    timeStart = i
                }
                
                checkCount += 1
                if checkCount >= 20 { //some kind of threshold here, 20 is (20/400) = .05 sec
                    return timeStart
                }
            }
            else{
                checkCount = 0
                timeStart = i
            }
        }
        
        //didnt sense anything
        return -1
    }
    
    
}
