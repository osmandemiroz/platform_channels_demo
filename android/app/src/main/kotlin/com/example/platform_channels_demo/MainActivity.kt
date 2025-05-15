package com.example.platform_channels_demo

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BasicMessageChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import java.util.Random

class MainActivity : FlutterActivity() {
    private val TAG = "NativeBridge"
    
    // Channel names - must match exactly with the Flutter side
    private val METHOD_CHANNEL = "com.example.native_bridge/methods"
    private val EVENT_CHANNEL = "com.example.native_bridge/events"
    private val BASIC_MESSAGE_CHANNEL = "com.example.native_bridge/basic_messages"
    
    // For event channel
    private var eventSink: EventChannel.EventSink? = null
    private val random = Random()
    private val handler = Handler(Looper.getMainLooper())
    private var eventRunnable: Runnable? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup Method Channel
        setupMethodChannel(flutterEngine)
        
        // Setup Event Channel
        setupEventChannel(flutterEngine)
        
        // Setup Basic Message Channel
        setupBasicMessageChannel(flutterEngine)
        
        Log.i(TAG, "Flutter engine configured with platform channels")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopEventChannel()
    }

    // MethodChannel implementation
    private fun setupMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Battery level not available.", null)
                    }
                }
                "getDeviceInfo" -> {
                    result.success("Android ${Build.VERSION.RELEASE} (SDK ${Build.VERSION.SDK_INT}), " +
                            "Device: ${Build.MANUFACTURER} ${Build.MODEL}")
                }
                "computeSum" -> {
                    try {
                        val a = call.argument<Int>("a") ?: 0
                        val b = call.argument<Int>("b") ?: 0
                        result.success(a + b)
                    } catch (e: Exception) {
                        result.error("INVALID_ARGUMENTS", "Could not compute sum with given arguments", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    // Get battery level using Android APIs
    private fun getBatteryLevel(): Int {
        val batteryLevel: Int
        
        batteryLevel = if (VERSION.SDK_INT >= VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(null, IntentFilter(Intent.ACTION_BATTERY_CHANGED))
            intent!!.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) * 100 / intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
        }
        
        return batteryLevel
    }

    // EventChannel implementation
    private fun setupEventChannel(flutterEngine: FlutterEngine) {
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    Log.i(TAG, "EventChannel: Started listening")
                    eventSink = events
                    startEventChannel()
                }

                override fun onCancel(arguments: Any?) {
                    Log.i(TAG, "EventChannel: Stopped listening")
                    eventSink = null
                    stopEventChannel()
                }
            }
        )
    }
    
    // Start sending periodic events
    private fun startEventChannel() {
        eventRunnable = object : Runnable {
            override fun run() {
                if (eventSink != null) {
                    // Example sensor data or periodic event
                    val eventType = when (random.nextInt(3)) {
                        0 -> "SENSOR_DATA"
                        1 -> "BATTERY_UPDATE"
                        else -> "LOCATION_UPDATE"
                    }
                    
                    val eventValue = random.nextInt(100)
                    
                    // Create a map with event data
                    val eventData = HashMap<String, Any>()
                    eventData["type"] = eventType
                    eventData["value"] = eventValue
                    eventData["timestamp"] = System.currentTimeMillis()
                    
                    // Send the event to Flutter
                    eventSink?.success(eventData)
                    
                    // Schedule the next event
                    handler.postDelayed(this, 3000) // Send event every 3 seconds
                }
            }
        }
        
        // Start sending events immediately
        handler.post(eventRunnable!!)
    }
    
    // Stop sending events
    private fun stopEventChannel() {
        eventRunnable?.let { handler.removeCallbacks(it) }
        eventRunnable = null
    }

    // BasicMessageChannel implementation
    private fun setupBasicMessageChannel(flutterEngine: FlutterEngine) {
        val messageChannel = BasicMessageChannel(flutterEngine.dartExecutor.binaryMessenger, 
                                               BASIC_MESSAGE_CHANNEL, 
                                               StandardMessageCodec.INSTANCE)
        
        messageChannel.setMessageHandler { message, reply ->
            Log.i(TAG, "Received message from Flutter: $message")
            
            // Echo the message back with some additional data
            val response = "Android received: '$message' at ${System.currentTimeMillis()}"
            
            // Reply to Flutter
            reply.reply(response)
        }
    }
}
