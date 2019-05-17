//
//  SpectralViewController.swift
//  TempiHarness
//
//  Created by John Scalo on 1/7/16.
//  Copyright © 2016 John Scalo. All rights reserved.
//

import UIKit
import AVFoundation

class SpectralViewController: UIViewController {
    
    var audioInput: TempiAudioInput!
    var spectralView: SpectralView!
    var intensity20khz: UILabel!
    var xPositionLabel: UILabel!
    var yPositionLabel: UILabel!
    
    var xPos: Float!
    var yPos: Float!
    var zPos: Float!
    var Positions: [Float]!
    
    var LocationFinder: Localization!
    
    var count: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spectralView = SpectralView(frame: self.view.bounds)
        spectralView.backgroundColor = UIColor.black
        self.view.addSubview(spectralView)
        
        //***** maybe this works?
/*        let sampleTextField =  UITextField(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        sampleTextField.placeholder = "Enter text here"
        sampleTextField.font = UIFont.systemFont(ofSize: 15)
        sampleTextField.borderStyle = UITextField.BorderStyle.roundedRect
        sampleTextField.autocorrectionType = UITextAutocorrectionType.no
        sampleTextField.keyboardType = UIKeyboardType.default
        sampleTextField.returnKeyType = UIReturnKeyType.done
        sampleTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        sampleTextField.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        //sampleTextField.delegate = self as! UITextFieldDelegate
        self.view.addSubview(sampleTextField)
*/
        intensity20khz =  UILabel(frame: CGRect(x: 20, y: 100, width: 300, height: 40))
        intensity20khz.text = "0"
        intensity20khz.font = UIFont.systemFont(ofSize: 15)
        intensity20khz.textColor = UIColor.white
        self.view.addSubview(intensity20khz)
        
        xPositionLabel =  UILabel(frame: CGRect(x: 200, y: 100, width: 300, height: 40))
        xPositionLabel.text = "x: 0.0"
        xPositionLabel.font = UIFont.systemFont(ofSize: 15)
        xPositionLabel.textColor = UIColor.white
        self.view.addSubview(xPositionLabel)
        
        yPositionLabel =  UILabel(frame: CGRect(x: 200, y: 150, width: 300, height: 40))
        yPositionLabel.text = "y: 0.0"
        yPositionLabel.font = UIFont.systemFont(ofSize: 15)
        yPositionLabel.textColor = UIColor.white
        self.view.addSubview(yPositionLabel)
        
        self.Positions = [Float(0.0), Float(0.0), Float(0.0)]
        self.LocationFinder = Localization()
        
        
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
        
        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        audioInput.startRecording()
    }
    
   // func textFieldShouldReturn(_ textField: UITextField) -> Bool {
   //     self.view.endEditing(true)
   //     return false
   // }
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        // Interpoloate the FFT data so there's one band per pixel.
        let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))
            
        
        tempi_dispatch_main { () -> () in
            self.spectralView.fft = fft
            self.spectralView.setNeedsDisplay()
            self.intensity20khz.text = String(Int(self.intensity20khz.text!)!+1)
                //NSString(format: "%.2f", fft.bandMagnitudes[Int(fft.bandMagnitudes.count * 20000/22050)]) as String //NSString(fft.bandMagnitudes[Int(fft.bandMagnitudes.count * 20000/22050)])
            self.xPositionLabel.text = "x: " + (NSString(format: "%.2f", self.Positions[0]) as String)
            self.yPositionLabel.text = "y: " + (NSString(format: "%.2f", self.Positions[1]) as String)
            
            
            var speaker1 = fft.bandMagnitudes[Int(fft.bandMagnitudes.count * 19500/22050)]
            var speaker2 = fft.bandMagnitudes[Int(fft.bandMagnitudes.count * 20100/22050)]
            var speaker3 = fft.bandMagnitudes[Int(fft.bandMagnitudes.count * 20750/22050)]
            var speaker4 = fft.bandMagnitudes[Int(fft.bandMagnitudes.count * 21500/22050)]
            
            //Insert putting things into Localization here
            self.LocationFinder.updateVectors(newValues: [speaker1, speaker2, speaker3, speaker4])
            
            
            self.count+=1
            //every once in a while (with a counter) recalculate position
            if self.count > 100{
                self.Positions = self.LocationFinder.getLocation()
                self.count = 0
            }
            
            
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }
}

