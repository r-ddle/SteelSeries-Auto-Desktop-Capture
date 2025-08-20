; ===================================================================
; SteelSeries Desktop Capture Auto-Enable Script - PRODUCTION VERSION
; ===================================================================
; Description: Silently enables SteelSeries Desktop Capture service on startup
; Version: 1.0 (Production)
; AutoHotkey Version: v2.0+
; 
; Deployment: Add to Windows Task Scheduler to run at startup
; Execution: Silent background operation, no user interaction
; Repository: https://github.com/yourusername/steelseries-desktop-capture-auto-enable
; ===================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon  ; Hide from system tray for clean startup

; Configuration Constants
SERVICE_NAME := "SteelSeriesCaptureSvc.exe"
DELAY_BETWEEN_ATTEMPTS := 1500  ; 1.5 seconds in milliseconds
MAX_ATTEMPTS := 2
INITIAL_DELAY := 3000  ; 3 second delay after startup for system stabilization

; Start the service check process immediately
StartupServiceCheck()

; ===================================================================
; MAIN FUNCTIONS
; ===================================================================

/**
 * Main startup function - runs service check and exits
 */
StartupServiceCheck() {
    ; Brief delay to allow system services to fully initialize
    Sleep(INITIAL_DELAY)
    
    try {
        ; Check if service is already running
        if (CheckCaptureService()) {
            ; Service already running - exit silently
            ExitApp(0)
        }
        
        ; Service not running - attempt to enable
        success := EnableServiceWithRetry()
        
        ; Exit with appropriate code
        ExitApp(success ? 0 : 1)
        
    } catch Error as e {
        ; Log error to Windows Event Log if possible, then exit
        try {
            ; Attempt to write to Application Event Log
            logMsg := "SteelSeries Desktop Capture Auto-Enable failed: " . e.message
            RunWait('powershell.exe -Command "Write-EventLog -LogName Application -Source \\"Application\\" -EventId 1001 -EntryType Error -Message \\"' . logMsg . '\\""', "", "Hide")
        }
        ExitApp(1)
    }
}

/**
 * Enable service with retry logic
 * Returns: Boolean indicating overall success
 */
EnableServiceWithRetry() {
    ; First attempt
    if (!EnableDesktopCapture()) {
        return false
    }
    
    ; Wait and verify
    Sleep(DELAY_BETWEEN_ATTEMPTS)
    if (CheckCaptureService()) {
        return true
    }
    
    ; Second attempt
    if (!EnableDesktopCapture()) {
        return false
    }
    
    ; Final verification
    Sleep(DELAY_BETWEEN_ATTEMPTS)
    return CheckCaptureService()
}

/**
 * Check if SteelSeries capture service is running
 * Returns: Boolean - true if running, false if not
 */
CheckCaptureService() {
    try {
        return ProcessExist(SERVICE_NAME) > 0
    } catch {
        return false
    }
}

/**
 * Send Alt+P keystroke to enable desktop capture
 * Returns: Boolean indicating success
 */
EnableDesktopCapture() {
    try {
        ; Use Send function for maximum reliability in v2
        Send("!p")  ; Alt+P
        return true
    } catch {
        return false
    }
}

; ===================================================================
; PRODUCTION SCRIPT - MINIMAL OVERHEAD DESIGN
; ===================================================================
; This script is designed for:
; - Maximum reliability and compatibility
; - Minimal resource usage (< 10MB RAM, < 10 seconds execution)
; - Silent operation with no user interaction
; - Quick execution and clean exit
; - Fail-safe operation (won't break if SteelSeries not installed)
; ===================================================================