require "program-transformations.k"
require "builtin-functions.k"
require "meta.k"
require "../domains/domain/domain.k"

module CORE 
	imports PROGRAM-TRANSFORMATIONS
	imports BUILTIN-FUNCTIONS
	imports META //because of mergeZval
	imports DOMAIN
	imports ID-HOOKS

syntax Domain ::= "Concrete" | "Signs" | "Types"


// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Core} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Documents} 
		PHP scripts are parsed as Document. Documents comes in different flavours, depending
		on if the closing tag if present, if some additional HTML is present etc. */
// ---------------------------------------------------------------------------------------------

/*@ In all cases, and at least for now (we may want to be more precise later) we extract the PHP
	script from the Document and schedule it for execution. 
	Before executing the script we perform a pre-processing refactoring operation which consists 
	in moving all function and class declaration to the top of the program (i.e. before any 
	statement). This models the fact that PHP allows function call and class instantiation before 
	function or class declaration. */

syntax K ::= "runScript" "(" K ")" 

rule runScript(Prog:K) => 
		addSourceLabels(Prog)  
		~> refactor 		
		~> checkDeprecated 
		~> initStatic

syntax K ::= "checkDeprecated"

rule 	(quotedCode(Prog:K) ~> checkDeprecated) => detectDeprecated(Prog)

syntax K ::= "initStatic"

rule 	<k> (visitedK(Prog:K) ~> initStatic) => makeStaticDecls(Prog, L) ~> start ... </k>
		<globalStaticScope> L:Loc </globalStaticScope> 

syntax K ::= "start"

rule visitedK(Prog) ~> start => Prog 

rule [document-1]:
	<k> 'Document(_:K,, _:K,, Prog:K) => runScript(Prog) ... </k>
	<trace> Trace:List => Trace ListItem("document-1") </trace>
	[structural]

rule [document-2]:
	<k> 'Document(_:K,, _:K,, Prog:K,, _:K,, 'ListWrap(.KList)) => runScript(Prog) ... </k>
	<trace> Trace:List => Trace ListItem("document-2") </trace>
	[structural]

rule [document-3]: 
	<k> 'Document(PreHTML:K,, _:K,, Prog:K,, _:K,, PostHTML:K) => 'Echo(PreHTML) ~> runScript(Prog) ~> 'Echo(PostHTML) ... </k>
	<trace> Trace:List => Trace ListItem("document-3") </trace>
	[structural]

rule [inline-html]:  
	<k> 'InlineHTML('CloseTag(_),,Stuff:K,,'FullOpenTag(_)) => 'Echo(Stuff) ... </k>
	<trace> Trace:List => Trace ListItem("inline-html") </trace>
	[structural]

/* Empty document */

rule [template-document-empty]:
	<k> 'TemplateDocument('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("template-document-empty") </trace>
	[structural]

/* literal */

rule [template-document-literal]: 
	<k> 'TemplateDocument('ListWrap('Literal(L:String),, Stuff:KList)) => 
	'Echo('ListWrap(L)) ~>  'TemplateDocument('ListWrap(Stuff)) ... </k>
	<trace> Trace:List => Trace ListItem("template-document-literal") </trace>
	[structural]

/* inline echo */

rule [template-document-echo]: 
	<k> 'TemplateDocument('ListWrap(K:K,, Stuff:KList)) => 
	K ~> 'TemplateDocument('ListWrap(Stuff)) ... </k>
	<trace> Trace:List => Trace ListItem("template-document-echo") </trace>
	when getKLabel(K) ==KLabel 'InlineEcho
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Literals} */
// ---------------------------------------------------------------------------------------------

rule    [literal-int]:
	    <k> 'LNumber('Deci(Str:String)) => alpha(String2Int(Str)) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-int") </trace>
	    [structural]

rule    [literal-float]:
	    <k> 'DNumber(Str:String) => alpha(String2Float(Str)) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-float") </trace>
	    [structural]

rule    [literal-string]:
	    <k> 'Literal(Str:String) => alpha(Str) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-string") </trace>
	    [structural]

rule    [literal-true]:
	    <k> 'True(_) => alpha(true) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-true") </trace>
    	[structural]

rule    [literal-false]:
	    <k> 'False(_) => alpha(false) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-false") </trace>
	    [structural]

