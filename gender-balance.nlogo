turtles-own [
  manager  ;; a value that is 1 if one is a manager
  level ;; this is the hierarchical level [3 or 5]

  income
  tenure
  education
  competencies
  status
  ;motivation
  ;maternity

  promotion? ;; is 1 if one is up for promotion
  promoted   ;; is 1 if one has been promoted
  bias       ;; against the other gender

]

breed [ men man ]
breed [ women woman ]

to setup
  clear-ticks
  clear-all

  crt number_workers [
    set breed women
    setxy random-xcor random-ycor
    set color blue
    set shape "circle"
    set size 0.8
  ]

  ask n-of ((1 - women_proportion) * number_workers) turtles [
    set breed men
    set color blue
    set shape "circle"
    set size 0.8
  ]

  ask turtles with [ breed = women ] [
    set label "W" ]


  let num_mgmt (manag_proportion * number_workers)

  if hierarchy != "level0" [
    ask n-of num_mgmt turtles [
      set manager 1
      set color red
      set size 1
  ]
    if hierarchy != "level0" [
      ask turtles with [ color = red ] [
        set level 1 ]
      if hierarchy = "level2" [
        ask n-of (0.20 * num_mgmt) turtles with [ color = red ] [
          set level 2
          set size 1.2
          set color green
      ] ]
  ] ]
end

to setup-conditions
  ask men [
    set income random-normal 30 5 ;; in thousands gross year salary
  ]

  ask women [
    set income random-normal (30 - (pay_gap * 30)) 5
  ]

  ask turtles with [income < 10] [
    set income 10 ]

  ifelse number_workers < 250 [
    ask men with [ level = 1 ] [
      set income random-normal (30 * 1.5) 2 ]
    ask men with [ level = 2 ] [
      set income random-normal (30 * 3) 5 ]

    ask women with [ level = 1 ] [
      set income random-normal ((30 * 1.5) - pay_gap * (30 * 1.5)) 2 ]
    ask women with [ level = 2 ] [
      set income random-normal ((30 * 3) - pay_gap * (30 * 3)) 5 ]
  ] [
    ask men with [ level = 1 ] [
      set income random-normal (30 * 2) 3 ]
    ask men with [ level = 2 ] [
      set income random-normal (30 * 9) 10 ]

    ask women with [ level = 1 ] [
      set income random-normal ((30 * 2) - pay_gap * (30 * 2)) 3 ]
    ask women with [ level = 2 ] [
      set income random-normal ((30 * 9) - pay_gap * (30 * 9)) 10 ]
  ]

  ask turtles [
    set tenure random 11

    set education round ( random-normal 4 1 )
    ask turtles with [education > 6][
      set education 6 ]
    ask turtles with [education = 0][
      set education 1 ]

    set competencies random-normal 0 1

    set bias random-normal mean_bias 1
    ;; you can now control this parameter from the slider in the Interface

  ]

  reset-ticks
end

to improve
  ask turtles [
    set tenure (tenure + 1 / 12) ]

  ask turtles [
    let factor ([education] of self / 6)
    set competencies ( competencies + 0.01 * abs (competencies) * factor )
  ]

  tick

  if ticks = 12 * years [ stop ]

  promote
end


to connect
  ask turtles with [ level = 1 ] [
    create-links-with other turtles with [ level = 0 ] in-radius 10
    ask links [ set color yellow ]
  ]

  ask turtles with [ level = 0 ] [
    if count my-links > 1 [
      ask n-of (count my-links - 1) my-links [ die ]
  ] ]

  ask turtles with [ level = 2 ] [
    create-links-with other turtles with [ level != 0 ]
    ask my-links [ set color green ]
  ]
end

to layout
  layout-spring turtles with [ level != 2 ] links #1-constant #2-length #3-repulsion
 ;; these are: spring-constant spring-length repulsion-constant
  if any? turtles with [count my-links = 0] [
    connect ]

  layout-circle (turtles with [ level = 2 ]) 3
end

to promote
  if any? turtles with [ level = 0 and  ;; this if any? was added to prevent an error
    competencies > 0.5 and tenure > 3 and promoted = 0] [
  ask n-of random 2 (turtles with [ level = 0 and
    competencies > 0.5 and tenure > 3 and promoted = 0]) [
    if [promotion?] of self != 2 [  ;; I have added promoted = 0 so that only those who have never
      set promotion? 1 ]            ;; been promoted are up for it; the problem with the opposite is that
  ] ]                               ;; already promoted employees keep being promoted.

  ask turtles with [ promotion? = 1 ] [
    ifelse [breed] of self = ([breed] of one-of other turtles with [manager = 1] in-radius 10) [
      set promoted 1
      set income income * (1 + abs pay_gap) ;; I have changed this so that the
                                            ;; increase in income is proportional to the gap
    ] [
      ifelse [bias] of one-of other turtles with [manager = 1] in-radius 10 < 0 [
        set promotion? 2 ] [ ;; up again?
        set promoted 1
        set income income * (1 + abs pay_gap) ;; Same as above
      ]
    ]
  ]

  ask turtles with [ promotion? > 1 and promotion? < 2.1 ] [
    set promotion? (promotion? - 0.1)
  ]


