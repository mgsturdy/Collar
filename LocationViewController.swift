import UIKit
import MapKit
import CocoaMQTT
import CoreLocation
import UserNotifications

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    private var mqtt: CocoaMQTT!
    private let locationManager = CLLocationManager()
    private var geofenceRegion: CLCircularRegion?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        setupMQTT()
        requestNotificationPermission()
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
        
        if let geofenceRegion = geofenceRegion {
            if geofenceRegion.contains(location) == false {
                locationManager(manager: locationManager, didExitRegion: geofenceRegion)
            }
        }
    }

    private func setupGeofence(latitude: CLLocationDegrees, longitude: CLLocationDegrees, radius: CLLocationDistance) {
        let geofenceCenter = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        geofenceRegion = CLCircularRegion(center: geofenceCenter, radius: radius, identifier: "Geofence")
        geofenceRegion?.notifyOnExit = true
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }

    private func sendGeofenceNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Geofence Alert"
        content.body = "MQTT device has left the geofence area!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "GeofenceNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error sending geofence notification: \(error.localizedDescription)")
            } else {
                print("Geofence notification sent.")
            }
        }
    }

        // CLLocationManagerDelegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if geofenceRegion == nil {
                let geofenceRadius: CLLocationDistance = 100 // radius in meters
                setupGeofence(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, radius: geofenceRadius)
            }
            // Handle other location updates, e.g., send location to another device via MQTT
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == "Geofence" {
            sendGeofenceNotification()
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