rule    [literal-null]:
	    <k> 'Null(_) => alpha(NULL) ... </k>
	    <trace> Trace:List => Trace ListItem("literal-null") </trace>
	    [structural]		


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Blocks} 
		Blocks are evaluated by simply executing the statement (i.e. we simply discard
		parenthesis). */
// ---------------------------------------------------------------------------------------------

rule [block]:
	<k> 'Block(B:K) => B ... </k> 									
	<trace> Trace:List => Trace ListItem("block") </trace>
	[structural]

///////////////////////////////////////////////////////////////////////////////
/*@ \subsection{Sequential composition} 
        Statements are avaluated conditionally, depending on the status of the 
        machine. For example, if the status is NEXT, statements are executed 
        normally, but if the status is e.g. RET or ERR, statements are not 
        executed. */
///////////////////////////////////////////////////////////////////////////////

rule [seq-empty]:
	<k> 'ListWrap(.KList) => . ... </k>
        <trace> Trace:List => Trace ListItem("seq-empty") </trace>
	[transition]

rule [empty]:	
	<k> 'Empty(.KList) => . ... </k>
        <trace> Trace:List => Trace ListItem("empty") </trace>
	[transition]

rule [seq-cons]:
	<k> 'ListWrap(S:K,, Ss:KList) => S ~> 'ListWrap(Ss) ... </k>	
	<status> C:RunningCode </status>
        <trace> Trace:List => Trace ListItem("seq-cons") </trace>
	[transition]
	
rule [seq-cons-skip]:
	<k> 'ListWrap(S:K,, Ss:KList) => . ... </k>	
	<status> C:SkippingCode </status>
        <trace> Trace:List => Trace ListItem("seq-cons-skip") </trace>
	[transition]


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Expression as a statement} */
// ---------------------------------------------------------------------------------------------

context 'Expr(HOLE)

rule [expr-convert]:	
	<k> 'Expr(V:ConvertibleToLanguageValue => convertToLanguageValue(V)) ... </k>
	<trace> Trace:List => Trace ListItem("expr-convert") </trace>
	[step]

rule [expr]:	
	<k> 'Expr(V:LanguageValue) => . ... </k>
	<trace> Trace:List => Trace ListItem("expr") </trace>
	[step]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Variable lookup} 
		Variable lookup returns a reference, i.e. a pair consisting of a location (the location 
		of the appropriate symbol table) and the name of the variable itself. 
		Depending on the type of variable, different symbol tables may be considered: if 
		the variable is a user-defined one, the location of the current environment is used. 
		If the variable is a superglobal, the location of the superglobal envirnoment is 
		used. */
// ---------------------------------------------------------------------------------------------

syntax Var ::= "var" "(" AString ")"

rule [var2Id]: 	
	<k> 'Variable('Simple(Str:String)) => var(alpha(Str)) ... </k>
	<trace> Trace:List => Trace ListItem("var2Astring") </trace>
	[structural]

/*@ The following is the rule for variable lookup. Note that is makes use of the auxiliary
	predicates defined below. */

rule [var]:   
	<k> var(X:AString)  => lref(ref(Lr,pickScope(X)),X,arr) ... </k>
	<rootScope> Lr:Loc </rootScope>
	<trace> Trace:List => Trace ListItem("var") </trace>
	when isNotSpecialVar(X) orBool maybeSpecialVar(X)
	[step]

//SM-FIXME the rule above is wrong: we need to separate 'maybe' case out, and in that case merge with this-obj-cntx
// in particular, the case for "this" is currently wrong


//SM this should read the keys off the global scope instead of hard-coding them
syntax  List ::= "superglobalKeys()" [function]
rule superglobalKeys() => 
ListItem(alpha("_GET")) 
ListItem(alpha("_POST")) 
ListItem(alpha("GLOBALS"))
ListItem(alpha("_COOKIE"))
ListItem(alpha("_FILES"))

/*@ The following auxiliary function returns the key in the rootScope array containing the scope where X should be resolved.*/
syntax  Key ::= "pickScope" "(" AString ")"	[function]

rule pickScope(X) => alpha("SUPERGLOBALS")
     when containedInKeys(X,superglobalKeys())

rule pickScope(X) => alpha("GLOBALS")
     when doesNotIntersectKeys(X,superglobalKeys())

rule pickScope(X) => Top
     when maybeInKeys(X,superglobalKeys())

