/*
 * Simple Turkish Grammar
 * ==========================

var bayrak = yanlis
var no = 2
var no2 = no + 3

no = 14
yaz no

eger(bayrak)
{
  no = no + 3
}
degilse
  no = no - 10

yinele(no < 20)
  no = no + 1

yaz no

*/

start = statement*

statement 
  =	block_item
  / for_statement
  

if_statement
  = _ 'eğer' + '(' _ los:logical_statement  _ ')' _ nl
  		_ lines1:(compound_statement / block_item) _ nl
  lines2:( _ 'değilse' _ nl 
  		_ (compound_statement / block_item) )? nl
{      
  los.mainType = 'if';
  
  if(lines2 && typeof(lines2[5]) != "undefined")
     lines2 = lines2[5] 
		
	return {'type': 'logical', 
			'mainType': 'if',
		    'text': los.text,
			'truePart':lines1,
			'falsePart': lines2,
			'lineNumber': los.lineNumber,
			'start': los.start,
			'end': los.end
		   };	
}
 
while_statement
 = _ 'yinele' _ '(' los:logical_statement ')' _ nl 
   _ lines:(compound_statement / block_item) _ nl
{ 
    if(lines instanceof Array)
     for(var i=0; i < lines.length; i++)
		lines[i].up = 'while';
	else
	    lines.up = 'while';
	
	return {'type': 'logical', 
		'mainType': 'while',
		'text': los.text,
		'statements': lines,
		'lineNumber': los.lineNumber,
		'start': los.start,
		'end': los.end
	   };	
} 
 
for_statement
 = _ 'sayarakYinele' _ '(' _ dec1:declaration _ ',' _ los:logical_statement _ ',' _ dec2:declaration ')' _ nl
 	lines:(compound_statement / block_item) _ nl
 {
     console.log({'dec1': dec1, 'los': los, 'dec2':dec2})
	 los.mainType = 'for';

	window.eval(dec1.text);	 // initialization part
		
	while(window.eval(los.text)){
   
      	myEval(los);  // calculate the current value
		      	
		if(lines.constructor.name == "Array")
        	for(var k=0; k < lines.length; k++)
				myEval(lines[k], true);
       	else
    	     myEval(lines, true);
			 
		window.eval(dec2.text); // increment part
	}
	myEval(los);  // calculate the value after loop
	
    return [dec1, los, dec2, lines]; 
 }
 
compound_statement
 = nl _'{' _ [ \n]* _ b:block_item_list _ '}' _ nl _{  // block itemlar yerine bos da olabilir
 	return b
 }

block_item_list = (block_item)* 

block_item
 = declaration
 / if_statement
 / while_statement
 / print_statement
 / math_functions
 / expression_statement
 / logical_statement
 / null_statement
 / comment

null_statement
 = ';' _ comment? nl {
 	return {'type': 'null', 'text': '', 'lineNumber': location().start.line};
 }

declaration
 =  _ ('var' / 'değişken' / 'değ') _ dec:init_declarator_list _ nl{
	return {'type': 'declaration', '#evaluation': 0, 'text':'var '+dec.lhs+' = ' + dec.rhs, 'lhs':dec.lhs, 'rhs': dec.rhs, 'lineNumber': location().start.line};
 }
 /
  _ ass:init_declarator_list  {
	return {'type': 'assignment', '#evaluation': 0, 'text': ass.lhs+' = '+ass.rhs, 'lhs':ass.lhs, 'rhs': ass.rhs, 'lineNumber': location().start.line};
 }

init_declarator_list
 = 	init:init_declarator (',' _ init_declarator)* {return init;}

init_declarator
	= _ left:name _"="_ exp: (dogru / yanlis / math_functions / expression_statement) nl{

	if( typeof(exp) == 'boolean')
    	return {'lhs': left, 'rhs': exp.toString()}; // evaluate it, then return it       
    else 
        return {'lhs': left, 'rhs': exp.text};        
}   

print_statement = _ ("yaz" / "print") _ exp:(expression_statement / StringLiteral) _ comment? nl {
	if(typeof(exp.value) == 'string')
		return {'type':'print', 'subtype': 'string', 'text': exp.value, 'lineNumber': location().start.line}; // evaluate it, then return it       
	return {'type':'print', 'subtype': 'var', 'text': exp.text, 'lineNumber': location().start.line}; // evaluate it, then return it       
}

expression_statement = head:Term tail:(_ ("+" / "-") _ Term)* nl{  	    
   	return {'type':'expression', '#evaluation': 0, 'text':text(), 'lineNumber': location().start.line, 'start':location().start.column, 'end':location().end.column-1}; // evaluate it, then return it    
}

