breed [practices practice]
breed [actors actor]

practices-own [
  proactive? ;; if 1 then it is, otherwise reactive

  fixed ;; this turns to 1 when the leakage has been fixed
        ;; it does not mean it cannot get fired again, but it is unlikely

  ;time ;; the extent to which it takes time to fix the leakage
]

actors-own [
  disposition ;; a value indicating how much an actor is oriented towards proactiveness
  satisfaction ;; this is something that may be relevant when dealing with a leakage;
               ;; it could be a function of the disposition and increase as dispositions
               ;; are met
]



to setup
  clear-all
  reset-ticks

  resize-world 0 99 0 99
  set-patch-size 5

  ask patches [
    set pcolor 7

    sprout 1 [
      set breed practices
      set color white
      set shape "square"
      set size 1
    ]
  ]

  initiate

end

to initiate
  ;; this is to start the simulation
  ;; In the historical condition, there are only reactive leakages;
  ;; they are set by the ALPeC slider and they consist of a random number
  ;; where the upper limit is the number generated by the ALPeC slider

  ifelse historical? = true [
    ask n-of random (1 / 10 * (average-leakages-per-cycle) * (count patches)) practices [
      set color orange
    ]
  ] [
      ;set shape "boxed-x"
      ;set color 96
  ]


  ;; we also need to create individuals who deal with the leakages
  crt 6 [
    set breed actors
    set size 2
    set color black
    set shape "person"
    setxy random-xcor random-ycor
    set disposition random-normal mean-proactive-disposition 2
    set satisfaction 1 ;; everyone starts with a similar level (agnostic about their satisfaction at the start)
    set hidden? true
    if show-actors? [
      set hidden? not hidden?
    ]
  ]
end


to go
  ;; 1 tick is a day here
  tick

  ;; time to completion for a leakage is estimated by the time it
  ;; takes an actor to reach that leakage
  ask actors [
    if cos (ticks * 51.42857142857143) = 1 [
      if any? practices with [color = orange] [
        let available-practices (practices with [color = orange])
        let closest (min-one-of available-practices [ distance self ])
        face closest
      ]
    ]
    fd actor-quickness
  ]

  ask practices with [color = orange] [
    if any? actors in-radius 3 [
      set shape "boxed-x"
      set color black
      set fixed 1
    ]
    ask actors in-radius 3 [
      if [disposition] of self <= 0 [
        ;; the idea is that satisfaction increases more the first time
        ;; then the increase is less visible as subsequent leakages are fixed
        ;; the ln of 1 is zero, and that is why the value for satisfaction is
        ;; larger than that (+0.01)
        set satisfaction (satisfaction + (0.001 / ln (satisfaction + 0.01)))
      ]
    ]
  ]

  ask practices with [color = cyan] [
    if any? actors with [disposition > 0] in-radius 3 [
      set shape "boxed-x"
      set color black
      set fixed 2
    ]
    ask actors in-radius 3 [
      if [disposition] of self > 0 [
    ;; these other actors increase their satisfaction in relation to the
    ;; meeting/solving of proactive leakages / same incremental logic as above
      set satisfaction (satisfaction + (0.001 / ln (satisfaction + 0.01)))
      ]
    ]
  ]

  new-leakages
  disposition-adjustment

end

