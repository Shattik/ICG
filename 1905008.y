%{
#include<iostream>
#include<fstream>
#include<cstdlib>
#include<cstring>
#include<cmath>
#include "1905008.h"
// #define YYSTYPE SymbolInfo*

using namespace std;

int yyparse(void);
int yylex(void);
extern FILE *yyin;
extern int line_count;
extern int error_count;

ofstream asmout, optout;
long dataPosition;
SymbolTable *table;
Symbols *paras;
FILE *fp;
string functionReturn;
int error_line;
SymbolInfo *inFunction;


void yyerror(char *s)
{
    error_line = line_count;
	//write your code
}

void idTypeSetter(string str, Symbols* si)
{
    int size = si->length();
    for(int i=0; i<size; i++){
        if(str == "VOID") {
            error_count++;
        }
        else if(si->v[i].getType() == "ARRAY") {
            SymbolInfo sm = si->v[i];
            SymbolInfo *inf = table->lookUpCurrent(sm.getName());
            if(inf == NULL) {
                table->insert(sm.getName(), sm.getType(), str);
            }
            else{
                if(inf->getType() != "ARRAY") {
                    error_count++;
                }
                else if(inf->getRetType() != str) {
                    error_count++;
                }
                else {
                    error_count++;
                }
            }
        }
        else {
            SymbolInfo sm = si->v[i];
            SymbolInfo *inf = table->lookUpCurrent(sm.getName());
            if(inf == NULL) {
                table->insert(sm.getName(), str);
            }
            else{
                if(inf->getType() == "ARRAY" || inf->getType() == "FUNCTION") {
                    error_count++;
                }
                else if(inf->getType() != str) {
                    error_count++;
                }
                else {
                    error_count++;
                }
            }
        }
    }
    
}

void addParameter()
{
    if(paras == NULL){
        return;
    }
    for(int i=0; i<paras->length(); i++){
        if(paras->v[i].getType()=="VOID" && (paras->v[i].getName()!="" || paras->length()!=1)){
            error_count++;
            break;
        }
        else if(table->lookUpCurrent(paras->v[i].getName()) != NULL){
            error_count++;
            break;
        }
        else{
            table->insert(paras->v[i].getName(), paras->v[i].getType());
        }
    }
    paras = NULL;
}

void declareFunction(SymbolInfo *si, Symbols *par, string ret)
{
    if(table->lookUpCurrent(si->getName()) != NULL){
        error_count++;
        return;
    }
    SymbolInfo *fun = new SymbolInfo(si->getName(), "FUNCTION");
    fun->setRetType(ret);
    for(int i=0; i<par->length(); i++){
        if(par->v[i].getType()=="VOID" && (par->v[i].getName()!="" || par->length()!=1)){
            error_count++;
            continue;
        }
        fun->paramType.push_back(par->v[i].getType());
    }
    table->insert(fun);
}

void declareFunction(SymbolInfo *si, string ret)
{
    if(table->lookUpCurrent(si->getName()) != NULL){
        error_count++;
        return;
    }
    SymbolInfo *fun = new SymbolInfo(si->getName(), "FUNCTION");
    fun->setRetType(ret);
    table->insert(fun);
}

void checkDefinition(SymbolInfo* fun, string ret, Symbols *par)
{
    paras = par;
    if(fun->isDef){
        error_count++;
        return;
    }
    fun->isDef = true;
    if(fun->getType() != "FUNCTION"){
        error_count++;
    }
    else if(fun->getRetType() != ret){
        error_count++;
    }
    else if(par==NULL && fun->paramType.size()!=0){
        error_count++;
    }
    else if(par!=NULL && fun->paramType.size() != par->length()){
        error_count++;
    }
    else if(par!=NULL){
        for(int i=0; i<par->length(); i++){
            if(fun->paramType[i] != par->v[i].getType()){
                error_count++;
                break;
            }
        }
    }
}

void defineFunction(SymbolInfo *si, string ret, Symbols *par = NULL)
{
    SymbolInfo *fun = table->lookUpCurrent(si->getName());
    if(fun != NULL) {
        checkDefinition(fun, ret, par);
        inFunction = fun;
        return;
    }
    fun = new SymbolInfo(si->getName(), "FUNCTION");
    fun->setRetType(ret);
    if(par!=NULL){
        for(int i=0; i<par->length(); i++){
            fun->paramType.push_back(par->v[i].getType());
        }
    }
    fun->isDef = true;
    table->insert(fun);
    paras = par;
    inFunction = fun;
}

void funcCode()
{
    asmout<<inFunction->getName()<<" PROC"<<endl;
    if(inFunction->getName() == "main"){
        asmout<<"\tMOV AX, @DATA"<<endl;
        asmout<<"\tMOV DS, AX"<<endl;
    }
}

void codeForPrint()
{
    asmout<<"new_line PROC"<<endl;
    asmout<<"\tPUSH AX"<<endl;
    asmout<<"\tPUSH DX"<<endl;
    asmout<<"\tMOV AH, 2"<<endl;
    asmout<<"\tMOV DL, CR"<<endl;
    asmout<<"\tINT 21H"<<endl;
    asmout<<"\tMOV AH, 2"<<endl;
    asmout<<"\tMOV DL, LF"<<endl;
    asmout<<"\tINT 21H"<<endl;
    asmout<<"\tPOP DX"<<endl;
    asmout<<"\tPOP AX"<<endl;
    asmout<<"\tRET"<<endl;
    asmout<<"new_line ENDP"<<endl;
    asmout<<"print_output PROC  ;print what is in ax"<<endl;
    asmout<<"\tPUSH AX"<<endl;
    asmout<<"\tPUSH BX"<<endl;
    asmout<<"\tPUSH CX"<<endl;
    asmout<<"\tPUSH DX"<<endl;
    asmout<<"\tPUSH SI"<<endl;
    asmout<<"\tLEA SI, number"<<endl;
    asmout<<"\tMOV BX, 10"<<endl;
    asmout<<"\tADD SI, 4"<<endl;
    asmout<<"\tCMP AX, 0"<<endl;
    asmout<<"\tJNGE negate"<<endl;
    asmout<<"\tprint:"<<endl;
    asmout<<"\tXOR DX, DX"<<endl;
    asmout<<"\tDIV BX"<<endl;
    asmout<<"\tMOV [SI], DL"<<endl;
    asmout<<"\tADD [SI], '0'"<<endl;
    asmout<<"\tDEC SI"<<endl;
    asmout<<"\tCMP AX, 0"<<endl;
    asmout<<"\tJNE print"<<endl;
    asmout<<"\tINC SI"<<endl;
    asmout<<"\tLEA DX, SI"<<endl;
    asmout<<"\tMOV AH, 9"<<endl;
    asmout<<"\tINT 21H"<<endl;
    asmout<<"\tPOP SI"<<endl;
    asmout<<"\tPOP DX"<<endl;
    asmout<<"\tPOP CX"<<endl;
    asmout<<"\tPOP BX"<<endl;
    asmout<<"\tPOP AX"<<endl;
    asmout<<"\tRET"<<endl;
    asmout<<"\tnegate:"<<endl;
    asmout<<"\tPUSH AX"<<endl;
    asmout<<"\tMOV AH, 2"<<endl;
    asmout<<"\tMOV DL, '-'"<<endl;
    asmout<<"\tINT 21H"<<endl;
    asmout<<"\tPOP AX"<<endl;
    asmout<<"\tNEG AX"<<endl;
    asmout<<"\tJMP print"<<endl;
    asmout<<"print_output ENDP"<<endl;
}

void checkArguments(SymbolInfo *fun, Symbols* args)
{
    if(fun->paramType.size() > args->length()){
        error_count++;
    }
    else if(fun->paramType.size() < args->length()){
        error_count++;
    }
    else{
        for(int i=0; i<fun->paramType.size(); i++){
            if(fun->paramType[i] != args->v[i].getType()){
                error_count++;
            }
        }
    }
}

%}

