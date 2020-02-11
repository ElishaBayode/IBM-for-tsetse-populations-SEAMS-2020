; 11/11/2019
; This model was developed as part of my PhD project, under the supervision of Prof. John W. Hargrove
; the main objective is to simulate tsetse population growth in field suituation where temperatures vary diunarly and seasonaly.
; and to predict tsetse population extinction in the Zambezi valley of Zimbabwe.
;Next steps
;
;Clean up the model to improve readability
;

extensions [csv]                                             ; Including CSV exention

globals                                                      ; Declearing global variables
[                                                            ;Other global variables have sliders in the interface
  ov_cat1
  ov_cat2
  ov_cat3
  ov_cat4
  ov_cat5
  ov_cat6
  ov_cat7
  ov_cat8
  ov_cat9
  ov_cat10
  temp                                                        ; Temperature data
  num_dead
]

breed [pupae pupa]                                            ; This include newly deposited larvae before they larviposit
breed [immature-adults immature-adult]                        ; Newly emerged adults that are yet to ovulate, this stage lasts for 7 days.
breed [larvipositing-adults larvipositing-adult]              ; Marture adults larviposit every 9 days afterwards.
breed [leafs leaf]
breed [flowers flower]
breed [houses house]

leafs-own
[age1]

flowers-own
[age1]

Houses-own
[age1]


pupae-own
[age                                                          ; Pupae chronological age
dev_frac                                                      ; The development rate is temperature dependent. Each pupae complete a development fraction, which depends on the daily average temperature.
sex                                                           ; All pupae alive are female
age_emerg                                                     ; The age at which it developmet fractions sums to 1.
av_temp                                                       ; The avarage temperature experienced by pupae throughout the pupal period
total_temp]                                                   ; Toatal temperature (to estimate the average temprature)

immature-adults-own
[
age                                                           ; age of immature adults (0-7).
]

larvipositing-adults-own
[
age                                                           ; Chronological age of larvipositing adults (starting from 8 of emergence as adult).
ovarian_age                                                   ; To count the number of times the fly has ovulated.
]


to setup                                                       ;Initialize the model
  clear-all
  setup-globals
  setup-pupae
  setup-immature-adults
  setup-larvipositing-adults
  file-close-all                                            ; Close any files open from last run
  file-open "controlledTemp.csv"   ;                  controlledTemp.csv          ;Other temperature data in the source folder : 1yeartemp.csv controlledTemp.csv;constant_temp.csv, 1960 (5 times)  .csv, 1987temp.csv
  ; other setup goes here
  reset-ticks
end




to setup-globals       ;setting up global variables

end



to setup-pupae               ; setting up pupae
 create-pupae initial_no_pupae
[  setxy random-xcor random-ycor
    set shape "pupa"
    set size 0.8
    set color blue
    set age 0
   set dev_frac 0
  ]
end


to setup-immature-adults
  create-immature-adults initial_no_immature_adults
 [setxy random-xcor random-ycor
    set shape "immature-adult"
    set size 1
    set color red
  ]

end


to setup-larvipositing-adults
   create-larvipositing-adults initial_no_larvipositing_adults
 [setxy random-xcor random-ycor
    set shape "larvipositing-adult"
    set size 1.5
    set color yellow
    set ovarian_age 1
    set age 0
  ]

end

to go ; to start simulation
  set-current-directory "C:/Users/ELISHAARE/Desktop/New IBM for tsetse-SEAMS2020/IBM-for-tsetse-populations-SEAMS-2020"  ; Setting the current directory
  if file-at-end? [ stop ]
  set temp csv:from-row file-read-line
  ; model update goes here
  tick
  ask larvipositing-adults
  [move-larvipositing-adults]
  ask immature-adults
  [move-immature-adults]
 ask pupae
  [develop-pupa]
  ask pupae
  [emerge-pupa]
  ask immature-adults
  [develop-immature-adults]
  ask immature-adults
  [ovulate-immature-adults]
  ask larvipositing-adults
  [develop-larvipositing-adults]
  ask larvipositing-adults
  [larviposit ]
  ask pupae
  [kill-pupae]
  ask pupae
  [densityDepkill-pupae]
  ask immature-adults
  [Tempdepkill-immature-adults]
  ask immature-adults
  [kill-immature-adults]
  ask  larvipositing-adults
  [kill-larvipositing-adults]
  ask  larvipositing-adults
   [Tempdepkill-larvipositing-adults]
  ask leafs
  [dev_house_leaf_flower]
  ask flowers
  [dev_house_leaf_flower]
  ask houses
  [dev_house_leaf_flower]
  ask leafs
  [kill_flower_leaf_house]
  ask flowers
  [kill_flower_leaf_house]
  ask houses
  [kill_flower_leaf_house]
