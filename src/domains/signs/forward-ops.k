require "lattice.k"
require "../../lang/arith-ops.k"

module FORWARD-OPS
	imports LATTICE
	imports ARITH-OPS
	imports INIT

//@ \section{Operations on reference counters}

	syntax 	ARefCount ::= ARefCount "+ARefCount" ARefCount [function]

	rule	ARC0 +ARefCount ARC0   => ARC0
	rule	ARC0 +ARefCount ARC1   => ARC1
	rule	ARC0 +ARefCount ARC2   => ARC2
	rule	ARC0 +ARefCount ARC>2  => ARC>2

	rule	ARC1 +ARefCount ARC0   => ARC1
	rule	ARC1 +ARefCount ARC1   => ARC2
	rule	ARC1 +ARefCount ARC2   => ARC>2
	rule	ARC1 +ARefCount ARC>2  => ARC>2

	rule	ARC2 +ARefCount ARC0   => ARC2
	rule	ARC2 +ARefCount ARC1   => ARC>2
	rule	ARC2 +ARefCount ARC2   => ARC>2
	rule	ARC2 +ARefCount ARC>2  => ARC>2

	rule	ARC>2 +ARefCount ARC0  => ARC>2
	rule	ARC>2 +ARefCount ARC1  => ARC>2
	rule	ARC>2 +ARefCount ARC2  => ARC>2
	rule	ARC>2 +ARefCount ARC>2 => ARC>2

	syntax 	ARefCount ::= ARefCount "-ARefCount" ARefCount [function] 

	rule	ARC0 -ARefCount ARC0   => ARC0
	//rule	ARC0 -ARefCount ARC1   => ARC1
	//rule	ARC0 -ARefCount ARC2   => ARC2
	//rule	ARC0 -ARefCount ARC>2  => ARC>2

	rule	ARC1 -ARefCount ARC0   => ARC1
	rule	ARC1 -ARefCount ARC1   => ARC0
	//rule	ARC1 -ARefCount ARC2   => ARC>2
	//rule	ARC1 -ARefCount ARC>2  => ARC>2

	rule	ARC2 -ARefCount ARC0   => ARC2
	rule	ARC2 -ARefCount ARC1   => ARC1
	rule	ARC2 -ARefCount ARC2   => ARC0
	//rule	ARC2 -ARefCount ARC>2  => ARC>2

	rule	ARC>2 -ARefCount ARC0  => ARC>2
	rule	ARC>2 -ARefCount ARC1  => ARC>2
	rule	ARC>2 -ARefCount ARC2  => ARC>2
	rule	ARC>2 -ARefCount ARC>2 => ARC>2
	

	syntax 	Bool ::= ARefCount "<ARefCount" ARefCount [function] 

	rule	ARC0 <ARefCount ARC0   => false
	rule	ARC0 <ARefCount ARC1   => true
	rule	ARC0 <ARefCount ARC2   => true
	rule	ARC0 <ARefCount ARC>2  => true

	rule	ARC1 <ARefCount ARC0   => false
	rule	ARC1 <ARefCount ARC1   => false
	rule	ARC1 <ARefCount ARC2   => true
	rule	ARC1 <ARefCount ARC>2  => true

	rule	ARC2 <ARefCount ARC0   => false
	rule	ARC2 <ARefCount ARC1   => false
	rule	ARC2 <ARefCount ARC2   => false
	rule	ARC2 <ARefCount ARC>2  => true

	rule	ARC>2 <ARefCount ARC0  => false
	rule	ARC>2 <ARefCount ARC1  => false
	rule	ARC>2 <ARefCount ARC2  => false
	rule	ARC>2 <ARefCount ARC>2 => false // ?!?





