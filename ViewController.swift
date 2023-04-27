//
//  ViewController.swift
//  Geofence
//
//  Created by Matthew Goulet on 4/27/23.
//

import UIKit
import MapKit
import CoreLocation
import CocoaMQTT

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupMapView()
        setupLocationManager()
        setupLocationButton()
        setupGeofenceButton()
        setupGeofenceSlider()
        setupGeofenceRadiusLabel()
        setupMQTTClient()
    }
    
    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    private var geofenceButton: UIButton!
    private var geofenceSlider: UISlider!
    private var geofenceOverlay: MKCircle?
    private var geofenceRadiusLabel: UILabel!
    private var mqttClient: CocoaMQTT?
    
    private func setupMapView() {
        mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.showsUserLocation = true
        mapView.delegate = self // Set the delegate to self
        view.addSubview(mapView)

        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupMQTTClient() {
        let clientID = "iPhones" // Replace this with a unique client ID
        let mqttHost = "4451d218b08f49b0adf1e5d0357e53e6.s1.eu.hivemq.cloud" // Replace this with your MQTT host address
        let mqttPort: UInt16 = 8883 // Replace this with your MQTT host port (default SSL/TLS port is 8883)

        mqttClient = CocoaMQTT(clientID: clientID, host: mqttHost, port: mqttPort)
        mqttClient?.delegate = self

        // Enable SSL/TLS
        mqttClient?.enableSSL = true

        // Allow untrusted CA certificates (not recommended for production)
        // Only use this option for testing purposes or if you have a self-signed certificate
        mqttClient?.allowUntrustCACertificate = true
        
        // Set the username and password
        mqttClient?.username = "Snake10" // Replace this with your MQTT username
        mqttClient?.password = "quzvy0-xakhaM-peqkyh" // Replace this with your MQTT password


        mqttClient?.connect()
    }

    private func subscribeToTopic() {
        let topic = "#" // Replace this with the topic you want to subscribe to
        mqttClient?.subscribe(topic, qos: .qos1)
    }
    
    private func setupGeofenceRadiusLabel() {
        geofenceRadiusLabel = UILabel()
        geofenceRadiusLabel.translatesAutoresizingMaskIntoConstraints = false
        geofenceRadiusLabel.isHidden = true
        geofenceRadiusLabel.text = "Geofence Radius: \(Int(geofenceSlider.value))m"
        geofenceRadiusLabel.backgroundColor = UIColor.white
        geofenceRadiusLabel.layer.cornerRadius = 5
        geofenceRadiusLabel.clipsToBounds = true
        geofenceRadiusLabel.textAlignment = .center
        geofenceRadiusLabel.numberOfLines = 0
        geofenceRadiusLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        geofenceRadiusLabel.setContentHuggingPriority(.required, for: .horizontal)
        geofenceRadiusLabel.setContentHuggingPriority(.required, for: .vertical)
        geofenceRadiusLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        let padding = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        geofenceRadiusLabel.drawText(in: geofenceRadiusLabel.bounds.inset(by: padding))

        view.addSubview(geofenceRadiusLabel)

        NSLayoutConstraint.activate([
            geofenceRadiusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            geofenceRadiusLabel.bottomAnchor.constraint(equalTo: geofenceSlider.topAnchor, constant: -8)
        ])
    }

    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupLocationButton() {
        let locationButton = UIButton(type: .system)
        locationButton.setTitle("My Location", for: .normal)
        locationButton.addTarget(self, action: #selector(centerMapOnUserLocation), for: .touchUpInside)
        locationButton.translatesAutoresizingMaskIntoConstraints = false

        // Customizations
        locationButton.backgroundColor = UIColor.systemBlue
        locationButton.setTitleColor(UIColor.white, for: .normal)
        locationButton.layer.cornerRadius = 10
        locationButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        view.addSubview(locationButton)

        NSLayoutConstraint.activate([
            locationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            locationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGeofenceButton() {
        geofenceButton = UIButton(type: .system)
        geofenceButton.setTitle("Activate Geofence", for: .normal)
        geofenceButton.addTarget(self, action: #selector(toggleGeofence), for: .touchUpInside)
        geofenceButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Customizations
        geofenceButton.backgroundColor = UIColor.systemBlue
        geofenceButton.setTitleColor(UIColor.white, for: .normal)
        geofenceButton.layer.cornerRadius = 10
        geofenceButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        view.addSubview(geofenceButton)

        NSLayoutConstraint.activate([
            geofenceButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            geofenceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupGeofenceSlider() {
        geofenceSlider = UISlider()
        geofenceSlider.minimumValue = 5
        geofenceSlider.maximumValue = 100
        geofenceSlider.addTarget(self, action: #selector(geofenceRadiusChanged), for: .valueChanged)
        geofenceSlider.translatesAutoresizingMaskIntoConstraints = false
        geofenceSlider.isHidden = true

        view.addSubview(geofenceSlider)

        NSLayoutConstraint.activate([
            geofenceSlider.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            geofenceSlider.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            geofenceSlider.bottomAnchor.constraint(equalTo: geofenceButton.topAnchor, constant: -16)
        ])
    }
    
    @objc private func centerMapOnUserLocation() {
        guard let location = locationManager.location else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        mapView.setRegion(region, animated: true)
    }
    
    @objc private func toggleGeofence() {
        if geofenceSlider.isHidden {
            geofenceButton.setTitle("Deactivate Geofence", for: .normal)
            geofenceSlider.isHidden = false
            geofenceRadiusLabel.isHidden = false
            addGeofenceOverlay(radius: CLLocationDistance(geofenceSlider.value))
        } else {
            geofenceButton.setTitle("Activate Geofence", for: .normal)
            geofenceSlider.isHidden = true
            geofenceRadiusLabel.isHidden = true
            removeGeofenceOverlay()
        }
    }

    @objc private func geofenceRadiusChanged() {
        geofenceRadiusLabel.text = "Geofence Radius: \(Int(geofenceSlider.value))m"
        updateGeofenceOverlay(radius: CLLocationDistance(geofenceSlider.value))
    }

    private func addGeofenceOverlay(radius: CLLocationDistance) {
        guard let location = locationManager.location else { return }
        let circle = MKCircle(center: location.coordinate, radius: radius)
        mapView.addOverlay(circle)
        geofenceOverlay = circle
    }
    
    private func updateGeofenceOverlay(radius: CLLocationDistance) {
        removeGeofenceOverlay()
        addGeofenceOverlay(radius: radius)
    }

    private func removeGeofenceOverlay() {
        if let overlay = geofenceOverlay {
            mapView.removeOverlay(overlay)
            geofenceOverlay = nil
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let circleOverlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: circleOverlay)
            circleRenderer.fillColor = UIColor.black.withAlphaComponent(0.1)
            circleRenderer.strokeColor = UIColor.black
            circleRenderer.lineWidth = 2
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    
    
}

extension ViewController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopics success: NSDictionary, failed: [String]) {
    
        
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        print("Connected to MQTT server: \(ack)")
        
        if ack == .accept {
            subscribeToTopic()
        }
    }

    func mqtt(_ mqtt: CocoaMQTT, didStateChangeTo state: CocoaMQTTConnState) {
        print("MQTT connection state changed: \(state)")
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
        print("Message published: \(message.string ?? "")")
    }

    func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
        print("Published message acknowledged: \(id)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
        print("Message received: \(message.string ?? "")")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopics topics: [String]) {
        print("Subscribed to topic(s): \(topics)")
    }

    func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
        print("Unsubscribed from topic: \(topic)")
    }
    
    func mqttDidPing(_ mqtt: CocoaMQTT) {
        print("Sent PING")
    }
    
    func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
        print("Received PONG")
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        print("MQTT client disconnected: \(err?.localizedDescription ?? "No error")")
    }
}


