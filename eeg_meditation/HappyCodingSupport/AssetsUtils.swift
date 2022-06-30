#if os(OSX)
    typealias Image     = NSImage
    typealias ImageName = NSImage.Name
#elseif os(iOS)
    import UIKit

    typealias Image     = UIImage
    typealias ImageName = String
#endif

extension Image {
    static var assetsAppicon: Image { return Image(named: ImageName("AppIcon"))! }
    static var assetsAppiconOld: Image { return Image(named: ImageName("AppIcon_old"))! }
    static var assetsConnection1Dot: Image { return Image(named: ImageName("connection_1dot"))! }
    static var assetsConnection2Dots: Image { return Image(named: ImageName("connection_2dots"))! }
    static var assetsConnection3Dots: Image { return Image(named: ImageName("connection_3dots"))! }
    static var assetsConnectionConnecting: Image { return Image(named: ImageName("connection_connecting"))! }
    static var assetsConnectionNosignal: Image { return Image(named: ImageName("connection_nosignal"))! }
    static var assetsConnectionNosignalRed: Image { return Image(named: ImageName("connection_nosignal_red"))! }
    static var assetsConnectionOk: Image { return Image(named: ImageName("connection_ok"))! }
    static var assetsCounter: Image { return Image(named: ImageName("counter"))! }
    static var assetsMenuInfo: Image { return Image(named: ImageName("menu_info"))! }
    static var assetsSfChevronLeftSquareFill: Image { return Image(named: ImageName("SF_chevron_left_square_fill"))! }
    static var assetsSplashBackground: Image { return Image(named: ImageName("splash_background"))! }
    static var assetsTap: Image { return Image(named: ImageName("tap"))! }
    static var assetsTimer: Image { return Image(named: ImageName("timer"))! }
}