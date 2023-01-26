%option noyywrap
%x SINGCOM
%x MULCOM
%x STR

%{
#include<iostream>
#include<fstream>
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>
#include"1905008.h"
#include"y.tab.h"

using namespace std;

extern YYSTYPE yylval;
extern SymbolTable *table;
void yyerror(char *);
extern ofstream logout;

int line_count=1;
int error_count=0;

// FILE *logout;
// FILE *tokenout;

/*SymbolTable st(10);*/
string singleCom;
string multiCom;
string stlit;
string stlog;
int cnt;
int wesl;
bool flag;
bool wes;

%}

WHITESPACE [ \t\f\r\v]+
LETTER [a-zA-Z]
DIGIT [0-9]
FLOAT {DIGIT}+(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?|{DIGIT}+\.([Ee][+-]?{DIGIT}+)?|\.{DIGIT}+([Ee][+-]?{DIGIT}+)?
CL \'([^'"\\\n\t\r\f\v]|(\\['"ntafrvb0\\]))\'
REDP {DIGIT}*\.{DIGIT}+(\.{DIGIT}*)+([Ee][+-]?{DIGIT}+)?|{DIGIT}\.(\.{DIGIT}*)+([Ee][+-]?{DIGIT}+)?|({DIGIT}*\.)+\.{DIGIT}+([Ee][+-]?{DIGIT}+)?
ILLNUM {FLOAT}(\.{DIGIT}*)+([Ee]|{FLOAT}|{REDP})*|{REDP}(\.{DIGIT}*)+([Ee]|{FLOAT}|{REDP})*
ID ({LETTER}|_)({LETTER}|_|{DIGIT})*
WID {DIGIT}+(\.)?{ID}
NEWLINE \n

%%

{NEWLINE} {line_count++;}

{WHITESPACE} {}

"if"	{
			logout<<"Line# "<<line_count<<": Token <IF> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "IF");
            si->nodeName = "IF : if";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return IF;
		}
		
"else"	{
			logout<<"Line# "<<line_count<<": Token <ELSE> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "ELSE");
            si->nodeName = "ELSE : else";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return ELSE;
		}
		
"for"	{
			logout<<"Line# "<<line_count<<": Token <FOR> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "FOR");
            si->nodeName = "FOR : for";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return FOR;
		}
		
"while"	{
			logout<<"Line# "<<line_count<<": Token <WHILE> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "WHILE");
            si->nodeName = "WHILE : while";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return WHILE;
		}
		
"do"	{
			logout<<"Line# "<<line_count<<": Token <DO> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "DO");
            si->nodeName = "DO : do";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return DO;
		}
		
"break"	{
			logout<<"Line# "<<line_count<<": Token <BREAK> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "BREAK");
            si->nodeName = "BREAK : break";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return BREAK;
		}
		
"int"	{
			logout<<"Line# "<<line_count<<": Token <INT> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "INT");
            si->nodeName = "INT : int";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return INT;
		}
		
"char"	{
			logout<<"Line# "<<line_count<<": Token <CHAR> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "CHAR");
            si->nodeName = "CHAR : char";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return CHAR;
		}
		
"float"	{
			logout<<"Line# "<<line_count<<": Token <FLOAT> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "FLOAT");
            si->nodeName = "FLOAT : float";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return FLOAT;
		}
		
"double" {
			logout<<"Line# "<<line_count<<": Token <DOUBLE> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "DOUBLE");
            si->nodeName = "DOUBLE : double";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return DOUBLE;
		 }
		 
"void"	{
			logout<<"Line# "<<line_count<<": Token <VOID> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "VOID");
            si->nodeName = "VOID : void";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return VOID;
		}
		
"return"	{
                logout<<"Line# "<<line_count<<": Token <RETURN> Lexeme "<<yytext<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(yytext, "RETURN");
                si->nodeName = "RETURN : return";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return RETURN;
		    }
		    
"switch"	{
                logout<<"Line# "<<line_count<<": Token <SWITCH> Lexeme "<<yytext<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(yytext, "SWITCH");
                si->nodeName = "SWITCH : switch";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return SWITCH;
            }
            
