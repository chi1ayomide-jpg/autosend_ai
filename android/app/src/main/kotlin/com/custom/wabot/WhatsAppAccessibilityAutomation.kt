package com.custom.wabot

import android.accessibilityservice.AccessibilityService
import android.os.Bundle
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

        // Search for Chat input field by view ID or editable class name
        val inputNodes = rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp:id/entry")
            .ifEmpty { rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp.w4b:id/entry") }
            .ifEmpty { findEditableNodes(rootNode) }

        if (inputNodes.isNotEmpty()) {
            val chatInput = inputNodes[0]
            val arguments = Bundle().apply {
                putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, pendingMessage)
            }
            chatInput.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, arguments)
            Log.d("WabotAccessibility", "Typed pending message: $pendingMessage")

            // Locate and tap the "Send" button
            val sendNodes = rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp:id/send")
                .ifEmpty { rootNode.findAccessibilityNodeInfosByViewId("com.whatsapp.w4b:id/send") }
                .ifEmpty { rootNode.findAccessibilityNodeInfosByText("Send") }

            if (sendNodes.isNotEmpty()) {
                sendNodes[0].performAction(AccessibilityNodeInfo.ACTION_CLICK)
                Log.d("WabotAccessibility", "Clicked Send button!")
                pendingMessage = null
                isExecuting = false
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
        Log.w("WabotAccessibility", "Accessibility Service Interrupted")
    }
}
