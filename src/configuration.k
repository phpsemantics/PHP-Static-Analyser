require "lang/init.k"
require "lang/meta.k"

module CONFIGURATION
	imports INIT
	imports META //SM: for NEXT


// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
/*@ \section{Configuration} */
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
// =/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=
   
configuration
	<kphp>
		<script color="pink">
			<declarations> 'ListWrap(.KList) </declarations>
			<commands> 'ListWrap(.KList) </commands>
			<k> buildInitState ~> $PGM:K </k>
		</script>
//                <errorDump stream="stdout"> .List </errorDump>	
                <errorDump> .List </errorDump>	
		<tables color="yellow">
			<functions> .Map </functions>
    			<classes> .Map </classes>
    			<constants> .Map </constants>
    			<classInstanceCounters> .Map </classInstanceCounters>
    		</tables>	
		<br/>
		<mem>
			<scopes color="green">
				<currentScope> .K </currentScope>
				<globalScope> .K </globalScope>
        			<globalStaticScope> .K </globalStaticScope> 
        			<superGlobalScope> .K </superGlobalScope>
				<rootScope> .K </rootScope>
			</scopes> 
			<thematrix> .Map </thematrix>
			<heap color="red"> .Map </heap>
		 </mem>
		<br/>
       		<status> NEXT </status> 
		<returns> Bot </returns>
		<returns-loc> .Set </returns-loc>

		<control color="cyan">	
			<functionStack> .List </functionStack>
			<exceptionStack> .List </exceptionStack>
			<loopStack> .List </loopStack> 
			<context color="pink">
				 <currentForeachItem> .K </currentForeachItem> 
					     <object> NULL </object>
                		 <class> .K </class> 
                		<function> .K </function>
			</context>
			<br/>
			<functionArgumentsDeclaration> .K </functionArgumentsDeclaration>
			<processedFunBody> .K  </processedFunBody>
			<processedStaticDeclarations> .K </processedStaticDeclarations>
		</control>	
     		<br/> 		
     		<IO color="magenta">
     		    <in stream="stdin"> .List </in>
     		    //<out stream="stdout"> .List </out>	
     		    <out> .List </out>	   // use this one for model checking
                    <exitStatus> 0 </exitStatus>
     		    <errorManagement> 0 </errorManagement>
     		    <varDumpLevel> 0 </varDumpLevel>
     		</IO>
		<br/>
		<instrumentation color="red">
			<cleanTraceOnTermination> true </cleanTraceOnTermination> 
			<isTerminated> false </isTerminated> 
			<label> "@" </label>
		</instrumentation>     		
		<gc color="blue"> 
			<locationsToCollect> .List </locationsToCollect>
			<gcEnabled> false </gcEnabled>
		</gc>
		<trace> .List </trace>
		<domain> .K </domain>
    	</kphp>
endmodule