to new-leakages

  ;; new reaction leakages created every week (7 ticks)
  if cos (ticks * 51.42857142857143) = 1 [
    ;; fewer leakages appear during the course of the simulation
    ;; if there is a compensation mechanism, then the number of reactive leakages reduces
    ;; when proactive leakages significantly more than them

    ifelse re-pro-compensation [
      ;; the compensation mechanism is proportional
      if (count practices with [fixed = 2] / count practices with [fixed = 1]) > 0 [
        let compensation (count practices with [fixed = 2] / count practices with [fixed = 1])
        let comp-prop (1 / (20 * compensation))
        ask n-of random (comp-prop * (average-leakages-per-cycle) * (count patches)) practices with [fixed = 0] [
          set color orange
        ]
      ]
    ][
      ask n-of random (1 / 20 * (average-leakages-per-cycle) * (count patches)) practices with [fixed = 0] [
        set color orange
      ]
    ]
  ]

  ;; new proactive leakages once a year (360 instead of 354)
  if cos ticks = 1 [
    ;; these are located in a specific area
    let area-x random-xcor
    let area-y random-ycor
    let core-area patch area-x area-y
    ask core-area [
      ask n-of random (0.1 * (count patches in-radius 20)) practices in-radius 20 with [fixed = 0] [
        set shape "boxed-x"
        set color cyan
        set proactive? 1
      ]
    ]
  ]

  ;; at one point, some of the fixed leakages become available again
  ;; maybe after 5 years -- they enter the poll again, it does not mean
  ;; that they become visible!

  if cos (0.2 * (ticks * 5)) = 1 [
    ask n-of (0.10 * count practices with [color = black]) practices with [color = black] [
      set fixed 0
      set color white
      set shape "square"
      set size 1
    ]
  ]

end

to disposition-adjustment
  ask actors with [disposition > 0] [
    let reactive-sat (mean [satisfaction] of actors with [disposition <= 0])
    if satisfaction < reactive-sat [
      let delta-sat (reactive-sat - satisfaction) * disposition-change-factor
      set disposition disposition * (1 - delta-sat)
    ]
  ]
  ask actors with [disposition < 0] [
    let proactive-sat (mean [satisfaction] of actors with [disposition > 0])
    if satisfaction < proactive-sat [
      let delta-sat (proactive-sat - satisfaction) * disposition-change-factor
      set disposition disposition * (1 - delta-sat)
    ]
  ]

end

@#$#@#$#@
GRAPHICS-WINDOW
671
19
1179
528
-1
-1
5.0
1
10
1
1
1
0
1
1
1
0
99
0
99
0
0
1
ticks
30.0

BUTTON
42
34
108
67
NIL
setup
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
44
187
278
220
average-leakages-per-cycle
average-leakages-per-cycle
0
0.1
0.005
0.005
1
NIL
HORIZONTAL

SWITCH
125
34
245
67
historical?
historical?
0
1
-1000

SWITCH
127
73
268
106
show-actors?
show-actors?
1
1
-1000

SLIDER
43
223
276
256
mean-proactive-disposition
mean-proactive-disposition
0
2
1.0
0.5
1
NIL
HORIZONTAL

BUTTON
45
71
108
104
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

PLOT
46
374
246
524
Fixed leakages
Time
# fixed
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count practices with [ fixed > 0 ]"
"reactive" 1.0 0 -955883 true "" "plot count practices with [ fixed = 1 ]"
"proactive" 1.0 0 -11221820 true "" "plot count practices with [ fixed = 2 ]"

SLIDER
44
150
216
183
actor-quickness
actor-quickness
0
5
2.0
0.5
1
NIL
HORIZONTAL

PLOT
252
374
452
524
Leakages
Time
# leakages
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"all" 1.0 0 -16777216 true "" "plot count practices with [ color = orange or color = cyan ]"
"reactive" 1.0 0 -955883 true "" "plot count practices with [ color = orange ]"
"proactive" 1.0 0 -11221820 true "" "plot count practices with [ color = cyan ]"

BUTTON
44
110
107
143
NIL
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

MONITOR
325
38
405
83
Year count
ticks / 360
2
1
11

MONITOR
54
316
111
361
m-sat
mean [satisfaction] of actors
4
1
11

MONITOR
141
315
229
360
m-sat-react
mean [satisfaction] of actors with [disposition <= 0]
4
1
11

MONITOR
233
315
330
360
m-sat-proact
mean [satisfaction] of actors with [disposition > 0]
4
1
11

MONITOR
350
313
418
358
m-disp
mean [disposition] of actors
4
1
11

