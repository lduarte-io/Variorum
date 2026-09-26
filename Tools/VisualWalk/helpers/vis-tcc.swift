// vis-tcc — does THIS terminal (the responsible process) hold Accessibility and Screen Recording?
// Prints "AX <0|1> SCREEN <0|1>". Checks only; never prompts (granting is the author's).
import ApplicationServices
import CoreGraphics
print("AX \(AXIsProcessTrusted() ? 1 : 0) SCREEN \(CGPreflightScreenCaptureAccess() ? 1 : 0)")