end


to move-immature-adults
 right (random 360) - 179
  forward 4
end

to move-larvipositing-adults  ; allow flies to move randomly
 left (random 361) - 180
  forward 6
end


                     ; ; 15.9 I used this value to slow down pupal dev
to develop-pupa   ;pupae developing based on daily development fraction (this will be made temperature dependent)
  let pupal-growth ( 1 / (17.94 + 82.3 * exp(-0.253 * (  one-of temp - 16))))   ; development rate is temperature dependent. This formula is from Are & Hargrove (2019)
  set dev_frac  dev_frac + pupal-growth
  set age age + 1
  let temp_now  one-of temp
  set total_temp  total_temp + temp_now                                     ; The total temperature during the pupal period
end



to emerge-pupa   ; pupae emerging as immature adults
if dev_frac >= 1[          ;0.002
    ifelse random-float 1 < (0.002 + 0.00534 * exp(-1.552 * ((total_temp / age) - 16))  + 0.03 * exp(1.27100 * ((total_temp / age) - 32)) )
    [set breed leafs]   ;(b_1 + b_2 * exp(-b_3*((total_temp / age) - 16))  + b_4 * exp(-b_5*((total_temp / age) - 32))                    ; (Temperature-dependent mortality) The average tepmerature over the pupal period will determine the mortality
  [set breed immature-adults
  set shape "immature-adult"
  set size 1
  set color red
  set age 0]
  ]
end

to develop-immature-adults
set age  age + 1
end



to ovulate-immature-adults  ; immature adults ovulate after 7 days i.e. they become larvipositing adults
if age >= 8
  [set breed larvipositing-adults
  set shape "larvipositing-adult"
  set size 1.5
  set color yellow
  set age 0
  set ovarian_age 1]
end

to develop-larvipositing-adults
set age age + 1
end



to larviposit ; larvipositng adults produce a single larva every x days (depending on temperature)
if age mod 9 = 0
  [ set ovarian_age ovarian_age  + 1
    hatch 1
      [ set breed pupae
        set shape "pupa"
        set sex random 2
        ifelse sex = 0
          [ set color yellow ]
          [ die ]
       set shape "pupa"
    set size 0.8
    set color blue
    set age 0
   set dev_frac 0
        ] ]
end


to kill-pupae               ;background mortality for pupae
if random-float 1 < 0.02;0.001 ;* exp (0.001 * age)  ;probably too high
  [set breed leafs
  set age1 1]
end

to kill-immature-adults    ;immature-adults  background mortality for
 if random-float 1 < 0.02; 0.1 * exp (- 0.6 * age); 0.02
  [set breed flowers
  set age1 1]

end

to Tempdepkill-immature-adults    ;immature-adults  background mortality for
 if random-float 1 <= exp(- 0.850 + 0.083 * one-of temp) / 100; exp(- 0.85 + 0.083 * one-of temp) / 100;exp(- 0.1543 + 0.083 * one-of temp) / 100; exp(-1.543+0.083 * 28)/100
  [set breed flowers
  set age1 0]
end
                           ;- 1.543
to Tempdepkill-larvipositing-adults    ;larvipositing-adults  background mortality for
 if random-float 1 <=  exp( - 1.543 + 0.083 * one-of temp) / 100;exp(- 0.85 + 0.083 * one-of temp) / 100
  [set breed houses
  set age1 1]
end

to kill-larvipositing-adults ; larvipositing-adults background mortality
 if random-float 1 <=  0.0001;0.01 * exp (0.01 * age)
  [set breed houses
  set age1 1]
end

to dev_house_leaf_flower
set age1 age1 + 1
end

to kill_flower_leaf_house
 if age1 = 3
  [die]
end



to densityDepkill-pupae    ; Density-dependent mortality. This ensures the population does not grow beyound the carrying-capacity
 ;a0 <- 0.5

;NN <- seq(1, 30000, 10)

;KK <- 30000

;mu <- a0 / (1 + KK*exp(-5e-4*NN))
 if random-float 1 <= (0.8 / (1 + 15000 * exp(-4e-4 * count pupae)));(0.02359 / (1 + 15 * exp(-7e-4 * 15000)))
  [die]
end



;1 / (0.1046 + 0.0052 * (24 - 32))



;;;;;;;;;;;;;;;;;;;;;; Reporters ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to-report ovarian_categ1
  set ov_cat1 count larvipositing-adults with [ovarian_age = 1]
  report ov_cat1
end

to-report ovarian_categ2
  set ov_cat2 count larvipositing-adults with [ovarian_age = 2]
  report ov_cat2
end


to-report ovarian_categ3
  set ov_cat1 count larvipositing-adults with [ovarian_age = 3]
  report ov_cat3
end

to-report ovarian_categ4
  set ov_cat1 count larvipositing-adults with [ovarian_age = 4]
  report ov_cat3
end


to-report ovarian_categ5
  set ov_cat1 count larvipositing-adults with [ovarian_age = 5]
  report ov_cat5
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
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
1
1
1
ticks
30.0

BUTTON
19
88
83
121
Setup
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
98
88
161
121
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
-3
675
169
708
initial_no_pupae
initial_no_pupae
0
25000
802.0
1
1
NIL
HORIZONTAL

SLIDER
-2
710
201
743
initial_no_immature_adults
initial_no_immature_adults
0
6000
7006.0
1
1
NIL
HORIZONTAL

SLIDER
-5
745
220
778
initial_no_larvipositing_adults
initial_no_larvipositing_adults
0
16000
3039.0
1
1
NIL
HORIZONTAL

PLOT
725
10
1459
386
Tsetse population in the zambezi valley of Zimbabwe
Time (days) from Oct 9 1959 to Jan 31 2019
Tsetse population 
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Larviposting-adults" 1.0 0 -16777216 true "" "plot count larvipositing-adults "
"pupae" 1.0 0 -13840069 true "" "plot count pupae"
"pen-2" 1.0 0 -817084 true "" "plot count immature-adults "

MONITOR
147
520
219
565
Ovarain_1
count larvipositing-adults with [ovarian_age = 1]
17
1
11

MONITOR
218
520
393
565
Mortality_larvipositing-adults 
count houses / count larvipositing-adults
17
1
11

MONITOR
396
521
507
566
Mortality pupae 
count leafs / count pupae
17
1
11

MONITOR
509
522
666
567
Mortality immature-adults 
count flowers / (count immature-adults)
17
1
11

PLOT
725
389
1458
789
Ovariav_cat
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Ovarian_1" 1.0 0 -7500403 true "" "plot count larvipositing-adults with [Ovarian_age = 1]"
"Ovarian_2" 1.0 0 -2674135 true "" "plot count larvipositing-adults with [Ovarian_age = 2]"
"Ovarian_3" 1.0 0 -955883 true "" "plot count larvipositing-adults with [Ovarian_age = 3]"
"Ovarian_4" 1.0 0 -6459832 true "" "plot count larvipositing-adults with [Ovarian_age = 4]"
"Ovarian_5" 1.0 0 -1184463 true "" "plot count larvipositing-adults with [Ovarian_age = 5]"
"Ovarian_6" 1.0 0 -10899396 true "" "plot count larvipositing-adults with [Ovarian_age = 6]"
"Ovarian_7" 1.0 0 -13840069 true "" "plot count larvipositing-adults with [Ovarian_age = 7]"
"Ovarian_8" 1.0 0 -14835848 true "" "plot count larvipositing-adults with [Ovarian_age = 8]"
"Ovarian_9" 1.0 0 -11221820 true "" "plot count larvipositing-adults with [Ovarian_age = 9]"
"Ovarian_10" 1.0 0 -13791810 true "" "plot count larvipositing-adults with [Ovarian_age = 10]"
"Ovarian_11" 1.0 0 -13345367 true "" "plot count larvipositing-adults with [Ovarian_age = 11] "
"Ovarian_12" 1.0 0 -8630108 true "" "plot count larvipositing-adults with [Ovarian_age = 12]"
"Ovarian_13" 1.0 0 -5825686 true "" "plot count larvipositing-adults with [Ovarian_age = 13]"
"Ovarian_14" 1.0 0 -2064490 true "" "plot count larvipositing-adults with [Ovarian_age = 14]"
"Ovarian_15" 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 15]"
"Ovarian_16" 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 16]"
"Ovarian_17" 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 17]"
"Ovarian_18" 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 18]"
"Ovarian_19" 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 19]"
"Ovarian_20" 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 20]"
"Ovarian_21 " 1.0 0 -16777216 true "" "plot count larvipositing-adults with [Ovarian_age = 21]"
"Ovarian_0" 1.0 0 -16777216 true "" "plot count immature-adults "

