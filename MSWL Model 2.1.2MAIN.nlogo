;; This is the MS Work Location Model v2.0
;; The name of the company from where the empirical data has been collected
;; has been kept confidential

extensions [csv] ; r]

globals [
  alpha
  coef1
  coef2

  Team1-start
  Team2-start
  Team3-start
  Team4-start
  Team5-start
  Team6-start
  Team7-start
  Team8-start
]

breed [employees employee]
breed [managers manager]

undirected-link-breed [ generic-links generic-link ]
directed-link-breed [ work-links work-link ]
directed-link-breed [ friend-links friend-link ]

employees-own [
  i-motivation ;; intrinsic
  e-motivation ;;  extrinsic
  e-m_base
  sodm ;; socially oriented decision making
  aoc ;; affective organizational commitment
  vte ;; team virtual appreciation (vte) is the extent to which one believes the team would
  ;; perform well online
  ident ;; this is team identity
  wfh-current ;; how much work from home is currently performed
  wfh-ideal ;; how much work from home one would ideally prefer
            ;; % ideal home work: 0 = 100% office, 100 = 100% home
  performance

  ;; additional inputs related to empirical data
  age
  gender
  education
  tenure
  manager?

  back_pre.pandemic ;; whether employees are asked about how 'good' it would
                    ;; be to come back to pre-pandemic layout (0 = null, 100 = excellent)
  ;office_vs_home    ;; % ideal home work: 0 = 100% office, 100 = 100% home
  COVID_phase1      ;; where did you work? 1 = home, 5 = office
  COVID_phase2
  COVID_phase3
  ;; wfh-current ;; this is COVID_phase4


  ;; Social networks
  freq_Team1 ;; frequency of interactions w/other team 1 = never, 7 = always
  freq_Team2
  freq_Team3
  freq_Team4
  freq_Team5
  freq_Team6
  freq_Team7
  freq_Team8

  dir_Team1 ;; direction of interactions w/other team 1 = always from me, 7 = always from them
  dir_Team2
  dir_Team3
  dir_Team4
  dir_Team5
  dir_Team6
  dir_Team7
  dir_Team8

  friend_Team1 ;; regularity of exchanges on topics off of work
  friend_Team2 ;; 1 = none from this team, 2 = one, 3 = 2,
  friend_Team3 ;; 3 = more than 2, 5 = everyone from this team
  friend_Team4
  friend_Team5
  friend_Team6
  friend_Team7
  friend_Team8

  dissonance ;; the divergence between ideal and actual work conditions
  team-dissonance ;; same as above, but at a team level

  turnover-count ;; this counts how many aspects "mount" to become a
                 ;; a possible cause of turnover
  toc-emot       ;; these are to make the count without repetitions
  toc-imot
  toc-aoc
  toc-diss
  toc-tdiss

  new? ;; to determine whether an employee is a new hire

  ;;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%;;
  ;; checks below this line
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  res.err
  emot-trigger
  imot-trigger
  aoc-trigger

]

turtles-own [
  team-ID ;; this is the identification for the team
  team-verbose ;; this is the actual name of the team
]

managers-own [

]


to setup
  clear-all
  reset-ticks

  ifelse Data? [
    ;; here is where to populate the code with empirical data

    ;; the number of observations in a column is used to determine how many agents
    ;; are attributed data at the beginning of the simulation:

    crt (length (csv:from-file "data.sc.csv") - 1) [
      set color yellow
      setxy random-xcor random-ycor
      set breed employees
      set shape "circle 2"
      set size 0.8
    ]
    data-input

  ][


    ;; runs the simulation without data

    crt num_employees [
      set color yellow
      setxy random-xcor random-ycor
      set breed employees
      set shape "circle 2"
      set size 0.8

      ;; demographics
      set age round (random-normal 40 6)
      set gender random 2

      set education random-poisson 3 ;; need to have mainly 2-3
      ask employees with [education = 0] [ set education 1 ]
      ask employees with [education > 4] [ set education 4 ]

      set tenure random 7


      ;; attitudinal variables
      set i-motivation random-normal mean_i-mot 1
      ask employees with [i-motivation < 1] [set i-motivation 1]
      ask employees with [i-motivation > 7] [set i-motivation 7]

      set e-motivation random-normal mean_e-mot 1
      ask employees with [e-motivation < 1] [set e-motivation 1]
      ask employees with [e-motivation > 7] [set e-motivation 7]

      set e-m_base e-motivation

      ;; (psycho-cognitive dispositions)
      set sodm random-normal mean_sodm 1
      ask employees with [sodm < 1] [set sodm 1]
      ask employees with [sodm > 7] [set sodm 7]

      set aoc random-normal mean_aoc 1
      ask employees with [aoc < 1] [set aoc 1]
      ask employees with [aoc > 7] [set aoc 7]

      ;; physical and social environment of work
      set vte random-normal mean_vte 1
      ask employees with [vte < 1] [set vte 1]
      ask employees with [vte > 7] [set vte 7]

      set ident random-normal mean_ident 1
      ask employees with [ident < 1] [set ident 1]
      ask employees with [ident > 7] [set ident 7]

      set back_pre.pandemic random-normal mean_back-pre.pandemic 20
      ask employees with [back_pre.pandemic < 0] [set back_pre.pandemic 0]
      ask employees with [back_pre.pandemic > 100] [set back_pre.pandemic 100]

      set wfh-current random-normal mean_wfh-c 1 ;; max for this is 5.0 (100% home)
      ask employees with [wfh-current < 0] [set wfh-current 1]
      ask employees with [wfh-current > 5] [set wfh-current 5]

      set COVID_phase1 random-normal (random mean_wfh-c + 1) 1
      ask employees with [COVID_phase1 < 0] [set COVID_phase1 1]
      ask employees with [COVID_phase1 > 5] [set COVID_phase1 5]

      set COVID_phase2 random-normal (mean_wfh-c - 2) 1
      ask employees with [COVID_phase2 < 0] [set COVID_phase2 1]
      ask employees with [COVID_phase2 > 5] [set COVID_phase2 5]

      set COVID_phase3 random-normal (mean_wfh-c - 1) 1
      ask employees with [COVID_phase3 < 0] [set COVID_phase3 1]
      ask employees with [COVID_phase3 > 5] [set COVID_phase3 5]

      set wfh-ideal random-normal mean_wfh-i 20;; max for this is 100 (% home)
      ask employees with [wfh-ideal < 0] [set wfh-ideal 0]
      ask employees with [wfh-ideal > 100] [set wfh-ideal 100]

      ;; SOCIAL NETWORKS
      ;; frequency of interactions
      set freq_Team1 random 8
      set freq_Team2 random 8
      set freq_Team3 random 8
      set freq_Team4 random 8
      set freq_Team5 random 8
      set freq_Team6 random 8
      set freq_Team7 random 8
      set freq_Team8 random 8

      ;; direction of interactions
      set dir_Team1 random 8
      set dir_Team2 random 8
      set dir_Team3 random 8
      set dir_Team4 random 8
      set dir_Team5 random 8
      set dir_Team6 random 8
      set dir_Team7 random 8
      set dir_Team8 random 8

      ;; friendship
      set friend_Team1 random 6
      set friend_Team2 random 6
      set friend_Team3 random 6
      set friend_Team4 random 6
      set friend_Team5 random 6
      set friend_Team6 random 6
      set friend_Team7 random 6
      set friend_Team8 random 6

      ;; at the beginning, everyone's performance is attributed at
      ;; random, but subsequently it is going to be calculated
      ;; TEMPORARILY NOT IN USE
      set performance random-float 1.01
    ]


    ask employees with [who > 0 and who <= num_managers] [
      set color red
      setxy (-10 + random 21) (-10 + random 21)
      set team-ID [who] of self
    ]

  initialize
  ]

end


;; In the below code is the actual data input for this model.
;; Every variable mentioned in the below has been measured through a survey
;; distributed among employees in between January and February 2022.

