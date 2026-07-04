package com.tvtextfield.tv_textfield

import android.graphics.Color
import android.graphics.Typeface
import android.text.InputType
import android.view.Gravity
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class TvTextFieldFactory(private val messenger: BinaryMessenger) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: android.content.Context, viewId: Int, args: Any?): PlatformView {
        @Suppress("UNCHECKED_CAST")
        val params = args as? Map<String, Any?> ?: emptyMap()
        return TvTextFieldPlatformView(context, messenger, viewId, params)
    }
}

class TvTextFieldPlatformView(
    context: android.content.Context,
    messenger: BinaryMessenger,
    viewId: Int,
    private var params: Map<String, Any?>,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val channel = MethodChannel(messenger, "tv_textfield/edit_text_$viewId")
    private val editText = EditText(context)

    init {
        channel.setMethodCallHandler(this)
        applyParams()
        editText.setOnFocusChangeListener { _, hasFocus ->
            channel.invokeMethod("onFocusChanged", hasFocus)
        }
        editText.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: android.text.Editable?) {
                if (suppressTextEvents) {
                    return
                }
                channel.invokeMethod("onTextChanged", s?.toString() ?: "")
            }
        })
        editText.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE ||
                actionId == EditorInfo.IME_ACTION_GO ||
                actionId == EditorInfo.IME_ACTION_NEXT ||
                actionId == EditorInfo.IME_ACTION_SEARCH ||
                actionId == EditorInfo.IME_ACTION_SEND
            ) {
                channel.invokeMethod("onSubmitted", editText.text?.toString() ?: "")
                true
            } else {
                false
            }
        }
        editText.isFocusable = true
        editText.isFocusableInTouchMode = true
    }

    private var suppressTextEvents = false

    private fun applyParams() {
        editText.hint = params["hint"] as? String ?: ""
        val text = params["text"] as? String ?: ""
        if (editText.text.toString() != text) {
            suppressTextEvents = true
            try {
                editText.setText(text)
                editText.setSelection(text.length)
            } finally {
                suppressTextEvents = false
            }
        }
        editText.isEnabled = params["enabled"] as? Boolean ?: true
        editText.inputType = mapKeyboardType(params["keyboardType"] as? String)
        if (params["obscureText"] as? Boolean == true) {
            editText.inputType =
                editText.inputType or InputType.TYPE_TEXT_VARIATION_PASSWORD
            editText.transformationMethod =
                android.text.method.PasswordTransformationMethod.getInstance()
        }
        val textColor = params["textColor"] as? Number
        if (textColor != null) {
            editText.setTextColor(textColor.toInt())
        } else {
            editText.setTextColor(Color.WHITE)
        }
        editText.setHintTextColor(Color.GRAY)
        editText.setBackgroundColor(Color.TRANSPARENT)
        editText.typeface = Typeface.DEFAULT
        editText.maxLines = (params["maxLines"] as? Number)?.toInt() ?: 1
        editText.minLines = (params["minLines"] as? Number)?.toInt() ?: 1
        editText.gravity = mapTextAlign(params["textAlign"] as? String)
        if (params["autofocus"] as? Boolean == true) {
            editText.requestFocus()
        }
        mapImeAction(params["textInputAction"] as? String)?.let { editText.imeOptions = it }
    }

    private fun mapKeyboardType(name: String?): Int {
        return when (name) {
            "number" -> InputType.TYPE_CLASS_NUMBER
            "phone" -> InputType.TYPE_CLASS_PHONE
            "emailAddress" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS
            "url" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_URI
            "visiblePassword" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD
            "multiline" -> InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE
            else -> InputType.TYPE_CLASS_TEXT
        }
    }

    private fun mapTextAlign(name: String?): Int {
        return when (name) {
            "center" -> Gravity.CENTER
            "right", "end" -> Gravity.CENTER_VERTICAL or Gravity.END
            else -> Gravity.CENTER_VERTICAL or Gravity.START
        }
    }

    private fun mapImeAction(name: String?): Int? {
        return when (name) {
            "done" -> EditorInfo.IME_ACTION_DONE
            "go" -> EditorInfo.IME_ACTION_GO
            "next" -> EditorInfo.IME_ACTION_NEXT
            "search" -> EditorInfo.IME_ACTION_SEARCH
            "send" -> EditorInfo.IME_ACTION_SEND
            else -> null
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setText" -> {
                val text = call.arguments as? String ?: ""
                if (editText.text.toString() != text) {
                    suppressTextEvents = true
                    try {
                        editText.setText(text)
                        editText.setSelection(text.length)
                    } finally {
                        suppressTextEvents = false
                    }
                }
                result.success(null)
            }
            "setFocused" -> {
                val focused = call.arguments as? Boolean ?: false
                if (focused) {
                    editText.requestFocus()
                } else {
                    editText.clearFocus()
                }
                result.success(null)
            }
            "update" -> {
                @Suppress("UNCHECKED_CAST")
                params = call.arguments as? Map<String, Any?> ?: params
                applyParams()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    override fun getView(): View = editText

    override fun dispose() {
        channel.setMethodCallHandler(null)
    }
}