syntax Bool ::= "containedInKeys" "(" AString "," List ")"		[function]
syntax Bool ::= "doesNotIntersectKeys" "(" AString "," List ")"		[function]
syntax Bool ::= "maybeInKeys" "(" AString "," List ")"		[function]
rule containedInKeys(X,Y) => foldrorBool(false,mapX<=Lattice(X,Y))
//SM case above misses "contained fragmented" case, but still sound
//   consider using notStrictlyIncluded(Y,SetItem(X)) as well
rule doesNotIntersectKeys(X,Y) => notBool foldrorBool(false,mapglb=/=LatticeBot(X,Y)) 
rule maybeInKeys(X,Y) => notBool(containedInKeys(X,Y) orBool doesNotIntersectKeys(X,Y)) 




/*@ The following auxiliary predicate returns true if the variable is special (e.g. this), 
	false otherwise  */

syntax Bool ::= "isSpecialVar" "(" AString ")"			[function]
syntax Bool ::= "isNotSpecialVar" "(" AString ")"		[function]
syntax Bool ::= "maybeSpecialVar" "(" AString ")"		[function]

rule 	maybeSpecialVar(X) => (alpha("this") <Lattice X)
rule	isNotSpecialVar(X) => (notBool maybeSpecialVar(X))
rule	isSpecialVar(X) => (alpha("this") ==Lattice X)


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Variable variables} */
// ---------------------------------------------------------------------------------------------

context 'IndirectReference(HOLE)

rule [variable-variable-arg2Value] :	
	<k> 'IndirectReference(R:ConvertibleToLanguageValue => convertToLanguageValue(R)) ... </k>
	[intermediate]

rule [variable-variable-global]:	
	<k> 'IndirectReference(X:AString) => var(X) ... </k>
        <currentScope> Lg </currentScope>
        <globalScope> Lg </globalScope>
	[step]

rule [variable-variable-function]:	
	<k> 'IndirectReference(X:AString) => ref(Lg,X) ... </k> //SM suspicious: should this be Lc? in php var-var can be local to function scope
        <currentScope> Lc </currentScope>
        <globalScope> Lg </globalScope>
	when (isNotSpecialVar(X) orBool maybeSpecialVar(X)) andBool Lc =/=K Lg
	[step]

//SM-FIXME this rule is wrong: we need to separate 'maybe' case out, and in that case merge with this-obj-cntx
// in particular, the case for "this" is currently wrong
	

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Array access} */
// ---------------------------------------------------------------------------------------------

// Array access is strict in both arguments
// NOTE: is this non-deterministic?

context [array-access-strict-LHS]: 
	'ArrayAccess(HOLE,,_)
	[structural]

context [array-access-strict-RHS]: 
	'ArrayAccess(_,,HOLE)
	[structural]

// The RHS is fully evaluated to a Language Value

rule [array-access-LHS2LangValue]: 	
	<k> 'ArrayAccess(_,,(R:ConvertibleToLanguageValue => convertToLanguageValue(R))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-LHS2LangValue") </trace>
	[intermediate]

// The RHS must be a key. If it's not, we try to convert it to Int as follows

rule [array-access-key-cast-float]:	
	<k> 'ArrayAccess(_,,(F:AFloat => 'IntCast(F))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-key-cast-float") </trace>
	[intermediate]
	
rule [array-access-key-cast-NULL]:	
	<k> 'ArrayAccess(_,,(NULL => 'StringCast(NULL))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-key-cast-NULL") </trace>
	[intermediate]
	
rule [array-access-key-cast-bool]:	
	<k> 'ArrayAccess(_,,(B:ABool => 'IntCast(B))) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-key-cast-bool") </trace>
	[intermediate]

rule [array-access-key-cast-bot]:	
	<k> 'ArrayAccess(_,,Bot) => ref(Bot,Top) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-key-cast-bot") </trace>
	[intermediate]

/*
rule [array-access-key-cast-string]:	
	<k> 'ArrayAccess(_,,(S:AString => 'IntCast(S))) ... </k>
	when isIntType(String2Int(S)) // TODO: this condition only works in concrete.
                                  // need to update the predicates 
	[intermediate]
*/

// Finally if no key is provided, we use NULL as s special key

rule [array-access-no-key]:	
	<k> 'ArrayAccess(_,,('None(.KList) => NoKey)) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-no-key") </trace>
	[step]

// And here we give semantics to array access -- generating references.