to data-input

  ;; setting demographics
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set age item 1 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set gender item 2 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set education item 3 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set tenure item 6 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set manager? item 7 values ] ]) ;; 6 = manager, 7 = product manager, 9 = tech lead
                                      ;; to recognize those with managerial responsibilities:
  ask employees with [ manager? = 6 or manager? = 7 or manager? = 9 ] [ set color red ]


  ;; the name of the team (coded and actual)
  (foreach (n-values count turtles turtle) (but-first csv:from-file "data.sc.csv") [
    [ agents values ] -> ask agents [
      set team-ID item 9 values ] ])
  (foreach (n-values count turtles turtle) (but-first csv:from-file "data.sc.csv") [
    [ agents values ] -> ask agents [
      set team-verbose item 10 values ] ])


  ;; attitudinal variables
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set i-motivation item 55 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set e-motivation item 54 values ] ])
  ask employees [ set e-m_base e-motivation ]

    ;; (psycho-cognitive dispositions)
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set sodm item 48 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set aoc item 49 values ] ])


    ;; physical and social environment of work
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set vte item 50 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set ident item 51 values ] ])

  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set back_pre.pandemic item 11 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set wfh-ideal item 12 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set COVID_phase1 item 13 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set COVID_phase2 item 14 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set COVID_phase3 item 15 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "data.sc.csv") [
    [ empl values ] -> ask empl [
      set wfh-current item 16 values ] ])


    ;; SOCIAL NETWORKS
    ;; frequency of interactions
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team1 item 1 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team2 item 2 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team3 item 3 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team4 item 4 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team5 item 5 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team6 item 6 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team7 item 7 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set freq_Team8 item 8 values ] ])


      ;; direction of interactions
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team1 item 9 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team2 item 10 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team3 item 11 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team4 item 12 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team5 item 13 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team6 item 14 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team7 item 15 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set dir_Team8 item 16 values ] ])


      ;; friendship
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team1 item 17 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team2 item 18 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team3 item 19 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team4 item 20 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team5 item 21 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team6 item 22 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team7 item 23 values ] ])
  (foreach (n-values count employees employee) (but-first csv:from-file "SNA_Teams.csv") [
    [ empl values ] -> ask empl [
      set friend_Team8 item 24 values ] ])

  if Actual-team-sizes [
    if count employees with [team-ID = 1] < Team1-DZCPE [
      let new-e1 (Team1-DZCPE - count employees with [team-ID = 1])
      ask n-of new-e1 employees with [team-ID = 1] [
        hatch 1 ] ]
    if count employees with [team-ID = 2] < Team2-RFSHW [
      let new-e2 (Team2-RFSHW - count employees with [team-ID = 2])
      ask n-of new-e2 employees with [team-ID = 2] [
        hatch 1 ] ]
    if count employees with [team-ID = 3] < Team3-VP25 [
      let new-e3 (Team3-VP25 - count employees with [team-ID = 3])
      ask n-of new-e3 employees with [team-ID = 3] [
        hatch 1 ] ]
    ;; there is a problem with Team 4: 6 responses and 17 members.
    ;; see the changes below
    if count employees with [team-ID = 4] < Team4-SC [
      let new-e4 (Team4-SC - count employees with [team-ID = 4])
      ask n-of (new-e4 / 2) employees with [team-ID = 4] [
        hatch 2 ]
      ask one-of employees with [team-ID = 4] [
        hatch 1 ] ]
    if count employees with [team-ID = 5] < Team5-NGCP [
      let new-e5 (Team5-NGCP - count employees with [team-ID = 5])
      ask n-of new-e5 employees with [team-ID = 5] [
        hatch 1 ] ]
    if count employees with [team-ID = 6] < Team6-CS [
      let new-e6 (Team6-CS - count employees with [team-ID = 6])
      ask n-of new-e6 employees with [team-ID = 6] [
        hatch 1 ] ]
    if count employees with [team-ID = 7] < Team7-DPdM [
      let new-e7 (Team7-DPdM - count employees with [team-ID = 7])
      ask n-of new-e7 employees with [team-ID = 7] [
        hatch 1 ] ]
    if count employees with [team-ID = 8] < Team8-TETRA [
      let new-e8 (Team8-TETRA - count employees with [team-ID = 8])
      ask n-of new-e8 employees with [team-ID = 8] [
        hatch 1 ] ]
  ]

  team_formation

end


;; the part below is to create teams for the simulated data input