Term
  = head:Factor tail:(_ ("*" / "/" / "%") _ Factor)* 

Factor
  = "(" _ expr:expression_statement _ ")" { return expr; }
  / f:Float { return f.text;}
  / i:Integer { return i.text;}
  / name
  

logical_statement = _ f1:factor2 _ op:operator _ f2:factor2 log:(_ logical_operator _ logical_statement)* _ nl
{
	var text = f1+' ';
    
    if(f2)
	    text += op + ' ' + f2; 
        
    if(log[0])
    {	
    	log = log[0];
//    	console.log(log)
    
    	text += ' '+ log[1];
        text += ' '+ log[3].text;
    }
    
	return {'type':'logical', 'text': text, 'lineNumber': location().start.line, 'start': location().start.column-1, 'end': location().end.column-1};
}

// bu kullilmiyor simdi
factor = "(" expr: expression_statement ")" {return expr;}
	   / name
	   / Float
       / integer 
	  

factor2 = "(" logical_statement ")" 
	   / name
	   / Float
       / integer


//// math functions

math_functions
 = taban / tavan/ karekok

taban = 'taban' _ '(' _ exp:expression_statement _ ')'{
 	return {'type':'math_func', '#evaluation': 0, 'text': 'Math.floor(' + exp.text + ')', 'lineNumber': location().end.line, 'start':location().start.column, 'end':location().end.column-1}; 
}
tavan = 'tavan' _ '(' _ exp:expression_statement _ ')'{
 	return {'type':'math_func', '#evaluation': 0, 'text': 'Math.ceil(' + exp.text + ')', 'lineNumber': location().end.line, 'start':location().start.column, 'end':location().end.column-1}; 
}
karekok = 'karekök' _ '(' _ exp:expression_statement _ ')'{
 	return {'type':'math_func', '#evaluation': 0, 'text': 'Math.sqrt(' + exp.text + ')', 'lineNumber': location().end.line, 'start':location().start.column, 'end':location().end.column-1}; 
}


///// Name = Variable

name = l:letter i:integer {return l+i}
     / l:letter {return l;} 

dogru = 'doğru' {return true;}
yanlis = 'yanlış' {return false;}


letter "letter" 
  = [a-zA-Z_|ş|ğ|ç|ö|ü|ı|ü|Ş|Ğ|Ç|Ö|Ü|I|Ü]+ {return text()} 

StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return { type: "Literal", value: chars.join("") };
    }

DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

LineContinuation
  = "\\" LineTerminatorSequence { return ""; }  
  
LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"  
  
LineTerminator
  = [\n\r\u2028\u2029]  
 
SourceCharacter
  = . 
 
EscapeSequence
  = CharacterEscapeSequence

CharacterEscapeSequence
  = SingleEscapeCharacter

SingleEscapeCharacter
  = "'" / '"'  / "\\"  
  / "b"  { return "\b"; }
  / "f"  { return "\f"; }
  / "n"  { return "\n"; }
  / "r"  { return "\r"; }
  / "t"  { return "\t"; }
  / "v"  { return "\v"; } 
  
  
Float "float" 
  = _ '-'? [0-9]+ '.' [0-9]* { return {type: 'float', text: text()}; }

Integer "integer"
  = _ '-'? [0-9]+ { return {type: 'integer', text: text()}; }
   
integer "integer"
  = [0-9]+ { return parseInt(text(), 10); }

_ "whitespace"
  = [ \t\r]* {return null;}
  
nl "newline"
  = comment? [\n]* {return null;}
  
comment 
   = _ "//" _ [ a-zA-Z0-9|\=|(|)|+|\-|\+|*|\._|ş|ğ|ç|ö|ü|ı|Ş|Ğ|Ç|Ö|Ü|I|Ü]* nl {return {type: 'comment', value: text()}; }
  
operator
  = operator_text / operator_symbol
  
logical_operator
  = logical_operator_text / logical_operator_symbol
  
logical_operator_text
  = "ve"					{ return "&&"; }
	/ "veya"				{ return "||"; }
    
logical_operator_symbol
  = "&&"					{ return text(); }
	/ "||"					{ return text(); }    

operator_text
  =  "büyükeşit" 			{ return ">="; }
	/ "küçükeşit"			{ return "<="; }
	/ "küçük"				{ return "<"; }
	/ "büyük"	 			{ return ">"; }
	/ "eşitdeğil"			{ return "!="; }  
	/ "eşit"				{ return "=="; }
  
operator_symbol
  = "<="					{ return text(); }
	/ "<"					{ return text(); }
	/ ">="					{ return text(); }
	/ ">"					{ return text(); }
	/ "=="					{ return text(); }
	/ "!="					{ return text(); }