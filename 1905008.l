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
            SymbolInfo *si = new SymbolInfo(yytext, "IF");
            si->nodeName = "IF : if";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return IF;
		}
		
"else"	{
            SymbolInfo *si = new SymbolInfo(yytext, "ELSE");
            si->nodeName = "ELSE : else";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return ELSE;
		}
		
"for"	{
            SymbolInfo *si = new SymbolInfo(yytext, "FOR");
            si->nodeName = "FOR : for";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return FOR;
		}
		
"while"	{
            SymbolInfo *si = new SymbolInfo(yytext, "WHILE");
            si->nodeName = "WHILE : while";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return WHILE;
		}
		
"do"	{
            SymbolInfo *si = new SymbolInfo(yytext, "DO");
            si->nodeName = "DO : do";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return DO;
		}
		
"break"	{
            SymbolInfo *si = new SymbolInfo(yytext, "BREAK");
            si->nodeName = "BREAK : break";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return BREAK;
		}
		
"int"	{
            SymbolInfo *si = new SymbolInfo(yytext, "INT");
            si->nodeName = "INT : int";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return INT;
		}
		
"char"	{
            SymbolInfo *si = new SymbolInfo(yytext, "CHAR");
            si->nodeName = "CHAR : char";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return CHAR;
		}
		
"float"	{
            SymbolInfo *si = new SymbolInfo(yytext, "FLOAT");
            si->nodeName = "FLOAT : float";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return FLOAT;
		}
		
"double" {
            SymbolInfo *si = new SymbolInfo(yytext, "DOUBLE");
            si->nodeName = "DOUBLE : double";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return DOUBLE;
		 }
		 
"void"	{
            SymbolInfo *si = new SymbolInfo(yytext, "VOID");
            si->nodeName = "VOID : void";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return VOID;
		}
		
"return"	{
                SymbolInfo *si = new SymbolInfo(yytext, "RETURN");
                si->nodeName = "RETURN : return";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return RETURN;
		    }
		    
"switch"	{
                SymbolInfo *si = new SymbolInfo(yytext, "SWITCH");
                si->nodeName = "SWITCH : switch";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return SWITCH;
            }
            
"case"	{
            SymbolInfo *si = new SymbolInfo(yytext, "CASE");
            si->nodeName = "CASE : case";
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
			return CASE;
		}
		
"default"	{
                SymbolInfo *si = new SymbolInfo(yytext, "DEFAULT");
                si->nodeName = "DEFAULT : default";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return DEFAULT;
            }
		
"continue"	{
                SymbolInfo *si = new SymbolInfo(yytext, "CONTINUE");
                si->nodeName = "CONTINUE : continue";
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return CONTINUE;
            }

"println"   {
                SymbolInfo *si = new SymbolInfo(yytext, "PRINTLN");
                si->nodeName = (string)"PRINTLN : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
                yylval.si = si;
                return PRINTLN;
            }              		
            
{DIGIT}+ 	{
				SymbolInfo *si = new SymbolInfo(yytext, "CONST_INT");
                si->nodeName = (string)"CONST_INT : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return CONST_INT;
			}
			
{FLOAT}     {
				SymbolInfo *si = new SymbolInfo(yytext, "CONST_FLOAT");
                si->nodeName = (string)"CONST_FLOAT : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return CONST_FLOAT;
            }
            
{REDP}  {
            error_count++;
        }
        
{ILLNUM}    {
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
				SymbolInfo *si = new SymbolInfo(s, "CONST_CHAR");
                si->nodeName = (string)"CONST_CHAR : "+s;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return CONST_CHAR;
            }
            
\'\'    {
            error_count++;
        }
        
\'[^ \t\r\f\v\n]?   {
                        error_count++;
                    }
                    
\'\\\'  {
            error_count++;
        }    
        
\'[^\n]+\'  {
                error_count++;
            }
            
"+"|"-" {
            SymbolInfo *si = new SymbolInfo(yytext, "ADDOP");
            si->nodeName = (string)"ADDOP : "+yytext;
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
            return ADDOP;
        }
        
"*"|"/"|"%" {
				SymbolInfo *si = new SymbolInfo(yytext, "MULOP");
                si->nodeName = (string)"MULOP : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return MULOP;
            }
            