//@ \section{Arithmetic operations}

	// Plus
	syntax  AInt ::= AInt "+AInt" AInt	[function]	

	rule 	AIntBot +AInt AIntBot			=> AIntBot
	rule 	AIntBot +AInt AIntNeg 			=> AIntBot
	rule 	AIntBot +AInt AIntZero 			=> AIntBot
	rule 	AIntBot +AInt AIntPos 			=> AIntBot
	rule 	AIntBot +AInt AIntTop 			=> AIntBot
	
	rule 	AIntTop +AInt AIntBot 			=> AIntBot
	rule 	AIntTop +AInt AIntNeg 			=> AIntTop
	rule 	AIntTop +AInt AIntZero 			=> AIntTop
	rule 	AIntTop +AInt AIntPos 			=> AIntTop
	rule 	AIntTop +AInt AIntTop 			=> AIntTop
	
	rule 	AIntNeg +AInt AIntBot 			=> AIntBot
	rule 	AIntNeg +AInt AIntNeg 			=> AIntNeg
	rule 	AIntNeg +AInt AIntZero 			=> AIntNeg
	rule 	AIntNeg +AInt AIntPos 			=> AIntTop
	rule 	AIntNeg +AInt AIntTop 			=> AIntTop

	rule 	AIntZero +AInt AIntBot 			=> AIntBot
	rule 	AIntZero +AInt AIntNeg 			=> AIntNeg
	rule 	AIntZero +AInt AIntZero 		=> AIntZero
	rule 	AIntZero +AInt AIntPos 			=> AIntPos
	rule 	AIntZero +AInt AIntTop 			=> AIntTop

	rule 	AIntPos +AInt AIntBot 			=> AIntBot
	rule 	AIntPos +AInt AIntNeg 			=> AIntTop
	rule 	AIntPos +AInt AIntZero 			=> AIntPos
	rule 	AIntPos +AInt AIntPos 			=> AIntPos
	rule 	AIntPos +AInt AIntTop 			=> AIntTop

	syntax  AFloat ::= AFloat "+AFloat" AFloat	[function]
   
	rule 	AFloatBot +AFloat AFloatBot		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatNeg 		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatZero 		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatPos 		=> AFloatBot
	rule 	AFloatBot +AFloat AFloatTop 		=> AFloatBot
	
	rule 	AFloatTop +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatTop +AFloat AFloatNeg 		=> AFloatTop
	rule 	AFloatTop +AFloat AFloatZero 		=> AFloatTop
	rule 	AFloatTop +AFloat AFloatPos 		=> AFloatTop
	rule 	AFloatTop +AFloat AFloatTop 		=> AFloatTop
	
	rule 	AFloatNeg +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatNeg +AFloat AFloatNeg 		=> AFloatNeg
	rule 	AFloatNeg +AFloat AFloatZero 		=> AFloatNeg
	rule 	AFloatNeg +AFloat AFloatPos 		=> AFloatTop
	rule 	AFloatNeg +AFloat AFloatTop 		=> AFloatTop

	rule 	AFloatZero +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatZero +AFloat AFloatNeg 		=> AFloatNeg
	rule 	AFloatZero +AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatZero +AFloat AFloatPos 		=> AFloatPos
	rule 	AFloatZero +AFloat AFloatTop 		=> AFloatTop

	rule 	AFloatPos +AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatPos +AFloat AFloatNeg 		=> AFloatTop
	rule 	AFloatPos +AFloat AFloatZero 		=> AFloatPos
	rule 	AFloatPos +AFloat AFloatPos 		=> AFloatPos
	rule 	AFloatPos +AFloat AFloatTop 		=> AFloatTop
  
	// Min
	syntax  AInt ::= AInt "-AInt" AInt	[function]	
    
	syntax  AFloat ::= AFloat "-AFloat" AFloat	[function]

	// Mul
	syntax  AInt ::= AInt "*AInt" AInt	[function]	

    	rule 	AIntBot *AInt AIntBot			=> AIntBot
	rule 	AIntBot *AInt AIntNeg 			=> AIntBot
	rule 	AIntBot *AInt AIntZero 			=> AIntBot
	rule 	AIntBot *AInt AIntPos 			=> AIntBot
	rule 	AIntBot *AInt AIntTop 			=> AIntBot
	
	rule 	AIntTop *AInt AIntBot 			=> AIntBot
	rule 	AIntTop *AInt AIntNeg 			=> AIntTop
	rule 	AIntTop *AInt AIntZero 			=> AIntZero
	rule 	AIntTop *AInt AIntPos 			=> AIntTop
	rule 	AIntTop *AInt AIntTop 			=> AIntTop
	
	rule 	AIntNeg *AInt AIntBot 			=> AIntBot
	rule 	AIntNeg *AInt AIntNeg 			=> AIntPos
	rule 	AIntNeg *AInt AIntZero 			=> AIntZero
	rule 	AIntNeg *AInt AIntPos 			=> AIntNeg
	rule 	AIntNeg *AInt AIntTop 			=> AIntTop

	rule 	AIntZero *AInt AIntBot 			=> AIntBot
	rule 	AIntZero *AInt AIntNeg 			=> AIntZero
	rule 	AIntZero *AInt AIntZero 		=> AIntZero
	rule 	AIntZero *AInt AIntPos 			=> AIntZero
	rule 	AIntZero *AInt AIntTop 			=> AIntZero

	rule 	AIntPos *AInt AIntBot 			=> AIntBot
	rule 	AIntPos *AInt AIntNeg 			=> AIntNeg
	rule 	AIntPos *AInt AIntZero 			=> AIntZero
	rule 	AIntPos *AInt AIntPos 			=> AIntPos
	rule 	AIntPos *AInt AIntTop 			=> AIntTop


	syntax  AFloat ::= AFloat "*AFloat" AFloat	[function]

    	rule 	AFloatBot *AFloat AFloatBot		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatNeg 		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatZero 		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatPos 		=> AFloatBot
	rule 	AFloatBot *AFloat AFloatTop 		=> AFloatBot
	
	rule 	AFloatTop *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatTop *AFloat AFloatNeg 		=> AFloatTop
	rule 	AFloatTop *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatTop *AFloat AFloatPos 		=> AFloatTop
	rule 	AFloatTop *AFloat AFloatTop 		=> AFloatTop
	
	rule 	AFloatNeg *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatNeg *AFloat AFloatNeg 		=> AFloatPos
	rule 	AFloatNeg *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatNeg *AFloat AFloatPos 		=> AFloatNeg
	rule 	AFloatNeg *AFloat AFloatTop 		=> AFloatTop

	rule 	AFloatZero *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatZero *AFloat AFloatNeg 		=> AFloatZero
	rule 	AFloatZero *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatZero *AFloat AFloatPos 		=> AFloatZero
	rule 	AFloatZero *AFloat AFloatTop 		=> AFloatZero

	rule 	AFloatPos *AFloat AFloatBot 		=> AFloatBot
	rule 	AFloatPos *AFloat AFloatNeg 		=> AFloatNeg
	rule 	AFloatPos *AFloat AFloatZero 		=> AFloatZero
	rule 	AFloatPos *AFloat AFloatPos 		=> AFloatPos
	rule 	AFloatPos *AFloat AFloatTop 		=> AFloatTop

	// Div (TODO) 

    // Mod (TODO) 

	syntax 	AInt ::= "negative_AInt" "(" AInt ")" [function]
	rule	negative_AInt(AIntBot) 	=> AIntBot
	rule	negative_AInt(AIntPos) 	=> AIntNeg
	rule	negative_AInt(AIntZero) => AIntZero
	rule	negative_AInt(AIntNeg) 	=> AIntPos
	rule	negative_AInt(AIntTop) 	=> AIntTop
	
	syntax 	AFloat ::= "negative_AFloat" "(" AFloat ")" [function]
	rule	negative_AFloat(AFloatBot) 	=> AFloatBot
	rule	negative_AFloat(AFloatPos) 	=> AFloatNeg
	rule	negative_AFloat(AFloatZero) 	=> AFloatZero
	rule	negative_AFloat(AFloatNeg) 	=> AFloatPos
	rule	negative_AFloat(AFloatTop) 	=> AFloatTop
	



