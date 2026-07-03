package com.tvtextfield.tv_textfield

import android.content.res.Configuration
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class TvTextfieldPlugin : FlutterPlugin, ActivityAware, MethodChannel.MethodCallHandler {
    private var flutterPluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private var activityBinding: ActivityPluginBinding? = null
    private var platformChannel: MethodChannel? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        flutterPluginBinding = binding
        binding.platformViewRegistry.registerViewFactory(
            "tv_textfield/edit_text",
            TvTextFieldFactory(binding.binaryMessenger),
        )
        platformChannel = MethodChannel(binding.binaryMessenger, "tv_textfield/platform")
        platformChannel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        platformChannel?.setMethodCallHandler(null)
        platformChannel = null
        flutterPluginBinding = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getPlatformInfo" -> {
                val context = activityBinding?.activity ?: flutterPluginBinding?.applicationContext
                val uiMode = context?.resources?.configuration?.uiMode ?: 0
                val isAndroidTv =
                    (uiMode and Configuration.UI_MODE_TYPE_MASK) ==
                        Configuration.UI_MODE_TYPE_TELEVISION
                result.success(
                    mapOf(
                        "isAndroidTv" to isAndroidTv,
                        "isTvOS" to false,
                        "isTelevision" to isAndroidTv,
                    ),
                )
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }
}
