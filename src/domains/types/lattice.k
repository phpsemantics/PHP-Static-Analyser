module LATTICE
       
	   
       syntax ErrFlag ::= "MayBeNull" | "VisibilityErr" | "ImplicitTypeConversion" | "NullTypeConversion"
	   
       syntax AStringValue ::= "AStringTop" | String | "AStringBot"
       
       syntax AString ::= "(" AStringValue "," List ")"

       rule isAStringConcrete => false // avoid confusion String = AString
	   
       syntax AIntValue ::= "AInt" | "AIntBot"
	   
       syntax AInt ::= "(" AIntValue "," List ")"
	
       syntax ABoolValue ::= "ABoolTop" | "ABoolTrue" | "ABoolFalse" | "ABoolBot"

       syntax ABool ::= "(" ABoolValue "," List ")"	   
	   
       syntax AFloatValue ::= "AFloat" | "AFloatBot"
	   
	   syntax AFloat ::= "(" AFloatValue "," List ")"
	   
	   syntax ANumValue ::= AFloatValue | AIntValue | "ANum"
	   
	   syntax ANum ::= AInt| AFloat| "(" "ANum" "," List ")"
	   
	   syntax PlainLanguageValue ::= DomainValue //SM this is a big issue: what values should the lang folder see? clash with memory.k
	   
	   syntax Scalar ::= ANumValue | AStringValue | ABoolValue | Null | Bot | Top
	
	   syntax Scalar ::= "getValue" "(" DomainValue ")" [function]
	   
	   syntax DomainValue ::= ANum | AString | ABool | Null 
	   
	   syntax VEPair ::= "VE" "(" Scalar "," List ")"
	   
	   syntax VEPair ::= "lub_Domain" "(" DomainValue "," DomainValue ")" [function]
	   
	   syntax PlainLanguageValue ::= "specify" "(" VEPair ")" [function]

	   syntax AInt ::= "specify_AInt" "(" VEPair ")" [function]
	   
	   syntax AFloat ::= "specify_AFloat" "(" VEPair ")" [function]
	   
	   syntax AString ::= "specify_AString" "(" VEPair ")" [function]
	   
	   syntax ABool ::= "specify_ABool" "(" VEPair ")" [function]
	  
	   syntax VEPair ::= "generalize" "(" DomainValue ")" [function]
	   
	   rule generalize( (V:AIntValue,E):AInt) => VE(V,E)
	   rule generalize( (V:AFloatValue,E):AFloat) => VE(V,E)
	   rule generalize( (V:AStringValue,E):AString) => VE(V,E)
	   rule generalize( (V:ABoolValue,E):ABool) => VE(V,E)
	  
	  
	   rule specify(VE(V:AIntValue, E)) => specify_AInt(VE(V,E))	
	   rule specify(VE(V:AFloatValue, E)) => specify_AFloat(VE(V,E))
	   rule specify(VE(V:AStringValue, E)) => specify_AString(VE(V,E))
	   rule specify(VE(V:ABoolValue, E)) => specify_ABool(VE(V,E))
	   rule specify(VE(NULL, _) ) => NULL
	   rule specify(VE(Top, _) ) => Top
	  
	   rule specify_AInt ( VE(I:AIntValue, E) ) => (I,E)
	   rule specify_AFloat ( VE(F:AFloatValue, E) ) => (F,E)
	   rule specify_AString ( VE(S:AStringValue, E) ) => (S,E)
	   rule specify_ABool ( VE(B:ABoolValue, E) ) => (B,E)
	  
	  
	   rule getValue( (V:AIntValue, E:List) ) => V
	   rule getValue( (V:AFloatValue, E:List) ) => V
	   rule getValue( (V:AStringValue, E:List) ) => V
	   rule getValue( (V:ABoolValue, E:List) ) => V
	   
	   
	   rule lub(V1:DomainValue, V2:DomainValue) => specify(lub_Domain(V1, V2))
	   
	   //TODO : lub (Array(), NULL)
           //SM yes, we need this, see examples
	   //rule lub(A:Array, B:K) => Top
	  // when A =/=K B
	   
	   syntax List ::= "getErrFlags" "(" K ")" [function]
	   
	   rule getErrFlags ( (V:AIntValue, E:List) ) => E
	   rule getErrFlags ( (V:AFloatValue, E:List) ) => E
	   rule getErrFlags ( (V:AStringValue, E:List) ) => E
	   rule getErrFlags ( (V:ABoolValue, E:List) ) => E
	   rule getErrFlags( NULL ) => .List
	   
	   rule lub_Domain(D1,D2) =>  VE(lub_Value(getValue(D1), getValue(D2)), mergeList(getErrFlags(D1), getErrFlags(D2)) )
	   when D1 =/=K NULL andBool D2 =/=K NULL
	   
	   rule lub_Domain( D1, NULL) => VE(getValue(D1), mergeList (ListItem(MayBeNull), getErrFlags(D1)))
	   when D1 =/=K NULL
	   
	   rule lub_Domain(NULL, NULL) => VE(NULL, .List)
	   
	   rule lub_Domain( NULL, D1) => VE(getValue(D1), mergeList (ListItem(MayBeNull), getErrFlags(D1)))
	   
       syntax Scalar ::= "lub_Value" "(" Scalar "," Scalar ")" [function]
	   
	   //RR-FIXME : do lub of two bots more precisely
	   
	   rule lub_Value(X, AIntBot)=> X
	   rule lub_Value(AIntBot, X) => X
	   rule lub_Value(X, AFloatBot)=> X
	   rule lub_Value(AFloatBot, X) => X	   
	   rule lub_Value(X, ABoolBot)=> X
	   rule lub_Value(ABoolBot, X) => X
	   rule lub_Value(X, AStringBot)=> X
	   rule lub_Value(AStringBot, X) => X
	   
       rule lub_Value(X:ABoolValue, ABoolTop)=>ABoolTop
	   rule lub_Value(ABoolTop, X:ABoolValue) => ABoolTop
	   rule lub_Value(ABoolFalse, ABoolFalse) => ABoolFalse
	   rule lub_Value(ABoolTrue, ABoolTrue) => ABoolTrue
	   rule lub_Value(ABoolTrue, ABoolFalse) => ABoolTop
	   rule lub_Value(ABoolFalse, ABoolTrue) => ABoolTop
	   
	   rule lub_Value(S1:String, S2:String)=>AStringTop
	   when S1 =/=String S2
	   
	   rule lub_Value(S1:String, S2:String)=>S1
	   when S1 ==String S2

	   rule lub_Value(I:AIntValue, S1:AStringValue)=>Top

	   rule lub_Value(S1:AStringValue, I:AIntValue)=>Top

           rule lub_Value(AStringTop, X:AStringValue)=>AStringTop
 
           rule lub_Value(X:AStringValue, AStringTop)=>AStringTop

	   rule lub_Value(ANum, N:ANumValue)=>ANum
	   
	   rule lub_Value(N:ANumValue, ANum)=>ANum
	   
	   rule lub_Value(I:AIntValue, F:AFloatValue)=>ANum
	   
	   rule lub_Value(F:AFloatValue, I:AIntValue)=> ANum
	   
	   rule lub_Value(I1:AIntValue, I2:AIntValue) => AInt

	   rule lub_Value(F1:AFloatValue, F2:AFloatValue) => AFloat
	   
	   rule lub_Value(Bot, V) => V
	   
	   rule lub_Value(V, Bot) => V