//@ \section{Type conversion primitives}


syntax AString ::= "*toString" "(" LanguageValue ")"   [function]


rule 	*toString(I:AInt) => AStringTop
rule 	*toString(F:AFloat) => AStringTop
rule 	*toString(S:AString) => S
rule 	*toString(ABoolTop) => AStringTop
rule 	*toString(Top) => AStringTop
rule	*toString(ABoolTrue) => "1"
rule	*toString(ABoolFalse) => ""

// TODO: define!!!

rule	*toString(_:CompoundValue) => AStringTop



    // to boolean
    syntax ABool ::= "*toBoolean" "(" LanguageValue ")" [function]

    rule *toBoolean(B:ABool) => B 
	        [internal]
	
    rule *toBoolean(AIntZero) => ABoolFalse 
	        [internal]

    rule  *toBoolean(N:AInt) => ABoolTrue 
	        when (N =/=K AIntZero)
	        [internal]

    rule *toBoolean(AFloatZero) => ABoolFalse 
	        [internal]

    rule *toBoolean(F:AFloat) => ABoolTrue 
	        when (F =/=K AFloatZero)
	        [internal]

    rule *toBoolean("") => ABoolFalse 
	        [internal]

    rule *toBoolean("0") => ABoolFalse 
	        [internal]

    rule  *toBoolean(S:String) => ABoolTrue 
	        when notBool ((S ==String "") orBool (S ==String "0"))
	        [internal]

    rule  *toBoolean(AStringTop) => ABoolTop [internal]
    rule  *toBoolean(Top) => ABoolTop [internal]

    rule *toBoolean(Array(_,Elems)) => ABoolFalse 
	        when (Elems ==List .List)
	        [internal]

    rule *toBoolean(Array(_,Elems)) => ABoolTrue   
	        when (notBool (Elems ==List .List))
	        [internal]

