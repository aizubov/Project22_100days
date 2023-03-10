//
//  ViewController.swift
//  Project22_100days
//
//  Created by user228564 on 3/9/23.
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var myLabel: UILabel!
    @IBOutlet weak var distanceReading: UILabel!
    
    var locationManager: CLLocationManager?
    var firstDetected: Bool = true
    var currentBeaconUuid: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        myLabel.text = "No beacon"
        
        myView.layer.cornerRadius = 128
        myView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        beaconAdd(uuid: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", identifier: "Apple AirLocate E2C56DB5")
        beaconAdd(uuid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", identifier: "Apple AirLocate 5A4BCFCE")
        beaconAdd(uuid:"74278BDA-B644-4520-8F0C-720EAF059935", identifier: "Apple AirLocate 74278BDA")
    }
    
    func beaconAdd(uuid: String, identifier: String) {
        let uuid = UUID(uuidString: uuid)!
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: identifier)
        let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid)
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: beaconConstraint)
    }
    
    func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 1) { [weak self] in
            self?.myLabel.text = "\(name)"

            switch distance {
            case .far:
                self?.view.backgroundColor = .blue
                self?.distanceReading.text = "FAR"
                self?.myView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                
            case .near:
                self?.view.backgroundColor = .orange
                self?.distanceReading.text = "NEAR"
                self?.myView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            case .immediate:
                self?.view.backgroundColor = .red
                self?.distanceReading.text = "RIGHT HERE"
                self?.myView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

            case .unknown:
                fallthrough
                
            default:
                self?.view.backgroundColor = .gray
                self?.distanceReading.text = "UNKNWON"
                self?.myLabel.text = "No beacon"
                self?.myView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
    }
    
    func firstTimeBeaconDetected() {
        if firstDetected {
            firstDetected = false
            let ac = UIAlertController(title: "Beacon detected", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            
            if currentBeaconUuid == nil { currentBeaconUuid = region.uuid }
            guard currentBeaconUuid == region.uuid else { return }
            
            update(distance: beacon.proximity, name: region.identifier)
            firstTimeBeaconDetected()
        } else {
            update(distance: .unknown, name: "No beacon")
        }
    }
}