//SM temporary hack to run examples
           rule lub_Value(X,NULL) => Top when X =/=K NULL
           rule lub_Value(NULL,X) => Top when X =/=K NULL
           rule lub_Value(NULL,NULL) => NULL
	   
	   syntax Scalar ::= "valueOfErr"  "(" ErrFlag ")" [function]
	   
	   rule valueOfErr( MayBeNull) => NULL
	   
	   rule valueOfErr( VisibilityErr) => Bot
	   
	   rule valueOfErr( ImplicitTypeConversion) => Bot

	   rule valueOfErr(NullTypeConversion) => Bot
	   
	   syntax Scalar ::= "valueOfErrs" "(" List ")" [function]
	   
	   rule valueOfErrs(.List) => Bot
	  
	   rule valueOfErrs(ListItem(E)  L) => lub_Value(valueOfErr(E), valueOfErrs(L))
	   
	   /*
	   syntax Bool ::= "keepErrFlag" "(" ErrFlag ")" [predicate] 		//true if valueOfErr = Bot ?
	   
	   rule keepErrFlag(MayBeNull) => false
	   
	   rule keepErrFlag(VisibilityErr) => true
	   
	   rule keepErrFlag(ImplicitTypeConversion) => true
	   
	   rule keepErrFlag(NullTypeConversion) => true
	   */
	   
	   syntax List ::= "ErrsOfErr" "(" ErrFlag ")" [function]
	   
	   rule ErrsOfErr(MayBeNull) => ListItem(NullTypeConversion) 
	   //SM this is called once we use the NULL information and the resulting value we know is not NULL
	   
	   rule ErrsOfErr(VisibilityErr) => ListItem(VisibilityErr)
	   
	   rule ErrsOfErr(ImplicitTypeConversion) => ListItem(ImplicitTypeConversion)
	   
	   rule ErrsOfErr(NullTypeConversion) => ListItem(NullTypeConversion)
	   
	   syntax List ::= "FilterErrFlags" "(" List ")" [function]
	   
	   rule FilterErrFlags(.List) => .List
	   
	   rule FilterErrFlags(ListItem(E:ErrFlag) L) => ErrsOfErr(E) FilterErrFlags(L)
	   
	   
	   /*
	   rule FilterErrFlags(ListItem(E:ErrFlag) L) => FilterErrFlags(L)
	   when notBool(keepErrFlag(E))
	   
	   rule FilterErrFlags(ListItem(E:ErrFlag) L) =>ListItem(E) FilterErrFlags(L)
	   when keepErrFlag(E)
	   */
	   
           syntax Bool ::= K "==Lattice" K [function]
	   syntax Bool ::= K "<Lattice" K		[function]
	   syntax Bool ::= Scalar "<ScalarLattice" Scalar [function]

	   rule D1:DomainValue ==Lattice D2:DomainValue => generalize(D1) ==Lattice generalize(D2) 
           rule Top ==Lattice X => X ==K Top
           rule X ==Lattice Top => X ==K Top
           rule Bot ==Lattice X => X ==K Bot
           rule X ==Lattice Bot => X ==K Bot          

	   rule VE(V1, E1):VEPair ==Lattice VE(V2, E2):VEPair => (lub_Value(V1,valueOfErrs(E1)) ==K lub_Value(V2,valueOfErrs(E2)))
           
	   
	   rule D1:DomainValue <Lattice D2:DomainValue => generalize(D1) <Lattice generalize(D2)
	   
	   rule VE(V1, E1):VEPair <Lattice VE(V2, E2):VEPair => (lub_Value(V1,valueOfErrs(E1)) <ScalarLattice lub_Value(V2,valueOfErrs(E2)))
	   
	   rule Top <Lattice X:K => false
	   rule X:K <Lattice Bot => false
	   
	   rule X:K <Lattice Top => true
	   when X =/=K Top
	   
	   rule Bot <Lattice X:K => true
	   when X =/=K Bot
	   
	   rule Top <ScalarLattice _ => false
	   rule X <ScalarLattice Top => true
	   when X =/=K Top
	   
	   rule AInt <ScalarLattice AInt => false
	   rule (AFloat <ScalarLattice AFloat) => false
	   rule ANum <ScalarLattice X:ANumValue => false
	   rule (AInt <ScalarLattice AFloat) => false
	   rule (AFloat <ScalarLattice AInt) => false
	   rule (AInt <ScalarLattice ANum) => true
	   rule (AFloat <ScalarLattice ANum) => true
	   
	   rule  AStringTop <ScalarLattice AStringTop => false
	   rule AStringTop <ScalarLattice X:Scalar => false
	   rule S:String <ScalarLattice S2:String => false
	   rule S:String <ScalarLattice AStringTop => true
	   
	   rule S:AStringValue <ScalarLattice I:AIntValue => false
	   rule S:AStringValue <ScalarLattice F:AFloatValue => false
	   rule S:AStringValue <ScalarLattice ANum => false
	   rule S:AStringValue <ScalarLattice B:ABoolValue => false
	   
	   rule I:AIntValue <ScalarLattice S:AStringValue => false
	   rule I:AIntValue <ScalarLattice B:ABoolValue => false
	   
	   rule F:AFloatValue <ScalarLattice S:AStringValue => false
	   rule F:AFloatValue <ScalarLattice B:ABoolValue => false
	   
	   rule ANum <ScalarLattice X => X ==K Top
	   
	   
	   rule B:ABoolValue <ScalarLattice X => X ==K Top orBool ((X ==K ABoolTop)andBool(B =/=K ABoolTop))
	   
	   
	   syntax 	Bool ::= K ">Lattice" K		[function]
	   
	   rule A:K >Lattice B:K => B <Lattice A
	


	   //list manipulation TODO move
	   
	   syntax Bool ::= ErrFlag "inList" List   [function]
	   rule K1:ErrFlag inList ListItem(K2:ErrFlag) L2:List => K1 ==K K2 orBool  K1 inList L2
	   
	   rule _ inList .List => false
	   
	   
	   syntax List ::= "mergeList" "(" List "," List ")" [function]
	   
	   rule mergeList(.List, L) => L
	   
	   rule mergeList(ListItem(E1)  L1:List, L2:List) => mergeList(L1, L2)
	   when E1 inList L2
	   
	   rule mergeList (ListItem(E1)  L1:List, L2:List) => mergeList(L1, ListItem(E1) L2)
	   when notBool(E1 inList L2)
	   
	   syntax Bool ::= List "incList" List [function]
	   
	   rule .List incList _ => true
	   
	   rule ListItem(E1:ErrFlag)  L1:List incList L2:List => false
	   when notBool(E1 inList L2)
	   
	   rule ListItem(E1:ErrFlag)  L1:List incList L2:List => L1 incList L2
	   when E1 inList L2
	   
	   syntax List ::= "addErrFlag" "(" ErrFlag "," List ")" 	[function]
	   
	   rule addErrFlag(E, L) => L
	   when E inList L
	   
	   rule addErrFlag(E,L) => ListItem(E) L
	   when notBool(E inList L)

