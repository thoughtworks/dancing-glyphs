/*
 *  Copyright 2016 Erik Doernenburg
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */


import Cocoa

// configuration (at some point we should add a configure sheet)

// glyph and colors
let GLYPH = NSBezierPath.TWSquareGlyphPath()
let BGCOLOR = DARKMODE ? NSColor.blackColor() : NSColor.TWGrayColor().lighter(0.1)
let GLCOLORS = [ NSColor.TWLightGreenColor(), NSColor.TWHotPinkColor(), NSColor.TWTurquoiseColor() ]


// whether to draw on a light or dark background
let DARKMODE = true

// the size of the glyphs in relation to the screen
let SIZE: Double = 0.32

// the centre points of the glyphs are set on an equilateral triangle
// GRTSPEED is the speed with which the triangle revolves around its centre
// for the speed x/60 means x rotations per minute
let GRTSPEED: Double = 2*M_PI * 1/60

// the glyphs move away from the centre
// MVMID is the middle distance, MVAMP the amplitude
let MVMID: Double = 0.08
let MVAMP: Double = 0.06
let MVSPEED: Double = 2*M_PI * 11/60

// the glyphs travel on a circle around their individual "ideal" centre point
// CRRAD is the radius of that circle
let CRRAD: Double = 0.04
let CRSPEED: Double = 2*M_PI * 17/60

// the glyphs each rotate around their centre point
// RTMAX is the maximum angle to either side they rotate
let RTMAX: Double = 2*M_PI * 8/360
let RTSPEED1: Double = 2*M_PI * 8/60
let RTSPEED2: Double = 2*M_PI * 7/60
let RTSPEED3: Double = 2*M_PI * 6/60


