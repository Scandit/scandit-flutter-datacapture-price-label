import Flutter
import UIKit

public class ScanditFlutterDataCapturePriceLabelPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = ScanditFlutterDataCapturePriceLabelPlugin()
        registrar.publish(instance)
    }
}
