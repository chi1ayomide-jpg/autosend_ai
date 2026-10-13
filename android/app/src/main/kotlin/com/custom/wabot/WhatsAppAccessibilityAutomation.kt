package com.custom.wabot

import android.accessibilityservice.AccessibilityService
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class WhatsAppAccessibilityAutomation : AccessibilityService() {

    companion object {
        var pendingMessage: String? = null
        var isExecuting: Boolean = false
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isExecuting || pendingMessage.isNullOrEmpty()) return

        val rootNode = rootInActiveWindow ?: return

        // 1. Check for "OK" or "Continue" popups if WhatsApp shows contact confirmation
        try {
            val okNodes = rootNode.findAccessibilityNodeInfosByText("OK")
            if (okNodes.isNotEmpty() && okNodes[0].isVisibleToUser) {
                okNodes[0].performAction(AccessibilityNodeInfo.ACTION_CLICK)
            }
        } catch (_: Exception) {}

        // 2. Search for Chat input field by view ID or editable class name
        val inputNodes = rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp:id/entry")
            .ifEmpty { rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp.w4b:id/entry") }
            .ifEmpty { rootNode.findAccessibilityNodeInfosByViewId("com.gbwhatsapp:id/entry") }
            .ifEmpty { findEditableNodes(rootNode) }

        if (inputNodes.isNotEmpty()) {
            val chatInput = inputNodes[0]
            val arguments = Bundle().apply {
                putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, pendingMessage)
            }
            chatInput.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, arguments)
            Log.d("OmniFlowAccessibility", "Typed message: $pendingMessage")

            // 3. Locate and tap the "Send" button across Standard, Business, and GB variants
            val sendNodes = rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp:id/send")
                .ifEmpty { rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp.w4b:id/send") }
                .ifEmpty { rootNode.findAccessibilityNodeInfosByViewId("com.gbwhatsapp:id/send") }
                .ifEmpty { rootNode.findAccessibilityNodeInfosByText("Send") }

            if (sendNodes.isNotEmpty()) {
                sendNodes[0].performAction(AccessibilityNodeInfo.ACTION_CLICK)
                Log.d("OmniFlowAccessibility", "Clicked Send button successfully!")
                pendingMessage = null
                isExecuting = false

                // Auto return back to OmniFlow AI after sending
                Handler(Looper.getMainLooper()).postDelayed({
                    try {
                        performGlobalAction(GLOBAL_ACTION_BACK)
                    } catch (e: Exception) {
                        Log.e("OmniFlowAccessibility", "Failed to navigate back: ${e.message}")
                    }
                }, 800)
            }
        }
    }

    private fun findEditableNodes(node: AccessibilityNodeInfo): List<AccessibilityNodeInfo> {
        val list = mutableListOf<AccessibilityNodeInfo>()
        if (node.isEditable) {
            list.add(node)
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            list.addAll(findEditableNodes(child))
        }
        return list
    }

    override fun onInterrupt() {
        Log.w("OmniFlowAccessibility", "Accessibility Service Interrupted")
    }
}
