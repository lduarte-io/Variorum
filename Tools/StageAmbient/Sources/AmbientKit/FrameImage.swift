import CoreGraphics
import Foundation

public enum FrameImage {
    /// A 1-bit frame (0 / 255 bytes) as a DeviceGray image, optionally scaled up nearest-neighbour. For
    /// the offscreen renders; the window app hands Core Animation 32-bit frames of its own.
    public static func gray(_ frame: UnsafeMutableBufferPointer<UInt8>, size: PixelSize, scale: Int = 1) -> CGImage? {
        let w = size.width * scale, h = size.height * scale
        var data = Data(count: w * h)
        data.withUnsafeMutableBytes { (dst: UnsafeMutableRawBufferPointer) in
            let d = dst.bindMemory(to: UInt8.self)
            if scale == 1 {
                d.baseAddress!.update(from: frame.baseAddress!, count: size.count)
            } else {
                for y in 0..<h {
                    let sy = y / scale
                    for x in 0..<w { d[y * w + x] = frame[sy * size.width + x / scale] }
                }
            }
        }
        guard let provider = CGDataProvider(data: data as CFData) else { return nil }
        return CGImage(width: w, height: h, bitsPerComponent: 8, bitsPerPixel: 8, bytesPerRow: w,
                       space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: 0),
                       provider: provider, decode: nil, shouldInterpolate: false, intent: .defaultIntent)
    }
}
