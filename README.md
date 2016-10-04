# Dancing Glyphs Screen Saver

*This is work-in-progress. Not everything may work as expected.*


## Dancing Glyphs

![dancing-glyphs-sample](https://cloud.githubusercontent.com/assets/954026/17986355/81cb49ce-6b1a-11e6-9ca7-14204b725a2c.gif)

A while ago, while reading Cixin Liu's excellent novel The Three-Body Problem, I saw a shape in our brand asset library that had three of the typical ThoughtWorks glyphs superimposed, and somehow I thought, what if those three glyphs were dancing around each other like the suns in the novel? Wouldn't that make a great screen saver? 


## Glyph Wave

![glyph-wave-sample](https://cloud.githubusercontent.com/assets/954026/19091623/aa2b4db4-8a83-11e6-81e8-d356d4b09305.gif)

At some point when implementing the Dancing Glyphs saver I switched to the Metal to get the best possible performance while using as little power as possible. I then realised that with Metal I could render hundreds of glyphs, and so I explored different animations. Glyph Wave is the result of this. There are actually two versions of the wave, the linear one shown above and a circular one. Currently, the saver selects one by random when it starts.


