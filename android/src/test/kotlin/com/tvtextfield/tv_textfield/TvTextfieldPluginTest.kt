package com.tvtextfield.tv_textfield

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.mockito.Mockito
import kotlin.test.Test
import kotlin.test.assertEquals

internal class TvTextfieldPluginTest {
    @Test
    fun onMethodCall_unknownMethod_isNotImplemented() {
        val plugin = TvTextfieldPlugin()
        val call = MethodCall("unknownMethod", null)
        val mockResult: MethodChannel.Result = Mockito.mock(MethodChannel.Result::class.java)
        plugin.onMethodCall(call, mockResult)
        Mockito.verify(mockResult).notImplemented()
    }

    @Test
    fun onMethodCall_getPlatformInfo_withoutActivity_returnsNonTvDefaults() {
        val plugin = TvTextfieldPlugin()
        val call = MethodCall("getPlatformInfo", null)
        var resultPayload: Map<String, Any>? = null
        val mockResult = object : MethodChannel.Result {
            override fun success(result: Any?) {
                @Suppress("UNCHECKED_CAST")
                resultPayload = result as? Map<String, Any>
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                throw AssertionError("Unexpected error: $errorCode")
            }

            override fun notImplemented() {
                throw AssertionError("Unexpected notImplemented")
            }
        }

        plugin.onMethodCall(call, mockResult)

        assertEquals(false, resultPayload?.get("isAndroidTv"))
        assertEquals(false, resultPayload?.get("isTvOS"))
        assertEquals(false, resultPayload?.get("isTelevision"))
    }
}
