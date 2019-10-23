//
//  ViewController.swift
//  BLEDemo
//
//  Created by Jindrich Dolezy on 11/04/2018.
//  Copyright © 2018 Dzindra. All rights reserved.
//

import UIKit
import UserNotifications


class DeviceVC: UIViewController {
    
    enum ViewState: Int {
        case disconnected
        case connected
        case ready
    }
    
    var device: BTDevice? {
        didSet {
            navigationItem.title = device?.name ?? "Device"
            device?.delegate = self
        }
    }
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var blinkSwitch: UISwitch!
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var serialLabel: UILabel!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var volumePatchButton: UIButton!
    @IBOutlet weak var filterPatchButton: UIButton!
    @IBOutlet weak var rangeSlider: UISlider!
    @IBOutlet weak var pitchPatchButton: UIButton!
    @IBOutlet weak var modulationPatchButton: UIButton!
    @IBOutlet weak var effectPatchButton: UIButton!
    @IBOutlet weak var crossfaderPatchButton: UIButton!


    var viewState: ViewState = .disconnected {
        didSet {
            switch viewState {
            case .disconnected:
                statusLabel.text = "Disconnected"
                blinkSwitch.isEnabled = false
                blinkSwitch.isOn = false
                speedSlider.isEnabled = false
                rangeSlider.isEnabled = false
                disconnectButton.isEnabled = false
                serialLabel.isHidden = true
            case .connected:
                statusLabel.text = "Probing..."
                blinkSwitch.isEnabled = false
                blinkSwitch.isOn = false
                speedSlider.isEnabled = false
                rangeSlider.isEnabled = false
                disconnectButton.isEnabled = true
                serialLabel.isHidden = true
            case .ready:
                statusLabel.text = "Ready"
                blinkSwitch.isEnabled = true
                disconnectButton.isEnabled = true
                serialLabel.isHidden = false
                speedSlider.isEnabled = true
                rangeSlider.isEnabled = true

                if let b = device?.blink {
                    blinkSwitch.isOn = b
                }
                if let s = device?.speed {
                    speedSlider.value = Float(s)
                }
                if let s = device?.range {
                    rangeSlider.value = Float(s)
                }
                serialLabel.text = device?.serial ?? "reading..."
            }
        }
    }
    
    deinit {
        device?.disconnect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Record text array :--------------------\n\(appDelegate.arrFFT)")
        
        viewState = .disconnected
    }

    @IBAction func disconnectAction() {
        device?.disconnect()
    }

    @IBAction func blinkChanged(_ sender: Any) {
        device?.blink = blinkSwitch.isOn
    }

    @IBAction func speedChanged(_ sender: UISlider) {
        device?.speed = Int(speedSlider.value)
    }

    @IBAction func rangeChanged(_ sender: UISlider) {
        device?.range = Int(rangeSlider.value)
    }
    
    @IBAction func volumePatchButton(_ sender: UIButton) {
        device?.patch = 1
        //--- create the alert
       let alert = UIAlertController(title: "VOLUME Patch", message: "Fader controls VOLUME ", preferredStyle: UIAlertController.Style.alert)
       //--- add an action (button)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
       //--- show the alert
       self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func filterPatchButton(_ sender: UIButton) {
        device?.patch = 3
        //--- create the alert
       let alert = UIAlertController(title: "FILTER Patch", message: "Fader controls FILTER ", preferredStyle: UIAlertController.Style.alert)
       //--- add an action (button)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
       //--- show the alert
       self.present(alert, animated: true, completion: nil)
    }

    @IBAction func pitchPatchButton(_ sender: UIButton) {
        device?.patch = 4
        //--- create the alert
       let alert = UIAlertController(title: "PITCH Patch", message: "Fader controls PITCH ", preferredStyle: UIAlertController.Style.alert)
       //--- add an action (button)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
       //--- show the alert
       self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func modulationPatchButton(_ sender: UIButton) {
        device?.patch = 5
        //--- create the alert
       let alert = UIAlertController(title: "MODULATION Patch", message: "Fader controls MODULATION ", preferredStyle: UIAlertController.Style.alert)
       //--- add an action (button)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
       //--- show the alert
       self.present(alert, animated: true, completion: nil)
    }

    @IBAction func effectPatchButton(_ sender: UIButton) {
        device?.patch = 6
        //--- create the alert
       let alert = UIAlertController(title: "EFFECT Patch", message: "Fader controls EFFECT ", preferredStyle: UIAlertController.Style.alert)
       //--- add an action (button)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
       //--- show the alert
       self.present(alert, animated: true, completion: nil)
    }

    @IBAction func crossfaderPatchButton(_ sender: UIButton) {
        device?.patch = 2
        //--- create the alert
       let alert = UIAlertController(title: "CROSSFADER Patch", message: "Fader controls CROSSFADER ", preferredStyle: UIAlertController.Style.alert)
       //--- add an action (button)
       alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
       //--- show the alert
       self.present(alert, animated: true, completion: nil)
    }
}

extension DeviceVC: BTDeviceDelegate {
    func deviceSerialChanged(value: String) {
        serialLabel.text = value
    }
    
    func deviceSpeedChanged(value: Int) {
        speedSlider.value = Float(value)
    }
    
    func deviceRangeChanged(value: Int) {
        rangeSlider.value = Float(value)
    }

    func devicePatchChanged(value: Int) {
        //! anpassen !
        rangeSlider.value = Float(value)
    }

    func deviceConnected() {
        viewState = .connected
    }
    
    func deviceDisconnected() {
        viewState = .disconnected
    }
    
    func deviceReady() {
        viewState = .ready
    }
    
    func deviceBlinkChanged(value: Bool) {
        blinkSwitch.setOn(value, animated: true)
        
        if UIApplication.shared.applicationState == .background {
            let content = UNMutableNotificationContent()
            content.title = "ESP Blinky"
            content.body = value ? "Now blinking" : "Not blinking anymore"
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request) { (error) in
                if let error = error {
                    print("DeviceVC: failed to deliver notification \(error)")
                }
            }
        }
    }
    
    
}