rule [array-access-simple]:	
	<k> 'ArrayAccess(L:Loc,,X:Key) => ref(L, X) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-simple") </trace>
	[step]

rule [array-access-nested]: 	
	<k> 'ArrayAccess(R:Ref,,K:Key) => lref(R,K,arr) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-nested") </trace>
	[step]

/* TODO: was 1st attempt in abstracting. Looks wrong, remove!
rule [array-access-simple]:	
	<k> 'ArrayAccess(L:Loc,,X:Key) => ref(L, X) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-simple") </trace>
	when isGammaSingleton(X)
	[step]

rule [array-access-nested]: 	
	<k> 'ArrayAccess(R:Ref,,K:Key) => lref(R,K,arr) ... </k>
	<trace> Trace:List => Trace ListItem("array-access-nested") </trace>
	when isGammaSingleton(K)
	[step]
*/

// This is not a real rule of the semantics. We just use it to catch a parser bug
// TODO: probably also need update

rule [array-access-parsing-error]:	
	<k> 'ArrayAccess(S:String,,_) ~> K:K => print("PARSING BUG!!!") ... </k>
	<errorManagement> _ => 4 </errorManagement>
	<trace> Trace:List => Trace ListItem("array-access-parsing-error") </trace>
	[error]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Assignment by value} */
// ---------------------------------------------------------------------------------------------

context [assign-strict-LHS]: 
	'Assign(HOLE,,_)
	[structural]
	
context [assign-strict-RHS]: 
	'Assign(_:KResult,,HOLE) 
	[structural]

// convert LHS reference to basic one

rule [assign-2-basic-ref]:
	<k> 'Assign((LR:LRef => toBasicRef(LR)),, V:Value) ... </k>
	[intermediate]

rule [assign-LHS2-gamma]:
	<k> 'Assign(ref(L,X),,V:KResult) => assign0(Lget(ref(L,X)),V) ... </k>
	[intermediate]


syntax K ::= "assign0" "(" K "," K ")" [strict(1)]

rule [assign-RHS2Loc-NonLiteral]:    
	<k>  assign0(sref(L,X),V:KResult) => assign1(L,V,isGammaSingleton(X)) ... </k>
	[intermediate]

//SM this is motivated by example <? $x=1; $x[0]=2; ?>
rule [assign-error]:    
	<k>  assign0(locNull,_) => NULL ... </k>
	[intermediate]


syntax K ::= "assign1" "(" K "," K "," Bool ")" [strict(1,2)]

/* SM changing strategy using sref2loc in convertoloc
rule [assign1-sref]:
	<k>  assign1(_:KResult,sref(L,X)=>L,_) ... </k>
	[intermediate]
*/

rule [assign-RHS2Loc-NonLiteral]:    
	<k>  assign1(_:KResult, (V:ConvertibleToLoc => convertToLoc(V,r)),UpdateType) ... </k>
	when notBool (isLiteral(V))
	[intermediate]


rule [assign-RHS2LangValue-overflow]:    
	<k> assign1(L:Loc,L1':Loc,UpdateType) =>  
			'Expr(assign1(L,convertToLanguageValue(L1'),UpdateType)) ~>
			'Expr(reset(L)) ~>
			convertToLanguageValue(L) ...
	</k>
	<thematrix> ... L1' |-> L1 ... </thematrix>
	<heap> M:Map </heap>
	when currentOverflow(M,L1) // TODO: check side conditions!
	[intermediate]

rule [assign-RHS2LangValue-no-overflow]:    
	<k> assign1(L:Loc,(L1':Loc => convertToLanguageValue(L1')),UpdateType) ... </k>  
	<thematrix> ... L1' |-> L1 ... </thematrix>	
	<heap> M:Map </heap>
	when notBool (currentOverflow(M,L1))
	[intermediate]

rule [assign-RHS2LangValue-locNull]:    
	<k> assign1(L:Loc,(locNull => NULL),UpdateType) ... </k>
	[intermediate]

rule [assign]:
	<k> assign1(L:Loc,V:LanguageValue,UpdateType) => 
		copyValueToLoc(V,L,UpdateType) ~> 
		zvalRead(L,@Value) ... </k>
	[step] 

rule [assign-error]:
	<k> assign1(thisTag(L:K),_,_) =>  ERROR("Cannot re-assign $this in %s on line %d") ... </k>
	[step, error]