PLOT
453
375
653
525
Disposition dynamics
Time
Disposition
0.0
10.0
-2.0
2.0
true
false
"" ""
PENS
"total" 1.0 0 -16777216 true "" "plot (mean [disposition] of actors)"
"react" 1.0 0 -955883 true "" "plot (mean [disposition] of actors with [disposition <= 0])"
"proact" 1.0 0 -11221820 true "" "plot (mean [disposition] of actors with [disposition > 0])"

SLIDER
43
262
272
295
disposition-change-factor
disposition-change-factor
0
0.05
0.02
0.001
1
NIL
HORIZONTAL

SWITCH
125
112
318
145
re-pro-compensation
re-pro-compensation
0
1
-1000

MONITOR
315
254
420
299
pro-reac-prop
count practices with [proactive? = 1] / count practices with [proactive? = 0]
2
1
11

MONITOR
423
255
542
300
fxd-re-pro-prop
count practices with [fixed = 2] / count practices with [fixed = 1]
2
1
11

@#$#@#$#@
# Notes on the model

This is a model on practices that distinguishes between proactive and reactive practices.

One of the agent-type of this model are practices. Practice is attached to the leakage, depending on the type it is. The sum of the reactive cases are the reactive practices.

Proactive detection of leakages makes them <i>proactive</i>. The quantity of these are very many more than the reactive leakages. There are potentially proactive/reactive cases. There are many leakages that are unknown --- there is a perceptive part of this.

Known cases/leakages are what we are interested in. 

If one follows a strict reactive approach, you only get leakages that expose themselves (no active detection). Few new leakages.

One proactive practice: (a) alarm wires (for potential leakage); automatic notification, instant knowledge whenever there is a leakage; (b) drone cases/leakages (in the 30-40-50) all at once in a particular time of a year. Many leakages become visible in this case. Some of these leakages are visible (not all of them) --- they fly over a specific neighborhood at a time. There are false positives (not many; or, at least, unknown). There could be a human error for Drone Systems that overlook some leakages.

<b>Objective of the model</b>. See things longitudinally. Does one practice have a <i>crowding out</i> effect on the other? Are there characteristics that make one preferable over the other? E.g., proactive take less time, fewer costs, more efficient (planning). What does this do to the unknown leakages (that will pop up at one point)? Which system is better positioned to anticipate the appearance of leakages? 
In general, it is about showing the difference between a proactive and a reactive approach.

There is the possibility that the a reactive call is also present in the proactive map. For alarms they use the drones data to double check (bit this is proactive vs proactive).

Scenarios moving from total reactive to total proactive and then testing the mix of the two.
When the simulation goes on to model proactive (60%, 70%) of the entire leakages, then the system works on distribution of resources, where people that do planned activities are not those that deal with reactive practices (or they have a system where they fit these into their planned schedule).

There is an effect of reduction of reactive practices due to proactive activity. This happens in the long run, obviously, because the actions taken now are non-leakages in the future!

<b>Visible vs invisible</b>. When the proactive action comes (drones) some hidden case becomes visible (and actionable). Proactive bringing of the practice into the visible space.


Alarm wires appeear in a specific area. The drones also survey one area at a time. There is no overlap between wires and drones (different types of pipe).

<b>Human agents</b>. Their number should become constant. Six agents here. There could be specialties (focus on type of practices); we could start with 3 proactive people and then the rest. This is somethig to test, in the sense that there could be a match or mismatch of resources with the ideal direction they take (reaction vs proaction). 
It could also be that the proactive vs reactive are dispositions of people. And that is an attitude that depends on the success rate (?) or on how many reactive vs proactive leakage there are.

<b>Historical perspective</b>. Perhaps the model could start with the reactive practices and then proactive leakages start appearing. This could be in a version of the simulation that shows the "history" of (or introduction of) proactive practices (leakages).


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

boxed-x
false
0
Rectangle -1 true false 15 15 285 285
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
Rectangle -7500403 true true 0 0 300 15
Rectangle -7500403 true true 0 15 15 285
Rectangle -7500403 true true 285 15 300 285
Rectangle -7500403 true true 0 285 300 300

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
