# DancingGlyphs
A screen saver for OS X that shows three ThoughtWorks glyphs dancing around.

This is work-in-progress. Plase note:

* Currently there is no configuration sheet, all configuration must be done in the source code at the top of `DancingGlypsView.swift`

* Rendering is not hardware accelerated yet and consumes a lot of CPU. Don't use this on battery power (yet).

* Rendering is also not multithreaded which puts a limit on performance. On a middle-of-the-road MacBook Pro (Retina) the framerate drops below 30 FPS when the glyphs are bigger than about 35% of the screen height.

* Frame rate is always displayed in the bottom left corner for now.
