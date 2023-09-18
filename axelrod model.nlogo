extensions [ nw ] ;this is only to count cultural regions after the model has already found stability

breed [ humans human ] ;to define a breed first the plural and then the singular
breed [ borders border ] ;we need a second breed because they change color based on similarity between humans

humans-own [culture] ;to give new attributes to each breed

to setup
  clear-all
  nw:set-context humans links                                                ;for counting regions later. The extension needs this to set the context to humans so it does not count borders as clusters
  set-default-shape humans "square"
  set-default-shape borders "border"
  ask patches [
    sprout-humans 1 [                                                        ;here we add the breed to sprout
      set color 115
      set culture n-values number-of-features [ random number-of-traits ]    ;creates the list of random traits according to the number of features (connects both sliders)
                                                                             ;I'm storing the list created as a turtle attribute
    ]
    foreach [ 0 90 180 270 ] [ the-heading ->                                ;this creates the right directions so we can use heading to locate borders properly. these values are called "the-heading"
      sprout-borders 1  [                                                    ;we dont need to state 4 because foreach has the 4 directions
        set heading the-heading                                              ;here we give each border the direction using the list in foreach
        set color black
      ]
    ]
  ]
  ask humans [ update-border-color ]  ;is a procedure created below
  reset-ticks
end

to update-border-color
  ask borders-here [                                                           ;asks only the borders in the patch (4)
    if patch-ahead 1 != nobody [                                               ;this is to only run the procedure if there is a neighbour (corner and side humans have less neighbours so there is error without this line)
      let neighbour one-of humans-on patch-ahead 1                             ;patch ahead looks only at the patch in the heading direction. 1 = looks only 1 patch ahead
                                                                               ;one-of gives an agentset of 1 agent. This way we extract the agent on the neighbour patch
      let match cultural-similarity neighbour myself                           ;cultural-similarity is written before it exists. because the code can be added later for that procedure
                                                                               ;neighbour and myself are lists
                                                                               ;match will be a number between 0-1
      set color scale-color 115 match 0 2                                      ;scale-color has 4 arguments: color, how dark or bright we want the color, range1 (0=black), range2(2=white)
                                                                               ;because our number (match in this case) is between 0 and 1, then the range 1 is the max intesity of my chosen color (purple here) and it will never really go to white
    ]
  ]
end

to-report cultural-similarity [human-a human-b]                              ;used in update-border-color procedure.
                                                                             ;human-a and human-b will be replaced by real values
  let culture-a [ culture ] of human-a                                       ;we are not defining human-a and b because we dont care, we just need a container for the culture associated to myself and neighbour
  let culture-b [ culture ] of human-b                                       ;this is possible bacause in update-border-color procedure these human-a and human-b are "filled" with neighbour and myself
  report mean ( map [ [trait-a trait-b] -> ifelse-value (trait-a = trait-b)   ;to extract the info and put it "in front" of each other to compare
                                                                             ;trait-a trait-b are just names. Netlogo knows automatically which values are we trying to map (check video recording). I think is because the way maps works = it puts to lists in from of each other
    [1]                                                                      ;if it is equal give 1
    [0]                                                                      ;if it is unequal give 0
                                                                             ;creates a list of 0s and 1s and the mean is calculated from this
  ] culture-a culture-b)

end

to go ;this also works for step button
  if all? borders [ member? color [115 0 110] ] [stop]                      ;to stop the model when it reaches stability. condition is that color is black or purple. (110 and 0 are two types of black color-see color swatches)
                                                                            ;member? ask if a value belongs to a list (purple or black
  ask one-of humans [                                                      ;pick one human at random
    let neighbour-choosing one-of humans-on neighbors4                       ;picks one neighbour at random. in the class it has the same name as other local variable (neighbour). It is possible because it is local and it is just a label for turtles
    if random-float 1 < cultural-similarity neighbour-choosing self  [     ;the cultural similarity (between 0-1). random-float 1 (gives a random number between 0 and 1)
                                                                           ;this gives a probability of interaction. If cultural-similarity is high then it will be very likely that it will be higher than the random number, but not always necessarily the case.
                                                                           ;eg. cultural-similarity 0.8 vs random number 0.67 = agents interact
      interact-with neighbour-choosing
    ]
  ]
  tick
end

to interact-with [ neighbour-choosing ]                                    ;[ ] is the place where we create the value. We give it a name, the procedure calculates it. Here it is just a label
                                                                           ;find all the positions in the cultures where we do not agree
  let indices-where-different filter [ index ->                            ;index is just a name to store the values. Filter gives back the value only if true.
    item index [culture] of neighbour-choosing != item index culture       ;filtering to get all positions were numbers are not the same
  ] range length culture                                                   ;"range length" is a combination that will always give and "index" to a list e.g list a= 1,4,5,10. the command gives= 0,1,2,3,4
  if debug? [                                                              ;for debugging. Show the feature-positions were humans have different traits (in a switch it works in real time)
    print (word self " " culture)                                          ;no need of because it is the agent own info. gives the culture list of the human
    print (word neighbour-choosing " " [culture] of neighbour-choosing )   ;of because we are accessing info of other humans. gives the culture list of the neighbour
    print indices-where-different                                          ;gives the positions were both culture lists are different
  ]

  if not empty? indices-where-different [                                    ;to avoid the error in case a list is empty
    let selected-index one-of indices-where-different                        ;pick one position where we differ at random
    let new-value item selected-index [culture] of neighbour-choosing        ;pick the trait of neighbour's culture at that position
    set culture replace-item selected-index culture new-value
    ask (turtle-set self humans-on neighbors4) [                             ;the command has to go at the end, after comupting and updating the similarity between the human and the neighbour
                                                                             ;colour of all borders need to be updated. So all 4 neighbors need to be asked
                                                                             ;within () is a local "agentset" with the human and its 4 neighbours
      update-border-color
    ]
  ]
end

to-report  number-of-regions                                                 ;here we use the extension
  ask humans [
    create-links-with (humans-on neighbors4)
    with [ culture = [culture] of myself ]                                   ;myself because it is the neighbours the ones that are asking my culture.
  ]
  let result length nw:weak-component-clusters
  ask links [die]                                                            ;we destroy them because we don't need them anymore, and in the next iteration we will need new ones
  report result
end
@#$#@#$#@
GRAPHICS-WINDOW
263
22
696
456
-1
-1
42.5
1
10
1
1
1
0
0
0
1
0
9
0
9
0
0
1
ticks
30.0

SLIDER
74
24
246
57
number-of-features
number-of-features
5
15
10.0
5
1
NIL
HORIZONTAL

SLIDER
74
63
246
96
number-of-traits
number-of-traits
5
15
15.0
5
1
NIL
HORIZONTAL

BUTTON
74
102
137
135
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
182
102
245
135
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
127
142
190
175
step
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
104
184
207
217
debug?
debug?
1
1
-1000

PLOT
52
302
252
452
cultural regions
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "if ticks mod 1000 = 0 [plot number-of-regions]"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

border
true
2
Polygon -955883 true true 0 0 45 60 255 60 300 0 0 0

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>number-of-regions</metric>
    <enumeratedValueSet variable="number-of-traits">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-features">
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
