; ===================================================================
; SteelSeries Desktop Capture Auto-Enable Script - TEST VERSION
; ===================================================================
; Description: Enables SteelSeries Desktop Capture service by sending Alt+P
; Version: 1.0 (Testing)
; AutoHotkey Version: v2.0+
; 
; Usage: 
; - Press F12 to manually trigger the process
; - Watch console output for debugging
; - ESC to exit script
; ===================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; Configuration Constants
SERVICE_NAME := "SteelSeriesCaptureSvc.exe"
DELAY_BETWEEN_ATTEMPTS := 1500  ; 1.5 seconds in milliseconds
MAX_ATTEMPTS := 2

; Initialize script
LogMessage("SteelSeries Desktop Capture Auto-Enable Script STARTED")
LogMessage("Press F12 to test the service check/enable process")
LogMessage("Press ESC to exit")
LogMessage("Service target: " . SERVICE_NAME)

; Show ready notification
MsgBox("Script Ready!`n`nControls:`n• F12 = Test Desktop Capture enable`n• F11 = Show debug log`n• ESC = Exit script`n`nWatch for tooltips showing progress...", "SteelSeries Test Script", "0x40")

; Hotkey Assignments
F12::{
    LogMessage("F12 key pressed - triggering service check")
    TriggerServiceCheck()
}
F11::{
    ; Show log file contents for debugging
    try {
        logFile := A_ScriptDir . "\SteelSeries_Test.log"
        if FileExist(logFile) {
            logContent := FileRead(logFile)
            MsgBox("Log Contents:`n`n" . logContent, "Debug Log", "0x40")
        } else {
            MsgBox("Log file not found at: " . logFile, "Debug", "0x30")
        }
    } catch Error as e {
        MsgBox("Error reading log: " . e.message, "Debug Error", "0x10")
    }
}
Esc::{
    LogMessage("ESC key pressed - exiting script")
    ExitScript()
}

; ===================================================================
; MAIN FUNCTIONS
; ===================================================================

/**
 * Main function to check and enable desktop capture service
 * Returns: Boolean indicating success
 */
TriggerServiceCheck() {
    LogMessage("")
    LogMessage("=== STARTING SERVICE CHECK SEQUENCE ===")
    
    try {
        ; Initial service check
        if (CheckCaptureService()) {
            LogMessage("✓ Service already running - no action needed")
            MsgBox("Desktop Capture service is already running!", "Success", "0x40")
            return true
        }
        
        LogMessage("⚠ Service not detected - beginning enable sequence")
        
        ; First attempt
        LogMessage("Attempt 1: Sending Alt+P...")
        if (!EnableDesktopCapture()) {
            LogMessage("✗ Failed to send Alt+P on first attempt")
            return false
        }
        
        ; Wait and check
        LogMessage("Waiting " . DELAY_BETWEEN_ATTEMPTS . "ms before verification...")
        WaitWithDelay(DELAY_BETWEEN_ATTEMPTS)
        
        if (CheckCaptureService()) {
            LogMessage("✓ SUCCESS: Service enabled after first attempt")
            MsgBox("Desktop Capture enabled successfully!", "Success", "0x40")
            return true
        }
        
        ; Second attempt
        LogMessage("Service still not running - attempting second activation...")
        LogMessage("Attempt 2: Sending Alt+P...")
        if (!EnableDesktopCapture()) {
            LogMessage("✗ Failed to send Alt+P on second attempt")
            MsgBox("Failed to send Alt+P keystroke. Please check if SteelSeries GG is running.", "Error", "0x10")
            return false
        }
        
        ; Final verification
        WaitWithDelay(DELAY_BETWEEN_ATTEMPTS)
        if (CheckCaptureService()) {
            LogMessage("✓ SUCCESS: Service enabled after second attempt")
            MsgBox("Desktop Capture enabled successfully!", "Success", "0x40")
            return true
        } else {
            LogMessage("✗ FAILED: Service still not running after both attempts")
            MsgBox("Could not enable Desktop Capture after 2 attempts.`n`nPlease verify:`n• SteelSeries GG is installed and running`n• Alt+P shortcut is configured properly", "Service Enable Failed", "0x30")
            return false
        }
        
    } catch Error as e {
        LogMessage("✗ CRITICAL ERROR: " . e.message)
        MsgBox("Script error: " . e.message, "Error", "0x10")
        return false
    }
}

/**
 * Check if SteelSeries capture service is currently running
 * Returns: Boolean - true if running, false if not
 */
CheckCaptureService() {
    try {
        servicePID := ProcessExist(SERVICE_NAME)
        if (servicePID > 0) {
            LogMessage("Service check: RUNNING (PID: " . servicePID . ")")
            return true
        } else {
            LogMessage("Service check: NOT RUNNING")
            return false
        }
    } catch Error as e {
        LogMessage("Error checking service: " . e.message)
        return false
    }
}

/**
 * Send Alt+P keystroke to enable desktop capture
 * Returns: Boolean indicating success
 */
EnableDesktopCapture() {
    try {
        ; Send Alt+P using most reliable method
        Send("!p")  ; ! = Alt modifier, p = P key
        LogMessage("Alt+P keystroke sent successfully")
        return true
    } catch Error as e {
        LogMessage("Failed to send Alt+P: " . e.message)
        return false
    }
}

/**
 * Safe delay function with error handling
 * @param milliseconds - Time to wait
 */
WaitWithDelay(milliseconds) {
    try {
        Sleep(milliseconds)
    } catch Error as e {
        LogMessage("Sleep error: " . e.message)
    }
}

/**
 * Debug logging function with timestamp
 * @param message - Message to log
 */
LogMessage(message) {
    timestamp := FormatTime(A_Now, "HH:mm:ss")
    formattedMessage := "[" . timestamp . "] " . message
    
    ; Output to debug console (visible in debuggers like DebugView)
    OutputDebug(formattedMessage)
    
    ; Show in tooltip for 3 seconds, then clear
    ToolTip(formattedMessage, 10, 10)
    SetTimer(() => ToolTip(), -3000)  ; Clear tooltip after 3 seconds
    
    ; Write to a log file for persistent logging
    try {
        logFile := A_ScriptDir . "\SteelSeries_Test.log"
        FileAppend(formattedMessage . "`n", logFile)
    } catch {
        ; Ignore file write errors to prevent script failure
    }
}

/**
 * Clean exit function
 */
ExitScript() {
    LogMessage("Script terminated by user")
    ToolTip()  ; Clear any remaining tooltips
    ExitApp()
}

; ===================================================================
; SCRIPT INITIALIZATION COMPLETE
; ===================================================================