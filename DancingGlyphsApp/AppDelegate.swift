
import Cocoa
import ScreenSaver

@NSApplicationMain
class AppDelegate: NSObject
{
    @IBOutlet weak var window: NSWindow!
    
    var view: ScreenSaverView!
 
    func setupAndStartAnimation()
    {
        view = DancingGlyphsView(frame: window.contentView!.frame, isPreview: false)
        view.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)
        window.backingType = DancingGlyphsView.backingStoreType()
        view.startAnimation()
    }
    
    @IBAction func showPreferences(_ sender: NSObject!)
    {
        window.beginSheet(view.configureSheet()!, completionHandler: nil)
    }

}


extension AppDelegate: NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        setupAndStartAnimation()
    }
}


extension AppDelegate: NSWindowDelegate
{
    func windowWillClose(_ notification: Notification)
    {
        NSApplication.shared().terminate(window)
    }
    
    func windowDidResize(_ notification: Notification)
    {
    }
    
    func windowDidEndSheet(_ notification: Notification)
    {
        view.stopAnimation()
        view.startAnimation()
    }
}