// ---------------------------------------------------------------------------------------------
/*@ \subsection{Shortcuts} */
// ---------------------------------------------------------------------------------------------

rule [concat-assign]: 
	<k> 'ConcatAssign(X:K,, Y:K) => 'Assign(X,, 'Concat(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("concat-assign") </trace>
	[structural]

rule [div-assign]: 
	<k> 'DivAssign(X:K,, Y:K) => 'Assign(X,, 'Div(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("div-assign") </trace>
	[structural]

rule [min-assign]: 
	<k> 'MinAssign(X:K,, Y:K) => 'Assign(X,, 'Min(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("min-assign") </trace>
	[structural]
	
rule [mod-assign]: 
	<k> 'ModAssign(X:K,, Y:K) => 'Assign(X,, 'Mod(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("mod-assign") </trace>
	[structural]

rule [plus-assign]: 
	<k> 'PlusAssign(X:K,, Y:K) => 'Assign(X,, 'Plus(X,, Y)) ... </k>
	<trace> Trace:List => Trace ListItem("plus-assign") </trace>
	[structural]	

// the following bitwise ops are not fully supported - we exclude them from the trace 

rule //[and-assign]: 
	<k> 'AndAssign(X:K,, Y:K) => 'Assign(X,, 'And(X,, Y)) ... </k>
	//<trace> Trace:List => Trace ListItem("and-assign") </trace>
	[structural]

rule //[or-assign]: 
	<k> 'OrAssign(X:K,, Y:K) => 'Assign(X,, 'Or(X,, Y)) ... </k>
	//<trace> Trace:List => Trace ListItem("or-assign") </trace>
	[structural]

rule //[xor-assign]: 
	<k> 'XorAssign(X:K,, Y:K) => 'Assign(X,, 'LXor(X,, Y)) ... </k>
	//<trace> Trace:List => Trace ListItem("xor-assign") </trace>
	[structural]

// ---------------------------------------------------------------------------------------------
/*@ \subsection{Assignment by reference} */
// ---------------------------------------------------------------------------------------------

context [ref-assign-strict-LHS]:
	'ReferenceAssign(HOLE,,_)
	[structural]

context [ref-assign-strict-RHS]:
	'ReferenceAssign(_:KResult,,HOLE)
	[structural]

rule [ref-assign-LHS2BasicRef]:
	<k> 'ReferenceAssign((LR:LRef => toBasicRef(LR)),, V:Value) ... </k>
	<trace> Trace:List => Trace ListItem("ref-assign-LHS2BasicRef") </trace>
	[intermediate]

rule [ref-assign-RHS2Loc]:
	<k> 'ReferenceAssign(_,, (V:ConvertibleToLoc => convertToLoc(V, l))) ... </k>
	<trace> Trace:List => Trace ListItem("ref-assign-RHS2Loc") </trace>
	[intermediate]

rule [ref-assign-obj-prop]:
	<k> 'ReferenceAssign(ref((L':Loc => L2'), X:Key),, L1':Loc) ... </k>
	<thematrix> 
	... 
		L'  |-> L 
		L1' |-> L1 
		L2' |-> L2
	... 
	</thematrix>	
        <heap> 
        ... 
        	L  |-> zval(OID(L2',_,_),_,_,_) 
		L1 |-> _
		L2 |-> zval(Array(_,Elems),_,_,_)
	...
	</heap>
	<trace> Trace:List => Trace ListItem("ref-assign-fresh-obj-prop") </trace>
	//when notBool (Elems hasProperty X) //SM why is this commented?
	[intermediate]

rule [ref-assign-array-elem]:
	<k> 
		'ReferenceAssign(ref(L':Loc, X:Key),, L1':Loc) =>  
            	ArrayUpdateElem(L', X, L1') ~>
		rebuildArray(
			L',X,
			L1',L1,arrayRemove(Elems,X)) ~> //SM if x is a singleton, it should not be lubbed to the aliasing source
		ref(L', X) 
	... </k>
	<thematrix> 
	... 
		L'  |-> L 
		L1' |-> L1
	... 
	</thematrix>	
        <heap> 
	... 
		L  |-> zval(Array(_,Elems),_,_,_) 
		L1 |-> _ 
	... 
	</heap>
	<trace> Trace:List => Trace ListItem("ref-assign-fresh-array-elem") </trace>
	when isGammaSingleton(X)
	[step]

rule [ref-assign-array-elem-weak]:
	<k> 
		'ReferenceAssign(ref(L':Loc, X:Key),, L1':Loc) =>              	
		rebuildArray(
			L',X,
			L1',L1,Elems) ~>		
		ArrayAliasElem(L', X, L1) ~>
		ref(L', X) 
	... </k>
	<thematrix> 
	... 
		L'  |-> L 
		L1' |-> L1
	... 
	</thematrix>	
        <heap> 
	... 
		L  |-> zval(Array(_,Elems),_,_,_) 
		L1 |-> _ 
	... 
	</heap>
	<trace> Trace:List => Trace ListItem("ref-assign-fresh-array-elem-weak") </trace>
	when notBool isGammaSingleton(X)
	[step]




// --------------- AUXILIARY OPS FOR REFERENCE ASSIGN --------------------
// .................... TODO: MOVE? --------------------------------------


// Auxiliary operation used by the reference assignment. 
// It takes care of aliasing the required keys (in case there is more
// then one)....

syntax K ::= "rebuildArray" "(" Loc "," Key "," 
				Loc "," Loc "," 
				List ")"

rule [rebuild-array]: 
    <k> rebuildArray(L',X,L1',L1,Elems) => 
	// write the lub 
	write(
		mergeValuesAtLocs(
			bot,
			SetItem(L1')
			KeySet2LocSet(intersectClose(X,elems2keys(Elems)),Elems)),
		L1',
		true) ~>
	// alias the affected key to the target
	aliasAllKeys2Loc(L',intersectClose(X,elems2keys(Elems)),L1) ...
        </k>
	<trace> Trace:List => Trace ListItem("rebuild-array") </trace>
        [internal]	


// --------------- AUXILIARY OPS FOR REFERENCE ASSIGN --------------------
// .................... END ------- --------------------------------------


rule [ref-assign-language-value]:
	<k> 'ReferenceAssign(ref(L:Loc, X:Key),,V:PlainLanguageValue) => 
		WARNING("Only variables should be assigned by reference in %s on line %d\n") ~> 
			'Assign(ref(L:Loc, X:Key),,V:PlainLanguageValue) ... </k>
	<trace> Trace:List => Trace ListItem("ref-assign-language-value") </trace>
	[step, error]


// --------------------------------------------------------------------------------------------
/*@ \subsection{Some and None} */
// ---------------------------------------------------------------------------------------------

context 'Some(HOLE)
rule 	'Some(V:Value) => V
rule isKResult ('Some(X:K)) => true	    	            when isKResult(X)
rule isKResult ('None(_)) => true


// --------------------------------------------------------------------------------------------
/*@ \subsection{List Assignment} */
// ---------------------------------------------------------------------------------------------

context [list-assign-strict-LHS]: 
	'ListAssign(HOLE,,_:K)
	[structural]

context [list-assign-strict-RHS]: 
	'ListAssign(_:KResult,,HOLE)
	[structural]

context [list-elems-strict]: 
	'List('ListWrap(_:KList,, 'Some(HOLE),, _:KList))
	[structural]

rule isKResult ('List('ListWrap(X:KList))) => true 	    when isKResult(X)

rule [list-assign-RHS2Loc]: 	
	<k> 'ListAssign(_:KResult,, (R:ConvertibleToLoc => convertToLoc(R,r))) ... </k>
	<trace> Trace:List => Trace ListItem("list-assign-RHS2Loc") </trace>
	[intermediate]
	
rule [list-assign]: 
	<k> 'ListAssign('List(Vars:K),,L:Loc) => assignSeqOfIds(Vars, L, 0) ~>  L ... </k>
	<trace> Trace:List => Trace ListItem("list-assign") </trace>
	[step]
	
syntax K ::= "assignSeqOfIds" "(" K "," Loc "," Int ")"

rule [assign-seq-some-non-list]:    
	<k> assignSeqOfIds('ListWrap('Some(X:KResult),, Xs:KList), L:Loc,I:Int) =>             
    assignSeqOfIds('ListWrap(Xs), L, I +Int 1) ~> 'Expr('Assign(X,, 'ArrayAccess(L,, I))) ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-some-non-list") </trace>
	when getKLabel(X) =/=KLabel 'List
	[internal]

rule [assign-seq-some-list]:    
	<k> assignSeqOfIds('ListWrap('Some('List('ListWrap(X:KList))),, Xs:KList), L:Loc, I:Int ) =>
	assignSeqOfIds('ListWrap(Xs), L, I +Int 1) ~> 'Expr('ListAssign('List('ListWrap(X)),, 'ArrayAccess(L,, I))) ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-some-list") </trace>
	when isKResult(X)								
	[internal]

rule [assign-seq-skip]:
	<k> assignSeqOfIds('ListWrap('None(_),, Xs:KList), L:Loc, I:Int )  =>
		assignSeqOfIds('ListWrap(Xs), L, I +Int 1) ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-skip") </trace>
	[internal]

rule [assign-seq-nil]:    
	<k> assignSeqOfIds('ListWrap(.KList), L:Loc, _ ) => . ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-nil") </trace>
	[internal]
	
rule [assign-seq-not-a-loc]:    
	<k> 'ListAssign(_:KResult,, V:LanguageValue) => false ... </k>
	<trace> Trace:List => Trace ListItem("assign-seq-not-a-loc") </trace>
	[internal, error]




// ---------------------------------------------------------------------------------------------
/*@ \subsection{IsSet} */
// ---------------------------------------------------------------------------------------------

context [internal-fun-isset-args-strict]:
	'InternalFunction('Isset('ListWrap(_:KList,,HOLE,,_:KList)))
	[structural]
	
rule [internal-fun-isset-2-spec]: 	
	<k> 'InternalFunction('Isset('ListWrap(Arg:KResult))) => isset(Arg) ... </k>
	<trace> Trace:List => Trace ListItem("internal-fun-isset-2-spec") </trace>
	[structural]
	
syntax K ::= "isset" "(" K ")" [strict]

rule [isset-arg2BasicRef]:    
	<k> isset(LR:LRef => readBasicRef(LR)) ... </k>
	<trace> Trace:List => Trace ListItem("isset-arg2BasicRef") </trace>
	[internal, intermediate]

rule [isset-true]:
	<k> isset (ref(L':Loc, K:Key)) => true ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,_ ListItem([K,public,_]) _),_,_,_)  ... </heap> 
	<trace> Trace:List => Trace ListItem("isset-true") </trace>
	[internal]

rule [isset-false]:
	<k> isset (ref(L':Loc, K:Key)) => false ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(Array(_,Elems),_,_,_)  ... </heap> 
	<trace> Trace:List => Trace ListItem("isset-false") </trace>
	when notBool (Elems hasProperty K)
	[internal]

// this never gets called because toBasicRef (called above) always CREATE the ref
// TODO: fix it

rule [isset-null]: 	
	<k> isset(ref(locNull,_)) => false ... </k>
	<trace> Trace:List => Trace ListItem("isset-null") </trace>
	[internal]

rule [isset-scalar]:    
	<k> isset (ref(L':Loc, K:Key)) => false ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> ... L |-> zval(V:PlainLanguageValue,_,_,_)  ... </heap> 
	<trace> Trace:List => Trace ListItem("isset-scalar") </trace>
	when notBool (V isCompoundValue)
	[internal]



// ---------------------------------------------------------------------------------------------
/*@ \subsection{Unset} */
// ---------------------------------------------------------------------------------------------

rule [unset-cons]:
	<k> 'Unset('ListWrap(Item:K,, T:KList)) => 'Unset(Item) ~> 'Unset('ListWrap(T)) ... </k>
	<trace> Trace:List => Trace ListItem("unset-cons") </trace>
	[internal]
	
rule [unset-nil]:
	<k> 'Unset('ListWrap(.KList)) => . ... </k>
	<trace> Trace:List => Trace ListItem("unset-nil") </trace>
	[step]

context [unset-strict]: 
	'Unset(HOLE) 
	when getKLabel(HOLE) =/=KLabel 'ListWrap
	[structural]

rule [unset-arg2BasicRef]: 
	<k> 'Unset(LR:LRef => readBasicRef(LR)) ... </k>
	<trace> Trace:List => Trace ListItem("unset-arg2BasicRef") </trace>
	[intermediate]

rule [unset-obj-prop]:        
	<k> 'Unset(ref((L' => L1),X)) ... </k>
	<thematrix> ... L' |-> L ... </thematrix>	
	<heap> ... L |-> zval(OID(L1,_,_),_,_,_) ... </heap>
	<trace> Trace:List => Trace ListItem("unset-obj-prop") </trace>
	[intermediate]

rule [unset-null-ref]:    
	<k> 'Unset(ref(L':Loc, X:Key))=> . ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap>... L |-> zval(Array(_,Elems),_,_,_)  ...</heap>
	<trace> Trace:List => Trace ListItem("unset-null-ref") </trace>
	when notBool (Elems hasProperty X)				
	[step]

rule [unset-non-current]:
	<k> 'Unset(ref(L':Loc, X:Key)) => decRefCount(L1') ~> nullify(L1') ... </k>
	<thematrix> 
	... 
		L' |-> L 
		L1' |-> L1 
	... 
	</thematrix>	
	<heap> 
	... 
		L |-> zval(Array([Y,Vis1],_ (ListItem([X,Vis,L1']) => .) _),_,_,_)  
		L1 |-> zval(V:PlainLanguageValue,_,_,_) 
	... 
	</heap>       
	<trace> Trace:List => Trace ListItem("unset-non-current") </trace>
	when (Y =/=K X) orBool (Vis =/=K Vis1)
	[step]

rule [unset-current-none]:    
	<k> 'Unset(ref(L':Loc, X:Key)) => decRefCount(L1') ~> nullify(L1')... </k>
	<thematrix> 
	... 
		L' |-> L 
		L1' |-> L1 
	... 
	</thematrix>	
	<heap> 
	... 
		L |-> zval(Array(none,_ (ListItem([X,Vis,L1']) => .) _),_,_,_)  
		L1 |-> zval(V:PlainLanguageValue,_,_,_) 
	... 
	</heap>       
	<trace> Trace:List => Trace ListItem("unset-current-none") </trace>
	[step]
	
rule [unset-current-not-last]:
	<k> 'Unset(ref(L':Loc, X:Key)) => decRefCount(L1') ~> nullify(L1') ... </k>
	<thematrix> 
	... 
		L' |-> L 
		L1' |-> L1 
	... 
	</thematrix>	
	<heap> 
	... 
		L |-> zval(Array([X,Vis] => [X1,V1],_ ((ListItem([X,Vis,L1']) => .) ListItem([X1,V1,_])) _),_,_,_)  
		L1 |-> zval(V:PlainLanguageValue,_,_,_) 
	... 
	</heap>       
	<trace> Trace:List => Trace ListItem("unset-current-not-last") </trace>
	[step]

rule [unset-current-last]:   
	<k> 'Unset(ref(L':Loc, X:Key)) => decRefCount(L1') ~> nullify(L1')... </k>
	<thematrix> 
	... 
		L' |-> L 
		L1' |-> L1 
	... 
	</thematrix>	
	<heap> 
	... 
		L |-> zval(Array([X,Visib] => none, E:List (ListItem([X,Visib,L1']) => .)),_,_,_)  
		L1 |-> zval(V:PlainLanguageValue,_,_,_) 
	... 
	</heap>       
	<trace> Trace:List => Trace ListItem("unset-current-last") </trace>
	[step]

rule [unset-refNull]:    
	<k> 'Unset(ref(locNull, _)) => . ... </k>
	<trace> Trace:List => Trace ListItem("unset-refNull") </trace>
	[step]

// An internal operation to be used after unsetting a variable. 
// It checks the reference counter. 
// When uncertain about its exact value, it merges the affected ZVALUE
// with NULL

syntax K ::= "nullify" "(" Loc ")"

rule [nullify]: 
	<k> nullify(L') => . ... </k>
	<thematrix> ... L' |-> L ... </thematrix>
	<heap> 
		... 
		L |-> (zval(V,T,RC,IR) => 
			#if (isGammaSingleton(RC)) #then    
				zval(V,T,RC,IR)
			#else
				mergeZval(zval(V,T,RC,IR),nullZval)
			#fi)
		... 
	</heap>



// ---------------------------------------------------------------------------------------------
/*@ \subsection{Auxiliary predicates} */ 
// ---------------------------------------------------------------------------------------------

syntax Bool ::= "currentOverflow" "(" Map "," Loc ")" [function]

rule currentOverflow(Mem:Map(L |-> zval(Array(Crnt,_),_,_,_)), L) => Crnt ==K none
rule currentOverflow(Mem:Map(L |-> zval(V,_,_,_)), L) => false
	when notBool (isArrayType(V))




endmodule 
