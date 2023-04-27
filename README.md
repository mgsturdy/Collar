# GeoFence

Set up your project in Xcode and add the CocoaMQTT library using Swift Package Manager. You can find the library here: https://github.com/emqx/CocoaMQTT

I used CocoaPods to intall the package dependences. There is some info online about this. 


Create a StoryBoard application with UIkit.



Add the following keys to your info.plist file:

<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to display it on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to display it on the map.</string>

Other Package Dependencies

- CocoaMQTT 2.1.3
- MqttCocoaAsyncSocket 1.0.8
- Starscream 3.1.2

