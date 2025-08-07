;; setting up the breeds


breed [creators creator]
breed [users user]
breed [developers developer]
breed [PMs PM] ; these are policy makers

creators-own [
  remuneration ;; mainly lack of
  recognition
  create ;; this is a disposition that is probably a function of the two above
  items ;; the number of products of a creator's making
]

users-own [
  quality
  authenticity
  usefulness ;; quality can be defined in terms of this one
  reliability ;; only slightly relevant -- probably not
  skills ;; the mastery in the use of an AI tool
]

developers-own [
  reach ;; they want to use as much materials as possible
  profit ;; they have a function for making some
  transparency ;; cite the sources!
  struggle ;; this is to signify the different animae
           ;; that coexist in an organization such as this one
]

;; characteristics of PM are expressed through options (see the interface)
;; to study how they affect the actors in this ecosystem


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;                  SETUP PROCEDURES
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; the model starts with setting up the various actors

to setup
  clear-all
  reset-ticks

  ;; the numbers below are set arbitrarily, assuming
  ;; there are relatively fewer creators than users (10%)
  ;; and way fewer companies proposing AI models (3)

  ;; we could later modify the numbers and have larger numbers
  ;; if the below reveal to be a bit too simplistic

  crt 10 [
    set breed creators
    set shape "star"
    set color yellow
    setxy random-xcor random-ycor
  ]

  crt 100 [
    set breed users
    set shape "person"
    set color 16
    setxy random-xcor random-ycor
  ]

  crt 3 [
    set breed developers
    set shape "ai_firm"
    set color 65
    set size 2

    ask developers with [who = (count creators + count users + 0)] [
      setxy -7 7
      ]
    ask developers with [who = (count creators + count users + 1)] [
      setxy 0 -7
    ]
    ask developers with [who = (count creators + count users + 2)] [
      setxy 7 7
    ]
  ]

  setup-characteristics
end

