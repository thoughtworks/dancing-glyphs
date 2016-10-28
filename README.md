# ThoughtWorks Glyph Screen Savers

Two screen savers that show ThoughtWorks glyphs dancing around. See below for installation instructions.


## Dancing Glyphs

![dancing-glyphs-sample](https://cloud.githubusercontent.com/assets/954026/17986355/81cb49ce-6b1a-11e6-9ca7-14204b725a2c.gif)

A while ago, while reading Cixin Liu's novel The Three-Body Problem, I saw a shape in our brand asset library that had three of the typical ThoughtWorks glyphs superimposed, and somehow I thought, what if those three glyphs were dancing around each other like the suns in the novel? Wouldn't that make a great screen saver? 


## Glyph Wave

![glyph-wave-sample](https://cloud.githubusercontent.com/assets/954026/19091623/aa2b4db4-8a83-11e6-81e8-d356d4b09305.gif)

At some point when implementing the Dancing Glyphs saver I switched to the Metal API to get the best possible performance while using as little power as possible. I then realised that with Metal I could render hundreds of glyphs, and so I explored different animations. Glyph Wave is the result of this. There are actually two versions of the wave, the linear one shown above and a circular one. By default, the saver selects one by random when it starts.


## Technology

The screen savers are written in Swift 3 and Metal using Xcode 8. They require El Capitan or Sierra to run. Older versions of OS X do not support Metal, unfortunately.


## Download and Installation

Head to the [releases page](https://github.com/thoughtworks/dancing-glyphs/releases) and download the `ThoughtWorksGlyphSavers.dmg` file. If your web browser doesn't do it automatically, open the file you just downloaded. Then double-click on the `DancingGlyphs.saver` and `GlyphWave.saver` files to install the respective screen saver. After they are installed you can select the savers in System Preferences. 

The screen savers currently do no check whether updates are available. So, you might want to go back to the releases page every couple of months.

