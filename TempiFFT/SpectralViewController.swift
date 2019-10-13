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
 
    @IBOutlet weak var spectralView: SpectralView!
    
    var audioInput: TempiAudioInput!
    var isAnalysis:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
//----start ---------------
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height

        let button = UIButton(frame: CGRect(x: screenWidth-150, y: 10, width: 130, height: 30))
        button.backgroundColor = .systemBlue
        button.setTitle("Start Analysis", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.view.addSubview(button)//-----------------------
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
//--end ------------------

        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
        audioInput.startRecording()
    }

  
//--- start --------------------

    @objc func buttonAction(sender: UIButton!) {
      print("REFRESH Button tapped")
        if(isAnalysis == false){
            isAnalysis=true
            sender.backgroundColor = .systemRed
            sender.setTitle("Stop Analysis", for: .normal)
        }else{
            isAnalysis=false
            sender.backgroundColor = .systemGreen
            sender.setTitle("Start Analysis", for: .normal)
        }
    }
//---- end --------------------
    
    func gotSomeAudio(timeStamp: Double, numberOfFrames: Int, samples: [Float]) {
        // NB: The default buffer size on iOS is 512. This will not give a terribly high resolution. In practice you'll want to bucket up the buffers into a larger array of at least size 2048.
        let fft = TempiFFT(withSize: numberOfFrames, sampleRate: 44100.0)
        fft.windowType = TempiFFTWindowType.hanning
        fft.fftForward(samples)
        
        // Interpoloate the FFT data so there's one band per pixel.
        let screenWidth = UIScreen.main.bounds.size.width * UIScreen.main.scale
        
        // NB: The UI in this demo app is geared towards a linear calculation. If you instead use calculateLogarithmicBands, the labels will not be placed correctly.
        fft.calculateLinearBands(minFrequency: 0, maxFrequency: fft.nyquistFrequency, numberOfBands: Int(screenWidth))

        tempi_dispatch_main { () -> () in
            self.spectralView.fft = fft
            self.spectralView.setNeedsDisplay()
        }
    }
    
    override func didReceiveMemoryWarning() {
        NSLog("*** Memory!")
        super.didReceiveMemoryWarning()
    }


}