to setup-characteristics

  ask creators [
    ;; the current AI model does not remunerate creators
    ;; hence, even though the simulation already sets it to 0
    ;; we reiterate its non-existence
    set remuneration 0

    ;; also, recognition is very low or minimal;
    ;; perhaps it makes sense that this depends on the AI model
    ;; and it could vary depending on how these models decide to
    ;; recognize the sources they use. Assuming recognition
    ;; goes from 0 to 10 (the latter is max), a random number
    ;; set on the low end of the spectrum may serve the scope.
    ;; This is to be intended as recognition of their work;
    ;; for a highly popular artist, for example, recognition may
    ;; be easier from the wider public.
    ;; NOTE: there could be a way in which the users also exercise
    ;; recognition even in cases when the AI model does not explicitly
    ;; point at the source.
    set recognition random-float 3

    ;; creativity is a disposition that may be influenced, among
    ;; many other factors, by AI. However, as a basis, a creator
    ;; produces content also as a pulsion deriving from their passion
    ;; and need of expression. A random normal distribution for creativity
    ;; dispositions is in order.
    ;; The below number expresses the count of products that the artist/creator
    ;; is able to produce in a given time period. High 'create' leads to
    ;; more products of this creative disposition.
    set create median (list 0 random-normal 5 2.5 10)

    ;; the stock of items produced is a function of the 'create' disposition.
    ;; A way to go about it would be to have a power funtion for this, since
    ;; we know that the 1% of artists produce most of the contents (say, 80%,
    ;; even though we know it is more like 98% or 99%).
    ;; Hence:
    if create >= 8 [
      set items 50
    ]
    if create < 8 [
      set items round (create / 100 * 50)
    ]
  ]

  ask users [

    ;; how much the information received is close to the original
    ;; information is something that becomes valuable as a function of
    ;; usefulness. However, AI cannot really produce 'independent'
    ;; or 'critical' thinking, hence authentic only means whether
    ;; the information is close to the original source.
    ;; NOTE: this may be a component of the AI model, and
    ;; relates to the quantity (and quality) of information
    ;; that the AI model can process. At the same time,
    ;; there is also a component of 'perception' that is
    ;; psychologically bound to users.
    ;; The range is 0-10 for this one.
    set authenticity median (list 0 random-normal 5 2.5 10)

    ;; a stepping stone to measuring quality; given this is
    ;; an attribute of the users, it is a perception, attached to the
    ;; use of the AI tool
    set usefulness median (list 0 random-normal 5 2.5 10)

    ;; reliability is not implemented (for now)
    ; set reliability ;; only slightly -- probably not

    ;; skills are generally very low, both because these are
    ;; new tools and because people do not spend time in
    ;; understanding how to use them
    set skills median (list 0 random-normal 3 2.5 10)

    ;; the concern with quality relates to the usefulness of
    ;; the information and is a function of the skills to
    ;; make the AI model work and of the usefulness
    set quality ( usefulness * skills / 100 )
  ]


  ask developers [
    ;; reach is something that allows AI firms to access information
    ;; on the web; it is defined by a slider in the Interface and it
    ;; works as a range from the agent-developer to the outside.
    ;; When it is 0 then access is unlimited -- to the whole web without
    ;; limitations.
    set reach web-scraping

    ;; the profit function is derived from the structure of costs and
    ;; the price they make users pay for it. However, the companies have
    ;; a free version (usually) available.
    ;; Profits are highest when there are no constraints. In other words
    ;; when the market is a 'wild west' type.
    ;; At the beginning of the simulation, profits are set at €1,000 mln
    ;; on average. The numbers below are expressed in billion euros
    set profit random-normal 1 0.1

    ;; the different models may have a different way of citing the sources
    ;; they use; they can range from complete transparency (1) to
    ;; no transparency at all (0). The starting point for these three
    ;; companies is somewhere in the middle, with variations around
    ;; the 0.5 mean
    set transparency median (list 0 random-normal 0.5 0.25 1)

    ;; there are different interests in a company; for example,
    ;; IT developers may have more idealistic takes on how the
    ;; service should be structured and offered while the management
    ;; may be more concerned with economic margins. The higher the
    ;; disagreement between parties, the more a company is
    ;; struggling to keep a position in the market. The effect is
    ;; visible both on (a) how they react to policy and (b) how
    ;; it affects profits.
    ;; The starting point is a relatively low struggle, levels, since
    ;; we assume each company is thriving with the new technology and
    ;; they can use economic power to 'buy' consensus (also along
    ;; the impression that a successful team should not be changed.
    set struggle median (list 0 random-normal 0.5 0.15 1)
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;                  GO PROCEDURES
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  tick

  if Applied_policy = "laissez faire / wild west" [
    ask developers [
      set web-scraping 0
      set reach web-scraping
    ]
  ]


;"opt-out"
;"levy"
;"fair remuneration"
;"centralized register"
;"PDM"
;"watermarking"
end
@#$#@#$#@
GRAPHICS-WINDOW
399
10
836
448
-1
-1
13.0
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
29
15
95
48
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

MONITOR
402
457
459
502
#items
sum [items] of creators
2
1
11

MONITOR
461
457
514
502
% (>8)
sum [items] of creators with [create >= 8] / sum [items] of creators
2
1
11

SLIDER
30
69
202
102
web-scraping
web-scraping
0
10
0.0
1
1
NIL
HORIZONTAL

CHOOSER
204
12
394
57
Applied_policy
Applied_policy
"laissez faire / wild west" "opt-out" "levy" "fair remuneration" "centralized register" "PDM" "watermarking"
0

BUTTON
108
14
171
47
NIL
go
NIL
1
T
OBSERVER
NIL
G
NIL
NIL
1

@#$#@#$#@
# Notes for a model

## AI and human creativity: what does the future hold?
The EU AI Act 2024 brought into force a ‘reservation right’ or ‘opt-out’ mechanism, which would allow creators to opt out from AI companies using their work for training their models.

The ‘opt-out’ has been widely criticised by almost stakeholders in the field, including creators. The creators want more licensing but licensing millions of works for creating AI models – which will involve works which are protected by copyright and others which are not – will be costly, time-consuming and ultimately will slow down the potential of AI, as whole.

This begs the question: what should the future hold? How should we approach AI training and outputs, the development of AI technologies rather than hindering it, whilst at the same time ensuring creators are protected.

To do this, this paper explores the viability of opt-out for the various actors in the field - (a) creators, (b) AI developers/technology companies, (c) users and (d) policy makers – and proposes some solutions moving forward. 

Criticisms against the reservation right can be accessed here. This is CIPPMs policy response to UK Government’s consultation: <a>https://microsites.bournemouth.ac.uk/cippm/2025/04/01/cippm-responds-to-ukipos-consultation-on-ai-and-copyright/</a>

### Creators
Creators are mainly concerned about the lack of <b>remuneration</b> and <b>recognition</b> when their work is used by AI companies. Creators such as Elton John, Paul McCartney, Dua Lipa, Ed Sheeran (most vociferously from the music industry who has been the strongest lobbyist group in the UK) make this point very strongly. They point out that if their work is taken in this manner and reproduced without remuneration and recognition, there is no incentive to create again. In this sense, the music industry has been the most vociferous in terms of lobbying. To add ‘salt to their wounds’ a case in UK (Getty Images v Stability) and two cases in USA (against Meta and OpenAI), both concluded that there is no copyright infringement at the training stage, even though copyright works may have been used in the process. The defendants were unable to show sufficient evidence of ‘substantially similar’.

However, on the other hand it has meant that UK has been unable to move forward with legislation (unlike the EU, USA, Japan etc) due to strong lobbying by the creative industries against the development of AI technologies.  As a result, and with a void in legislation, UK is very much behind other countries which is also an issue.

### Users
Users are mainly concerned about <b>quality</b> and <b>authenticity</b> of the GenAI material and usefulness of the content. Users – as well as Governments – will also be concerned about the <b>reliability</b> of the model. AI tools have known to “hallucinate’ thereby leading to wrong responses and facts. However, many believe that with time, the accuracy will improve. 

Also, apart from reproducing literary, dramatic, musical and artistic works, AI tools are used increasingly for writing messages, emails, exploring ideas for events etc., which are outside the realm of copyright. 

See: <a> https://www.theguardian.com/wellness/ng-interactive/2025/jun/30/ai-chatgpt-personal-messages </a>

As a user per se, opt-out may not be an aspect that users are too concerned about. A user is more likely to be interested in the quality of the output and whilst they may have some sympathy with creators, it will not be their prime concern as a user of AI models.


### AI developers
Very much not in favour of opt-out as they want/require as much material as possible for training their models. Furthermore, <b>profit</b> is key for AI developers as opposed to aspects such as recognition or remunerating creators. Another issue facing AI developers is <b>transparency</b> – and this is a requirement under EU’s AI Act. There is pressure for AI models to reveal and identify all sources that have been used in training their AI models.

There are other questions facing AI models such as who the creator is – is it the firm; is it the software engineers? Or data scientists?

<p style="color:#6495ED;">DS: The questions above are probably very relevant and important, but they are also difficult to model if we are interested in policy making. This is because they require to take 'AI developers' as a company (a firm). And this is a separate model altogether -- a model in a model, if we do it here. Perhaps they -- these quesstions -- can be represented in terms of internal struggle among the parties that make the organization that brings AI tools into the market.</p>

### Policy makers/ legislators 
UK proposed opt-out as its favoured option in December 2024, but, it has been met with heavy criticism. 

In the meantime, there have been policy developments in the EU.

In July 2025, a report by the JURI Committee of the European Parliament, recommended that the European Commission shall “immediately impose a remuneration obligation on providers of general purpose AI models and systems in respect of the novel use of content protected by copyright”. However, the report does not detail how such a transitory measure could be introduced without a reform of its own. 

The report focuses mainly on remunerating individual creators and
other rightsholders (paragraph 2). “Considering, however, the vast amounts of public resources that are being appropriated by AI companies for the development of AI systems, remuneration mechanisms need to channel value back to the entire information ecosystem. Expanding this recommendation beyond the narrow category of rightsholders seems therefore crucial”. But is it possible?

A third point relates to opt-out and the creation of a centralised register for opt-outs. However, this carries its own issues. For example, who will enforce it? 

A final recommendation in the draft report concerns the legal status of AI-generated outputs. Paragraph 12 suggests that “AI-generated content should remain ineligible for copyright protection, and that the public domain status of such works be clearly determined.”

### Possible solutions in this area which could be tested: 
<ol>
<li> An <b>AI systems levy</b> distributed through collective management organisations (CMOs): this would be a mandatory single equitable remuneration, akin to a levy on high-tech equipment which exist in countries such as Germany amongst others on users of AI systems that generate creative literary, dramatic, musical and artistic (LDMA) content that compete with the original work. The monies collected from the levy/tax can be paid to cultural funds of collective management organisations for the purpose of fostering and supporting human literary and artistic productions. See also policy response.</li>

<li> Replacing opt-out with a <b>fair remuneration</b> system for all creators, if their work is used in AI training, supported by the private copying exception under copyright. According to this solution, whether a work is protected by copyright – or not – the author will be eligible for remuneration. It may be as small as 1 euro – but the idea will be to remunerate the creator. I have many questions about this….</li>

<li> Can a <b>centralised register</b> for opt-outs work? There are issues with this as outlined in the policy response.</li>

<li> Can AI generated outputs be <b>public domain property</b> as opposed to being eligible for copyright?</li>

<li>Can <b>watermarking</b> / fingerprinting be a solution in this area?</li>
</ol>



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

ai_firm
false
0
Polygon -7500403 true true 60 30 0 105 300 105 60 105
Polygon -7500403 true true 120 105 75 210 90 210 105 180 135 180 150 210 165 210 135 105
Rectangle -7500403 true true 180 105 210 210
Rectangle -7500403 true true 15 105 30 210
Rectangle -7500403 true true 270 105 285 210
Rectangle -7500403 true true 15 210 285 225
Polygon -7500403 true true 105 30 45 105 345 105 105 105
Polygon -7500403 true true 150 30 90 105 390 105 150 105
Polygon -7500403 true true 195 30 135 105 435 105 195 105
Polygon -7500403 true true 240 30 180 105 480 105 240 105
Polygon -7500403 true true 285 30 225 105 525 105 285 105

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