"++"    {
				SymbolInfo *si = new SymbolInfo(yytext, "INCOP");
                si->nodeName = (string)"INCOP : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return INCOP;
        }

"--"    {
            SymbolInfo *si = new SymbolInfo(yytext, "DECOP");
            si->nodeName = (string)"DECOP : "+yytext;
            si->isLeaf = true;
            si->start = line_count;
            si->end = line_count;
            yylval.si = si;
            return DECOP;
        }          
          
"<"|"<="|">"|">="|"=="|"!=" {
                                SymbolInfo *si = new SymbolInfo(yytext, "RELOP");
                                si->nodeName = (string)"RELOP : "+yytext;
                                si->isLeaf = true;
                                si->start = line_count;
                                si->end = line_count;
                                yylval.si = si;
                                return RELOP;
                            }
                            
"=" {
        SymbolInfo *si = new SymbolInfo(yytext, "ASSIGNOP");
        si->nodeName = (string)"ASSIGNOP : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return ASSIGNOP;
    }
    
"&&"|"||" {
				SymbolInfo *si = new SymbolInfo(yytext, "LOGICOP");
                si->nodeName = (string)"LOGICOP : "+yytext;
                si->isLeaf = true;
                si->start = line_count;
                si->end = line_count;
				yylval.si = si;
				return LOGICOP;
          }  

"&"|"|"|"^"|"<<"|">>" {
                            SymbolInfo *si = new SymbolInfo(yytext, "BITOP");
                            si->nodeName = (string)"BITOP : "+yytext;
                            si->isLeaf = true;
                            si->start = line_count;
                            si->end = line_count;
                            yylval.si = si;
                            return BITOP;
                      }
                      
"!" {
        SymbolInfo *si = new SymbolInfo(yytext, "NOT");
        si->nodeName = (string)"NOT : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return NOT;
    }
    
"(" {
        SymbolInfo *si = new SymbolInfo(yytext, "LPAREN");
        si->nodeName = (string)"LPAREN : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return LPAREN;
    }
    
")" {
        SymbolInfo *si = new SymbolInfo(yytext, "RPAREN");
        si->nodeName = (string)"RPAREN : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return RPAREN;
    }
    
"{" {
        SymbolInfo *si = new SymbolInfo(yytext, "LCURL");
        si->nodeName = (string)"LCURL : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return LCURL;
    }
    
"}" {
        SymbolInfo *si = new SymbolInfo(yytext, "RCURL");
        si->nodeName = (string)"RCURL : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return RCURL;
    }    

"[" {
        SymbolInfo *si = new SymbolInfo(yytext, "LSQUARE");
        si->nodeName = (string)"LSQUARE : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return LSQUARE;
    }
    
"]" {
        SymbolInfo *si = new SymbolInfo(yytext, "RSQUARE");
        si->nodeName = (string)"RSQUARE : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return RSQUARE;
    }
    
"," {
        SymbolInfo *si = new SymbolInfo(yytext, "COMMA");
        si->nodeName = (string)"COMMA : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return COMMA;
    }
    
";" {
        SymbolInfo *si = new SymbolInfo(yytext, "SEMICOLON");
        si->nodeName = (string)"SEMICOLON : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return SEMICOLON;
    }
    
{ID} {
        SymbolInfo *si = new SymbolInfo(yytext, "ID");
        si->nodeName = (string)"ID : "+yytext;
        si->isLeaf = true;
        si->start = line_count;
        si->end = line_count;
        yylval.si = si;
        return ID;
     }
     
{WID} {
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
                        line_count++;
                        BEGIN(INITIAL);
                    }
                    
<SINGCOM><<EOF>>   {
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
                error_count++;
            }
            else if(flag){
                SymbolInfo *si = new SymbolInfo(stlit, "MULTI_LINE_STRING");
                yylval.si = si;
                return MULTI_LINE_STRING;
            }
            else{
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
            line_count++;
            error_count++;
            BEGIN(INITIAL);
        }
        
<STR><<EOF>> {
                error_count++;
                BEGIN(INITIAL);
             }
                    
<STR>[^\\'"\n]+|.   {
                        stlog.append(yytext);
                        stlit.append(yytext);
                    }      

.   {
        error_count++;
    }

    
%%