// Object case: we add it, even if the online docs says this behaviour is "PHP 4 only"
// Since the expected behaviour for PHP 5 is not mentioned, I guess it is undefined..?

    rule  *toBoolean(OID(L,_,_) => convertToLanguageValue(L))   
	        [internal]

    rule   *toBoolean(NULL) => ABoolFalse   [internal]

    // to float
	syntax  AFloat ::= "*toFloat" "(" K ")"  [function]
    rule   *toFloat(ABoolFalse) => AFloatZero  [internal]
	
    rule  *toFloat(ABoolTrue) =>   AFloatPos  [internal]

    rule  *toFloat(AIntPos) => AFloatPos    [internal]
	rule  *toFloat(AIntNeg) => AFloatNeg    [internal]
	rule  *toFloat(AIntZero) => AFloatZero   [internal]
		
	rule  *toFloat(AIntTop) => AFloatTop  [internal]
	rule  *toFloat(Top) => AFloatTop  [internal]

    rule  *toFloat(F:AFloat) => F [internal]

    rule *toFloat(S:String) => *toFloat(string2Number(S)) [internal]
	
    rule  *toFloat(O:CompoundValue) => WARNING("conversion of compound types to integer is undefined (http://www.php.net/manual/en/language.types.integer.php)\n") ~> 1.0   [internal, error]

//@ \section{Logical ops}

    syntax  ABool ::= "notABool" ABool [function]

    rule    notABool ABoolTrue => ABoolFalse
    rule    notABool ABoolFalse => ABoolTrue
    rule    notABool ABoolBot => ABoolBot
    rule    notABool ABoolTop => ABoolTop

