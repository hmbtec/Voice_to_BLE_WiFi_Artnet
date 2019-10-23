//
//  SpectralViewController.swift
//  TempiHarness
//
//  Created by John Scalo on 1/7/16.
//  Copyright © 2016 John Scalo. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class SpectralViewController: UIViewController, SFSpeechRecognizerDelegate {

    //--- BLE
    
    //--- FFT
    @IBOutlet weak var spectralView: SpectralView!
    
    var audioInput: TempiAudioInput!
    var isAnalysis:Bool = false
    
    //----
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    
    
    //MARK:- func
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        speechRecognizer!.delegate = self  //3
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                //self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
        //*********
        
        
//----start ---------------
        
        
        let audioInputCallback: TempiAudioInputCallback = { (timeStamp, numberOfFrames, samples) -> Void in
            self.gotSomeAudio(timeStamp: Double(timeStamp), numberOfFrames: Int(numberOfFrames), samples: samples)
        }
//--end ------------------

        audioInput = TempiAudioInput(audioInputCallback: audioInputCallback, sampleRate: 44100, numberOfChannels: 1)
       // audioInput.startRecording()
    }
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.landscapeRight.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        
        //--
        let screenWidth = UIScreen.main.bounds.size.width
        //let screenHeight = UIScreen.main.bounds.size.height
        let navigatioHeight = self.navigationController?.navigationBar.frame.height
        let button = UIButton(frame: CGRect(x: screenWidth-150, y: navigatioHeight!, width: 130, height: 30))
        button.backgroundColor = .blue
        button.setTitle("Start Analysis", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)//-----------------------
    }
    
    @IBAction func btnBack(_ sender: Any) {
        
    }
    
//--- start --------------------

    @objc func buttonAction(sender: UIButton!) {
      print("REFRESH Button tapped")
        if(isAnalysis == false){
            isAnalysis=true
            sender.backgroundColor = .red
            sender.setTitle("Stop Analysis", for: .normal)
            audioInput.startRecording()
            
            //----
            startRecording()
            
        }else{
            isAnalysis=false
            sender.backgroundColor = .green
            sender.setTitle("Start Analysis", for: .normal)
            audioInput.stopRecording()
            
            
            //----
            audioEngine.stop()
            recognitionRequest?.endAudio()
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


    
    //MARK:- Speech
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
         let inputNode = audioEngine.inputNode
//        else {
//            fatalError("Audio engine has no input node")
//        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                //let text = result?.bestTranscription.formattedString
                //print(text as Any)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                let text = result?.bestTranscription.formattedString
                let randomInt = Int.random(in: 1...5)
                let dicTemp = NSMutableDictionary()
                dicTemp.setValue("\(randomInt)", forKey: "status_byte")
                dicTemp.setValue(text, forKey: "text")
                appDelegate.arrFFT.add(dicTemp as Any)
                print("Record text array :--------------------\n\(appDelegate.arrFFT)")
               // self.microphoneButton.isEnabled = true
                
                //---
                self.navigationController?.popViewController(animated: true)
//                let stoy = UIStoryboard(name: "Main_Bluetooth", bundle: nil)
//                let vc = stoy.instantiateViewController(withIdentifier: "NearbyDevicesVC") as! NearbyDevicesVC
//                self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        print("Say something, I'm listening!")
        
    }
    
}