to initialize

  ifelse count employees with [count my-generic-links = 0] < 3 [
    ask employees with [count my-generic-links = 0] [
      ifelse abs xcor < 0.1 and abs ycor < 0.1 [
        setxy random-xcor random-ycor
        fd 0.1
      ] [
        facexy 0 0
        fd 0.1
      ]
    ]
  ] [
    ask employees with [count my-generic-links = 0] [
      fd 0.1 ]
  ]

  ask employees with [ color = red ] [
    ifelse any? employees with [color = red and self != myself] in-radius 6 [
      setxy (-10 + random 21) (-10 + random 21)
    ] [
      create-generic-links-with other employees in-radius 4
      [set color orange]
    ]
  ]

  ask generic-links [
    ifelse labels? = TRUE [
      if [team-ID] of end2 = 0 [
        let other-ID [team-ID] of end1
        ask end2 [
          set team-ID other-ID
          set label team-ID
        ]
      ]
    ] [
      ask end1 [
        set label ""
      ]
      ask end2 [
        set label ""
      ]
    ]
  ]

  ask employees [
    if team-ID = 1 [ set team-verbose "Team1"]
    if team-ID = 2 [ set team-verbose "Team2"]
    if team-ID = 3 [ set team-verbose "Team3"]
    if team-ID = 4 [ set team-verbose "Team4"]
    if team-ID = 5 [ set team-verbose "Team5"]
    if team-ID = 6 [ set team-verbose "Team6"]
    if team-ID = 7 [ set team-verbose "Team7"]
    if team-ID = 8 [ set team-verbose "Team8"]
  ]

  ifelse all? employees [count my-links > 0] [

    make-connections
    ;other_teams
    stop
  ][
    initialize
  ]

  ;; the code below is to assign team-ID to members of the same
  ;; team -- labels appear only if labels? is ON



  ;  ask generic-links with [color = orange] [
;    let IDT [team-ID] of end2
;    ask end1 [
;      set team-ID IDT
;      if labels? [set label team-ID]
;    ]

;  ask employees with [color = yellow and team-ID != 0] [
;    let IDT [team-ID] of self
;    ask link-neighbors with [team-ID = 0] [
;      set team-ID IDT
;      if labels? [set label team-ID]
;    ]
;  ]


end


;; team formation with empirical data

to team_formation

  ask employees with [count my-links = 0] [
    let ID-self [team-ID] of self
    move-to one-of employees with [team-ID = ID-self]
    ;fd 1
    create-generic-links-with other employees in-radius 12 with [team-ID = ID-self]

    repeat 10 [layout-spring (employees with [team-ID = ID-self]) generic-links 2 3 2]

    ]

  if team_color [
    ask employees with [any? my-links] [
      let ID-self [team-ID] of self
      if ID-self = 0 [ask my-links [set color 2]]
      if ID-self = 1 [ask my-links [set color 12]]
      if ID-self = 2 [ask my-links [set color 22]]
      if ID-self = 3 [ask my-links [set color 32]]
      if ID-self = 4 [ask my-links [set color 42]]
      if ID-self = 5 [ask my-links [set color 52]]
      if ID-self = 6 [ask my-links [set color 62]]
      if ID-self = 7 [ask my-links [set color 72]]
      if ID-self = 8 [ask my-links [set color 82]]
    ]


    ;; 28 April 2023: labels visualization not working properly, changed here
    if labels? [
      ask employees with [count my-links > 0] [
        if count link-neighbors with [ label != "" ] = 0 [
          set label [team-verbose] of self
        ]
      ]
    ]
  ]

  ; this is to distantiate team members
  repeat 20 [layout-spring employees generic-links 0.1 1 2]

  ifelse count employees with [count my-links > 0] = count employees [
    ifelse ticks < 2 [
      make-connections ] [
      make-new-connections ]
    stop
  ][
    team_formation ]

end


to other_teams
  ;; team members communicate with each other
  ;; depending on proximity

  if out-reach [
    ask employees [
      let ID-self [team-ID] of self
      create-links-with other employees in-radius extra-team-comm with [team-ID != ID-self]
      [set color cyan]
    ]
  ]
end


;; the next step in the empirical data version is to
;; set the connections between agents in line with what is
;; in the SNA data

to make-connections

  if Data? = false [
    ask employees with [ color = red ] [
      let teamX [generic-link-neighbors] of self
      ask teamX [ create-generic-links-with other teamX ]
      ask generic-links [ set color 3 ]
    ]
  ]


  ;; the frequency of contact determines the creation of a work-link
  ;; in the code below, whether this is reciprocated is a question not asked
  ask employees with [ freq_Team1 > 1 and team-ID != 1 ] [
    if [dir_Team1] of self < 4 [
      create-work-link-to one-of employees with [team-ID = 1]
      ;; setting the thickness of links according to frequency of interactions
      ;; the denominator is 14 because 7 gave too thick links
      ask my-work-links [ set thickness ([freq_Team1] of end1 / 14) ]
  ] ]
  if any? employees with [team-ID = 2] [
    ask employees with [ freq_Team2 > 1 and team-ID != 2 ] [
      if [dir_Team2] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 2]
        ask my-work-links [ set thickness ([freq_Team2] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 3] [
    ask employees with [ freq_Team3 > 1 and team-ID != 3 ] [
      if [dir_Team3] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 3]
        ask my-work-links [ set thickness ([freq_Team3] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 4] [
    ask employees with [ freq_Team4 > 1 and team-ID != 4 ] [
      if [dir_Team4] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 4]
        ask my-work-links [ set thickness ([freq_Team4] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 5] [
    ask employees with [ freq_Team5 > 1 and team-ID != 5 ] [
      if [dir_Team5] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 5]
        ask my-work-links [ set thickness ([freq_Team5] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 6] [
    ask employees with [ freq_Team6 > 1 and team-ID != 6 ] [
      if [dir_Team6] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 6]
        ask my-work-links [ set thickness ([freq_Team6] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 7] [
    ask employees with [ freq_Team7 > 1 and team-ID != 7 ] [
      if [dir_Team7] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 7]
        ask my-work-links [ set thickness ([freq_Team7] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 8] [
    ask employees with [ freq_Team8 > 1 and team-ID != 8 ] [
      if [dir_Team8] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 8]
        ask my-work-links [ set thickness ([freq_Team8] of end1 / 14) ]
  ] ] ]

  ask work-links [ set color 43 ]

  ;; the code below is for the friendship links
  ;; the number of 'friends' is proportional to the scale
  ;; the max number is 4 (more would be a bit difficult to justify)
  ask employees with [friend_Team1 > 1] [
    let num-fr [friend_Team1] of self - 1
    create-friend-links-to n-of num-fr other employees with [team-ID = 1]
    if Labels-friend-links [ask my-friend-links [ set label "T1" ]]
  ]
  if any? employees with [team-ID = 2] [
    ask employees with [friend_Team2 > 1] [
      let num-fr [friend_Team2] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 2]
      if Labels-friend-links [ask my-friend-links [ set label "T2" ]]
  ] ]
  if any? employees with [team-ID = 3] [
    ask employees with [friend_Team3 > 1] [
      let num-fr [friend_Team3] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 3]
      if Labels-friend-links [ask my-friend-links [ set label "T3" ]]
  ] ]
  if any? employees with [team-ID = 4] [
    ask employees with [friend_Team4 > 1] [
      let num-fr [friend_Team4] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 4]
      if Labels-friend-links [ask my-friend-links [ set label "T4" ]]
  ] ]
  if any? employees with [team-ID = 5] [
    ask employees with [friend_Team5 > 1] [
      let num-fr [friend_Team5] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 5]
      if Labels-friend-links [ask my-friend-links [ set label "T5" ]]
  ] ]
  if any? employees with [team-ID = 6] [
    ask employees with [friend_Team6 > 1] [
      let num-fr [friend_Team6] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 6]
      if Labels-friend-links [ask my-friend-links [ set label "T6" ]]
  ] ]
  if any? employees with [team-ID = 7] [
    ask employees with [friend_Team7 > 1] [
      let num-fr [friend_Team7] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 7]
      if Labels-friend-links [ask my-friend-links [ set label "T7" ]]
  ] ]
  if any? employees with [team-ID = 8] [
    ask employees with [friend_Team8 > 1] [
      let num-fr [friend_Team8] of self - 1
      create-friend-links-to n-of num-fr other employees with [team-ID = 8]
      if Labels-friend-links [ask my-friend-links [ set label "T8" ]]
  ] ]

  ;; there could be a way to reduce the friendship links
  ;; since the friendship level of the recipient of the link is not
  ;; checked but randomly assigned, it could be that this agent has
  ;; friend_TeamX (where X is the team of the incoming link) that is 0.
  ;; If that is the case, then the friendship is "in the head" of the
  ;; agent who started the link, but it is not reciprocal. Hence, the
  ;; link could be eliminated.
  ;; There are different reasons for doing the above; one being that there
  ;; are many links in the empirical data driven simulation; maybe too many?

  ask friend-links [ set color 53 ]

  ;; the chooser 'Link-visualizer' in the Interface shows the links

  if Link-visualizer = "Team" [
    ask friend-links [ hide-link ]
    ask work-links [ hide-link ] ]
  if Link-visualizer = "Across teams" [
    ask friend-links [ hide-link ]
    ask generic-links [ hide-link ] ]
  if Link-visualizer = "Work:In&Out" [
    ask friend-links [ hide-link ]]
  if Link-visualizer = "Everything Across" [
    ask generic-links [ hide-link ] ]
  if Link-visualizer = "Friendship" [
    ask work-links [ hide-link ]
    ask generic-links [ hide-link ] ]
  if Link-visualizer = "Everything" [ ]


end


;;; the below is for new hires only
to make-new-connections

  if Data? = false [
    ask employees with [ color = red ] [
      let teamX [generic-link-neighbors] of self
      ask teamX [ create-generic-links-with other teamX with [new? = 1] ]
      ask generic-links [ set color 3 ]
    ]
  ]


  ;; the frequency of contact determines the creation of a work-link
  ;; in the code below, whether this is reciprocated is a question not asked
  if any? employees with [team-ID = 1] [
    ask employees with [ freq_Team1 > 1 and team-ID != 1 and new? = 1] [
      if [dir_Team1] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 1]
        ;; setting the thickness of links according to frequency of interactions
        ;; the denominator is 14 because 7 gave too thick links
        ask my-work-links [ set thickness ([freq_Team1] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 2] [
    ask employees with [ freq_Team2 > 1 and team-ID != 2  and new? = 1] [
      if [dir_Team2] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 2]
        ask my-work-links [ set thickness ([freq_Team2] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 3] [
    ask employees with [ freq_Team3 > 1 and team-ID != 3 and new? = 1] [
      if [dir_Team3] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 3]
        ask my-work-links [ set thickness ([freq_Team3] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 4] [
    ask employees with [ freq_Team4 > 1 and team-ID != 4  and new? = 1] [
      if [dir_Team4] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 4]
        ask my-work-links [ set thickness ([freq_Team4] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 5] [
    ask employees with [ freq_Team5 > 1 and team-ID != 5  and new? = 1] [
      if [dir_Team5] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 5]
        ask my-work-links [ set thickness ([freq_Team5] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 6] [
    ask employees with [ freq_Team6 > 1 and team-ID != 6  and new? = 1] [
      if [dir_Team6] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 6]
        ask my-work-links [ set thickness ([freq_Team6] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 7] [
    ask employees with [ freq_Team7 > 1 and team-ID != 7  and new? = 1] [
      if [dir_Team7] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 7]
        ask my-work-links [ set thickness ([freq_Team7] of end1 / 14) ]
  ] ] ]
  if any? employees with [team-ID = 8] [
    ask employees with [ freq_Team8 > 1 and team-ID != 8  and new? = 1] [
      if [dir_Team8] of self < 4 [
        create-work-link-to one-of employees with [team-ID = 8]
        ask my-work-links [ set thickness ([freq_Team8] of end1 / 14) ]
  ] ] ]

  ask work-links [ set color 43 ]

  ;; the code below is for the friendship links
  ;; the number of 'friends' is proportional to the scale
  ;; the max number is 4 (more would be a bit difficult to justify)
  ask employees with [friend_Team1 > 1 and new? = 1] [
    let num-fr [friend_Team1] of self - 1
      ifelse count employees with [team-ID = 1] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 1]
        if Labels-friend-links [ask my-friend-links [ set label "T1" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 1]
        if Labels-friend-links [ask my-friend-links [ set label "T1" ]]
      ]
  ]
  if any? employees with [team-ID = 2] [
    ask employees with [friend_Team2 > 1 and new? = 1] [
      let num-fr [friend_Team2] of self - 1
      ifelse count employees with [team-ID = 2] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 2]
        if Labels-friend-links [ask my-friend-links [ set label "T2" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 2]
        if Labels-friend-links [ask my-friend-links [ set label "T2" ]]
      ]
  ] ]
  if any? employees with [team-ID = 3] [
    ask employees with [friend_Team3 > 1 and new? = 1] [
      let num-fr [friend_Team3] of self - 1
      ifelse count employees with [team-ID = 3] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 3]
        if Labels-friend-links [ask my-friend-links [ set label "T3" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 3]
        if Labels-friend-links [ask my-friend-links [ set label "T3" ]]
      ]
  ] ]
  if any? employees with [team-ID = 4] [
    ask employees with [friend_Team4 > 1 and new? = 1] [
      let num-fr [friend_Team4] of self - 1
      ifelse count employees with [team-ID = 4] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 4]
        if Labels-friend-links [ask my-friend-links [ set label "T4" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 4]
        if Labels-friend-links [ask my-friend-links [ set label "T4" ]]
      ]
  ] ]
  if any? employees with [team-ID = 5] [
    ask employees with [friend_Team5 > 1 and new? = 1] [
      let num-fr [friend_Team5] of self - 1
      ifelse count employees with [team-ID = 5] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 5]
        if Labels-friend-links [ask my-friend-links [ set label "T5" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 5]
        if Labels-friend-links [ask my-friend-links [ set label "T5" ]]
      ]
  ] ]
  if any? employees with [team-ID = 6] [
    ask employees with [friend_Team6 > 1 and new? = 1] [
      let num-fr [friend_Team6] of self - 1
      ifelse count employees with [team-ID = 6] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 6]
        if Labels-friend-links [ask my-friend-links [ set label "T6" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 6]
        if Labels-friend-links [ask my-friend-links [ set label "T6" ]]
      ]
  ] ]
  if any? employees with [team-ID = 7] [
    ask employees with [friend_Team7 > 1 and new? = 1] [
      let num-fr [friend_Team7] of self - 1
      ifelse count employees with [team-ID = 7] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 7]
        if Labels-friend-links [ask my-friend-links [ set label "T7" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 7]
        if Labels-friend-links [ask my-friend-links [ set label "T7" ]]
      ]
  ] ]
  if any? employees with [team-ID = 8] [
    ask employees with [friend_Team8 > 1 and new? = 1] [
      let num-fr [friend_Team8] of self - 1
      ifelse count employees with [team-ID = 8] >= num-fr [
        create-friend-links-to n-of num-fr other employees with [team-ID = 8]
        if Labels-friend-links [ask my-friend-links [ set label "T8" ]]
      ] [
        create-friend-link-to one-of other employees with [team-ID = 8]
        if Labels-friend-links [ask my-friend-links [ set label "T8" ]]
      ]
  ] ]

  ;; there could be a way to reduce the friendship links
  ;; since the friendship level of the recipient of the link is not
  ;; checked but randomly assigned, it could be that this agent has
  ;; friend_TeamX (where X is the team of the incoming link) that is 0.
  ;; If that is the case, then the friendship is "in the head" of the
  ;; agent who started the link, but it is not reciprocal. Hence, the
  ;; link could be eliminated.
  ;; There are different reasons for doing the above; one being that there
  ;; are many links in the empirical data driven simulation; maybe too many?

  ask friend-links [ set color 53 ]


end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; if working from HOME the friendship links cannot work the
;; same way as in the OFFICE --- on the contrary, there are other
;; EXOGENOUS influences (to be factored in at random) and the
;; weight of the work relations is higher
;;
;; CHANGE NEEDED IN THE CODE BELOW -- 30 April
;;
;; DONE! v2.0
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;; the code below is to update eMOTIVATION, aoc and ident based
;; on the individual connections in place.

;; also, the values adjust to the team average
;; (for now, the ideal thing to do would be that of adjusting
;; the values to the 'next' psycho-cognitively close person)

to update
  tick

  if ticks = 22 * (Years * 12) [stop]

  ;; motivation is updated depending on the work relations
  ;; within the team and outside of it

  ask employees [


    ;; the following code is to avoid that the numbers spike up
    ;; to a level where there is no way to interpret them
    if [e-motivation] of self > 7 [
      set e-motivation 7 - random-float 0.2
    ]
    if [i-motivation] of self > 7 [
      set i-motivation 7 - random-float 0.2
    ]
    if [aoc] of self > 7 [
      set aoc 7 - random-float 0.2
    ]
    if [e-motivation] of self < 1 [
      set e-motivation 1 + random-float 0.2
    ]
    if [i-motivation] of self < 1 [
      set i-motivation 1 + random-float 0.2
    ]
    if [aoc] of self < 1 [
      set aoc 1 + random-float 0.2
    ]

    ;; instead of being influenced by everyone, the agent is
    ;; affected by one team member at a time (i.e. interactions that
    ;; leave a 'mark' are limited)

    ;; first a subset of workers is chosed--- 5 is a mid-range number
    let close-workers [generic-link-neighbors in-radius 6] of self

    ;; then one of them is chosen to influence the agent
    ifelse any? close-workers [
      let the-one one-of close-workers

      ;; the difference is calculated such that it is positive if the
      ;; other employee is more motivated than the one who triggers the
      ;; process
      let delta-em1 [e-motivation] of the-one - [e-motivation] of self

      ;; the update mechanism is a tiny fraction of the delta, calculated
      ;; as a function of sodm (docility)
      let update-em1 ([sodm] of self) / 140 * delta-em1

      ;; this is the mean sodm of the team
      let sodm-ref mean [sodm] of employees with [team-ID = [team-ID] of self]

      ;; the update only works if sodm of the self is higher than
      ;; the average of sodm in the team---this is to allow for very
      ;; pro-social individuals only to be affected
      if [sodm] of self >= sodm-ref [
        set e-motivation e-motivation + update-em1
      ]
    ] []

    ;; the influential agents outside of the team are those with whom
    ;; communication happens with high frequency
    if any? my-in-work-links with [thickness > 4 / 14] [
      let distant-worker one-of [in-work-link-neighbors] of self
      let delta-em2 [e-motivation] of self - [e-motivation] of distant-worker

      ;; influence is much weaker, the tie is weaker
      let update-em2 ([sodm] of self) / 280 * delta-em2

      ;; also sodm needs to be close to inquisitiveness, hence sodm needs to be
      ;; very high
      if [sodm] of self >= 0.90 * max [sodm] of employees [
        set e-motivation e-motivation + update-em2
      ]
    ]

    ;; the third mechanism is that of friendship, the logic
    ;; is similar to the one above -- the difference is that this link
    ;; works more when employees are in the office and less when they work
    ;; from home.
    ;; The 'friend' is the one with which the agent "said" (from the survey)
    ;; they talk to, not the other way around--this is why it is out-going links
    ;; more friendship links mean one is more likely to be influenced
    if count my-out-friend-links > 1 [
      let friend-worker one-of [out-friend-link-neighbors] of self
      let delta-em3 [e-motivation] of self - [e-motivation] of friend-worker

      ;; finally, the influence is higher when employees are
      ;; in the office
      let office-boost1 delta-em3 * (1.25 - 0.25 * [wfh-current] of self)

      ;; influence is also weaker, the tie is weaker
      let update-em3 ([sodm] of self) / 560 * office-boost1

      ;; also sodm needs to be close to inquisitiveness, hence sodm needs to be
      ;; very high
      if [sodm] of self >= 0.90 * max [sodm] of employees [
        set e-motivation e-motivation + update-em3
      ]
    ]



    ;; the code below follows a similar logic than the one above, but it influences
    ;; AOC instead.

    let close-workers2 [generic-link-neighbors in-radius 6] of self
    ifelse any? close-workers [
      let the-one one-of close-workers2
      let delta-aoc1 [aoc] of the-one - [aoc] of self
      let update-aoc1 ([sodm] of self) / 140 * delta-aoc1
      let sodm-ref mean [sodm] of employees with [team-ID = [team-ID] of self]
      if [sodm] of self >= sodm-ref [
        set aoc aoc + update-aoc1
      ]
    ] []
    if any? my-in-work-links with [thickness > 4 / 14] [
      let distant-worker2 one-of [in-work-link-neighbors] of self
      let delta-aoc2 [aoc] of self - [aoc] of distant-worker2
      let update-aoc2 ([sodm] of self) / 280 * delta-aoc2
      if [sodm] of self >= 0.90 * max [sodm] of employees [
        set aoc aoc + update-aoc2
      ]
    ]

    if count my-out-friend-links > 1 [
      let friend-worker2 one-of [out-friend-link-neighbors] of self
      let delta-aoc3 [aoc] of self - [aoc] of friend-worker2
      let office-boost2 delta-aoc3 * (1.25 - 0.25 * [wfh-current] of self)
      let update-aoc3 ([sodm] of self) / 560 * office-boost2
      if [sodm] of self >= 0.90 * max [sodm] of employees [
        set aoc aoc + update-aoc3
      ]
    ]

    ;; 12 MAY 2022:
    ;; PERHAPS A FOURTH POLICY COULD BE A RECOMMENDATION: WHERE INDIVIDUALS
    ;; ARE SUGGESTED HOW TO WORK, BUT DO NOT DO THAT (SOMETHING CHANGES IN
    ;; THEIR DISPOSITIONS -- NOT AS HARD AS THE OTHER ONES)
    ;;
    ;; IMPLEMENTED v2.1


    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;;
    ;;                  UPDATE WORKING CONDITIONS
    ;;
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    ;; The next step is that of factoring in the preferences for working
    ;; conditions and how they might change. One element is the
    ;; divergence between current and actual working conditions

    ;; if they are currently working in the office but the ideal is
    ;; home, then we have dissonance
    let normalize-ideal (1 + 0.04 * [wfh-ideal] of self)

    if [wfh-current] of self < 3 and [wfh-ideal] of self > 60 [
      set dissonance abs (normalize-ideal - [wfh-current] of self)
    ]
    ;; opposite situation here:
    if [wfh-current] of self > 3 and [wfh-ideal] of self < 40 [
      set dissonance abs (normalize-ideal - [wfh-current] of self)
    ]

    ;; another is the virtual team efficacy and the average online (i.e. home)
    ;; time spent by the team in the actual working conditions--
    ;; when one thinks their team works excellently online but they are
    ;; mainly in the office, then it is probably a problem

    ;; the code if any? has been added (12 May) to prevent an error
    ;; from happening
    if any? my-generic-links [
      let team-wfh mean [wfh-current] of generic-link-neighbors
      let team-vte mean [vte] of generic-link-neighbors

      ;; the procedure also counts whether the individual feels
      ;; identified with the team.
      ;; If the team is great working online but the current
      ;; situation makes it work mainly in the office (and
      ;; the agent is identified with the team), then:
      if team-vte > 5 and team-wfh < 3 and [ident] of self > 4 [
        set team-dissonance abs ((team-vte / 7) * 5 - team-wfh)
      ]
      ;; the opposite scenario here:
      if team-vte < 3 and team-wfh > 3 and [ident] of self > 4 [
        set team-dissonance abs ((team-vte / 7) * 5 - team-wfh)
      ]
    ]

  ]

  turnover-triggers

  policy


    ;; next is iMOTIVATION -- this is a bit tricker because it is
    ;; supposed to be sticker than the other type. But it is also
    ;; the one that affects turnover the most and directly
    ;; the 'descriptive stats' file in the R-Studio project shows
    ;; that there is a good correlation between the two and
    ;; a regression explains ca. 26% of it
    ;; here is the update mechanism based on that:
  ifelse imot-update [
    let emot [e-motivation] of employees
    let imot [i-motivation] of employees
    let orgcom [aoc] of employees
    let empl_num sort [who + 1] of employees

    ;; Code for the regression:
    ;(r:putdataframe "data" "imot" imot "emot" emot "orgcom" orgcom "empl_num" empl_num)
    ;set alpha (r:get "lm(imot ~ orgcom + emot, data=data)$coef[1]")
    ;set coef1 (r:get "lm(imot ~ orgcom + emot, data=data)$coef[2]")
    ;set coef2 (r:get "lm(imot ~ orgcom + emot, data=data)$coef[3]")

    ;; the calculation below is not ideal because it is a random selection
    ;; instead of the exact corresponding value for the selected observation
    ask employees [
    ;  set res.err one-of (r:get "rnorm(max(data$empl_num), 0, sd(lm(imot ~ orgcom + emot, data=data)$residuals))")

    ;  set i-motivation (alpha + coef1 * [aoc] of self +
    ;    coef2 * [e-motivation] of self + res.err)
    ]

    ;r:eval "write.csv(data, file='reg.input.csv')"
    ;export-world (word "results " date-and-time ".csv")
  ][
    ask employees [
      ;; the below equation is calculated on the initial values
      ;; and it does not change throughout the simulation

      set i-motivation (0.7408 + 0.5906 * [aoc] of self +
        0.2577 * [e-motivation] of self + (random-normal 0 1))
    ]
  ]

  ;; repeated from the above to visualize other links
  ;; if necessary during the simulation

  if Link-visualizer = "Team" [
    ask generic-links [ show-link ]
    ask friend-links [ hide-link ]
    ask work-links [ hide-link ] ]
  if Link-visualizer = "Across teams" [
    ask work-links [ show-link ]
    ask friend-links [ hide-link ]
    ask generic-links [ hide-link ] ]
  if Link-visualizer = "Work:In&Out" [
    ask work-links [ show-link ]
    ask generic-links [ show-link ]
    ask friend-links [ hide-link ] ]
  if Link-visualizer = "Everything Across" [
    ask work-links [ show-link ]
    ask friend-links [ show-link ]
    ask generic-links [ hide-link ] ]
  if Link-visualizer = "Friendship" [
    ask friend-links [ show-link ]
    ask work-links [ hide-link ]
    ask generic-links [ hide-link ] ]
  if Link-visualizer = "Everything" [
    ask friend-links [ show-link ]
    ask work-links [ show-link ]
    ask generic-links [ show-link ] ]



end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;                  THE TRIGGERS OF TURNOVER
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; The code below takes from the interface to determine whether an
;; employee is likely to enter a turnover phase and to subsequently leave
;; the organization

to turnover-triggers
  ;; there are -- so far -- three conditions that trigger turnover intentions.
  ;; Two are around motivation, the other is AOC, then the other two are
  ;; those described as dissonance above -- team and individual dissonance.
  ;; The triggers are the thresholds in the Interface. Here is how they
  ;; work.

  ask employees [
    ;; the code if any? has been added (12 May) to prevent an error
    ;; from happening
    if any? my-generic-links [
      ;; first, the three dispositional characters:
      ;; if the value of the agent is below the threshold level of that of the team
      ;; then there is a trigger for turnover that is activated
      set emot-trigger e-motivation_threshold * mean [e-motivation] of generic-link-neighbors
      set imot-trigger i-motivation_threshold * mean [i-motivation] of generic-link-neighbors
      set aoc-trigger aoc_threshold * mean [aoc] of generic-link-neighbors

      if [e-motivation] of self <= emot-trigger [
        if toc-emot = 0 [
          set toc-emot 1
      ] ]
      if [i-motivation] of self <= imot-trigger [
        if toc-imot = 0 [
          set toc-imot 1
      ] ]
      if [aoc] of self <= aoc-trigger [
        if toc-aoc = 0 [
          set toc-aoc 1
      ] ]

      ;; then the two dissonance-based
      if [dissonance] of self > dissonance_threshold [
        if toc-diss = 0 [
          set toc-diss 1
      ] ]
      if [team-dissonance] of self > team-dissonance_threshold [
        if toc-tdiss = 0 [
          set toc-tdiss 1
      ] ]


      ;; here are the "aggravating' factors --
      ;; any number is more or less arbitrary here; this is why
      ;; there is one slider for all of them.
      ;; age: younger people are more likely to leave
      if [age] of self < 35 [
        set emot-trigger emot-trigger * (1 + Demographics_effect)
        set imot-trigger imot-trigger * (1 + Demographics_effect)
        set aoc-trigger aoc-trigger * (1 + Demographics_effect)
      ]
      ;; gender: male employees are more likely to leave
      if [gender] of self = 0 [
        set emot-trigger emot-trigger * (1 + Demographics_effect)
        set imot-trigger imot-trigger * (1 + Demographics_effect)
        set aoc-trigger aoc-trigger * (1 + Demographics_effect)
      ]

      ;; educated people are more likely to leave
      if [education] of self >= 3 [
        set emot-trigger emot-trigger * (1 + Demographics_effect)
        set imot-trigger imot-trigger * (1 + Demographics_effect)
        set aoc-trigger aoc-trigger * (1 + Demographics_effect)
      ]

      ;; tenure works against turnover
      if [tenure] of self < 3 [
        set emot-trigger emot-trigger * (1 + Demographics_effect)
        set imot-trigger imot-trigger * (1 + Demographics_effect)
        set aoc-trigger aoc-trigger * (1 + Demographics_effect)
      ]

      set turnover-count (toc-emot + toc-imot + toc-aoc + toc-diss + toc-tdiss)
    ]
  ]

  if Leaving? [
    ask employees with [turnover-count >= Number_of_critical_triggers] [
      die ]
  ]


  ;; IMPLEMENTED v2.1
  ;; the code below features hiring to replenish resources
  ;; and to just expand the work of the teams
  if Hiring? [

    ;; the below is to monitor the number of employees per team
    ;; so that it could serve as a benchmark to replenish resources
    if ticks = 1 [
      set Team1-start count employees with [team-ID = 1]
      set Team2-start count employees with [team-ID = 2]
      set Team3-start count employees with [team-ID = 3]
      set Team4-start count employees with [team-ID = 4]
      set Team5-start count employees with [team-ID = 5]
      set Team6-start count employees with [team-ID = 6]
      set Team7-start count employees with [team-ID = 7]
      set Team8-start count employees with [team-ID = 8]
    ]

    ;; I want to make it such that some resources are replenished
    ;; but not all the time, always on a monthly basis
    if cos (ticks / 22 * 360) = 1 [

      ;; this is the code to make it random
      ifelse random-poisson 2 = 1 [
        if Team1-start < count employees with [team-ID = 1] [
          ask one-of employees with [team-ID = 1] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team2-start < count employees with [team-ID = 2] [
          ask one-of employees with [team-ID = 2] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team3-start < count employees with [team-ID = 3] [
          ask one-of employees with [team-ID = 3] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team4-start < count employees with [team-ID = 4] [
          ask one-of employees with [team-ID = 4] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team5-start < count employees with [team-ID = 5] [
          ask one-of employees with [team-ID = 5] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team6-start < count employees with [team-ID = 6] [
          ask one-of employees with [team-ID = 6] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team7-start < count employees with [team-ID = 7] [
          ask one-of employees with [team-ID = 7] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
        if Team8-start < count employees with [team-ID = 8] [
          ask one-of employees with [team-ID = 8] [
            hatch 1
            set new? 1
            team_formation
          ]
        ]
      ][

        ;; opportunity for hiring opens once a month
        ;; independent of those who left
        if cos (ticks / 22 * 360) = 1 [

          ;; it is dependent from other resources (e.g., budget, procedures)
          ;; and that is calculated with at random
          if random-poisson 2 = 1 [


            ;; then the employees are allocated at random
            ask one-of employees [
              hatch 1
              set new? 1
              team_formation
            ]
          ]
        ]
      ]
    ]
  ]


end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;                  POLICY IMPLEMENTATION
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; This part of the simulation is to implement policies that go
;; in the sense of defining which direction to go with the location
;; of work.

to policy
  if Type-of-policy != "None" [
    if ticks = 22 * Month_of_implementation [
      if Type-of-policy = "Absolute-same for everyone" [

        ;; everyone is set to work as demanded
        ask employees [
          set wfh-current office_vs_home
        ]
      ]
      if Type-of-policy = "Relative to the team" [

        ;; the team adjusts by 50% the distance between the
        ;; current state and the one prescribed
        ask employees [
          let team-based mean [wfh-current] of generic-link-neighbors
          let delta-team (office_vs_home - team-based) * 0.5
          set wfh-current wfh-current + delta-team
        ]
      ]
      if Type-of-policy = "Relative to the employee" [

        ;; the individual adjusts and becomes 50% closer
        ;; to what prescribed by the policy
        ask employees [
          let ind-based [wfh-current] of self
          let delta-ind (office_vs_home - ind-based) * 0.5
          set wfh-current wfh-current + delta-ind
        ]
      ]
      if Type-of-policy = "Recommendation" [

        ;; IMPLEMENTED v2.1
        ;; here there is a recommendation, not an actual
        ;; norm---hence, the adjustment is minimal (10%)
        ask employees [
          let ind-based [wfh-current] of self
          let delta-ind (office_vs_home - ind-based) * 0.1
          set wfh-current wfh-current + delta-ind
        ]
      ]
    ]
  ]
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;
;;                  OLD CODE BELOW
;;
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; there are two stages, one casts effects on motivation
;; the second stage transforms these effects on performance

;; to structure the effects of the various elements on motivation
;; we shall divide them into positives and negatives
;; positives: aoc
;; negatives: wfh-c != wfh-i
;;            vte < wfh-c
;; the effects are more visible in e-m than on i-m

to motivation
  tick

  if ticks = 22 * (Years * 12) [stop]

  ask employees [
    set e-motivation e-motivation * (1 + aoc / 100)

    let wfh-gap (wfh-current - wfh-ideal)
    set e-motivation e-motivation * (1 + wfh-gap / 100)

    let vte-app (vte - wfh-current)
    set e-motivation e-motivation * (1 + vte-app / 100)
  ]

  ;; I am assuming that intrinsic motivation modifies more slowly
  ;; yet it is affected by modifications in extrinsic motivation

  if ticks > 0 and cos (ticks * 36) = 1 [
    ask employees [
      let e-m_gap (e-motivation - e-m_base)
      let e-m_quant abs e-m_gap / e-m_base
      if e-m_quant >= 0.1 [
        set i-motivation (i-motivation * (1 + e-m_gap / 100))
      ]
      if ticks > 10 [
        set e-m_base e-motivation
      ]
    ]
  ]

;; there are also social effects, that are calculated using sodm
;; and ident, meaning that a stronger identification with the team
;; suggests also alignment with its general disposition on wfh

  ask employees [
    ifelse count my-links with [color != orange] > 1 [
      let id-conn (mean [ident] of link-neighbors with [breed = employees])
      let id-team (mean [ident] of employees with [team-ID = [team-ID] of self])
      let aoc-conn (mean [aoc] of link-neighbors with [breed = employees])
      let aoc-team (mean [aoc] of employees with [team-ID = [team-ID] of self])

      ;; the first 'conn' measure is that of immediate team members while
      ;; the 'team' measure is of the entire team --- the difference determines
      ;; how much the closest contacts are influencial. When the gap is not so
      ;; wide then the impact is higher

      let id-gap (id-conn - id-team)
      let id-self ([ident] of self - id-conn)
      if abs id-gap / id-team < 0.1 [
        set e-motivation e-motivation * (1 + id-self / 100)
        set ident ident * (1 + id-self * sodm / standard-deviation [sodm] of employees)
      ]
      let aoc-gap (aoc-conn - aoc-team)
      let aoc-self ([aoc] of self - aoc-conn)
      if abs aoc-gap / aoc-team < 0.1 [
        set e-motivation e-motivation * (1 + aoc-self / 100)
        set aoc aoc * (1 + aoc-self * sodm / standard-deviation [aoc] of employees)
      ]

    ][
      if any? my-links with [color != orange] [
        let id-conn reduce + ([ident] of link-neighbors with [breed = employees])
        let id-team (mean [ident] of employees with [team-ID = [team-ID] of self])
        let aoc-conn reduce + ([aoc] of link-neighbors with [breed = employees])
        let aoc-team (mean [aoc] of employees with [team-ID = [team-ID] of self])

        let id-gap (id-conn - id-team)
        let id-self ([ident] of self - id-conn)
        if abs id-gap / id-team < 0.1 [
          set e-motivation e-motivation * (1 + id-self / 100)
          set ident ident * (1 + id-self * sodm / standard-deviation [sodm] of employees)
        ]
        let aoc-gap (aoc-conn - aoc-team)
        let aoc-self ([aoc] of self - aoc-conn)
        if abs aoc-gap / aoc-team < 0.1 [
          set e-motivation e-motivation * (1 + aoc-self / 100)
          set aoc aoc * (1 + aoc-self * sodm / standard-deviation [aoc] of employees)
        ]
      ]
    ]
  ]

end
@#$#@#$#@
GRAPHICS-WINDOW
509
12
946
450
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
20
19
86
52
setup
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
263
477
435
510
num_employees
num_employees
0
200
80.0
1
1
NIL
HORIZONTAL

SLIDER
263
511
435
544
num_managers
num_managers
1
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
264
567
436
600
mean_i-mot
mean_i-mot
1
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
264
602
436
635
mean_e-mot
mean_e-mot
1
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
263
637
435
670
mean_sodm
mean_sodm
1
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
263
674
435
707
mean_aoc
mean_aoc
1
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
263
709
435
742
mean_vte
mean_vte
1
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
263
745
435
778
mean_ident
mean_ident
1
7
4.0
1
1
NIL
HORIZONTAL

SLIDER
262
819
434
852
mean_wfh-c
mean_wfh-c
1
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
459
645
631
678
extra-team-comm
extra-team-comm
0
10
10.0
1
1
NIL
HORIZONTAL

SWITCH
459
612
578
645
out-reach
out-reach
1
1
-1000

SWITCH
441
478
544
511
labels?
labels?
0
1
-1000

SLIDER
262
855
434
888
mean_wfh-i
mean_wfh-i
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
954
13
1238
174
Motivation
Time
Motivation
0.0
10.0
1.0
7.0
true
true
"" ""
PENS
"e-mot" 1.0 0 -5825686 true "" "plot mean [e-motivation] of employees"
"i-mot" 1.0 0 -11221820 true "" "plot mean [i-motivation] of employees"

MONITOR
1020
363
1083
408
m-emot
mean [e-motivation] of employees
3
1
11

MONITOR
958
363
1015
408
m-aoc
mean [aoc] of employees
3
1
11

MONITOR
1251
365
1332
410
alpha
alpha
3
1
11

MONITOR
1082
363
1206
408
m-imot
mean [i-motivation] of employees
8
1
11

MONITOR
1333
365
1405
410
coef1
coef1
4
1
11

SWITCH
21
475
124
508
Data?
Data?
1
1
-1000

SWITCH
21
508
136
541
team_color
team_color
0
1
-1000

TEXTBOX
267
459
417
477
Simulated data
12
24.0
1

TEXTBOX
22
457
136
475
Empirical data
12
24.0
1

INPUTBOX
20
608
111
668
Team1-DZCPE
29.0
1
0
Number

INPUTBOX
112
608
203
668
Team2-RFSHW
7.0
1
0
Number

INPUTBOX
20
669
110
729
Team3-VP25
5.0
1
0
Number

INPUTBOX
111
669
203
729
Team4-SC
17.0
1
0
Number

INPUTBOX
20
730
110
790
Team5-NGCP
22.0
1
0
Number

INPUTBOX
111
730
202
790
Team6-CS
5.0
1
0
Number

INPUTBOX
20
791
109
851
Team7-DPdM
5.0
1
0
Number

INPUTBOX
110
791
202
851
Team8-TETRA
7.0
1
0
Number

TEXTBOX
22
558
172
576
Team actual numbers
10
44.0
1

SWITCH
20
574
202
607
Actual-team-sizes
Actual-team-sizes
0
1
-1000

MONITOR
1334
412
1420
457
res.err
standard-deviation [res.err] of employees
4
1
11

MONITOR
1251
412
1334
457
coef2
coef2
4
1
11

CHOOSER
194
18
353
63
Link-visualizer
Link-visualizer
"Team" "Across teams" "Friendship" "Work:In&Out" "Everything across" "Everything"
0

MONITOR
21
57
78
106
Month
ticks / 22
2
1
12

SLIDER
83
69
255
102
Years
Years
1
5
2.0
1
1
NIL
HORIZONTAL

SLIDER
262
784
435
817
mean_back-pre.pandemic
mean_back-pre.pandemic
0
100
50.0
1
1
NIL
HORIZONTAL

BUTTON
86
19
160
52
NIL
update
T
1
T
OBSERVER
NIL
U
NIL
NIL
1

SWITCH
21
862
196
895
Labels-friend-links
Labels-friend-links
1
1
-1000

PLOT
1238
13
1523
174
Affective Organizational Commitment
Time
Commitment
0.0
10.0
1.0
7.0
true
true
"" ""
PENS
"aoc" 1.0 0 -955883 true "" "plot mean [aoc] of employees"

SLIDER
25
309
284
342
e-motivation_threshold
e-motivation_threshold
0
1
0.6
0.1
1
percent
HORIZONTAL

SLIDER
25
345
283
378
i-motivation_threshold
i-motivation_threshold
0
1
0.6
0.1
1
percent
HORIZONTAL

SLIDER
26
382
284
415
aoc_threshold
aoc_threshold
0
1
0.8
0.1
1
percent
HORIZONTAL

MONITOR
1251
467
1371
512
team-dissonance
mean [team-dissonance] of employees
4
1
11

MONITOR
1381
468
1464
513
dissonance
mean [dissonance] of employees
4
1
11

SLIDER
286
309
505
342
dissonance_threshold
dissonance_threshold
0
3
1.0
1
1
delta
HORIZONTAL

SLIDER
285
345
504
378
team-dissonance_threshold
team-dissonance_threshold
0
3
1.0
1
1
delta
HORIZONTAL

MONITOR
1255
517
1317
562
emot-tr
mean [emot-trigger] of employees
4
1
11

MONITOR
1322
517
1408
562
toc-empl22
mean [turnover-count] of employees
3
1
11

PLOT
954
174
1238
324
Turnover Intentions
Time
Numb. empl.
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"3-triggers" 1.0 0 -1184463 true "" "plot count employees with [turnover-count = 3]"
"4-triggers" 1.0 0 -955883 true "" "plot count employees with [turnover-count = 4]"
"5-triggers" 1.0 0 -2674135 true "" "plot count employees with [turnover-count = 5]"
"#empl" 1.0 0 -7500403 true "" "plot count employees"

TEXTBOX
23
114
173
132
POLICY IMPLEMENTATION
12
24.0
1

SLIDER
23
130
244
163
Month_of_implementation
Month_of_implementation
0
12
3.0
1
1
months
HORIZONTAL

SLIDER
246
130
418
163
office_vs_home
office_vs_home
1
5
1.0
1
1
NIL
HORIZONTAL

CHOOSER
24
165
249
210
Type-of-policy
Type-of-policy
"None" "Relative to the team" "Relative to the employee" "Absolute-same for everyone" "Recommendation"
0

SWITCH
182
419
316
452
imot-update
imot-update
1
1
-1000

PLOT
1238
174
1523
324
Turnover Triggers
Time
Num. empl.
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"emot" 1.0 0 -16777216 true "" "plot sum [toc-emot] of employees"
"imot" 1.0 0 -7500403 true "" "plot sum [toc-imot] of employees"
"aoc" 1.0 0 -2674135 true "" "plot sum [toc-aoc] of employees"
"diss" 1.0 0 -955883 true "" "plot sum [toc-diss] of employees"
"Tdiss" 1.0 0 -13345367 true "" "plot sum [toc-tdiss] of employees"

SLIDER
287
381
503
414
Demographics_effect
Demographics_effect
0
1
0.8
0.01
1
NIL
HORIZONTAL

SWITCH
27
253
137
286
Leaving?
Leaving?
0
1
-1000

MONITOR
140
253
197
298
#empl
count employees
0
1
11

TEXTBOX
28
231
178
249
Turnover factors
12
24.0
1

SLIDER
208
254
435
287
Number_of_critical_triggers
Number_of_critical_triggers
3
5
4.0
1
1
NIL
HORIZONTAL

MONITOR
962
418
1050
463
wfh-current
mean [wfh-current] of employees
4
1
11

SWITCH
265
70
368
103
Hiring?
Hiring?
0
1
-1000

MONITOR
674
471
753
516
work-links
count work-links
2
1
11

MONITOR
756
471
842
516
friend-links
count friend-links
2
1
11

MONITOR
846
471
918
516
gen-links
count generic-links
2
1
11

@#$#@#$#@
# General considerations on MSWL Model

The MS Work Location (MSWL) Model is designed to study how the choice of location after COVID would affect employee turnover in the company [name anonymized]. Eight teams in total have been selected to be part of this research; they are all teams that are coordinated by the same leader.

The model is based on survey data, collected between January and February 2022. This data is used to determine the origination points of the employees and their reflection on turnover. This latter is the outcome variable and it can be benchmarked with data on turnover over the four phases (the last is open ended) of COVID, defined as:
<ul>
<li> Phase 1. Before COVID-19---until February 2020.</li>
<li> Phase 2. With COVID-19---February 2020 - June 2021.</li>
<li> Phase 3. With COVID-19, low incidence rate---June 2021 - November 2021.</li>
<li> Phase 4. With COVID-19, high incidence rate---November 2021 - February 2022.</li>
</ul>

### Turnover data
Turnover data is known for each of these phases and split by team. The information on employees is only available through the survey (i.e. January/February 2022). The model looks at data in retrospect. Basically, we can assume that the information we know as it was measured towards the last part of Phase 4 is also valid at the beginning of that period (more or less). Hence, those employees who left (8 between November 2021 and January 2022, 2 from Team1 and 6 from Team4) have somehow been affected by the team environment that generated the measurements collected in February 2022. And the measurement is not (this is the assumption) far away from where it was during the three months period. 

So, with this data, we can reinstate these 8 employees with less-than-average-attributed values for some of the relevant variables, and have them leave by the time the simulation hits February 2022.

#### Time
It is probably fair to approximate average working days per month to 22. Assuming no more than one meaningful interaction per coupled agents happens on a given day, it can be assumed that 22 ticks equal one month.

#### Variables linked to turnover
There are a few variables that have been shown to be positively related to employee turnover. Here are a few considerations of how the following are connected it in the model:
<ul>
<li><b>Affective commitment.</b> This is traditionally related to turnover in the sense that higher values have a negative impact on it. The higher this value is the less likely is that one leaves the organization.</li>
<li><b>Motivation.</b> Unmotivated employees are typically the ones who leave. We have two measures of motivation in this simulation: extrinsic and intrinsic. Those with lower levels of intrinsic motivaiton are more likely to leave quicker than those with lower levels of extrinsic motivation. The latter is, in fact, easier to restore while the former runs deep in a person's work life.</li>
<li><b>Ideal vs actual work conditions.</b> The data tells us the ideal split between actual work location (office vs home) and ideal preferences. It is fair to assume that when one's particular work condition is far from ideal, then the employee will look for a different organization and leave. </li>
</ul>

From the above, one could think there are three conditions: (a) Affective commitment and (b) Motivation are lower than their mean values in both the team's and friendship circles within the organization, and (c) the conditions are distant from ideal. When three thresholds are met, the agent leaves. The effect of the friendship circles only matter when a friend either left or is about to leave---this is because we did not ask directly about friendship but, more generally, whether people would talk about something other than work with someone outside of their team. This is a weak measure making for someone being acquaintance rather than friend. Hence, the effect of the relation is weaker. These are weak ties indeed (weaker than work ties). The trigger for being influenced is <i>socially-oriented decision making</i>.

When the above is calculated, then demographic variables come into play in the following way: (1) older employees tend not to leave, (b) men have a higher tendency to leave than women, (3) education plays in favor of leaving (highly educated people are more likely to find another job), and (4) tenure works against turnover.

### Variables and parameters
The simulation is fairly rich in input data. Here is a list of the data coming from the survey (see above) feeding variables in the model to characterize the agents:
<ul>
<li><b>Age.</b> Measured in years.</li>
<li><b>Gender.</b> '0' for men and '1' for women.</li>
<li><b>Education.</b> '1' secondary, '2' bachelor, '3' master, and '4' PhD.</li>
<li><b>Tenure.</b> The number of years an employee has been with the organization; measured in intervals: 'less than 1 year' = 1, '1-2' = 2, '3-5' = 3, '6-10' = 4, '11-20' = 5, and 'more than 20' = 6.</li>
<li><b>Manager.</b> Whether an employee has managerial responsibilities.</li>
<li><b>Team.</b> Whether the employee works in a team (from 0 to 8).</li>
<li><b>Motivation.</b> This is split into intrinsic and extrinsic motivation, measured on a 7-point Likert scale (two single items).</li>
<li><b>Socially-oriented decision making.</b> This is the concept of 'sociability' or 'docility' as mentioned in Secchi (2021) after Simon (1991); measured on a 7-point Likert scale (summated scale).</li>
<li><b>Affective organizational commitment.</b> This is a standard measure of commitment on a 7-point Likert scale (summated scale).</li>
<li><b>Virtual team efficacy.</b> The extent to which a team is good in performing online tasks; 7-point Likert scale (summated scale).</li>
<li><b>Team identification.</b> The degree with which employees identify themselves with the team they work with/in; 7-point Likert scale (summated scale).</li>
<li><b>Back to pre-pandemic.</b> Employees assessed on a 0-100 scale where 0 is 'terrible' and 100 is 'excellent' whether going back to pre-pandemic conditions is something they would be positive about.</li>
<li><b>Ideal split.</b> The ideal split between working from home and from the office; measured on a 0-100 scale, where 0 is 'always from the office' and 100 is 'always from home'.</li>
<li><b>Phase 1, 2, 3, and 4.</b> See above for the definition of the phases; we asked where each employee spent their working day between the office and home. They were measured on a 5-point scale where '1' is 'in the office all the time' and 5 is 'at home all the time'.</li>
</ul>

The survey also contained social network measures, to undestand the flow of information (and influence) outside each team:
<ul>
<li><b>Frequency.</b> On a scale 1-7 ('never' to 'always') the survey asked participants how frequently they get in touch with someone from another team.</li>
<li><b>Direction.</b> On a scale 1-7 ('Always from me to him/her' to 'Always from him/her' to me) the survey asked participants about the direction of the information flow between themselves and someone from another team.</li>
<li><b>Friendship.</b> On a scale 1-5 ('nobody', 'one', 'two', more than 'two' or 'everyone') the survey asked participants whether they talk about something other than work with someone outside of their team.</li>
</ul>



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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="MAIN-exp" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 22 [update]</go>
    <timeLimit steps="24"/>
    <metric>count employees</metric>
    <metric>count employees with [team-ID = 1]</metric>
    <metric>count employees with [team-ID = 2]</metric>
    <metric>count employees with [team-ID = 3]</metric>
    <metric>count employees with [team-ID = 4]</metric>
    <metric>count employees with [team-ID = 5]</metric>
    <metric>count employees with [team-ID = 6]</metric>
    <metric>count employees with [team-ID = 7]</metric>
    <metric>count employees with [team-ID = 8]</metric>
    <metric>count employees with [turnover-count = 1]</metric>
    <metric>count employees with [turnover-count = 2]</metric>
    <metric>count employees with [turnover-count = 3]</metric>
    <metric>count employees with [turnover-count = 4]</metric>
    <metric>count employees with [turnover-count = 5]</metric>
    <metric>list [age] of employees with [turnover-count = 3]</metric>
    <metric>list [age] of employees with [turnover-count = 4]</metric>
    <metric>list [age] of employees with [turnover-count = 5]</metric>
    <metric>list [gender] of employees with [turnover-count = 3]</metric>
    <metric>list [gender] of employees with [turnover-count = 4]</metric>
    <metric>list [gender] of employees with [turnover-count = 5]</metric>
    <metric>list [tenure] of employees with [turnover-count = 3]</metric>
    <metric>list [tenure] of employees with [turnover-count = 4]</metric>
    <metric>list [tenure] of employees with [turnover-count = 5]</metric>
    <metric>list [education] of employees with [turnover-count = 3]</metric>
    <metric>list [education] of employees with [turnover-count = 4]</metric>
    <metric>list [education] of employees with [turnover-count = 5]</metric>
    <metric>count employees with [new? = 1]</metric>
    <metric>list [team-ID] of employees with [new? = 1]</metric>
    <metric>sum [toc-emot] of employees</metric>
    <metric>sum [toc-imot] of employees</metric>
    <metric>sum [toc-aoc] of employees</metric>
    <metric>sum [toc-diss] of employees</metric>
    <metric>sum [toc-tdiss] of employees</metric>
    <metric>mean [e-motivation] of employees</metric>
    <metric>standard-deviation [e-motivation] of employees</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 1]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 2]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 3]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 4]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 5]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 6]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 7]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 8]</metric>
    <metric>mean [i-motivation] of employees</metric>
    <metric>standard-deviation [i-motivation] of employees</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 1]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 2]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 3]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 4]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 5]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 6]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 7]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 8]</metric>
    <metric>mean [aoc] of employees</metric>
    <metric>standard-deviation [aoc] of employees</metric>
    <metric>mean [aoc] of employees with [team-ID = 1]</metric>
    <metric>mean [aoc] of employees with [team-ID = 2]</metric>
    <metric>mean [aoc] of employees with [team-ID = 3]</metric>
    <metric>mean [aoc] of employees with [team-ID = 4]</metric>
    <metric>mean [aoc] of employees with [team-ID = 5]</metric>
    <metric>mean [aoc] of employees with [team-ID = 6]</metric>
    <metric>mean [aoc] of employees with [team-ID = 7]</metric>
    <metric>mean [aoc] of employees with [team-ID = 8]</metric>
    <metric>mean [vte] of employees</metric>
    <metric>standard-deviation [vte] of employees</metric>
    <metric>mean [vte] of employees with [team-ID = 1]</metric>
    <metric>mean [vte] of employees with [team-ID = 2]</metric>
    <metric>mean [vte] of employees with [team-ID = 3]</metric>
    <metric>mean [vte] of employees with [team-ID = 4]</metric>
    <metric>mean [vte] of employees with [team-ID = 5]</metric>
    <metric>mean [vte] of employees with [team-ID = 6]</metric>
    <metric>mean [vte] of employees with [team-ID = 7]</metric>
    <metric>mean [vte] of employees with [team-ID = 8]</metric>
    <enumeratedValueSet variable="out-reach">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_i-mot">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="e-motivation_threshold">
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Labels-friend-links">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hiring?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_wfh-i">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_aoc">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_ident">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Link-visualizer">
      <value value="&quot;Team&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i-motivation_threshold">
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Data?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_managers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_wfh-c">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_sodm">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Type-of-policy">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Relative to the team&quot;"/>
      <value value="&quot;Relative to the employee&quot;"/>
      <value value="&quot;Absolute-same for everyone&quot;"/>
      <value value="&quot;Recommendation&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Month_of_implementation">
      <value value="1"/>
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team7-DPdM">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Demographics_effect">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Actual-team-sizes">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team6-CS">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team1-DZCPE">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aoc_threshold">
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team8-TETRA">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team4-SC">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="team_color">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_employees">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team5-NGCP">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_e-mot">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="team-dissonance_threshold">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dissonance_threshold">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team2-RFSHW">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team3-VP25">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="imot-update">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Years">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number_of_critical_triggers">
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_back-pre.pandemic">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leaving?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="labels?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_vte">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="office_vs_home" first="1" step="1" last="5"/>
    <enumeratedValueSet variable="extra-team-comm">
      <value value="5"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="MAIN-exp_HiringOFF" repetitions="3" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>repeat 22 [update]</go>
    <timeLimit steps="24"/>
    <metric>count employees</metric>
    <metric>count employees with [team-ID = 1]</metric>
    <metric>count employees with [team-ID = 2]</metric>
    <metric>count employees with [team-ID = 3]</metric>
    <metric>count employees with [team-ID = 4]</metric>
    <metric>count employees with [team-ID = 5]</metric>
    <metric>count employees with [team-ID = 6]</metric>
    <metric>count employees with [team-ID = 7]</metric>
    <metric>count employees with [team-ID = 8]</metric>
    <metric>count employees with [turnover-count = 1]</metric>
    <metric>count employees with [turnover-count = 2]</metric>
    <metric>count employees with [turnover-count = 3]</metric>
    <metric>count employees with [turnover-count = 4]</metric>
    <metric>count employees with [turnover-count = 5]</metric>
    <metric>list [age] of employees with [turnover-count = 3]</metric>
    <metric>list [age] of employees with [turnover-count = 4]</metric>
    <metric>list [age] of employees with [turnover-count = 5]</metric>
    <metric>list [gender] of employees with [turnover-count = 3]</metric>
    <metric>list [gender] of employees with [turnover-count = 4]</metric>
    <metric>list [gender] of employees with [turnover-count = 5]</metric>
    <metric>list [tenure] of employees with [turnover-count = 3]</metric>
    <metric>list [tenure] of employees with [turnover-count = 4]</metric>
    <metric>list [tenure] of employees with [turnover-count = 5]</metric>
    <metric>list [education] of employees with [turnover-count = 3]</metric>
    <metric>list [education] of employees with [turnover-count = 4]</metric>
    <metric>list [education] of employees with [turnover-count = 5]</metric>
    <metric>count employees with [new? = 1]</metric>
    <metric>list [team-ID] of employees with [new? = 1]</metric>
    <metric>sum [toc-emot] of employees</metric>
    <metric>sum [toc-imot] of employees</metric>
    <metric>sum [toc-aoc] of employees</metric>
    <metric>sum [toc-diss] of employees</metric>
    <metric>sum [toc-tdiss] of employees</metric>
    <metric>mean [e-motivation] of employees</metric>
    <metric>standard-deviation [e-motivation] of employees</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 1]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 2]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 3]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 4]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 5]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 6]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 7]</metric>
    <metric>mean [e-motivation] of employees with [team-ID = 8]</metric>
    <metric>mean [i-motivation] of employees</metric>
    <metric>standard-deviation [i-motivation] of employees</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 1]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 2]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 3]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 4]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 5]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 6]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 7]</metric>
    <metric>mean [i-motivation] of employees with [team-ID = 8]</metric>
    <metric>mean [aoc] of employees</metric>
    <metric>standard-deviation [aoc] of employees</metric>
    <metric>mean [aoc] of employees with [team-ID = 1]</metric>
    <metric>mean [aoc] of employees with [team-ID = 2]</metric>
    <metric>mean [aoc] of employees with [team-ID = 3]</metric>
    <metric>mean [aoc] of employees with [team-ID = 4]</metric>
    <metric>mean [aoc] of employees with [team-ID = 5]</metric>
    <metric>mean [aoc] of employees with [team-ID = 6]</metric>
    <metric>mean [aoc] of employees with [team-ID = 7]</metric>
    <metric>mean [aoc] of employees with [team-ID = 8]</metric>
    <metric>mean [vte] of employees</metric>
    <metric>standard-deviation [vte] of employees</metric>
    <metric>mean [vte] of employees with [team-ID = 1]</metric>
    <metric>mean [vte] of employees with [team-ID = 2]</metric>
    <metric>mean [vte] of employees with [team-ID = 3]</metric>
    <metric>mean [vte] of employees with [team-ID = 4]</metric>
    <metric>mean [vte] of employees with [team-ID = 5]</metric>
    <metric>mean [vte] of employees with [team-ID = 6]</metric>
    <metric>mean [vte] of employees with [team-ID = 7]</metric>
    <metric>mean [vte] of employees with [team-ID = 8]</metric>
    <enumeratedValueSet variable="out-reach">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_i-mot">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="e-motivation_threshold">
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Labels-friend-links">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hiring?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_wfh-i">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_aoc">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_ident">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Link-visualizer">
      <value value="&quot;Team&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="i-motivation_threshold">
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Data?">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_managers">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_wfh-c">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_sodm">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Type-of-policy">
      <value value="&quot;None&quot;"/>
      <value value="&quot;Relative to the team&quot;"/>
      <value value="&quot;Relative to the employee&quot;"/>
      <value value="&quot;Absolute-same for everyone&quot;"/>
      <value value="&quot;Recommendation&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Month_of_implementation">
      <value value="1"/>
      <value value="3"/>
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team7-DPdM">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Demographics_effect">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Actual-team-sizes">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team6-CS">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team1-DZCPE">
      <value value="29"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aoc_threshold">
      <value value="0.6"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team8-TETRA">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team4-SC">
      <value value="17"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="team_color">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num_employees">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team5-NGCP">
      <value value="22"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_e-mot">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="team-dissonance_threshold">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="dissonance_threshold">
      <value value="0"/>
      <value value="1"/>
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team2-RFSHW">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team3-VP25">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="imot-update">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Years">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Number_of_critical_triggers">
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_back-pre.pandemic">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Leaving?">
      <value value="true"/>
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="labels?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mean_vte">
      <value value="4"/>
    </enumeratedValueSet>
    <steppedValueSet variable="office_vs_home" first="1" step="1" last="5"/>
    <enumeratedValueSet variable="extra-team-comm">
      <value value="5"/>
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

dashed
0.5
-0.2 0 0.0 1.0
0.0 1 4.0 4.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