//@ \section{Comparisons}




    syntax  ABool ::= AInt "==AInt" AInt [function]

    rule    AIntBot ==AInt AIntBot         => ABoolBot
    rule    AIntBot ==AInt  AIntNeg        => ABoolBot
    rule    AIntBot ==AInt  AIntZero       => ABoolBot
    rule    AIntBot ==AInt  AIntPos        => ABoolBot
    rule    AIntBot ==AInt  AIntTop        => ABoolBot

    rule    AIntNeg ==AInt  AIntBot        => ABoolBot
    rule    AIntNeg ==AInt  AIntNeg        => ABoolTop
    rule    AIntNeg ==AInt  AIntZero       => ABoolFalse
    rule    AIntNeg ==AInt  AIntPos        => ABoolFalse
    rule    AIntNeg ==AInt AIntTop         => ABoolTop
    
    rule    AIntZero ==AInt  AIntBot       => ABoolBot
    rule    AIntZero ==AInt  AIntNeg       => ABoolFalse
    rule    AIntZero ==AInt  AIntZero      => ABoolTrue
    rule    AIntZero ==AInt  AIntPos       => ABoolFalse
    rule    AIntZero ==AInt  AIntTop       => ABoolTop

    rule    AIntPos ==AInt  AIntBot        => ABoolBot
    rule    AIntPos ==AInt AIntNeg         => ABoolFalse
    rule    AIntPos ==AInt  AIntZero       => ABoolFalse
    rule    AIntPos ==AInt  AIntPos        => ABoolTop
    rule    AIntPos ==AInt  AIntTop        => ABoolTop
    
    rule    AIntTop ==AInt  AIntBot        => ABoolBot
    rule    AIntTop ==AInt  AIntNeg        => ABoolTop
    rule    AIntTop ==AInt  AIntZero       => ABoolTop
    rule    AIntTop ==AInt  AIntPos        => ABoolTop
    rule    AIntTop ==AInt  AIntTop        => ABoolTop


    syntax  ABool ::= AFloat "==AFloat" AFloat [function]
    
	rule    AFloatBot ==AFloat AFloatBot         => ABoolBot
    rule    AFloatBot ==AFloat  AFloatNeg        => ABoolBot
    rule    AFloatBot ==AFloat  AFloatZero       => ABoolBot
    rule    AFloatBot ==AFloat  AFloatPos        => ABoolBot
    rule    AFloatBot ==AFloat  AFloatTop        => ABoolBot

    rule    AFloatNeg ==AFloat  AFloatBot        => ABoolBot
    rule    AFloatNeg ==AFloat  AFloatNeg        => ABoolTop
    rule    AFloatNeg ==AFloat  AFloatZero       => ABoolFalse
    rule    AFloatNeg ==AFloat  AFloatPos        => ABoolFalse
    rule    AFloatNeg ==AFloat AFloatTop         => ABoolTop
    
    rule    AFloatZero ==AFloat  AFloatBot       => ABoolBot
    rule    AFloatZero ==AFloat  AFloatNeg       => ABoolFalse
    rule    AFloatZero ==AFloat  AFloatZero      => ABoolTrue
    rule    AFloatZero ==AFloat  AFloatPos       => ABoolFalse
    rule    AFloatZero ==AFloat  AFloatTop       => ABoolTop

    rule    AFloatPos ==AFloat  AFloatBot        => ABoolBot
    rule    AFloatPos ==AFloat AFloatNeg         => ABoolFalse
    rule    AFloatPos ==AFloat  AFloatZero       => ABoolFalse
    rule    AFloatPos ==AFloat  AFloatPos        => ABoolTop
    rule    AFloatPos ==AFloat  AFloatTop        => ABoolTop
    
    rule    AFloatTop ==AFloat  AFloatBot        => ABoolBot
    rule    AFloatTop ==AFloat  AFloatNeg        => ABoolTop
    rule    AFloatTop ==AFloat  AFloatZero       => ABoolTop
    rule    AFloatTop ==AFloat  AFloatPos        => ABoolTop
    rule    AFloatTop ==AFloat  AFloatTop        => ABoolTop
	
    syntax  ABool ::= ABool "==ABool" ABool [function]
    
	rule ABoolBot ==ABool _ => ABoolBot
	rule _ ==ABool ABoolBot => ABoolBot
	
	rule ABoolTop ==ABool B => ABoolTop
	when B =/=K ABoolBot
	
	rule B ==ABool ABoolTop => ABoolTop
	when B =/=K ABoolBot
	
	rule ABoolTrue ==ABool ABoolTrue => ABoolTrue
	
	rule ABoolFalse ==ABool ABoolFalse => ABoolTrue
	
	rule ABoolTrue ==ABool ABoolFalse => ABoolFalse
	
	rule ABoolFalse ==ABool ABoolTrue => ABoolFalse
	
    syntax  ABool ::= AString "==AString" AString [function]
    
	
	rule S1:String ==AString S2:String => ABoolTrue
	when S1 ==String S2
	
	rule S1:String ==AString S2:String => ABoolFalse
	when notBool(S1 ==String S2)
	
	rule AStringTop ==AString S => ABoolTop
	when S =/=K AStringBot
	
	rule S ==AString AStringTop => ABoolTop
	when S =/=K AStringBot
	
	
	rule greater(AIntZero, AIntZero) => ABoolFalse
	
	rule greater(AIntNeg, AIntNeg) => ABoolTop
	
	rule greater(AIntPos, AIntPos) => ABoolTop
	   
	rule greater(AIntNeg, AIntZero) => ABoolFalse
	
	rule greater(AIntZero, AIntNeg) => ABoolTrue
	
	rule greater(AIntNeg, AIntPos) => ABoolFalse

	rule greater(AIntPos, AIntNeg) => ABoolTrue
	
	rule greater(AIntPos, AIntZero) => ABoolTrue
	
	rule greater(AIntZero, AIntPos) => ABoolFalse
	
	rule greater(AIntBot, _ ) => ABoolBot
	
	rule greater(_, AIntBot) => ABoolBot
	
	rule greater(AIntTop, I:AInt) => ABoolTop
		when I =/=K AIntBot
		
	rule greater(I:AInt, AIntTop) => ABoolTop
		when I =/=K AIntBot
	
	
	
	rule less(AIntZero, AIntZero) => ABoolFalse
	
	rule less(AIntNeg, AIntNeg) => ABoolTop
	
	rule less(AIntPos, AIntPos) => ABoolTop
	   
	rule less(AIntNeg, AIntZero) => ABoolTrue
	
	rule less(AIntZero, AIntNeg) => ABoolFalse
	
	rule less(AIntNeg, AIntPos) => ABoolTrue

	rule less(AIntPos, AIntNeg) => ABoolFalse
	
	rule less(AIntPos, AIntZero) => ABoolFalse
	
	rule less(AIntZero, AIntPos) => ABoolTrue
	
	rule less(AIntBot, _ ) => ABoolBot
	
	rule less(_, AIntBot) => ABoolBot
	
	rule less(AIntTop, I:AInt) => ABoolTop
		when I =/=K AIntBot
		
	rule less(I:AInt, AIntTop) => ABoolTop
		when I =/=K AIntBot
	
	
	rule lessEqual(AIntZero, AIntZero) => ABoolTrue
	
	rule lessEqual(AIntNeg, AIntNeg) => ABoolTop
	
	rule lessEqual(AIntPos, AIntPos) => ABoolTop
	   
	rule lessEqual(AIntNeg, AIntZero) => ABoolTrue
	
	rule lessEqual(AIntZero, AIntNeg) => ABoolFalse
	
	rule lessEqual(AIntNeg, AIntPos) => ABoolTrue

	rule lessEqual(AIntPos, AIntNeg) => ABoolFalse
	
	rule lessEqual(AIntPos, AIntZero) => ABoolFalse
	
	rule lessEqual(AIntZero, AIntPos) => ABoolTrue
	
	rule lessEqual(AIntBot, _ ) => ABoolBot
	
	rule lessEqual(_, AIntBot) => ABoolBot
	
	rule lessEqual(AIntTop, I:AInt) => ABoolTop
		when I =/=K AIntBot
		
	rule lessEqual(I:AInt, AIntTop) => ABoolTop
		when I =/=K AIntBot
		
		
	rule greaterEqual(AIntZero, AIntZero) => ABoolTrue
	
	rule greaterEqual(AIntNeg, AIntNeg) => ABoolTop
	
	rule greaterEqual(AIntPos, AIntPos) => ABoolTop
	   
	rule greaterEqual(AIntNeg, AIntZero) => ABoolFalse
	
	rule greaterEqual(AIntZero, AIntNeg) => ABoolTrue
	
	rule greaterEqual(AIntNeg, AIntPos) => ABoolFalse

	rule greaterEqual(AIntPos, AIntNeg) => ABoolTrue
	
	rule greaterEqual(AIntPos, AIntZero) => ABoolTrue
	
	rule greaterEqual(AIntZero, AIntPos) => ABoolFalse
	
	rule greaterEqual(AIntBot, _ ) => ABoolBot
	
	rule greaterEqual(_, AIntBot) => ABoolBot
	
	rule greaterEqual(AIntTop, I:AInt) => ABoolTop
		when I =/=K AIntBot
		
	rule greaterEqual(I:AInt, AIntTop) => ABoolTop
		when I =/=K AIntBot
	
	
	// String concatenation operation
	rule [concat-string-concrete]:
	<k> 'Concat(S1:String,, S2:String) => S1 +String S2 ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-concrete") </trace>
	[step]
	
	rule [concat-string-top-1]:
	<k> 'Concat(AStringTop,, S:AString) => AStringTop ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-top-1") </trace>
	[step]
	
	rule [concat-string-top-2]:
	<k> 'Concat(S:AString,, AStringTop) => AStringTop ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-top-2") </trace>
	[step]
	
	rule [concat-string-bot-1]:
	<k> 'Concat(AStringBot,, S:AString) => AStringBot ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-bot-1") </trace>
	[step]
	
	rule [concat-string-bot-2]:
	<k> 'Concat(S:AString,, AStringBot) => AStringBot ... </k>
	<trace> Trace:List => Trace ListItem("concat-string-bot-2") </trace>
	[step]
	