"case"	{
			logout<<"Line# "<<line_count<<": Token <CASE> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "CASE");
            si->nodeName = "CASE : case";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return CASE;
		}
		
"default"	{
                logout<<"Line# "<<line_count<<": Token <DEFAULT> Lexeme "<<yytext<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(yytext, "DEFAULT");
                si->nodeName = "DEFAULT : default";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return DEFAULT;
            }
		
"continue"	{
                logout<<"Line# "<<line_count<<": Token <CONTINUE> Lexeme "<<yytext<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(yytext, "CONTINUE");
                si->nodeName = "CONTINUE : continue";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return CONTINUE;
            }

"println"   {
                logout<<"Line# "<<line_count<<": Token <PRINTLN> Lexeme "<<yytext<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(yytext, "PRINTLN");
                si->nodeName = (string)"PRINTLN : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return PRINTLN;
            }              		
            
{DIGIT}+ 	{
                logout<<"Line# "<<line_count<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				SymbolInfo *si = new SymbolInfo(yytext, "CONST_INT");
                si->nodeName = (string)"CONST_INT : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return CONST_INT;
			}
			
{FLOAT}     {
                logout<<"Line# "<<line_count<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
				SymbolInfo *si = new SymbolInfo(yytext, "CONST_FLOAT");
                si->nodeName = (string)"CONST_FLOAT : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return CONST_FLOAT;
            }
            
{REDP}  {
            logout<<"Error at line# "<<line_count<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
            error_count++;
        }
        
{ILLNUM}    {
                logout<<"Error at line# "<<line_count<<": ILLFORMED_NUMBER "<<yytext<<endl;
                error_count++;
            }
            
{CL}        {
                char ch;
                if(yytext[1] == '\\'){
                    switch(yytext[2]){
                        case '\\' :
                            ch = 92;
                            break;
                        case '\'' :
                            ch = 39;
                            break;
                        case '\"' :
                            ch = 34;
                            break;
                        case 'n' :
                            ch = 10;
                            break;
                        case 't' :
                            ch = 9;
                            break;
                        case 'a' :
                            ch = 7;
                            break;
                        case 'f' :
                            ch = 12;
                            break;
                        case 'r' :
                            ch = 13;
                            break;
                        case 'b' :
                            ch = 8;
                            break;
                        case 'v' :
                            ch = 11;
                            break;
                        case '0' :
                            ch = 0;
                    }
                    }
                    else{
                        ch = yytext[1];
                }
                string s = "";
                s += ch;
                logout<<"Line# "<<line_count<<": Token <CONST_CHAR> Lexeme "<<s<<" found"<<endl;
				SymbolInfo *si = new SymbolInfo(s, "CONST_CHAR");
                si->nodeName = (string)"CONST_CHAR : "+s;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return CONST_CHAR;
            }
            
\'\'    {
            logout<<"Error at line# "<<line_count<<": EMPTY_CONST_CHAR "<<yytext<<endl;
            error_count++;
        }
        
\'[^ \t\r\f\v\n]?   {
                        logout<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
                        error_count++;
                    }
                    
\'\\\'  {
            logout<<"Error at line# "<<line_count<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
            error_count++;
        }    
        
\'[^\n]+\'  {
                logout<<"Error at line# "<<line_count<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
                error_count++;
            }
            
"+"|"-" {
            logout<<"Line# "<<line_count<<": Token <ADDOP> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "ADDOP");
            si->nodeName = (string)"ADDOP : "+yytext;
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
            return ADDOP;
        }
        
"*"|"/"|"%" {
                logout<<"Line# "<<line_count<<": Token <MULOP> Lexeme "<<yytext<<" found"<<endl;
				SymbolInfo *si = new SymbolInfo(yytext, "MULOP");
                si->nodeName = (string)"MULOP : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return MULOP;
            }
            
"++"    {
                logout<<"Line# "<<line_count<<": Token <INCOP> Lexeme "<<yytext<<" found"<<endl;
				SymbolInfo *si = new SymbolInfo(yytext, "INCOP");
                si->nodeName = (string)"INCOP : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return INCOP;
        }

