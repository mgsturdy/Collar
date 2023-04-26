import UIKit
import MapKit
import CocoaMQTT
import CoreLocation

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    private var mqtt: CocoaMQTT!
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMQTT()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    private func setupMQTT() {
        let mqttClientID = "your_client_id"
        mqtt = CocoaMQTT(clientID: mqttClientID, host: "4451d218b08f49b0adf1e5d0357e53e6.s1.eu.hivemq.cloud", port: 8883)
        mqtt.username = "Snake10"
        mqtt.password = "quzvy0-xakhaM-peqkyh"
        mqtt.delegate = self
        mqtt.connect()
    }

    private func updateMapLocation(latitude: Double, longitude: Double) {
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }

    // CLLocationManagerDelegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            // Handle location updates, e.g., send location to another device via MQTT
        }
    }
}

extension LocationViewController: CocoaMQTTDelegate {
    func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
        mqtt.subscribe("#")
    }

    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        if let msgString = message.string, let data = msgString.data(using: .utf8) {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let lat = json["latitude"] as? Double, let lon = json["longitude"] as? Double {
                        DispatchQueue.main.async {
                            self.updateMapLocation(latitude: lat, longitude: lon)
                        }
                    }
                }
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
            }
        }
    }
}