;;; the code below this line was added after class --- it deals with promotion to management
  ;; if competencies are very high, one has been in the company for at least 6 years, has been
  ;; promoted before, and is still an employee, then it gets promoted to Management if ...
  ;; ... well, if the same conditions outlined above (bias/gender) are met

  let top-comp mean [competencies] of turtles + 1.5 * standard-deviation [competencies] of turtles

  if any? turtles with [ level = 0 and
    competencies > top-comp and tenure > 6 and promoted = 1] [
  ask n-of random 2 (turtles with [ level = 0 and
    competencies > top-comp and tenure > 6 and promoted = 1]) [
    if [promotion?] of self != 2 [  ;; I have added promoted = 0 so that only those who have never
      set promotion? 3 ]            ;; been promoted are up for it; the problem with the opposite is that
  ] ]                               ;; already promoted employees keep being promoted.

  ask turtles with [ promotion? = 3 ] [
    ifelse [breed] of self = ([breed] of one-of other turtles with [manager = 1] in-radius 10) [
      set promoted 3
      set manager 1
      set color red
      set size 1
      set income income * (1 + abs pay_gap * 2)
    ] [
      ifelse [bias] of one-of other turtles with [manager = 1] in-radius 10 < 0 [
        set promotion? 2 ] [ ;; up again?
        set promoted 1
        set manager 1
        set color red
        set size 1
        set income income * (1 + abs pay_gap * 2) ;; Same as above
      ]
    ]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
498
10
957
470
-1
-1
13.67
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
33
33
100
67
setup
setup\nsetup-conditions
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
32
78
205
111
number_workers
number_workers
0
1000
350.0
1
1
NIL
HORIZONTAL

SLIDER
32
111
205
144
women_proportion
women_proportion
0
1
0.5
0.01
1
NIL
HORIZONTAL

SLIDER
32
145
205
178
manag_proportion
manag_proportion
0
0.3
0.1
0.1
1
NIL
HORIZONTAL

CHOOSER
327
77
419
122
hierarchy
hierarchy
"level0" "level1" "level2"
1

SLIDER
32
211
205
244
pay_gap
pay_gap
-0.20
0.20
0.05
0.05
1
NIL
HORIZONTAL

MONITOR
212
78
321
123
W_mean-salary
mean [income] of women
2
1
11

MONITOR
212
123
321
168
M_mean-salary
mean [income] of men
2
1
11

BUTTON
101
33
171
67
NIL
layout
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
171
33
251
66
improve
improve
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
17
251
233
401
Competencies dynamics
Time (months)
Mean competence levels
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"c-women" 1.0 0 -955883 true "" "plot mean [competencies] of women"
"c-men" 1.0 0 -13840069 true "" "plot mean [competencies] of men"

SLIDER
32
178
205
211
years
years
0
50
50.0
10
1
NIL
HORIZONTAL

MONITOR
328
123
397
168
up for it?
count turtles with [promotion? = 1]
0
1
11

PLOT
234
251
475
401
Number of promoted employees
Time (months)
# promoted
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"p-women" 1.0 0 -955883 true "" "plot count women with [promoted = 1]"
"p-men" 1.0 0 -13840069 true "" "plot count men with [promoted = 1]"

SLIDER
212
211
384
244
mean_bias
mean_bias
-1
1
-0.5
0.05
1
NIL
HORIZONTAL

PLOT
234
406
475
561
Average income
Time (months)
Mean income
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"i-women" 1.0 0 -955883 true "" "plot mean [income] of women"
"i-men" 1.0 0 -13840069 true "" "plot mean [income] of men"

TEXTBOX
217
181
424
207
I have added this slider to be the mean of the normal distribution for 'bias'
11
95.0
1

TEXTBOX
482
519
720
589
These two plots are to check on whether the income gap will be covered (and when); it also checks on gender of management
11
95.0
1

PLOT
16
406
233
561
Managers
Time (months)
# managers
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"m-women" 1.0 0 -955883 true "" "plot count women with [manager = 1]"
"m-men" 1.0 0 -13840069 true "" "plot count men with [manager = 1]"

SLIDER
748
480
920
513
#1-constant
#1-constant
0
5
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
749
518
921
551
#2-length
#2-length
0
5
0.7
0.01
1
NIL
HORIZONTAL

SLIDER
750
555
922
588
#3-repulsion
#3-repulsion
0
5
0.02
0.01
1
NIL
HORIZONTAL

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
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
setup-conditions</setup>
    <go>layout
improve</go>
    <timeLimit steps="240"/>
    <metric>count women with [promoted = 1]</metric>
    <metric>count men with [promoted = 1]</metric>
    <metric>count women with [promotion? = 1]</metric>
    <metric>count men with [promotion? = 1]</metric>
    <metric>mean [income] of women</metric>
    <metric>mean [income] of men</metric>
    <metric>count women with [manager = 1]</metric>
    <metric>count men with [manager = 1]</metric>
    <enumeratedValueSet variable="manag_proportion">
      <value value="0.1"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number_workers">
      <value value="200"/>
      <value value="400"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="years">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pay_gap">
      <value value="0.05"/>
      <value value="0.2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="hierarchy">
      <value value="&quot;level1&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="women_proportion">
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_bias">
      <value value="-0.25"/>
      <value value="0"/>
      <value value="0.25"/>
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