"--"    {
            logout<<"Line# "<<line_count<<": Token <DECOP> Lexeme "<<yytext<<" found"<<endl;
            SymbolInfo *si = new SymbolInfo(yytext, "DECOP");
            si->nodeName = (string)"DECOP : "+yytext;
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
            return DECOP;
        }          
          
"<"|"<="|">"|">="|"=="|"!=" {
                                logout<<"Line# "<<line_count<<": Token <RELOP> Lexeme "<<yytext<<" found"<<endl;
                                SymbolInfo *si = new SymbolInfo(yytext, "RELOP");
                                si->nodeName = (string)"RELOP : "+yytext;
                                si->isLeaf = true;
                                si->start = line_count;
                                si->end = line_count;
                                yylval.si = si;
                                return RELOP;
                            }
                            
"=" {
        logout<<"Line# "<<line_count<<": Token <ASSIGNOP> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "ASSIGNOP");
        si->nodeName = (string)"ASSIGNOP : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return ASSIGNOP;
    }
    
"&&"|"||" {
                logout<<"Line# "<<line_count<<": Token <LOGICOP> Lexeme "<<yytext<<" found"<<endl;
				SymbolInfo *si = new SymbolInfo(yytext, "LOGICOP");
                si->nodeName = (string)"LOGICOP : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return LOGICOP;
          }  

"&"|"|"|"^"|"<<"|">>" {
                            logout<<"Line# "<<line_count<<": Token <BITOP> Lexeme "<<yytext<<" found"<<endl;
                            SymbolInfo *si = new SymbolInfo(yytext, "BITOP");
                            si->nodeName = (string)"BITOP : "+yytext;
                            si->isLeaf = true;
                            si->start = line_count;
                            si->end = line_count;
                            yylval.si = si;
                            return BITOP;
                      }
                      
"!" {
        logout<<"Line# "<<line_count<<": Token <NOT> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "NOT");
        si->nodeName = (string)"NOT : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return NOT;
    }
    
"(" {
        logout<<"Line# "<<line_count<<": Token <LPAREN> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "LPAREN");
        si->nodeName = (string)"LPAREN : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return LPAREN;
    }
    
")" {
        logout<<"Line# "<<line_count<<": Token <RPAREN> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "RPAREN");
        si->nodeName = (string)"RPAREN : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return RPAREN;
    }
    
"{" {
        logout<<"Line# "<<line_count<<": Token <LCURL> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "LCURL");
        si->nodeName = (string)"LCURL : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return LCURL;
    }
    
"}" {
        logout<<"Line# "<<line_count<<": Token <RCURL> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "RCURL");
        si->nodeName = (string)"RCURL : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return RCURL;
    }    

"[" {
        logout<<"Line# "<<line_count<<": Token <LSQUARE> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "LSQUARE");
        si->nodeName = (string)"LSQUARE : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return LSQUARE;
    }
    
"]" {
        logout<<"Line# "<<line_count<<": Token <RSQUARE> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "RSQUARE");
        si->nodeName = (string)"RSQUARE : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return RSQUARE;
    }
    
"," {
        logout<<"Line# "<<line_count<<": Token <COMMA> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "COMMA");
        si->nodeName = (string)"COMMA : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return COMMA;
    }
    
";" {
        logout<<"Line# "<<line_count<<": Token <SEMICOLON> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "SEMICOLON");
        si->nodeName = (string)"SEMICOLON : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return SEMICOLON;
    }
    
{ID} {
        logout<<"Line# "<<line_count<<": Token <ID> Lexeme "<<yytext<<" found"<<endl;
        SymbolInfo *si = new SymbolInfo(yytext, "ID");
        si->nodeName = (string)"ID : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return ID;
     }
     
{WID} {
            logout<<"Error at line# "<<line_count<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
            error_count++;
      }
     
"//" {
        BEGIN(SINGCOM);
        singleCom = "//";
        cnt = line_count;
     }
   
<SINGCOM>\\\n           {
                                singleCom.append(yytext);
                                line_count++;
                            }
                            