//@ \section{Input and output}

    // output
    syntax  K ::= "print" "(" K ")"
    
rule    [internal-print]:
            <k> print (V:AString)  => . ... </k>
            <out> ... . => ListItem(V) </out>
            [internal, output]   

rule [internal-print]:    
	<k> print (I:AInt  => *toString(I)) ... </k>
	<trace> Trace:List => Trace ListItem("internal-print") </trace>
	[internal, output]
    // input
    syntax K ::= "user_input"
	
    rule [input]:
    	<k>  user_input => AStringTop ...</k>
	
	rule [init-domain]:
		<k> initDomain => . ... </k>
		<domain> .K => Signs </domain>
		
	rule strlen(AStringTop) => AIntPos
	
	rule strlen(S:String) => AIntPos
		when S =/=String ""
		
	rule strlen("") => AIntZero
	
	rule strlen(AStringBot) => AIntBot

	syntax Bool ::= "isNumericString" "(" AString ")" [function]
	
	//RR-FIXME : Not trustworthy, relies on K behaviour
	rule isNumericString(S:String) => S isNumeric
		

//string2Number

	rule string2Number(_) => AIntTop	//RR-FIXME : quick fix, maybe should say Top because it could be a float ?


	syntax PlainLanguageValue ::= "string2Number" "(" AString ")"	[function]