//Type predicates	   

	   rule AisNull( Array(_,_)) => (ABoolFalse, .List)
	   rule AisNull(OID(_,_,_)) => (ABoolFalse, .List)
	   rule AisNull(NULL) => (ABoolTrue, .List)
	   rule AisNull(Top) => (ABoolTop, .List)
	   
	   rule AisNull(D:DomainValue) => AisNull(generalize(D))
	   when D =/=K NULL andBool D =/=K Top
	   
	   rule AisNull( VE(V,E)) => (ABoolTop, .List)
	   when MayBeNull inList E
	   
	   rule AisNull( VE(V,E)) => (ABoolFalse, .List)
	   when notBool(MayBeNull inList E)
	   
	   rule AisString( Array(_,_)) => (ABoolFalse, .List)
	   rule AisString(OID(_,_,_)) => (ABoolFalse, .List)
	   rule AisString(X:AInt) => (ABoolFalse, .List)
	   rule AisString(X:AFloat) => (ABoolFalse, .List)
	   rule AisString(X:ABool) => (ABoolFalse, .List)
	   rule AisString(X:AString) => (ABoolTrue, .List)
	   rule AisString(NULL) => (ABoolFalse, .List)
	   rule AisString(Top) => (ABoolTop, .List)
	   rule AisString(Anum) => (ABoolFalse, .List)
	   
	   rule AisBoolean( Array(_,_)) => (ABoolFalse, .List)
	   rule AisBoolean(OID(_,_,_)) => (ABoolFalse, .List)
	   rule AisBoolean(X:AInt) => (ABoolFalse, .List)
	   rule AisBoolean(X:AFloat) => (ABoolFalse, .List)
	   rule AisBoolean(X:ABool) => (ABoolTrue, .List)
	   rule AisBoolean(X:AString) => (ABoolFalse, .List)
	   rule AisBoolean(NULL) => (ABoolFalse, .List)
	   rule AisBoolean(Top) => (ABoolTop, .List)
	   rule AisBoolean(ANum) => (ABoolFalse, .List)
	   
	   rule AisObject( Array(_,_)) => (ABoolFalse, .List)
	   rule AisObject(OID(_,_,_)) => (ABoolTrue, .List)
	   rule AisObject(X:AInt) => (ABoolFalse, .List)
	   rule AisObject(X:AFloat) => (ABoolFalse, .List)
	   rule AisObject(X:ABool) => (ABoolFalse, .List)
	   rule AisObject(X:AString) => (ABoolFalse, .List)
	   rule AisObject(NULL) => (ABoolFalse, .List)
	   rule AisObject(Top) => (ABoolTop, .List)
	   rule AisObject(ANum) => (ABoolFalse, .List)
	   
	   rule AisArray( Array(_,_)) => (ABoolTrue, .List)
	   rule AisArray(OID(_,_,_)) => (ABoolFalse, .List)
	   rule AisArray(X:AInt) => (ABoolFalse, .List)
	   rule AisArray(X:AFloat) => (ABoolFalse, .List)
	   rule AisArray(X:ABool) => (ABoolFalse, .List)
	   rule AisArray(X:AString) => (ABoolFalse, .List)
	   rule AisArray(NULL) => (ABoolFalse, .List)
	   rule AisArray(Top) => (ABoolTop, .List)
	   rule AisArray(ANum) => (ABoolFalse, .List)
	   
	   rule AisNumber( Array(_,_)) => (ABoolFalse, .List)
	   rule AisNumber(OID(_,_,_)) => (ABoolFalse, .List)
	   rule AisNumber(X:AInt) => (ABoolTrue, .List)
	   rule AisNumber(X:AFloat) => (ABoolTrue, .List)
	   rule AisNumber(X:ABool) => (ABoolFalse, .List)
	   rule AisNumber(X:AString) => (ABoolFalse, .List)
	   rule AisNumber(NULL) => (ABoolFalse, .List)
	   rule AisNumber(Top) => (ABoolTop, .List)
	   rule AisNumber(ANum) => (ABoolTrue, .List)
	  
	   rule AisNumericString((AStringTop,_)) => (ABoolTop, .List)
	   rule AisNumericString((S:String, L)) => (ABoolTop, .List) //RR : we may be able to get some precision here, leaving it as is since our current isNumeric is untrusted
	   
	   

rule hasInfinitelyManyChildren(X:AString) => getValue(X) ==K AStringTop
rule hasInfinitelyManyChildren(X:ABool) => false 
rule hasInfinitelyManyChildren(X:AInt) => false 
rule hasInfinitelyManyChildren(X:AFloat) => false 
rule hasInfinitelyManyChildren(Top) => false 
rule hasInfinitelyManyChildren(Bot) => false 

rule intersects(X,H) => Bot =/=Lattice glb(X,H) 
//SM perhaps ==K is enough/better/more appropriate


//SM we should consider defining some gammas for values such that isGammaSingleton returns 1, e.g.
syntax K ::= "gamma(" PlainLanguageValue ")" [function]  //SM should not be K really

// AString: throwing away error flags information
rule gamma((S:String,L:List)) => S
rule gamma((AStringTop,L:List)) => "AStringTop"
rule gamma((AStringBot,L:List)) => "AStringBot"

endmodule