<SINGCOM>\n      {
                        logout<<"Line# "<<cnt<<": Token <SINGLE LINE COMMENT> Lexeme "<<singleCom<<" found"<<endl;
                        line_count++;
                        BEGIN(INITIAL);
                    }
                    
<SINGCOM><<EOF>>   {
                        logout<<"Line# "<<cnt<<": Token <SINGLE LINE COMMENT> Lexeme "<<singleCom<<" found"<<endl;
                        BEGIN(INITIAL);
                    }                     
   
<SINGCOM>[^\\\n]+|.           {
                                    singleCom.append(yytext);
                                }
                            
"/*" {
        BEGIN(MULCOM);
        multiCom = "/*";
        cnt = line_count;
     }
  
<MULCOM>"*/"    {
                    multiCom.append(yytext);
                    logout<<"Line# "<<cnt<<": Token <MULTI LINE COMMENT> Lexeme "<<multiCom<<" found"<<endl;
                    BEGIN(INITIAL);
                }
                
<MULCOM>\n         {
                        multiCom.append(yytext);
                        line_count++;
                    }
                    
<MULCOM>[^*\n]+|.    {
                                multiCom.append(yytext);
                    }
                    
<MULCOM><<EOF>>  {
                    logout<<"Error at line# "<<line_count<<": UNFINISHED_COMMENT "<<multiCom<<endl;
                    error_count++;
                    BEGIN(INITIAL);
                 }
                            
\"  {
        BEGIN(STR);
        cnt = line_count;
        stlog = "";
        stlit = "";
        flag = false;
        wes = false;
        stlog.append(yytext);
    }
    
<STR>\" {
            stlog.append(yytext);
            if(wes){
                logout<<"Error at line# "<<wesl<<" UNRECOGNIZED_ESCAPE_SEQUENCE "<<stlog<<endl;
                error_count++;
            }
            else if(flag){
                logout<<"Line# "<<cnt<<": Token <MULTI LINE STRING> Lexeme "<<stlog<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(stlit, "MULTI_LINE_STRING");
                yylval.si = si;
                return MULTI_LINE_STRING;
            }
            else{
                logout<<"Line# "<<cnt<<": Token <SINGLE LINE STRING> Lexeme "<<stlog<<" found"<<endl;
                SymbolInfo *si = new SymbolInfo(stlit, "SINGLE_LINE_STRING");
                yylval.si = si;
                return SINGLE_LINE_STRING;
            }
            BEGIN(INITIAL);
        }
        
<STR>\\['"ntafrvb0\\] {
                            stlog.append(yytext);
                            char ch;
                            switch(yytext[1]){
                                case '\\' :
                                    ch = 92;
                                    break;
                                case '\'' :
                                    ch = 39;
                                    break;
                                case '\"' :
                                    ch = 34;
                                    break;
                                case 'n' :
                                    ch = 10;
                                    break;
                                case 't' :
                                    ch = 9;
                                    break;
                                case 'a' :
                                    ch = 7;
                                    break;
                                case 'f' :
                                    ch = 12;
                                    break;
                                case 'r' :
                                    ch = 13;
                                    break;
                                case 'b' :
                                    ch = 8;
                                    break;
                                case 'v' :
                                    ch = 11;
                                    break;
                                case '0' :
                                    ch = 0;
                            }
                            stlit += ch;
                    }
                    
<STR>\\\n       {
                        stlog.append(yytext);
                        line_count++;
                        flag = true;
                    }
                    
<STR>\\|\\[^'"ntafrvb0\\\n]   {
                                    stlog.append(yytext);
                                    wes = true;  
                                    wesl = line_count;
                              }
                    
<STR>\n {
            logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<stlog<<endl;
            line_count++;
            error_count++;
            BEGIN(INITIAL);
        }
        
<STR><<EOF>> {
                logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<stlog<<endl;
                error_count++;
                BEGIN(INITIAL);
             }
                    
<STR>[^\\'"\n]+|.   {
                        stlog.append(yytext);
                        stlit.append(yytext);
                    }      

.   {
        logout<<"Error at line# "<<line_count<<": UNRECOGNIZED CHAR "<<yytext<<endl;
        error_count++;
    }

    
%%

