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

ofstream logout, error, tree;
SymbolTable *table;
Symbols *paras;
FILE *fp;
string functionReturn;
int error_line;


void yyerror(char *s)
{
    error_line = line_count;
    logout<<"Error at line no "<<error_line<<" : syntax error"<<endl;
	//write your code
}

void idTypeSetter(string str, Symbols* si)
{
    int size = si->length();
    for(int i=0; i<size; i++){
        if(str == "VOID") {
            error<<"Line# "<<line_count<<": Variable or field '"<<si->v[i].getName()<<"' declared void"<<endl;
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
                    error<<"Line# "<<line_count<<": '"<<sm.getName()<<"' redeclared as different kind of symbol"<<endl;
                    error_count++;
                }
                else if(inf->getRetType() != str) {
                    error<<"Line# "<<line_count<<": Conflicting types for '"<<sm.getName()<<"'"<<endl;
                    error_count++;
                }
                else {
                    error<<"Line# "<<line_count<<": Redefinition of variable '"<<sm.getName()<<"'"<<endl;
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
                    error<<"Line# "<<line_count<<": '"<<sm.getName()<<"' redeclared as different kind of symbol"<<endl;
                    error_count++;
                }
                else if(inf->getType() != str) {
                    error<<"Line# "<<line_count<<": Conflicting types for '"<<sm.getName()<<"'"<<endl;
                    error_count++;
                }
                else {
                    error<<"Line# "<<line_count<<": Redefinition of variable '"<<sm.getName()<<"'"<<endl;
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
            error<<"Line# "<<paras->v[i].start<<": Variable or field '"<<paras->v[i].getName()<<"' declared void"<<endl;
            error_count++;
            break;
        }
        else if(table->lookUpCurrent(paras->v[i].getName()) != NULL){
            error<<"Line# "<<paras->v[i].start<<": Redefinition of parameter '"<<paras->v[i].getName()<<"'"<<endl;
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
        error<<"Line# "<<line_count<<": Function '"<<si->getName()<<"' was declared earlier"<<endl;
        error_count++;
        return;
    }
    SymbolInfo *fun = new SymbolInfo(si->getName(), "FUNCTION");
    fun->setRetType(ret);
    for(int i=0; i<par->length(); i++){
        if(par->v[i].getType()=="VOID" && (par->v[i].getName()!="" || par->length()!=1)){
            error<<"Line# "<<line_count<<": Variable or field '"<<par->v[i].getName()<<"' declared void"<<endl;
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
        error<<"Line# "<<line_count<<": Function '"<<si->getName()<<"' was declared earlier"<<endl;
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
        error<<"Line# "<<line_count<<": Function '"<<fun->getName()<<"' was defined earlier"<<endl;
        error_count++;
        return;
    }
    fun->isDef = true;
    if(fun->getType() != "FUNCTION"){
        error<<"Line# "<<line_count<<": '"<<fun->getName()<<"' redeclared as different kind of symbol"<<endl;
        error_count++;
    }
    else if(fun->getRetType() != ret){
        error<<"Line# "<<line_count<<": Conflicting types for '"<<fun->getName()<<"'"<<endl;
        error_count++;
    }
    else if(par==NULL && fun->paramType.size()!=0){
        error<<"Line# "<<line_count<<": Conflicting types for '"<<fun->getName()<<"'"<<endl;
        error_count++;
    }
    else if(par!=NULL && fun->paramType.size() != par->length()){
        error<<"Line# "<<line_count<<": Conflicting types for '"<<fun->getName()<<"'"<<endl;
        error_count++;
    }
    else if(par!=NULL){
        for(int i=0; i<par->length(); i++){
            if(fun->paramType[i] != par->v[i].getType()){
                error<<"Line# "<<line_count<<": Conflicting types for '"<<fun->getName()<<"'"<<endl;
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
}

void checkArguments(SymbolInfo *fun, Symbols* args)
{
    if(fun->paramType.size() > args->length()){
        error<<"Line# "<<line_count<<": Too few arguments to function '"<<fun->getName()<<"'"<<endl;
        error_count++;
    }
    else if(fun->paramType.size() < args->length()){
        error<<"Line# "<<line_count<<": Too many arguments to function '"<<fun->getName()<<"'"<<endl;
        error_count++;
    }
    else{
        for(int i=0; i<fun->paramType.size(); i++){
            if(fun->paramType[i] != args->v[i].getType()){
                error<<"Line# "<<line_count<<": Type mismatch for argument "<<i+1<<" of '"<<fun->getName()<<"'"<<endl;
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
		logout<<"start : program "<<endl;
        $$ = new SymbolInfo("", "");
        $$->nodeName = "start : program";
        $$->isLeaf = false;
        $$->start = $1->start;
        $$->end = $1->end;
        $$->children.push_back($1);
        TreeHelp help;
        help.printTree(tree, $$, 0);
        help.deleteTree($$);
	}
	;

program : program unit 
                        {
                            logout<<"program : program unit "<<endl;
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
                    logout<<"program : unit "<<endl;
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
                            logout<<"unit : var_declaration "<<endl;
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "unit : var_declaration";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
     | func_declaration
                        {
                            logout<<"unit : func_declaration "<<endl;
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "unit : func_declaration";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
     | func_definition
                        {
                            logout<<"unit : func_definition "<<endl;
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
                                                                                logout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "<<endl;
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
                                                        logout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;
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
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {defineFunction($2, $1->getType(), $4);functionReturn=$1->getType();} compound_statement
                                                                                    {
                                                                                        logout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl; 
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
                                                                                    }
		| type_specifier ID LPAREN RPAREN {defineFunction($2, $1->getType());functionReturn=$1->getType();} compound_statement
                                                            {
                                                                logout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl;
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
                                                            }
        | type_specifier ID LPAREN error RPAREN compound_statement
                                                                    {
                                                                        error<<"Line# "<<error_line<<": Syntax error at parameter list of function definition"<<endl;
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
                                                                logout<<"parameter_list : parameter_list COMMA type_specifier ID "<<endl;
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
                                                    logout<<"parameter_list : parameter_list COMMA type_specifier "<<endl;
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
                                logout<<"parameter_list : type_specifier ID "<<endl;
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
                                logout<<"parameter_list : type_specifier "<<endl;
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
                                                                        logout<<"compound_statement : LCURL statements RCURL "<<endl;
                                                                        table->printAll(logout);
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
                                                        logout<<"compound_statement : LCURL RCURL "<<endl;
                                                        table->printAll(logout);
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
                                                                    logout<<"var_declaration : type_specifier declaration_list SEMICOLON "<<endl;
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
                                            error<<"Line# "<<error_line<<": Syntax error at declaration list of variable declaration"<<endl;
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
                            logout<<"type_specifier : INT "<<endl;
                            $$ = new SymbolInfo("", "INT");
                            $$->nodeName = "type_specifier : INT";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
 		| FLOAT
                    {
                        logout<<"type_specifier : FLOAT "<<endl;
                        $$ = new SymbolInfo("", "FLOAT");
                        $$->nodeName = "type_specifier : FLOAT";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $1->end;
                        $$->children.push_back($1);
                    }
 		| VOID
                    {
                        logout<<"type_specifier : VOID "<<endl;
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
                                                    logout<<"declaration_list : declaration_list COMMA ID "<<endl;
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
                                                                        logout<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<<endl;
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
                    logout<<"declaration_list : ID "<<endl;
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
                                                logout<<"declaration_list : ID LSQUARE CONST_INT RSQUARE "<<endl;
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
                            logout<<"statements : statement "<<endl;
                            $$ = new SymbolInfo("", "");
                            $$->nodeName = "statements : statement";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
	   | statements statement
                        {
                            logout<<"statements : statements statement "<<endl;
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
                                logout<<"statement : var_declaration "<<endl;
                                $$ = new SymbolInfo("", "");
                                $$->nodeName = "statement : var_declaration";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
	  | expression_statement
                            {
                                logout<<"statement : expression_statement "<<endl;
                                $$ = new SymbolInfo("", "");
                                $$->nodeName = "statement : expression_statement";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
	  | compound_statement
                            {
                                logout<<"statement : compound_statement "<<endl;
                                $$ = new SymbolInfo("", "");
                                $$->nodeName = "statement : compound_statement";
                                $$->isLeaf = false;
                                $$->start = $1->start;
                                $$->end = $1->end;
                                $$->children.push_back($1);
                            }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement
                                                                                        {
                                                                                            logout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl;
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
                                                                        logout<<"statement : IF LPAREN expression RPAREN statement "<<endl;
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
                                                                logout<<"statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl;
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
                                                    logout<<"statement : WHILE LPAREN expression RPAREN statement "<<endl;
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
                                                logout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl;
                                                if(!table->lookUp($3->getName())){
                                                    error<<"Line# "<<line_count<<": Undeclared variable '"<<$3->getName()<<"'"<<endl;
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
                                        logout<<"statement : RETURN expression SEMICOLON "<<endl;
                                        if(functionReturn == "VOID"){
                                            error<<"Line# "<<line_count<<": Void function cannot return anything"<<endl;
                                            error_count++;
                                        }
                                        else if(functionReturn=="INT" && $2->getType()=="FLOAT"){
                                            error<<"Line# "<<line_count<<": Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
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
                                        logout<<"expression_statement : SEMICOLON "<<endl;
                                        $$ = new SymbolInfo("", "");
                                        $$->nodeName = "expression_statement : SEMICOLON";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $1->end;
                                        $$->children.push_back($1);
                                    }
			| expression SEMICOLON
                                    {
                                        logout<<"expression_statement : expression SEMICOLON "<<endl;
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
                                    error<<"Line# "<<error_line<<": Syntax error at expression of expression statement"<<endl;
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
                logout<<"variable : ID "<<endl;
                $$ = new SymbolInfo("", "");
                SymbolInfo *sim = table->lookUp($1->getName());
                if(sim==NULL){
                    error<<"Line# "<<line_count<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
                    error_count++;
                    $$->setType("ERROR");
                }
                else if(sim->getType()=="FUNCTION"){
                    error<<"Line# "<<line_count<<": "<<$1->getName()<<" is a function"<<endl;
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
                                        logout<<"variable : ID LSQUARE expression RSQUARE "<<endl;
                                        $$ = new SymbolInfo("", "");
                                        SymbolInfo *sim = table->lookUp($1->getName());
                                        if(sim==NULL){
                                            error<<"Line# "<<line_count<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
                                            error_count++;
                                            $$->setType("ERROR");
                                        }
                                        else if(sim->getType()=="ARRAY"){
                                            $$->setType(sim->getRetType());
                                            if($3->getType()!="INT"){
                                                error<<"Line# "<<line_count<<": Array subscript is not an integer"<<endl;
                                                error_count++;
                                            }
                                        }
                                        else{
                                            error<<"Line# "<<line_count<<": '"<<$1->getName()<<"' is not an array"<<endl;
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
                                    logout<<"expression : logic_expression "<<endl;
                                    $$ = new SymbolInfo($1->getName(), $1->getType());
                                    $$->nodeName = "expression : logic_expression";
                                    $$->isLeaf = false;
                                    $$->start = $1->start;
                                    $$->end = $1->end;
                                    $$->children.push_back($1);
                                }
	   | variable ASSIGNOP logic_expression 	
                                            {
                                                logout<<"expression : variable ASSIGNOP logic_expression "<<endl;
                                                if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                    error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
                                                    error_count++;
                                                    $$ = new SymbolInfo("", "ERROR");
                                                }
                                                else if($1->getType()=="INT" && $3->getType()=="FLOAT"){
                                                    error<<"Line# "<<line_count<<": Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
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
                                    logout<<"logic_expression : rel_expression "<<endl;
                                    $$ = new SymbolInfo($1->getName(), $1->getType());
                                    $$->nodeName = "logic_expression : rel_expression";
                                    $$->isLeaf = false;
                                    $$->start = $1->start;
                                    $$->end = $1->end;
                                    $$->children.push_back($1);
                                }
		 | rel_expression LOGICOP rel_expression 
                                                {
                                                    logout<<"logic_expression : rel_expression LOGICOP rel_expression"<<endl;
                                                    if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                        error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                                        logout<<"rel_expression : simple_expression "<<endl;
                                        $$ = new SymbolInfo($1->getName(), $1->getType());
                                        $$->nodeName = "rel_expression : simple_expression";
                                        $$->isLeaf = false;
                                        $$->start = $1->start;
                                        $$->end = $1->end;
                                        $$->children.push_back($1);
                                    }
		| simple_expression RELOP simple_expression	
                                                    {
                                                        logout<<"rel_expression : simple_expression RELOP simple_expression "<<endl;
                                                        if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                            error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                            logout<<"simple_expression : term "<<endl;
                            $$ = new SymbolInfo($1->getName(), $1->getType());
                            $$->nodeName = "simple_expression : term";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
		  | simple_expression ADDOP term 
                                        {
                                            logout<<"simple_expression : simple_expression ADDOP term "<<endl;
                                            if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                                error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                            logout<<"term : unary_expression "<<endl;
                            $$ = new SymbolInfo($1->getName(), $1->getType());
                            $$->nodeName = "term : unary_expression";
                            $$->isLeaf = false;
                            $$->start = $1->start;
                            $$->end = $1->end;
                            $$->children.push_back($1);
                        }
     |  term MULOP unary_expression
                                    {
                                        logout<<"term : term MULOP unary_expression "<<endl;
                                        if($1->getType()=="VOID" || $3->getType()=="VOID"){
                                            error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        else if(($2->getName()=="%" || $2->getName()=="/") && $3->getName()=="0"){
                                            error<<"Line# "<<line_count<<": Warning: division by zero i=0f=1Const=0"<<endl;
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }    
                                        else if($2->getName()=="%" && ($1->getType()=="FLOAT" || $3->getType()=="FLOAT")){
                                            error<<"Line# "<<line_count<<": Operands of modulus must be integers"<<endl;
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
                                                logout<<"unary_expression : ADDOP unary_expression "<<endl;
                                                if($2->getType()=="VOID"){
                                                    error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                                    logout<<"unary_expression : NOT unary_expression "<<endl;
                                    if($2->getType()=="VOID"){
                                        error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                    logout<<"unary_expression : factor "<<endl;
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
                        logout<<"factor : variable "<<endl;
                        $$ = new SymbolInfo($1->getName(), $1->getType());
                        $$->nodeName = "factor : variable";
                        $$->isLeaf = false;
                        $$->start = $1->start;
                        $$->end = $1->end;
                        $$->children.push_back($1); 
                    }
	| ID LPAREN argument_list RPAREN
                                    {
                                        logout<<"factor : ID LPAREN argument_list RPAREN "<<endl;
                                        SymbolInfo *fun = table->lookUp($1->getName());
                                        if(fun==NULL){
                                            error<<"Line# "<<line_count<<": Undeclared function '"<<$1->getName()<<"'"<<endl;
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        else if(fun->getType()!="FUNCTION"){
                                            error<<"Line# "<<line_count<<": '"<<$1->getName()<<"'' is not a function"<<endl;
                                            error_count++;
                                            $$ = new SymbolInfo("", "ERROR");
                                        }
                                        // else if(fun->isDef==false){
                                        //     error<<"Line# "<<line_count<<": Undefined function '"<<$1->getName()<<"'"<<endl;
                                        //     error_count++;
                                        //     $$ = new SymbolInfo("", fun->getRetType());
                                        // }
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
                                    logout<<"factor : LPAREN expression RPAREN "<<endl;
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
                    logout<<"factor : CONST_INT "<<endl;
                    $$ = new SymbolInfo($1->getName(), "INT");
                    $$->nodeName = "factor : CONST_INT";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                } 
	| CONST_FLOAT
                {
                    logout<<"factor : CONST_FLOAT "<<endl;
                    $$ = new SymbolInfo($1->getName(), "FLOAT");
                    $$->nodeName = "factor : CONST_FLOAT";
                    $$->isLeaf = false;
                    $$->start = $1->start;
                    $$->end = $1->end;
                    $$->children.push_back($1);
                }
	| variable INCOP 
                    {
                        logout<<"factor : variable INCOP "<<endl;
                        if($1->getType()=="VOID"){
                            error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                        logout<<"factor : variable DECOP "<<endl;
                        if($1->getType()=="VOID"){
                            error<<"Line# "<<line_count<<": Void cannot be used in expression"<<endl;
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
                            logout<<"argument_list : arguments "<<endl;
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
                    logout<<"argument_list : "<<endl;
                    $$ = new Symbols();
                    $$->nodeName = "argument_list : ";
                    $$->isLeaf = false;
                    $$->start = line_count;
                    $$->end = line_count;
              }
			  ;
	
arguments : arguments COMMA logic_expression
                                            {
                                                logout<<"arguments : arguments COMMA logic_expression "<<endl;
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
                                logout<<"arguments : logic_expression "<<endl;
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
	
	paras = NULL;

	logout.open("log.txt");
	error.open("error.txt");
	tree.open("parsetree.txt");
	
	table = new SymbolTable(11);

	yyin=fp;
	yyparse();
	
	logout<<"Total Lines: "<<line_count<<endl;
	logout<<"Total Errors: "<<error_count<<endl;

	logout.close();
	error.close();
	tree.close();
	delete table;
	
	return 0;
}