%union{
    SymbolInfo* si;
    Symbols* smbls;
}

%token<si> CONST_INT CONST_FLOAT CONST_CHAR ADDOP MULOP INCOP RELOP LOGICOP BITOP ID SINGLE_LINE_STRING MULTI_LINE_STRING IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE ASSIGNOP NOT LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON DECOP PRINTLN
  
%type<smbls> declaration_list parameter_list arguments argument_list
%type<si> variable factor expression unary_expression term simple_expression rel_expression logic_expression type_specifier expression_statement statement statements var_declaration compound_statement func_declaration func_definition unit program start

// %left 
// %right
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
        $$ = new SymbolInfo("", "");
        $$->nodeName = "start : program";
        $$->isLeaf = false;
        $$->start = $1->start;
        $$->end = $1->end;
        $$->children.push_back($1);
        cout<<"Parse Done"<<endl;
	}
	;

program : program unit 
                        {
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "program : program unit";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $2->end;
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
	| unit
                {
                    $$ = new SymbolInfo("", "");
                    $$->nodeName = "program : unit";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                }
	;
	
unit : var_declaration
                        {
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "unit : var_declaration";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
     | func_declaration
                        {
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "unit : func_declaration";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
     | func_definition
                        {
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "unit : func_definition";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }   
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON
                                                                            {
                                                                                declareFunction($2, $4, $1->getType());
                                                                                $$ = new SymbolInfo("", "");
                                                                                $$->nodeName = "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON";
                                                                                $$->isLeaf = false;
                                                                                $$->start = $1->start;
                                                                                $$->end = $6->end;
                                                                                $$->children.push_back($1);
                                                                                $$->children.push_back($2);
                                                                                $$->children.push_back($3);
                                                                                $$->children.push_back($4);
                                                                                $$->children.push_back($5); 
                                                                                $$->children.push_back($6);
                                                                            }
		| type_specifier ID LPAREN RPAREN SEMICOLON
                                                    {
                                                        declareFunction($2, $1->getType());
                                                        $$ = new SymbolInfo("", "");
                                                        $$->nodeName = "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON";
                                                        $$->isLeaf = false;
                                                        $$->start = $1->start;
                                                        $$->end = $5->end;
                                                        $$->children.push_back($1);
                                                        $$->children.push_back($2);
                                                        $$->children.push_back($3);
                                                        $$->children.push_back($4);
                                                        $$->children.push_back($5); 
                                                    }
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {defineFunction($2, $1->getType(), $4);functionReturn=$1->getType();funcCode();} compound_statement
                                                                                    { 
                                                                                        $$ = new SymbolInfo("", "");
                                                                                        $$->nodeName = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
                                                                                        $$->isLeaf = false;
                                                                                        $$->start = $1->start;
                                                                                        $$->end = $7->end;
                                                                                        $$->children.push_back($1);
                                                                                        $$->children.push_back($2);
                                                                                        $$->children.push_back($3);
                                                                                        $$->children.push_back($4);
                                                                                        $$->children.push_back($5); 
                                                                                        $$->children.push_back($7);
                                                                                        if(inFunction->getName() == "main"){
                                                                                            asmout<<"\tMOV AX, 4CH"<<endl;
                                                                                            asmout<<"\tINT 21H"<<endl;
                                                                                        }
                                                                                        asmout<<inFunction->getName()<<" ENDP"<<endl;
                                                                                    }
		| type_specifier ID LPAREN RPAREN {defineFunction($2, $1->getType());functionReturn=$1->getType();funcCode();} compound_statement
                                                            {
                                                                $$ = new SymbolInfo("", "");
                                                                $$->nodeName = "func_definition : type_specifier ID LPAREN RPAREN compound_statement";
                                                                $$->isLeaf = false;
                                                                $$->start = $1->start;
                                                                $$->end = $6->end;
                                                                $$->children.push_back($1);
                                                                $$->children.push_back($2);
                                                                $$->children.push_back($3);
                                                                $$->children.push_back($4);
                                                                $$->children.push_back($6);
                                                                if(inFunction->getName() == "main"){
                                                                    asmout<<"\tMOV AX, 4CH"<<endl;
                                                                    asmout<<"\tINT 21H"<<endl;
                                                                }
                                                                asmout<<inFunction->getName()<<" ENDP"<<endl;
                                                            }
        | type_specifier ID LPAREN error RPAREN compound_statement
                                                                    {
                                                                        error_count++;
                                                                        SymbolInfo *er = new SymbolInfo("", "");
                                                                        er->nodeName = "parameter_list : error";
                                                                        er->start = error_line;
                                                                        er->end = error_line;
                                                                        er->isLeaf = true;
                                                                        $$ = new SymbolInfo("", "");
                                                                        $$->nodeName = "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement";
                                                                        $$->isLeaf = false;
                                                                        $$->start = $1->start;
                                                                        $$->end = $6->end;
                                                                        $$->children.push_back($1);
                                                                        $$->children.push_back($2);
                                                                        $$->children.push_back($3);
                                                                        $$->children.push_back(er);
                                                                        $$->children.push_back($5);
                                                                        $$->children.push_back($6);
                                                                    }                                                     
 		;				


parameter_list  : parameter_list COMMA type_specifier ID
                                                            {
                                                                $$ = new Symbols();
                                                                for(int i=0; i<$1->length(); i++){
                                                                    $$->insert($1->v[i]);
                                                                }
                                                                SymbolInfo si($4->getName(), $3->getType());
                                                                si.start = line_count;
                                                                $$->insert(si);
                                                                $$->nodeName = "parameter_list : parameter_list COMMA type_specifier ID";
                                                                $$->isLeaf = false;
                                                                $$->start = $1->start;
                                                                $$->end = $4->end;
                                                                $$->children.push_back($1);
                                                                $$->children.push_back($2);
                                                                $$->children.push_back($3);
                                                                $$->children.push_back($4);
                                                            }
		| parameter_list COMMA type_specifier
                                                {
                                                    $$ = new Symbols();
                                                    for(int i=0; i<$1->length(); i++){
                                                        $$->insert($1->v[i]);
                                                    }
                                                    SymbolInfo si("", $3->getType());
                                                    si.start = line_count;
                                                    $$->insert(si);
                                                    $$->nodeName = "parameter_list : parameter_list COMMA type_specifier";
                                                    $$->isLeaf = false;
                                                    $$->start = $1->start;
                                                    $$->end = $3->end;
                                                    $$->children.push_back($1);
                                                    $$->children.push_back($2);
                                                    $$->children.push_back($3);
                                                }
 		| type_specifier ID
                            {
                                $$ = new Symbols();
                                SymbolInfo si($2->getName(), $1->getType());
                                si.start = line_count;
                                $$->insert(si);
                                $$->nodeName = "parameter_list : type_specifier ID";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $2->end;
                                $$->children.push_back($1);
                                $$->children.push_back($2);
                            }
		| type_specifier
                            {
                                $$ = new Symbols();
                                SymbolInfo si("", $1->getType());
                                si.start = line_count;
                                $$->insert(si);
                                $$->nodeName = "parameter_list : type_specifier";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
 		;

 		
compound_statement : LCURL {table->enterScope();addParameter();} statements RCURL 
                                                                    {
                                                                        table->exitScope();
                                                                        $$ = new SymbolInfo("", "");
                                                                        $$->nodeName = "compound_statement : LCURL statements RCURL";
                                                                        $$->isLeaf = false;
                                                                        $$->start = $1->start;
                                                                        $$->end = $4->end;
                                                                        $$->children.push_back($1);
                                                                        $$->children.push_back($3);
                                                                        $$->children.push_back($4);
                                                                    }
 		    | LCURL {table->enterScope();addParameter();} RCURL
                                                    {
                                                        table->exitScope();
                                                        $$ = new SymbolInfo("", "");
                                                        $$->nodeName = "compound_statement : LCURL RCURL";
                                                        $$->isLeaf = false;
                                                        $$->start = $1->start;
                                                        $$->end = $3->end;
                                                        $$->children.push_back($1);
                                                        $$->children.push_back($3);
                                                    }
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON     
                                                                {
                                                                    idTypeSetter($1->getType(), $2);
                                                                    $$ = new SymbolInfo("", "");
                                                                    $$->nodeName = "var_declaration : type_specifier declaration_list SEMICOLON";
                                                                    $$->isLeaf = false;
                                                                    $$->start = $1->start;
                                                                    $$->end = $3->end;
                                                                    $$->children.push_back($1);
                                                                    $$->children.push_back($2);
                                                                    $$->children.push_back($3);
                                                                }
        | type_specifier error SEMICOLON
                                        {
                                            error_count++;
                                            SymbolInfo *er = new SymbolInfo("", "");
                                            er->nodeName = "declaration_list : error";
                                            er->start = error_line;
                                            er->end = error_line;
                                            er->isLeaf = true;
                                            $$ = new SymbolInfo("", "");
                                            $$->nodeName = "var_declaration : type_specifier declaration_list SEMICOLON";
                                            $$->isLeaf = false;
                                            $$->start = $1->start;
                                            $$->end = $3->end;
                                            $$->children.push_back($1);
                                            $$->children.push_back(er);
                                            $$->children.push_back($3);
                                        }                                                        
 		 ;
 		 
type_specifier	: INT 
                        {
                            $$ = new SymbolInfo("", "INT");
                            $$->nodeName = "type_specifier : INT";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
 		| FLOAT
                    {
                        $$ = new SymbolInfo("", "FLOAT");
                        $$->nodeName = "type_specifier : FLOAT";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $1->end;
                        $$->children.push_back($1);
                    }
 		| VOID
                    {
                        $$ = new SymbolInfo("", "VOID");
                        $$->nodeName = "type_specifier : VOID";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $1->end;
                        $$->children.push_back($1);
                    }
 		;
 		
declaration_list : declaration_list COMMA ID    
                                                {
                                                    $$ = new Symbols();
                                                    for(int i=0; i<$1->length(); i++){
                                                        $$->insert($1->v[i]);
                                                    }
                                                    $$->insert(*$3);
                                                    $$->nodeName = "declaration_list : declaration_list COMMA ID";
                                                    $$->isLeaf = false;
                                                    $$->start = $1->start;
                                                    $$->end = $3->end;
                                                    $$->children.push_back($1);
                                                    $$->children.push_back($2);
                                                    $$->children.push_back($3);
                                                }
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE
                                                                    {
                                                                        $$ = new Symbols();
                                                                        for(int i=0; i<$1->length(); i++){
                                                                            $$->insert($1->v[i]);
                                                                        }
                                                                        $3->setType("ARRAY");
                                                                        $$->insert(*$3);
                                                                        $$->nodeName = "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE";
                                                                        $$->isLeaf = false;
                                                                        $$->start = $1->start;
                                                                        $$->end = $6->end;
                                                                        $$->children.push_back($1);
                                                                        $$->children.push_back($2);
                                                                        $$->children.push_back($3);
                                                                        $$->children.push_back($4);
                                                                        $$->children.push_back($5);
                                                                        $$->children.push_back($6);
                                                                    }
                                                            
 		  | ID   
                {
                    $$ = new Symbols();
                    $$->insert(*$1);
                    $$->nodeName = "declaration_list : ID";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                }
 		  | ID LSQUARE CONST_INT RSQUARE 
                                            {
                                                $$ = new Symbols();
                                                $1->setType("ARRAY");
                                                $$->insert(*$1);
                                                $$->nodeName = "declaration_list : ID LSQUARE CONST_INT RSQUARE";
                                                $$->isLeaf = false;
                                                $$->start = $1->start;
                                                $$->end = $4->end;
                                                $$->children.push_back($1);
                                                $$->children.push_back($2);
                                                $$->children.push_back($3);
                                                $$->children.push_back($4);
                                            }
 		  ;
 		  
statements : statement
                        {
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "statements : statement";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
	   | statements statement
                        {
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "statements : statements statement";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $2->end;
                            $$->children.push_back($1);
                            $$->children.push_back($2);
                        }
	   ;
	   
statement : var_declaration
                            {
                                $$ = new SymbolInfo("", "");
                                $$->nodeName = "statement : var_declaration";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
	  | expression_statement
                            {
                                $$ = new SymbolInfo("", "");
                                $$->nodeName = "statement : expression_statement";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
	  | compound_statement
                            {
                                $$ = new SymbolInfo("", "");
                                $$->nodeName = "statement : compound_statement";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
                                                                                        {
                                                                                            $$ = new SymbolInfo("", "");
                                                                                            $$->nodeName = "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement";
                                                                                            $$->isLeaf = false;
                                                                                            $$->start = $1->start;
                                                                                            $$->end = $7->end;
                                                                                            $$->children.push_back($1);
                                                                                            $$->children.push_back($2);
                                                                                            $$->children.push_back($3);
                                                                                            $$->children.push_back($4);
                                                                                            $$->children.push_back($5);
                                                                                            $$->children.push_back($6);
                                                                                            $$->children.push_back($7);
                                                                                        }
	  | IF LPAREN expression RPAREN statement  %prec LOWER_THAN_ELSE 
                                                                    {
                                                                        $$ = new SymbolInfo("", "");
                                                                        $$->nodeName = "statement : IF LPAREN expression RPAREN statement";
                                                                        $$->isLeaf = false;
                                                                        $$->start = $1->start;
                                                                        $$->end = $5->end;
                                                                        $$->children.push_back($1);
                                                                        $$->children.push_back($2);
                                                                        $$->children.push_back($3);
                                                                        $$->children.push_back($4);
                                                                        $$->children.push_back($5);
                                                                    }
	  | IF LPAREN expression RPAREN statement ELSE statement
                                                            {
                                                                $$ = new SymbolInfo("", "");
                                                                $$->nodeName = "statement : IF LPAREN expression RPAREN statement ELSE statement";
                                                                $$->isLeaf = false;
                                                                $$->start = $1->start;
                                                                $$->end = $7->end;
                                                                $$->children.push_back($1);
                                                                $$->children.push_back($2);
                                                                $$->children.push_back($3);
                                                                $$->children.push_back($4);
                                                                $$->children.push_back($5);
                                                                $$->children.push_back($6);
                                                                $$->children.push_back($7);
                                                            }
	  | WHILE LPAREN expression RPAREN statement
                                                {
                                                    $$ = new SymbolInfo("", "");
                                                    $$->nodeName = "statement : WHILE LPAREN expression RPAREN statement";
                                                    $$->isLeaf = false;
                                                    $$->start = $1->start;
                                                    $$->end = $5->end;
                                                    $$->children.push_back($1);
                                                    $$->children.push_back($2);
                                                    $$->children.push_back($3);
                                                    $$->children.push_back($4);
                                                    $$->children.push_back($5);
                                                }
 	  | PRINTLN LPAREN ID RPAREN SEMICOLON
                                            {
                                                if(!table->lookUp($3->getName())){
                                                    error_count++;
                                                }
                                                $$ = new SymbolInfo("", "");
                                                $$->nodeName = "statement : PRINTLN LPAREN ID RPAREN SEMICOLON";
                                                $$->isLeaf = false;
                                                $$->start = $1->start;
                                                $$->end = $5->end;
                                                $$->children.push_back($1);
                                                $$->children.push_back($2);
                                                $$->children.push_back($3);
                                                $$->children.push_back($4);
                                                $$->children.push_back($5);
                                            }
	  | RETURN expression SEMICOLON
                                    {
                                        if(functionReturn == "VOID"){
                                            error_count++;
                                        }
                                        else if(functionReturn=="INT" && $2->getType()=="FLOAT"){
                                            error_count++;
                                        }
                                        $$ = new SymbolInfo("", "");
                                        $$->nodeName = "statement : RETURN expression SEMICOLON";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $3->end;
                                        $$->children.push_back($1);
                                        $$->children.push_back($2);
                                        $$->children.push_back($3);
                                    }
	  ;
	  
expression_statement 	: SEMICOLON
                                    {
                                        $$ = new SymbolInfo("", "");
                                        $$->nodeName = "expression_statement : SEMICOLON";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $1->end;
                                        $$->children.push_back($1);
                                    }
			| expression SEMICOLON
                                    {
                                        $$ = new SymbolInfo("", "");
                                        $$->nodeName = "expression_statement : expression SEMICOLON";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $2->end;
                                        $$->children.push_back($1);
                                        $$->children.push_back($2);
                                    } 
            | error SEMICOLON 
                                {
                                    error_count++;
                                    SymbolInfo *er = new SymbolInfo("", "");
                                    er->nodeName = "expression : error";
                                    er->start = error_line;
                                    er->end = error_line;
                                    er->isLeaf = true;
                                    $$ = new SymbolInfo("", "");
                                    $$->nodeName = "expression_statement : expression SEMICOLON";
                                    $$->isLeaf = false;
                                    $$->start = $2->start;
                                    $$->end = $2->end;
                                    $$->children.push_back(er);
                                    $$->children.push_back($2);
                                }                        
			;
	  
variable : ID 
            {
                $$ = new SymbolInfo("", "");
                SymbolInfo *sim = table->lookUp($1->getName());
                if(sim==NULL){
                    error_count++;
                    $$->setType("ERROR");
                }
                else if(sim->getType()=="FUNCTION"){
                    error_count++;
                    $$->setType("ERROR");
                }
                else{
                    $$->setType(sim->getType());
                }
                $$->nodeName = "variable : ID";
                $$->isLeaf = false;
                $$->start = $1->start;
                $$->end = $1->end;
                $$->children.push_back($1);
            }
	 | ID LSQUARE expression RSQUARE 
                                    {
                                        $$ = new SymbolInfo("", "");
                                        SymbolInfo *sim = table->lookUp($1->getName());
                                        if(sim==NULL){
                                            error_count++;
                                            $$->setType("ERROR");
                                        }
                                        else if(sim->getType()=="ARRAY"){
                                            $$->setType(sim->getRetType());
                                            if($3->getType()!="INT"){
                                                error_count++;
                                            }
                                        }
                                        else{
                                            error_count++;
                                            $$->setType("ERROR");
                                        }
                                        $$->nodeName = "variable : ID LSQUARE expression RSQUARE";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $4->end;
                                        $$->children.push_back($1);
                                        $$->children.push_back($2);
                                        $$->children.push_back($3);
                                        $$->children.push_back($4);
                                    }
	 ;
	 
 expression : logic_expression	
                                {
                                    $$ = new SymbolInfo($1->getName(), $1->getType());
                                    $$->nodeName = "expression : logic_expression";
                                    $$->isLeaf = false;
                                    $$->start = $1->start;
                                    $$->end = $1->end;
                                    $$->children.push_back($1);
                                }
	   | variable ASSIGNOP logic_expression 	
                                            {
                                                if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                    error_count++;
                                                    $$ = new SymbolInfo("", "ERROR");
                                                }
                                                else if($1->getType()=="INT" && $3->getType()=="FLOAT"){
                                                    error_count++;
                                                    $$ = new SymbolInfo("", "INT");
                                                }
                                                else{
                                                    $$ = new SymbolInfo("", $1->getType());
                                                }
                                                $$->nodeName = "expression : variable ASSIGNOP logic_expression";
                                                $$->isLeaf = false;
                                                $$->start = $1->start;
                                                $$->end = $3->end;
                                                $$->children.push_back($1);
                                                $$->children.push_back($2);
                                                $$->children.push_back($3);
                                            }
	   ;
			
logic_expression : rel_expression 
                                {
                                    $$ = new SymbolInfo($1->getName(), $1->getType());
                                    $$->nodeName = "logic_expression : rel_expression";
                                    $$->isLeaf = false;
                                    $$->start = $1->start;
                                    $$->end = $1->end;
                                    $$->children.push_back($1);
                                }
		 | rel_expression LOGICOP rel_expression 
                                                {
                                                    if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                        error_count++;
                                                        $$ = new SymbolInfo("", "ERROR");
                                                    }
                                                    else {
                                                        $$ = new SymbolInfo("", "INT");
                                                    }
                                                    $$->nodeName = "logic_expression : rel_expression LOGICOP rel_expression";
                                                    $$->isLeaf = false;
                                                    $$->start = $1->start;
                                                    $$->end = $3->end;
                                                    $$->children.push_back($1);
                                                    $$->children.push_back($2);
                                                    $$->children.push_back($3);
                                                }	
		 ;
			
rel_expression	: simple_expression 
                                    {
                                        $$ = new SymbolInfo($1->getName(), $1->getType());
                                        $$->nodeName = "rel_expression : simple_expression";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $1->end;
                                        $$->children.push_back($1);
                                    }
		| simple_expression RELOP simple_expression	
                                                    {
                                                        if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                            error_count++;
                                                            $$ = new SymbolInfo("", "ERROR");
                                                        }
                                                        else {
                                                            $$ = new SymbolInfo("", "INT");
                                                        }
                                                        $$->nodeName = "rel_expression : simple_expression RELOP simple_expression";
                                                        $$->isLeaf = false;
                                                        $$->start = $1->start;
                                                        $$->end = $3->end;
                                                        $$->children.push_back($1);
                                                        $$->children.push_back($2);
                                                        $$->children.push_back($3);
                                                    }
		;
				
simple_expression : term 
                        {
                            $$ = new SymbolInfo($1->getName(), $1->getType());
                            $$->nodeName = "simple_expression : term";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
		  | simple_expression ADDOP term 
                                        {
                                            if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                error_count++;
                                                $$ = new SymbolInfo("", "ERROR");
                                            }
                                            else if($1->getType()=="FLOAT" || $3->getType()=="FLOAT"){
                                                $$ = new SymbolInfo("", "FLOAT");
                                            }
                                            else if($1->getType()=="ERROR"){
                                                $$ = new SymbolInfo("", $3->getType());
                                            }
                                            else if($3->getType()=="ERROR"){
                                                $$ = new SymbolInfo("", $1->getType());
                                            }
                                            else{
                                                $$ = new SymbolInfo("", $1->getType());
                                            }
                                            $$->nodeName = "simple_expression : simple_expression ADDOP term";
                                            $$->isLeaf = false;
                                            $$->start = $1->start;
                                            $$->end = $3->end;
                                            $$->children.push_back($1);
                                            $$->children.push_back($2);
                                            $$->children.push_back($3);
                                        }
		  ;
					
term :	unary_expression
                        {
                            $$ = new SymbolInfo($1->getName(), $1->getType());
                            $$->nodeName = "term : unary_expression";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
     |  term MULOP unary_expression
                                    {
                                        if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        else if(($2->getName()=="%" || $2->getName()=="/") && $3->getName()=="0"){
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }    
                                        else if($2->getName()=="%" && ($1->getType()=="FLOAT" || $3->getType()=="FLOAT")){
                                            error_count++;
                                            $$ = new SymbolInfo("", "INT");
                                        }
                                        else if($2->getName()=="%%"){
                                            $$ = new SymbolInfo("", "INT");
                                        }
                                        else if($1->getType()=="INT" && $3->getType()=="INT"){
                                            $$ = new SymbolInfo("", "INT");
                                        }
                                        else if($1->getType()=="FLOAT" || $3->getType()=="FLOAT"){
                                            $$ = new SymbolInfo("", "FLOAT");
                                        }
                                        else if($1->getType()=="ERROR"){
                                            $$ = new SymbolInfo("", $3->getType());
                                        }
                                        else if($3->getType()=="ERROR"){
                                            $$ = new SymbolInfo("", $1->getType());
                                        }
                                        else{
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        $$->nodeName = "term : term MULOP unary_expression";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $3->end;
                                        $$->children.push_back($1);
                                        $$->children.push_back($2);
                                        $$->children.push_back($3);
                                    }
     ;

unary_expression : ADDOP unary_expression  
                                            {
                                                if($2->getType()=="VOID"){
                                                    error_count++;
                                                    $$ = new SymbolInfo("", "ERROR");
                                                    delete $2;
                                                }
                                                else{
                                                    $$ = new SymbolInfo($2->getName(), $2->getType());
                                                }
                                                $$->nodeName = "unary_expression : ADDOP unary_expression";
                                                $$->isLeaf = false;
                                                $$->start = $1->start;
                                                $$->end = $2->end;
                                                $$->children.push_back($1);
                                                $$->children.push_back($2);
                                            }
		 | NOT unary_expression 
                                {
                                    if($2->getType()=="VOID"){
                                        error_count++;
                                        $$ = new SymbolInfo("", "ERROR");
                                    }
                                    else{
                                        $$ = new SymbolInfo("", "INT");
                                    }
                                    $$->nodeName = "unary_expression : NOT unary_expression";
                                    $$->isLeaf = false;
                                    $$->start = $1->start;
                                    $$->end = $2->end;
                                    $$->children.push_back($1);
                                    $$->children.push_back($2);
                                }
		 | factor 
                {
                    $$ = new SymbolInfo($1->getName(), $1->getType());
                    $$->nodeName = "unary_expression : factor";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                }
		 ;
	
factor	: variable 
                    {
                        $$ = new SymbolInfo($1->getName(), $1->getType());
                        $$->nodeName = "factor : variable";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $1->end;
                        $$->children.push_back($1); 
                    }
	| ID LPAREN argument_list RPAREN
                                    {
                                        SymbolInfo *fun = table->lookUp($1->getName());
                                        if(fun==NULL){
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        else if(fun->getType()!="FUNCTION"){
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        else{
                                            checkArguments(fun, $3);
                                            $$ = new SymbolInfo("", fun->getRetType());
                                        }     
                                        $$->nodeName = "factor : ID LPAREN argument_list RPAREN";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $4->end;
                                        $$->children.push_back($1);
                                        $$->children.push_back($2);
                                        $$->children.push_back($3);
                                        $$->children.push_back($4);           
                                    }
	| LPAREN expression RPAREN
                                {
                                    $$ = new SymbolInfo($2->getName(), $2->getType());
                                    $$->nodeName = "factor : LPAREN expression RPAREN";
                                    $$->isLeaf = false;
                                    $$->start = $1->start;
                                    $$->end = $3->end;
                                    $$->children.push_back($1);
                                    $$->children.push_back($2);
                                    $$->children.push_back($3);
                                }
	| CONST_INT
                {
                    $$ = new SymbolInfo($1->getName(), "INT");
                    $$->nodeName = "factor : CONST_INT";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                } 
	| CONST_FLOAT
                {
                    $$ = new SymbolInfo($1->getName(), "FLOAT");
                    $$->nodeName = "factor : CONST_FLOAT";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                }
	| variable INCOP 
                    {
                        if($1->getType()=="VOID"){
                            error_count++;
                            $$ = new SymbolInfo("", "ERROR");
                        }
                        else{
                            $$ = new SymbolInfo("", $1->getType());
                        }
                        $$->nodeName = "factor : variable INCOP";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $2->end;
                        $$->children.push_back($1);
                        $$->children.push_back($2);
                    }
 	| variable DECOP
                    {
                        if($1->getType()=="VOID"){
                            error_count++;
                            $$ = new SymbolInfo("", "ERROR");
                        }
                        else{
                            $$ = new SymbolInfo("", $1->getType());
                        }
                        $$->nodeName = "factor : variable DECOP";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $2->end;
                        $$->children.push_back($1);
                        $$->children.push_back($2);
                    }
	;
	
argument_list : arguments
                        {
                            $$ = new Symbols();
                            $$->nodeName = "argument_list : arguments";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                            for(int i=0; i<$1->length(); i++){
                                $$->insert($1->v[i]);
                            }
                        }
			  | 
              {
                    $$ = new Symbols();
                    $$->nodeName = "argument_list : ";
                    $$->isLeaf = false;
                    $$->start = line_count;
                    $$->end = line_count;
              }
			  ;
	
arguments : arguments COMMA logic_expression
                                            {
                                                $$ = new Symbols();
                                                $$->nodeName = "arguments : arguments COMMA logic_expression";
                                                $$->isLeaf = false;
                                                $$->start = $1->start;
                                                $$->end = $3->end;
                                                $$->children.push_back($1);
                                                $$->children.push_back($2);
                                                $$->children.push_back($3);
                                                for(int i=0; i<$1->length(); i++){
                                                    $$->insert($1->v[i]);
                                                }
                                                $$->insert(*$3);
                                            }
	      | logic_expression
                            {
                                $$ = new Symbols();
                                $$->nodeName = "arguments : logic_expression";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                                $$->insert(*$1);
                            }
	      ;
 

%%
int main(int argc,char *argv[])
{
    
	if((fp=fopen(argv[1],"r"))==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}

    asmout.open("code.asm");
    optout.open("optimized_code.asm");
	
	paras = NULL;
	
	table = new SymbolTable(11);

    //initializing the asm file
    asmout<<".MODEL SMALL"<<endl;
    asmout<<".STACK 100H"<<endl;
    asmout<<".DATA"<<endl;
    asmout<<"\tCR EQU 0DH"<<endl;
    asmout<<"\tLF EQU 0AH"<<endl;
    asmout<<"\tnumber DB \"00000$\""<<endl;
    dataPosition = asmout.tellp();
    asmout<<".CODE"<<endl;

    inFunction = NULL;

	yyin=fp;
	yyparse();

    codeForPrint();
    asmout<<"END main"<<endl;
	
	delete table;
	fclose(fp);
    asmout.close();
    optout.close();
	return 0;
}

