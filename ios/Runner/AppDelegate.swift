import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  // Channel names - must match exactly with the Flutter side
  private let METHOD_CHANNEL = "com.example.native_bridge/methods"
  private let EVENT_CHANNEL = "com.example.native_bridge/events"
  private let BASIC_MESSAGE_CHANNEL = "com.example.native_bridge/basic_messages"
  
  // For event channel
  private var eventSink: FlutterEventSink?
  private var timer: Timer?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Get the Flutter view controller and binary messenger
    let controller = window?.rootViewController as! FlutterViewController
    let messenger = controller.binaryMessenger
    
    // Setup Method Channel
    setupMethodChannel(messenger: messenger)
    
    // Setup Event Channel
    setupEventChannel(messenger: messenger)
    
    // Setup Basic Message Channel
    setupBasicMessageChannel(messenger: messenger)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Method Channel Implementation
  
  private func setupMethodChannel(messenger: FlutterBinaryMessenger) {
    let methodChannel = FlutterMethodChannel(name: METHOD_CHANNEL, binaryMessenger: messenger)
    
    methodChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      
      switch call.method {
      case "getBatteryLevel":
        self.getBatteryLevel(result: result)
      case "getDeviceInfo":
        self.getDeviceInfo(result: result)
      case "computeSum":
        self.computeSum(call: call, result: result)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
  
  private func getBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
    
    if device.batteryState == UIDevice.BatteryState.unknown {
      result(FlutterError(code: "UNAVAILABLE", message: "Battery level not available.", details: nil))
    } else {
      let batteryLevel = Int(device.batteryLevel * 100)
      result(batteryLevel)
    }
    
    // Turn off battery monitoring
    device.isBatteryMonitoringEnabled = false
  }
  
  private func getDeviceInfo(result: FlutterResult) {
    let device = UIDevice.current
    let deviceInfo = """
      iOS \(device.systemVersion), 
      \(device.model), 
      \(device.name)
      """
    result(deviceInfo)
  }
  
  private func computeSum(call: FlutterMethodCall, result: FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let a = args["a"] as? Int,
          let b = args["b"] as? Int else {
      result(FlutterError(code: "INVALID_ARGUMENTS", message: "Could not compute sum with given arguments", details: nil))
      return
    }
    
    result(a + b)
  }
  
  // MARK: - Event Channel Implementation
  
  private func setupEventChannel(messenger: FlutterBinaryMessenger) {
    let eventChannel = FlutterEventChannel(name: EVENT_CHANNEL, binaryMessenger: messenger)
    
    // Create a handler for the event channel
    class EventChannelHandler: NSObject, FlutterStreamHandler {
      weak var appDelegate: AppDelegate?
      
      init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        super.init()
      }
      
      func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        print("EventChannel: Started listening")
        appDelegate?.eventSink = events
        appDelegate?.startEventChannel()
        return nil
      }
      
      func onCancel(withArguments arguments: Any?) -> FlutterError? {
        print("EventChannel: Stopped listening")
        appDelegate?.stopEventChannel()
        appDelegate?.eventSink = nil
        return nil
      }
    }
    
    // Set the stream handler
    let handler = EventChannelHandler(appDelegate: self)
    eventChannel.setStreamHandler(handler)
  }
  
  private func startEventChannel() {
    // Start sending events every 3 seconds
    timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
      guard let self = self, let eventSink = self.eventSink else { return }
      
      // Generate some example event data
      let eventTypes = ["ACCELEROMETER", "GYROSCOPE", "PROXIMITY"]
      let eventType = eventTypes[Int.random(in: 0..<eventTypes.count)]
      let eventValue = Int.random(in: 0...100)
      
      // Create a dictionary with event data
      let eventData: [String: Any] = [
        "type": eventType,
        "value": eventValue,
        "timestamp": Date().timeIntervalSince1970 * 1000  // Current time in milliseconds
      ]
      
      // Send the event to Flutter
      eventSink(eventData)
    }
  }
  
  private func stopEventChannel() {
    timer?.invalidate()
    timer = nil
  }
  
  // MARK: - Basic Message Channel Implementation
  
  private func setupBasicMessageChannel(messenger: FlutterBinaryMessenger) {
    let messageChannel = FlutterBasicMessageChannel(
      name: BASIC_MESSAGE_CHANNEL,
      binaryMessenger: messenger,
      codec: FlutterStandardMessageCodec.sharedInstance()
    )
    
    messageChannel.setMessageHandler { [weak self] (message, reply) in
      guard let message = message else {
        reply("No message received")
        return
      }
      
      print("Received message from Flutter: \(message)")
      
      // Echo the message back with some additional data
      let response = "iOS received: '\(message)' at \(Date().timeIntervalSince1970 * 1000)"
      
      // Reply to Flutter
      reply(response)
    }
  }
}
