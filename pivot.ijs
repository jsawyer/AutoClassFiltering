NB. +===============================+
NB. \+-----------------------------+/
NB. \|            setup            |/
NB. \+-----------------------------+/
NB. +===============================+

NB. load the coocurence data
load 'csv'
readnoun=: 3!:2@(1!:1&(]`<@.(32&>@(3!:0))))
path=: 'C:\Users\jsawyer\j64-602-user\J\Coocurence\New2\'

$coocurMatrix=: readnoun path,'coocurMatrix.ijn'
$headings=: readnoun path,'headings.ijn'

NB. +===============================+
NB. \+-----------------------------+/
NB. \|             use             |/
NB. \+-----------------------------+/
NB. +===============================+

NB. base data
'colNames base'=: ({.;<@}.)readcsv path, 'RawScoresHE.csv'
dat=: ".>0 2 4 {"1 base
NB. headings grouped by companies
dat1=: ({."1 </.}."1) x:dat

NB. =========================================================
NB. pivoting

NB. headings not to be intitial pivots
NotFirstPivots=: 17643008 49861602 76443001 17636580 95381505 12671004 8203002 96103940 93693000

NB. twice the average coocurence value in coocurMatrix
NB. used to determine if pivots have enough data
avgCoocurScore=: (2*+/%#)+/coocurMatrix

NB. a function that returns the top "cluster" of headings
g=: (([:{.@:I.>./=])@:(0,}:-}.)@:({:"1,0:){.{."1)

NB. gives the initial pivot point to use for a company
getInitialPivots=: 3 : 0
 NB. remove bad options
 p1=. headings (#@:[~:i.) {."1 y		NB. remove headings unkown to the co-occur matrix
 p2=. ({."1 y) -.@:e. NotFirstPivots	NB. remove bad initial pivot points
 p=: I. p1*p2	NB. indices of possible initial pivots

 NB. get more pivot points dig for the next cluster
 getPivots=: 3 : '(indices;pivots)[indices=.(#pivots){.p [pivots=. (pivots,g ((#pivots)}.p){raw)[''indices pivots''=.y'
 NB. test is pivot scores are high enough to work with
 testSumPivotCoocurScore=: 3 : 'avgCoocurScore>+/,(headings i. (0 pick y){{."1 raw){coocurMatrix,0'
 
 NB. return initial pivots and indices
 getPivots^:testSumPivotCoocurScore^:_ ]2#<i.0
)

NB. uses Ralphs suggestions as pivots
getSuggestedPivots=: 3 : 0
 NB. use the suggested headings
 NB. will speed up algorithm and (hopefully) be more accurate
)

NB. performs the next order of pivoting
iterate=: 3 : 0
 NB. new pivots from last iteration
 'indices pivots pcoocurScores'=. y
 
 NB. add scores from current pivots
 coocurValues=. (+/(indices{rawscores)*(headings i. pivots){coocurMatrix,0),0
 coocurScores=. $.^:_1 pcoocurScores+rawscores*(headings i. {."1 raw) { coocurValues
 
 NB. next iteration pivots
 nextIndices=.I. 0 indices} coocurScores (~:&:*) pcoocurScores
 nextPivots=. nextIndices{{."1 raw
 
 NB. return info for next iteration
 nextIndices;nextPivots;coocurScores
)

NB. where the magic happens
pivot=: 3 : 0
 NB. input processed
 NB. top cluster of headings are chosen for intial pivots
 raw=: y
 rawscores=: x:^:_1 {:"1 y
 NB. initialize
 initialPivots=. getInitialPivots y
 NB.initialPivots=. getSuggestedPivots y
 
 NB. uses 2nd order pivoting
 aux1=. (2500<{:"1 y)*.((>0:)*.(>:(+/%#)@:-.&0)) >{:iterate^:2 initialPivots,<0#~#raw
 aux2=. 1 (>{.initialPivots)}0#~#raw
 aux1,.aux2
)

NB. ~6.5 minutes
6!:2 'aux12=. <"0;pivot&.>dat1'

NB. ---------------------------------------------------------
NB. flagging "right" answers
right=: ,/&.|:>".&.>readcsv path, 'HandEdit.csv'

NB. 1's indicate headings that belong
aux3=: <"0(".>0 2{"1 base) e. right

NB. support that no headings with raw score below 2500 should be kept
NB. (100*+/@:{:%~[:+/{:#~2500<{.)(~.,:#/.~)/:~(;aux3)#;".&.>4{"1 base

NB. ---------------------------------------------------------
NB. write about it
((colNames, ;:'AUX1 AUX2 AUX3'), base,.aux12,.aux3) writecsv path, 'pivot4.csv'
