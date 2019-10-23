//
//  FirstScreenVC.swift
//  TempiFFT
//
//  Created by Maulik Vinodbhai Vora on 14/10/19.
//  Copyright © 2019 John Scalo. All rights reserved.
//

import UIKit

class FirstScreenVC: UIViewController {

    //MARK:- func
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let value = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
    }
    
    
    //MARK:- IBAction
    @IBAction func btnWiFi(_ sender: Any) {
        let stoy = UIStoryboard(name: "Main_UDP", bundle: nil)
        let vc = stoy.instantiateViewController(withIdentifier: "UDPViewController") as! UDPViewController
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }

    @IBAction func btnBLE(_ sender: Any) {
        print("Record text array :--------------------\n\(appDelegate.arrFFT)")
        
        let stoy = UIStoryboard(name: "Main_Bluetooth", bundle: nil)
        let vc = stoy.instantiateViewController(withIdentifier: "NearbyDevicesVC") as! NearbyDevicesVC
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnFFT(_ sender: Any) {
          let storyBoard = self.storyboard?.instantiateViewController(withIdentifier: "SpectralViewController") as! SpectralViewController
          self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"back", style:.plain, target:nil, action:nil)
          self.navigationController?.pushViewController(storyBoard, animated: true)
      }

    
}
