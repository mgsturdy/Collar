# Collar

Set up your project in Xcode and add the CocoaMQTT library using Swift Package Manager. You can find the library here: https://github.com/emqx/CocoaMQTT

Create a Tab Bar Controller and add the necessary View Controllers for your menu choices. You can do this either in the Interface Builder or programmatically. Two View Controllers, one for displaying the GPS location and one for settings.

Implement the MQTT functionality in your application. You can create a separate class for this or add the functionality directly to the relevant View Controller.

Main.storyboard:

Set up a Tab Bar Controller with two View Controllers. Assign the classes LocationViewController and SettingsViewController to the respective View Controllers.

Add the following keys to your info.plist file:

note you will need key/string identifiers before these. the read-mes screw this up


<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to display it on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to display it on the map.</string>

make sure you have the "isinitialviewcontroller" ticked for the locationviewcontroller in the storyboard