//RR-FIXME : concrete case (relies on K behaviour, not very trustworthy)

	/*
	rule string2Number("") => AIntZero ... [internal]

	// one character string

	rule [string2Number-char-non-digit]:    
	<k> string2Number(S:String) => 0 ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-char-non-digit") </trace>
	when (lengthString(S) ==Int 1 orBool lengthString(S) ==Int 2) andBool (notBool #isDigit(substrString(S, 0, 1)))
	[internal]

	rule [string2Number-char-digit]:    
	<k> string2Number(S:String) => String2Int(S) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-char-digit") </trace>
	when (lengthString(S) ==Int 1) andBool (#isDigit(substrString(S, 0, 1)))
	[internal]

	// non numeric 

	rule [string2Number-non-numeric]:    
	<k> string2Number(S:String) => 0 ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-non-numeric") </trace>
	when notBool (
		((lengthString(S) >Int 1) andBool #isDigit(substrString(S, 0, 1))) orBool	
		((substrString(S, 0, 1) ==String "-" orBool substrString(S, 0, 1) ==String ".") andBool (#isDigit(substrString(S, 1, 2)))) orBool
		((substrString(S, 0, 2) ==String "-.") andBool (#isDigit(substrString(S, 2, 3)))))
	[internal]
	
	// integer 

	rule [string2Number-int]:    
	<k> string2Number(S:String) => extractIntSubstring(S, substrString(S, 0, 1), 1, int) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-int") </trace>
	when ((lengthString(S) >Int 1) andBool
	#isDigit(substrString(S, 0, 1))) orBool
	((substrString(S, 0, 1) ==String "-") andBool (#isDigit(substrString(S, 1, 2))))
	[internal]

	// string starting with ".N" 

	rule [string2Number-float-dot]:    
	<k> string2Number(S:String) => extractIntSubstring(S, substrString(S, 0, 1), 1, float) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-float-dot") </trace>
	when ((lengthString(S) >Int 1) andBool
	#isDigit(substrString(S, 0, 1))) orBool
	((substrString(S, 0, 1) ==String ".") andBool (#isDigit(substrString(S, 1, 2))))
	[internal]

	// string starting with "-." 

	rule [string2Number-float-minus-dot]:    
	<k> string2Number(S:String) => extractIntSubstring(S, substrString(S, 0, 2), 2, float) ... </k>
	<trace> Trace:List => Trace ListItem("string2Number-float-minus-dot") </trace>
	when ((lengthString(S) >Int 2) andBool
	#isDigit(substrString(S, 0, 1))) orBool
	((substrString(S, 0, 2) ==String "-.") andBool (#isDigit(substrString(S, 2, 3))))
	[internal]
*/	
	
endmodule