PLOT
351
618
586
776
plot 1
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
"MortalityRatePupae" 1.0 0 -16777216 true "" "plot 100 * (count leafs / count pupae) "
"MortalityRateMature" 1.0 0 -2674135 true "" "plot 100 * (count houses / count larvipositing-adults )"

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

immature-adult
true
0
Line -7500403 true 150 75 150 120
Circle -7500403 false true 135 90 30
Circle -7500403 false true 105 105 90
Polygon -7500403 true true 180 135 240 180 240 75 180 135 120 135 120 135 120 135 60 75 60 180 120 135 90 210 150 135 225 210

larvipositing-adult
true
0
Line -7500403 true 150 60 150 105
Circle -7500403 false true 120 75 60
Circle -7500403 false true 103 103 95
Circle -7500403 false true 96 141 108
Polygon -7500403 false true 150 135 150 135 225 165 225 165 225 165 225 90 225 90 150 135 150 135 75 90 75 90 75 150 150 135 150 180 150 180 60 210 60 210 90 270 150 180 255 225 210 270 210 270 150 180 150 180
Circle -7500403 false true 120 210 60

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

pupa
true
0
Circle -7500403 false true 135 75 30
Circle -7500403 false true 116 86 67
Circle -7500403 false true 116 116 67
Circle -7500403 false true 103 118 95
Circle -7500403 false true 116 176 67
Circle -7500403 false true 135 225 30

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
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="MultiSimu10" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count  immature-adults</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 1]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 2]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 3]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 4]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 5]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 6]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 7]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 8]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 9]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 10]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 11]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 12]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 13]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 14]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 15]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 16]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 17]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 18]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 19]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 20]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 21]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 22]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 23]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 24]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 25]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 26]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 27]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 28]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 29]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 30]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 31]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 32]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 33]</metric>
    <enumeratedValueSet variable="initial_no_immature_adults">
      <value value="7006"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_no_larvipositing_adults">
      <value value="3039"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_no_pupae">
      <value value="802"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="MultiSimu10" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count  immature-adults</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 1]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 2]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 3]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 4]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 5]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 6]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 7]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 8]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 9]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 10]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 11]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 12]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 13]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 14]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 15]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 16]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 17]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 18]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 19]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 20]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 21]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 22]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 23]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 24]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 25]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 26]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 27]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 28]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 29]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 30]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 31]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 32]</metric>
    <metric>count  larvipositing-adults with [ovarian_age = 33]</metric>
    <enumeratedValueSet variable="initial_no_immature_adults">
      <value value="191"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_no_larvipositing_adults">
      <value value="152"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial_no_pupae">
      <value value="478"/>
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
