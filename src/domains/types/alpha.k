require "lattice.k"

module ALPHA
	imports LATTICE

	syntax K ::= "alpha" "(" K ")" [function]

	rule alpha(N:Int) =>    (AInt, .List) [structural]
	rule alpha(F:Float) =>  (AFloat, .List) [structural]	
	rule alpha(S:String) => (S, .List) [structural]
	rule alpha(NULL) =>     NULL [structural]
			
syntax Bool ::= "isGammaSingleton" "(" K ")" [function]

rule isGammaSingleton(NULL) => true
rule isGammaSingleton(N:ANum)=> false
rule isGammaSingleton(B:ABool) => false
rule isGammaSingleton( (S:String, L) ) => valueOfErrs(L) ==K Bot
rule isGammaSingleton ( (AStringTop, _) ) => false
rule isGammaSingleton(Top) => false

	rule alpha(true) => specify(VE(ABoolTrue, .List))	 [structural]
	
	rule alpha(false) => specify(VE(ABoolFalse, .List))	 [structural]

// reference counters

syntax  ARefCount ::= "ARC0" | "ARC1" | "ARC2" | "ARC>2"
// abstraction of reference counters
syntax K ::= "alphaRC" "(" K ")" [function]
	
	rule	alphaRC(N:Int) => 
			#if (N ==Int 0) #then
				ARC0
			#else
				#if (N ==Int 1) #then
					ARC1
				#else
					#if (N ==Int 2) #then
						ARC2
					#else
						ARC>2
					#fi
				#fi
			#fi
			

// reference counters
rule 	isGammaSingleton(ARC0)  => true
rule 	isGammaSingleton(ARC1)  => true
rule 	isGammaSingleton(ARC2)  => true
rule 	isGammaSingleton(ARC>2) => false



//what about Bot ?

endmodule
