//---------------------------------------------------------------------------

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <vcl.h>
#include <math.h>
#include <windows.h>
#include <IniFiles.hpp>
#include "global.h"
#include <cctype>


#include <algorithm>
#pragma hdrstop

#include "sim.h"
#include "class.cpp"
#include "bookmark.h"
#include "options.h"
#include "find.h"
#include "unit_prompt.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "CGAUGES"
#pragma link "trayicon"
#pragma link "CGRID"
#pragma link "PERFGRAP"
#pragma link "SHDocVw_OCX"
#pragma resource "*.dfm"
Tfmain *fmain;


#define ID_LEN 64
#define NBR_ROMS 15
#define TOTAL_CONTROL_BITS NBR_ROMS * 8
#define CYCLES_PER_INSTR 64
#define NBR_INSTRUCTIONS 256
#define TOTAL_CYCLES CYCLES_PER_INSTR * NBR_INSTRUCTIONS
#define STRING_LEN 256
#define INFO_LEN 256

#define PROMPT_LEN 128 * 1024

typedef enum {
	NOTOK, DIRECTIVE, INCLUDE,
	
	_VOID, _CHAR, _INT, _FLOAT, _DOUBLE,
	_SHORT, _LONG, _SIGNED, _UNSIGNED,
	
	STRUCT,	ENUM,
	
	IF, THEN, ELSE, FOR, DO, WHILE, BREAK, CONTINUE, SWITCH, CASE, DEFAULT, RETURN, _CONST,
	SIZEOF,
	
	PLUS, MINUS, ASTERISK, DIVISION, INCREMENT, DECREMENT, MOD, DOT, ARROW,
	
	EQUAL, NOT_EQUAL, LESS_THAN, LESS_THAN_OR_EQUAL, GREATER_THAN, GREATER_THAN_OR_EQUAL,
	LOGICAL_AND, LOGICAL_OR, LOGICAL_NOT,
	ATTRIBUTION,
	
	BITWISE_AND, BITWISE_OR, BITWISE_NOT, BITWISE_SL, BITWISE_SR, POINTER_REF,
	
	OPENING_PAREN, CLOSING_PAREN,
	OPENING_BRACE, CLOSING_BRACE,
	OPENING_BRACKET, CLOSING_BRACKET,

	SEMICOLON, COMMA,
	
	SYSTEM
} _ATOM; // internal token representation
_ATOM tok;

typedef enum {
	DELIMITER = 1,
	CHAR_CONST, STRING_CONST, INTEGER_CONST, FLOAT_CONST, DOUBLE_CONST,
	IDENTIFIER, RESERVED, END
} _ATOM_TYPE;
_ATOM_TYPE token_type;

typedef enum {
	DT_VOID = 1, DT_CHAR, DT_INT, DT_FLOAT, DT_DOUBLE, DT_STRUCT
} _BASIC_DATA;

struct _keyword_table{
	char *keyword;
	_ATOM key;
} keyword_table[] = {
	"void", _VOID,
	"char", _CHAR,
	"int", _INT,
	"float", _FLOAT,
	"double", _DOUBLE,
	"const", _CONST,
	"enum", ENUM,
	"struct", STRUCT,
	"sizeof", SIZEOF,
	"return", RETURN,
	"if", IF,
	"then", THEN,
	"else", ELSE,
	"for", FOR,
	"do", DO,
	"break", BREAK,
	"continue", CONTINUE,
	"while", WHILE,
	"switch", SWITCH,
	"case", CASE,
	"default", DEFAULT,
	"include", INCLUDE,
	"system", SYSTEM,
	"", NOTOK
};


typedef enum {
	SYNTAX,
	OPENING_PAREN_EXPECTED, 
	CLOSING_PAREN_EXPECTED,
	OPENING_BRACE_EXPECTED,
	CLOSING_BRACE_EXPECTED,
	OPENING_BRACKET_EXPECTED,
	CLOSING_BRACKET_EXPECTED,
	COMMA_EXPECTED,
	SEMICOLON_EXPECTED,
	VAR_TYPE_EXPECTED,
	IDENTIFIER_EXPECTED,
	EXCEEDED_GLOBAL_VAR_LIMIT,
	EXCEEDED_FUNC_DECL_LIMIT,
	NOT_VAR_OR_FUNC_OUTSIDE,
	NO_MAIN_FOUND,
	UNDECLARED_FUNC,
	SINGLE_QUOTE_EXPECTED,
	DOUBLE_QUOTE_EXPECTED,
	UNDECLARED_VARIABLE,
	MAX_PARAMS_LIMIT_REACHED,
	USER_FUNC_CALLS_LIMIT_REACHED,
	LOCAL_VAR_LIMIT_REACHED,
	RETURNING_VALUE_FROM_VOID_FUNCTION,
	INVALID_EXPRESSION,
	INVALID_ARGUMENT_FOR_BITWISE_NOT,
	WHILE_KEYWORD_EXPECTED,
	DUPLICATE_GLOBAL_VARIABLE,
	DUPLICATE_LOCAL_VARIABLE,
	STRING_CONSTANT_EXPECTED,
	POINTER_EXPECTED,
	INSUFFICIENT_ARGUMENTS,
	POINTER_SYNTAX,
	TOO_MANY_MATRIX_DIMENSIONS,
	INVALID_MATRIX_DIMENSION,
	MEMORY_ALLOCATION_FAILURE,
	MATRIX_INDEX_OUTSIDE_BOUNDS,
	INVALID_MATRIX_ATTRIBUTION,
	MATRIX_EXPECTED,
	UNKOWN_LIBRARY,
	UNKNOWN_DIRECTIVE,
	DIRECTIVE_SYNTAX,
	INCOMPATIBLE_FUNCTION_ARGUMENT,
	CONSTANT_VARIABLE_ASSIGNMENT,
	INVALID_BINARY_OPERANDS,
	STRUCT_EXPECTED,
	STRUCT_NAME_EXPECTED,
	UNDECLARED_STRUCT,
	INVALID_PRINTF_FORMAT_CODE,
	INCLUDE_FILE_NOT_FOUND,
	EXTENSION_EXPECTED
} _ERROR;

char *error_table[] = {
	"syntax error",
	"syntax error: opening parenthesis expected",
	"syntax error: closing parenthesis expected",
	"syntax error: opening brace expected",
	"syntax error: closing brace expected",
	"syntax error: opening bracket expected",
	"syntax error: closing bracket expected",
	"syntax error: comma expected",
	"syntax error: semicolon expected",
	"syntax error: variable type expected in the declaration",
	"syntax error: identifier expected",
	"global variable limit reached (max = 100)",
	"function declaration limit reached (max = 100)",
	"syntax error: only variable and function declarations are allowed outside of functions",
	"main funtion not found",
	"undeclared function",
	"syntax error: single quote expected",
	"syntax error: double quotes expected",
	"undeclared variable or unkown constant",
	"maximum number of function paramters reached (max = 10)",
	"maximum number of program-defined function calls reached (max = 100)",
	"local variables limit reached (max = 200)",
	"returning value from void function",
	"invalid expression",
	"invalid argument for the bitwise not operation",
	"while part of do-while loop expected",
	"duplicate global variable declared",
	"duplicate local variable declared",
	"string constant expected",
	"pointer expected",
	"insufficient function arguments",
	"pointer syntax error",
	"declared matrix exceeds the maximum number of dimensions (max = 10)",
	"invalid matrix dimension",
	"memory allocation failure",
	"matrix index outside bounds",
	"invalid matrix attribution",
	"matrix expected",
	"unkown library",
	"unknown directive",
	"directive syntax error",
	"incompatible function argument",
	"constant variable assignment",
	"invalid binary operands",
	"struct expected",
	"struct name expected but token is not an identifier for any structs",
	"undeclared struct",
	"invalid printf format code",
	"include file not found",
	"library file extension expected"
};

char token[STRING_LEN + 2]; // string token representation
char string_constant[STRING_LEN + 2]; // holds string and char constants without quotes and with escape sequences converted into the correct bytes
char *prog, *pbuf; // pointer to the current program position

void show_error(_ERROR e);
void send_msg(String s);
void do_copy(void);
void do_paste(void);
void do_reset(void);
void shift(int amount);
void get_token(void);
int POW(int n, int e);
void update_display(void);
void reset_lists(int cycle);
void NEW(void);
void write_cycle(void);
char *intToBinStr(char *str, unsigned char n);
String hexstr_char(unsigned char i);


unsigned int cycle_nbr = 0;
unsigned int instr_nbr = 0;
unsigned int ROM_nbr = 0;
char instr_name_clip[STRING_LEN];
char info[NBR_INSTRUCTIONS * CYCLES_PER_INSTR][INFO_LEN];
char info_clip[NBR_INSTRUCTIONS * CYCLES_PER_INSTR][INFO_LEN];
char instr_names[NBR_INSTRUCTIONS][STRING_LEN];
char instr_names_clip[NBR_INSTRUCTIONS][STRING_LEN];
unsigned char clipboard[NBR_INSTRUCTIONS * CYCLES_PER_INSTR][NBR_ROMS];
unsigned char ROMS[NBR_ROMS][NBR_INSTRUCTIONS * CYCLES_PER_INSTR];
unsigned char booltoint(bool b);
unsigned int get_index(String name);
void convert_constant();
String toHTML(String s);

int from_origin, from_dest;
int key_count;
char filename[STRING_LEN];
int from1, from2, to1, to2;
char prompt_buffer[PROMPT_LEN];

int textarea_len = 1;

bool serveron;
bool read_only = true;

int focus_index;

String textarea_data;
String HTML, HTMLtop, HTMLbottom;
unsigned int hits;
unsigned int number_users;

HANDLE hSerial;
DCB dcbSerialParams = {0};
COMMTIMEOUTS timeouts = {0};

__fastcall Tfmain::Tfmain(TComponent* Owner)
	: TForm(Owner)
{
}


unsigned int get_index(String name){
        return fmain->control_list->Items->IndexOf(name);

}



String hexstr_char(unsigned char i){
        String s;
        char table[] = "0123456789ABCDEF";

        s = s + table[(i & 0xF0) >> 4] + table[i & 0x0F];

        return s;

}


String hexstr(unsigned int i){
        String s;
        unsigned int a1, a2;

        a1 = (i / 16);
        switch(a1){
                case 10:
                        s = s + "A";
                        break;
                case 11:
                        s = s + "B";
                        break;
                case 12:
                        s = s + "C";
                        break;
                case 13:
                        s = s + "D";
                        break;
                case 14:
                        s = s + "E";
                        break;
                case 15:
                        s = s + "F";
                        break;
                default:
                        s = s + IntToStr(a1);
        }                                


        a2 = i % 16;
        switch(a2){
                case 10:
                        s = s + "A";
                        break;
                case 11:
                        s = s + "B";
                        break;
                case 12:
                        s = s + "C";
                        break;
                case 13:
                        s = s + "D";
                        break;
                case 14:
                        s = s + "E";
                        break;
                case 15:
                        s = s + "F";
                        break;
                default:
                        s = s + IntToStr(a2);
        }

        return s;

}
              



void READ(void){
        FILE *fp;
        TIniFile *ini;
        char name[STRING_LEN];
        char fullname[STRING_LEN];
        int pos;

        int val;
        int i, j, k;

        if(fmain->OpenDialog1->Execute()){
                strcpy(filename, fmain->OpenDialog1->FileName.c_str());
                ini = new TIniFile(GetCurrentDir() + "\\config.ini");
                ini->WriteString("general", "last_microcode_open", AnsiString(filename));
                delete ini;

                fmain->Caption = filename;
                strcpy(fullname, ExtractFileName(fmain->OpenDialog1->FileName).c_str());

                strcpy(name, fullname);
                fp = fopen(name, "r+b");
                fread(info, sizeof(char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR * INFO_LEN, fp);
                fread(instr_names, sizeof(char), NBR_INSTRUCTIONS * STRING_LEN, fp);
                fclose(fp);

                for(i = 0; i < 15; i++){
                        strcpy(name, fullname);
                        strcat(name, IntToStr(i).c_str());
                        fp = fopen(name, "r+b");
                        fread(&ROMS[i], sizeof(unsigned char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR, fp);
                        fclose(fp);

                }

                for(i = 0; i < 256; i++){
                        fmain->list_names->Items->Add("0x" + hexstr(i) + ": " + instr_names[i]);

                }
        }

}









void WRITE(void){
        FILE *fp;

        char name[STRING_LEN];
        char fullname[STRING_LEN];
        int pos;

        int val;
        int i, j, k;

        if(fmain->SaveDialog2->Execute())
        {
                strcpy(filename, fmain->SaveDialog2->FileName.c_str());
                fmain->Caption = filename;

                strcpy(fullname, ExtractFileName(fmain->SaveDialog2->FileName).c_str());
                strcpy(name, fullname);
                fp = fopen(name, "w+b");
                fwrite(info, sizeof(char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR * STRING_LEN, fp);
                fwrite(instr_names, sizeof(char), NBR_INSTRUCTIONS * STRING_LEN, fp);
                fclose(fp);

                for(i = 0; i < 15; i++){
                        strcpy(name, fullname);
                        strcat(name, IntToStr(i).c_str());
                        fp = fopen(name, "w+b");
                        fwrite(&ROMS[i], sizeof(unsigned char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR, fp);
                        fclose(fp);

                }
        }



}

void reset_lists(int cycle){
        strcpy(info[cycle], "");
        ROMS[0][cycle] = 0;
        ROMS[1][cycle] = 0;
        ROMS[2][cycle] = 0xC0;
        ROMS[3][cycle] = 0;
        ROMS[4][cycle] = 0;
        ROMS[5][cycle] = 0;
        ROMS[6][cycle] = 0;
        ROMS[7][cycle] = 0xF0;
        ROMS[8][cycle] = 0x8F;
        ROMS[9][cycle] = 0xFF;
        ROMS[10][cycle] = 0xFF;
        ROMS[11][cycle] = 0x47;
        ROMS[12][cycle] = 0xC0;
        ROMS[13][cycle] = 0;
        ROMS[14][cycle] = 0;

}

int POW(int n, int e){

        if(e == 0) return 1;
        else return n * POW(n, e - 1);

}

void Tfmain::write_cycle(void){
        int val;
        int i, j, k;
        int rom;

        if(read_only == true) return;

        strcpy(info[cycle_nbr], memo_info->Text.c_str());
        strcpy(instr_names[cycle_nbr / CYCLES_PER_INSTR], memo_name->Text.c_str());

        for(i = 0; i < 15 * 8; i++){
                if(i % 8 == 0) val = 0;
                if(control_list->Checked[i]) val = val + POW(2, i % 8);
                control_list->Checked[i % 8] = false;

                ROMS[i / 8][cycle_nbr] = val;
        }

        update_display();
}



void __fastcall Tfmain::Button3Click(TObject *Sender)
{
        if(cycle_nbr > 0) cycle_nbr--;

        update_display();

        fmain->list_cycle->ClearSelection();
        fmain->list_cycle->Selected[cycle_nbr % CYCLES_PER_INSTR] = true;

        fmain->list_names->ClearSelection();
        fmain->list_names->Selected[cycle_nbr / CYCLES_PER_INSTR] = true;

        fmain->list_cycle->SetFocus();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button4Click(TObject *Sender)
{

        if(cycle_nbr < NBR_INSTRUCTIONS * CYCLES_PER_INSTR - 1) cycle_nbr++;

        update_display();

        fmain->list_cycle->ClearSelection();
        fmain->list_cycle->Selected[cycle_nbr % CYCLES_PER_INSTR] = true;

        fmain->list_names->ClearSelection();
        fmain->list_names->Selected[cycle_nbr / CYCLES_PER_INSTR] = true;


        fmain->list_cycle->SetFocus();


}
//---------------------------------------------------------------------------




void __fastcall Tfmain::Button34Click(TObject *Sender)
{
         reset_lists(cycle_nbr);
         update_display();
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::SpeedButton7Click(TObject *Sender)
{
        Application->Terminate();
}
//---------------------------------------------------------------------------

unsigned char booltoint(bool b){
        if(b == true) return 1;
        else return 0;
}

void update_display(void){
        int i, j;
        unsigned char index;
        char offset;

        fmain->list_names->Clear();
        for(i = 0; i < 256; i++){
                        fmain->list_names->Items->Add(hexstr(i) + ": " + instr_names[i]);
        }
                
        for(i = 0; i < 15; i++){
                for(j = 0; j < 8; j++){
                        fmain->control_list->Checked[i * 8 + j] = ROMS[i][cycle_nbr] & POW(2, j);
                }
        }

        fmain->memo_info->Text = info[cycle_nbr];
        fmain->memo_name->Text = instr_names[cycle_nbr / CYCLES_PER_INSTR];

        fmain->list_names->Selected[cycle_nbr / CYCLES_PER_INSTR] = true;

        index = booltoint(fmain->control_list->Checked[0]) | (booltoint(fmain->control_list->Checked[1]) << 1);
        fmain->combo_type->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cond_flags_src")]);
        fmain->combo_flags_src->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("mdr_in_src")]);
        fmain->combo_mdr_src->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("mdr_out_src")]);
        fmain->combo_mdr_src_out->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("mar_in_src")]);
        fmain->combo_mar_src->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_cf_out_inv")]);
        fmain->combo_alu_cf_out_inv->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_cf_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_cf_in_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_cf_in_inv")]) << 2;
        fmain->combo_alu_cf_in->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("shift_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("shift_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("shift_src_2")]) << 2;
        fmain->combo_shift_src->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_2")]) << 2
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_3")]) << 3
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_4")]) << 4
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_5")]) << 5;
        fmain->combo_aluAmux->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_2")]) << 2
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_3")]) << 3
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_4")]) << 4
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_a_src_5")]) << 5;
        fmain->combo_aluAmux->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_b_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_b_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("alu_b_src_2")]) << 2;
        fmain->combo_aluBmux->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("zbus_out_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("zbus_out_src_1")]) << 1;
        fmain->combo_zbus->ItemIndex = index;

        offset = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_2")]) << 2
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_3")]) << 3
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_4")]) << 4
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_5")]) << 5
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("offset_6")]) << 6;
        offset = offset | ((offset << 1) & 0x80);
        fmain->edt_integer->Text = IntToStr(offset);


        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cond_sel_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cond_sel_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cond_sel_2")]) << 2
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cond_sel_3")]) << 3
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cond_inv")]) << 4;
        fmain->combo_cond->ItemIndex = index;


        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("zf_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("zf_in_src_1")]) << 1;
        fmain->combo_zf_in->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cf_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cf_in_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("cf_in_src_2")]) << 2;
        fmain->combo_cf_in->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("sf_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("sf_in_src_1")]) << 1;
        fmain->combo_sf_in->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("of_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("of_in_src_1")]) << 1
          |  booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("of_in_src_2")]) << 2;
        fmain->combo_of_in->ItemIndex = index;



        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("uzf_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("uzf_in_src_1")]) << 1;
        fmain->combo_uzf->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("ucf_in_src_0")])
          | booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("ucf_in_src_1")]) << 1;
        fmain->combo_ucf->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("usf_in_src")]);
        fmain->combo_usf->ItemIndex = index;

        index = booltoint(fmain->control_list->Checked[fmain->control_list->Items->IndexOf("uof_in_src")]);
        fmain->combo_uof->ItemIndex = index;
}

void NEW(void){
        int i;

        cycle_nbr = 0;
        
        
        for(i = 0; i < NBR_INSTRUCTIONS * CYCLES_PER_INSTR; i++){
                reset_lists(i);
        }
        for(i = 0; i < NBR_INSTRUCTIONS; i++){
                strcpy(instr_names[i], "");
                fmain->list_names->Items->Add("0x" + hexstr(i) + ": ");
        }
                                 
        update_display();
}























char *intToBinStr(char *str, unsigned char n){
	if(n & 0x80) str[0] = '1'; else str[0] = '0';
	if(n & 0x40) str[1] = '1'; else str[1] = '0';
	if(n & 0x20) str[2] = '1'; else str[2] = '0';
	if(n & 0x10) str[3] = '1'; else str[3] = '0';
	if(n & 0x08) str[4] = '1'; else str[4] = '0';
	if(n & 0x04) str[5] = '1'; else str[5] = '0';
	if(n & 0x02) str[6] = '1';	else str[6] = '0';
	if(n & 0x01) str[7] = '1'; else str[7] = '0';
        
        str[8] = '\0';

	return str;
}

void __fastcall Tfmain::Button5Click(TObject *Sender)
{
        do_copy();

}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button6Click(TObject *Sender)
{
        do_paste();

}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button7Click(TObject *Sender)
{
        do_reset();
}
//---------------------------------------------------------------------------







void __fastcall Tfmain::Button12Click(TObject *Sender)
{
        if(cycle_nbr == 0) return;
        
        clipboard[0][0] = ROMS[0][cycle_nbr];
        clipboard[0][1] = ROMS[1][cycle_nbr];
        clipboard[0][2] = ROMS[2][cycle_nbr];
        clipboard[0][3] = ROMS[3][cycle_nbr];
        clipboard[0][4] = ROMS[4][cycle_nbr];
        clipboard[0][5] = ROMS[5][cycle_nbr];
        clipboard[0][6] = ROMS[6][cycle_nbr];
        clipboard[0][7] = ROMS[7][cycle_nbr];
        clipboard[0][8] = ROMS[8][cycle_nbr];
        clipboard[0][9] = ROMS[9][cycle_nbr];
        clipboard[0][10] = ROMS[10][cycle_nbr];
        clipboard[0][11] = ROMS[11][cycle_nbr];
        clipboard[0][12] = ROMS[12][cycle_nbr];
        clipboard[0][13] = ROMS[13][cycle_nbr];

        ROMS[0][cycle_nbr - 1] = clipboard[0][0];
        ROMS[1][cycle_nbr - 1] = clipboard[0][1];
        ROMS[2][cycle_nbr - 1]= clipboard[0][2];
        ROMS[3][cycle_nbr - 1]= clipboard[0][3];
        ROMS[4][cycle_nbr - 1] = clipboard[0][4];
        ROMS[5][cycle_nbr - 1] = clipboard[0][5];
        ROMS[6][cycle_nbr - 1] = clipboard[0][6];
        ROMS[7][cycle_nbr - 1] = clipboard[0][7];
        ROMS[8][cycle_nbr - 1] = clipboard[0][8];
        ROMS[9][cycle_nbr - 1] = clipboard[0][9];
        ROMS[10][cycle_nbr - 1] = clipboard[0][10];
        ROMS[11][cycle_nbr - 1] = clipboard[0][11];
        ROMS[12][cycle_nbr - 1] = clipboard[0][12];
        ROMS[13][cycle_nbr - 1] = clipboard[0][13];

        strcpy(info[cycle_nbr - 1], info[cycle_nbr]);
        strcpy(info[cycle_nbr], "");

        reset_lists(cycle_nbr);
        cycle_nbr--;
        update_display();

}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button13Click(TObject *Sender)
{
        if(cycle_nbr == NBR_INSTRUCTIONS * CYCLES_PER_INSTR - 1) return;

        clipboard[0][0] = ROMS[0][cycle_nbr];
        clipboard[0][1] = ROMS[1][cycle_nbr];
        clipboard[0][2] = ROMS[2][cycle_nbr];
        clipboard[0][3] = ROMS[3][cycle_nbr];
        clipboard[0][4] = ROMS[4][cycle_nbr];
        clipboard[0][5] = ROMS[5][cycle_nbr];
        clipboard[0][6] = ROMS[6][cycle_nbr];
        clipboard[0][7] = ROMS[7][cycle_nbr];
        clipboard[0][8] = ROMS[8][cycle_nbr];
        clipboard[0][9] = ROMS[9][cycle_nbr];
        clipboard[0][10] = ROMS[10][cycle_nbr];
        clipboard[0][11] = ROMS[11][cycle_nbr];
        clipboard[0][12] = ROMS[12][cycle_nbr];
        clipboard[0][13] = ROMS[13][cycle_nbr];

        ROMS[0][cycle_nbr + 1] = clipboard[0][0];
        ROMS[1][cycle_nbr + 1] = clipboard[0][1];
        ROMS[2][cycle_nbr + 1]= clipboard[0][2];
        ROMS[3][cycle_nbr + 1]= clipboard[0][3];
        ROMS[4][cycle_nbr + 1] = clipboard[0][4];
        ROMS[5][cycle_nbr + 1] = clipboard[0][5];
        ROMS[6][cycle_nbr + 1] = clipboard[0][6];
        ROMS[7][cycle_nbr + 1] = clipboard[0][7];
        ROMS[8][cycle_nbr + 1] = clipboard[0][8];
        ROMS[9][cycle_nbr + 1] = clipboard[0][9];
        ROMS[10][cycle_nbr + 1] = clipboard[0][10];
        ROMS[11][cycle_nbr + 1] = clipboard[0][11];
        ROMS[12][cycle_nbr + 1] = clipboard[0][12];
        ROMS[13][cycle_nbr + 1] = clipboard[0][13];

        strcpy(info[cycle_nbr + 1], info[cycle_nbr]);
        strcpy(info[cycle_nbr], "");

        reset_lists(cycle_nbr);
        cycle_nbr++;
        update_display();

}
//---------------------------------------------------------------------------





void __fastcall Tfmain::control_listClickCheck(TObject *Sender)
{
        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::memo_infoKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
        write_cycle();         
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::memo_infoKeyUp(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
        write_cycle();         
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::list_cycleClick(TObject *Sender)
{
        cycle_nbr = instr_nbr * CYCLES_PER_INSTR + StrToInt(list_cycle->ItemIndex);
        update_display();


}
//---------------------------------------------------------------------------











void __fastcall Tfmain::combo_typeSelect(TObject *Sender)
{
        switch(combo_type->ItemIndex){
                case 0:
                        control_list->Checked[0] = false;
                        control_list->Checked[1] = false;
                        break;

                case 1:
                        control_list->Checked[0] = true;
                        control_list->Checked[1] = false;
                        break;

                case 2:
                        control_list->Checked[0] = false;
                        control_list->Checked[1] = true;
                        break;

                case 3:
                        control_list->Checked[0] = true;
                        control_list->Checked[1] = true;
                        break;

        }
        write_cycle();
}
//---------------------------------------------------------------------------













    




void __fastcall Tfmain::Button1Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, "notepad.exe", NULL,  NULL, SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button17Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, "calc.exe", NULL,  NULL, SW_SHOWNORMAL);        
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button18Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, "cmd.exe", NULL,  NULL, SW_SHOWNORMAL);        
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button20Click(TObject *Sender)
{
        int i;
        if(edt_integer->Text == "") i = 0;
        else i = StrToInt(edt_integer->Text);

        if(i & 0x01) control_list->Checked[13*8] = true;
        else control_list->Checked[13*8] = false;
        if(i & 0x02) control_list->Checked[13*8 + 1] = true;
        else control_list->Checked[13*8+1] = false;
        if(i & 0x04) control_list->Checked[13*8 + 2] = true;
        else control_list->Checked[13*8+2] = false;
        if(i & 0x08) control_list->Checked[13*8 + 3] = true;
        else control_list->Checked[13*8+3] = false;
        if(i & 0x10) control_list->Checked[13*8 + 4] = true;
        else control_list->Checked[13*8+4] = false;
        if(i & 0x20) control_list->Checked[13*8 + 5] = true;
        else control_list->Checked[13*8+5] = false;
        if(i & 0x40) control_list->Checked[13*8 + 6] = true;
        else control_list->Checked[13*8+6] = false;
        if(i & 0x80) control_list->Checked[13*8 + 7] = true;
        else control_list->Checked[13*8+7] = false;

        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button19Click(TObject *Sender)
{
        int i;
        if(edt_integer->Text == "") i = 0;
        else i = StrToInt(edt_integer->Text);

        if(i & 0x01) control_list->Checked[2] = true;
        else control_list->Checked[2] = false;
        if(i & 0x02) control_list->Checked[3] = true;
        else control_list->Checked[3] = false;
        if(i & 0x04) control_list->Checked[4] = true;
        else control_list->Checked[4] = false;
        if(i & 0x08) control_list->Checked[5] = true;
        else control_list->Checked[5] = false;
        if(i & 0x10) control_list->Checked[6] = true;
        else control_list->Checked[6] = false;
        if(i & 0x20) control_list->Checked[7] = true;
        else control_list->Checked[7] = false;
        if(i & 0x40) control_list->Checked[8] = true;
        else control_list->Checked[8] = false;

        write_cycle();
}
//---------------------------------------------------------------------------






















void __fastcall Tfmain::combo_aluAmuxSelect(TObject *Sender)
{
        int index = combo_aluAmux->ItemIndex;


        control_list->Checked[control_list->Items->IndexOf("alu_a_src_0")] = index & 0x01;
        control_list->Checked[control_list->Items->IndexOf("alu_a_src_1")] = index & 0x02;
        control_list->Checked[control_list->Items->IndexOf("alu_a_src_2")] = index & 0x04;
        control_list->Checked[control_list->Items->IndexOf("alu_a_src_3")] = index & 0x08;
        control_list->Checked[control_list->Items->IndexOf("alu_a_src_4")] = index & 0x10;
        control_list->Checked[control_list->Items->IndexOf("alu_a_src_5")] = index & 0x20;



        write_cycle();

}
//---------------------------------------------------------------------------




void __fastcall Tfmain::combo_aluBmuxSelect(TObject *Sender)
{
        int index = combo_aluBmux->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("alu_b_src_0")] = (index ) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("alu_b_src_1")] = (index ) & 0x02;
        control_list->Checked[control_list->Items->IndexOf("alu_b_src_2")] = (index ) & 0x04;

        write_cycle();
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::combo_aluopSelect(TObject *Sender)
{

        if(combo_aluop->Text == "plus"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = false;
        }
        else if(combo_aluop->Text == "minus"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = false;
        }
        else if(combo_aluop->Text == "and"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "or"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "xor"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "A"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "B"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "not A"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "not B"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "nand"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "nor"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }
        else if(combo_aluop->Text == "nxor"){
                control_list->Checked[control_list->Items->IndexOf("alu_op_0")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_op_1")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_2")] = false;
                control_list->Checked[control_list->Items->IndexOf("alu_op_3")] = true;
                control_list->Checked[control_list->Items->IndexOf("alu_mode")] = true;
        }

        write_cycle();
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::Copy1Click(TObject *Sender)
{
        do_copy();

}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Paste1Click(TObject *Sender)
{
        do_paste();

}
//---------------------------------------------------------------------------









void __fastcall Tfmain::BitBtn1Click(TObject *Sender)
{
        cycle_nbr = cycle_nbr / 64;
        cycle_nbr--;
        cycle_nbr = cycle_nbr * 64;

        update_display();

        fmain->list_cycle->ClearSelection();
        fmain->list_cycle->Selected[cycle_nbr % CYCLES_PER_INSTR] = true;



        fmain->list_names->ClearSelection();
        fmain->list_names->Selected[cycle_nbr / CYCLES_PER_INSTR] = true;

        fmain->list_cycle->SetFocus();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::BitBtn2Click(TObject *Sender)
{
        cycle_nbr = cycle_nbr / 64;
                cycle_nbr++;
                cycle_nbr = cycle_nbr * 64;


        update_display();

        fmain->list_cycle->ClearSelection();
        fmain->list_cycle->Selected[cycle_nbr % CYCLES_PER_INSTR] = true;



        fmain->list_names->ClearSelection();
        fmain->list_names->Selected[cycle_nbr / CYCLES_PER_INSTR] = true;

        fmain->list_cycle->SetFocus();
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::combo_condSelect(TObject *Sender)
{
        
        int index = combo_cond->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("cond_sel_0")] = (index) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("cond_sel_1")] = (index) & 0x02;
        control_list->Checked[control_list->Items->IndexOf("cond_sel_2")] = (index) & 0x04;
        control_list->Checked[control_list->Items->IndexOf("cond_sel_3")] = (index) & 0x08;
        control_list->Checked[control_list->Items->IndexOf("cond_inv")] = (index) & 0x10;

        write_cycle();
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::combo_alu_cf_inSelect(TObject *Sender)
{
        int index = combo_alu_cf_in->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("alu_cf_in_src_0")] = (index ) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("alu_cf_in_src_1")] = (index ) & 0x02;
        control_list->Checked[control_list->Items->IndexOf("alu_cf_in_inv")] = (index ) & 0x04;


        write_cycle();
}
//---------------------------------------------------------------------------













void __fastcall Tfmain::combo_mdr_srcSelect(TObject *Sender)
{
        int index = combo_mdr_src->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("mdr_in_src")] = index == 1;


        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_mar_srcSelect(TObject *Sender)
{
        int index = combo_mar_src->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("mar_in_src")] = index == 1;


        write_cycle();
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::combo_zf_inSelect(TObject *Sender)
{
	int index = combo_zf_in->ItemIndex;

    control_list->Checked[control_list->Items->IndexOf("zf_in_src_0")] = (index) & 0x01;
    control_list->Checked[control_list->Items->IndexOf("zf_in_src_1")] = (index) & 0x02;

    write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_cf_inSelect(TObject *Sender)
{
	int index = combo_cf_in->ItemIndex;

    control_list->Checked[control_list->Items->IndexOf("cf_in_src_0")] = (index) & 0x01;
    control_list->Checked[control_list->Items->IndexOf("cf_in_src_1")] = (index) & 0x02;
    control_list->Checked[control_list->Items->IndexOf("cf_in_src_2")] = (index) & 0x04;
    write_cycle();

}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_sf_inSelect(TObject *Sender)
{
	int index = combo_sf_in->ItemIndex;

    control_list->Checked[control_list->Items->IndexOf("sf_in_src_0")] = (index) & 0x01;
    control_list->Checked[control_list->Items->IndexOf("sf_in_src_1")] = (index) & 0x02;

    write_cycle();



}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_of_inSelect(TObject *Sender)
{
	int index = combo_of_in->ItemIndex;

    control_list->Checked[control_list->Items->IndexOf("of_in_src_0")] = (index) & 0x01;
    control_list->Checked[control_list->Items->IndexOf("of_in_src_1")] = (index) & 0x02;
    control_list->Checked[control_list->Items->IndexOf("of_in_src_2")] = (index) & 0x04;

    write_cycle();
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::list_namesClick(TObject *Sender)
{
        cycle_nbr = list_names->ItemIndex * CYCLES_PER_INSTR;
        instr_nbr = list_names->ItemIndex;
        update_display();

        fmain->list_cycle->ClearSelection();
        fmain->list_cycle->Selected[0] = true;
        fmain->list_names->Selected[cycle_nbr / CYCLES_PER_INSTR] = true;
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::memo_nameChange(TObject *Sender)
{
        write_cycle();
}
//---------------------------------------------------------------------------


 








void __fastcall Tfmain::combo_flags_srcSelect(TObject *Sender)
{
        int index = combo_flags_src->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("cond_flags_src")] = index == 1;

        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_mdr_src_outSelect(TObject *Sender)
{
        int index = combo_mdr_src_out->ItemIndex ;

        control_list->Checked[control_list->Items->IndexOf("mdr_out_src")] = index == 1;


        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_shift_srcSelect(TObject *Sender)
{
        int index = combo_shift_src->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("shift_src_0")] = (index) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("shift_src_1")] = (index) & 0x02;
        control_list->Checked[control_list->Items->IndexOf("shift_src_2")] = (index) & 0x04;

        write_cycle();
}
//---------------------------------------------------------------------------






void __fastcall Tfmain::combo_zbusSelect(TObject *Sender)
{
        int index = combo_zbus->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("zbus_out_src_0")] = (index) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("zbus_out_src_1")] = (index) & 0x02;

        write_cycle();
}
//---------------------------------------------------------------------------






void __fastcall Tfmain::combo_uzfSelect(TObject *Sender)
{
        int index = combo_uzf->ItemIndex;

        control_list->Checked[control_list->Items->IndexOf("uzf_in_src_0")] = (index) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("uzf_in_src_1")] = (index) & 0x02;

        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_ucfSelect(TObject *Sender)
{
        int index = combo_ucf->ItemIndex;
        

        control_list->Checked[control_list->Items->IndexOf("ucf_in_src_0")] = (index) & 0x01;
        control_list->Checked[control_list->Items->IndexOf("ucf_in_src_1")] = (index) & 0x02;

        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_usfSelect(TObject *Sender)
{
        int index = combo_usf->ItemIndex;
        

        control_list->Checked[control_list->Items->IndexOf("usf_in_src")] = index == 1;

        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::combo_uofSelect(TObject *Sender)
{
        int index = combo_uof->ItemIndex;
        

        control_list->Checked[control_list->Items->IndexOf("uof_in_src")] = index == 1;

        write_cycle();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N11Click(TObject *Sender)
{

       shift(1);

       update_display();
}

void shift(int amount){
        int i, j;
        bool exit = false;


        for(i = 0; i < CYCLES_PER_INSTR; i++){
                if(fmain->list_cycle->Selected[i] == true){
                        from1 = instr_nbr * CYCLES_PER_INSTR + i;
                        for(j = i; j < CYCLES_PER_INSTR; j++){
                                if(fmain->list_cycle->Selected[j] == false){
                                        to1 = instr_nbr * CYCLES_PER_INSTR + j - 1;
                                        exit = true;
                                        break;
                                }
                        }
                }
                if(exit == true) break;
        }


        for(i = from1; i <= to1; i++){

            strcpy(info_clip[i], info[i]);

            clipboard[i][0] = ROMS[0][i];
            clipboard[i][1] = ROMS[1][i];
            clipboard[i][2] = ROMS[2][i];
            clipboard[i][3] = ROMS[3][i];
            clipboard[i][4] = ROMS[4][i];
            clipboard[i][5] = ROMS[5][i];
            clipboard[i][6] = ROMS[6][i];
            clipboard[i][7] = ROMS[7][i];
            clipboard[i][8] = ROMS[8][i];
            clipboard[i][9] = ROMS[9][i];
            clipboard[i][10] = ROMS[10][i];
            clipboard[i][11] = ROMS[11][i];
            clipboard[i][12] = ROMS[12][i];
            clipboard[i][13] = ROMS[13][i];

            reset_lists(i);
        }

        for(i = from1; i <= to1; i++){

            strcpy(info[i + amount], info_clip[i]);

            ROMS[0][i + amount ] = clipboard[i][0];
            ROMS[1][i+ amount ] = clipboard[i][1];
            ROMS[2][i+ amount ]= clipboard[i][2];
            ROMS[3][i + amount]= clipboard[i][3];
            ROMS[4][i+ amount ] = clipboard[i][4];
            ROMS[5][i + amount] = clipboard[i][5];
            ROMS[6][i + amount] = clipboard[i][6];
            ROMS[7][i+ amount ] = clipboard[i][7];
            ROMS[8][i+ amount ] = clipboard[i][8];
            ROMS[9][i + amount] = clipboard[i][9];
            ROMS[10][i+ amount ] = clipboard[i][10];
            ROMS[11][i+ amount ] = clipboard[i][11];
            ROMS[12][i + amount] = clipboard[i][12];
            ROMS[13][i+ amount] = clipboard[i][13];
        }
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N21Click(TObject *Sender)
{
        shift(2);

        update_display();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N31Click(TObject *Sender)
{
        shift(3);

        update_display();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N41Click(TObject *Sender)
{

        shift(4);

        update_display();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N51Click(TObject *Sender)
{
        shift(5);

        update_display();
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N101Click(TObject *Sender)
{
        shift(10);

        update_display();
}
//---------------------------------------------------------------------------







void __fastcall Tfmain::StringGrid2KeyPress(TObject *Sender, char &Key)
{
        key_count++;
        
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::StringGrid2SelectCell(TObject *Sender, int ACol,
      int ARow, bool &CanSelect)
{
        key_count = 0;        
}
//---------------------------------------------------------------------------





void __fastcall Tfmain::list_cycleKeyPress(TObject *Sender, char &Key)
{
        switch(Key){
                case 'R', 'r':
                        do_reset();



                        break;

                case 'C', 'c':
                        do_copy();

                        break;

                case 'V', 'v':
                        do_paste();

                        break;

        default:  ;

        }
}

void send_msg(String s){
       // fmain->status->Panels[0].Items[0]->Text = s;
}

void do_copy(void){
        int i, j;
        bool exit = false;

        for(i = 0; i < CYCLES_PER_INSTR; i++){
                if(fmain->list_cycle->Selected[i] == true){
                        from1 = instr_nbr * CYCLES_PER_INSTR + i;
                        for(j = i; j < CYCLES_PER_INSTR; j++){
                                if(fmain->list_cycle->Selected[j] == false){
                                        to1 = instr_nbr * CYCLES_PER_INSTR + j - 1;
                                        exit = true;
                                        break;
                                }
                        }
                }
                if(exit == true) break;
        }

        for(i = from1; i <= to1; i++){
                strcpy(info_clip[i], info[i]);
                clipboard[i][0] = ROMS[0][i];
                clipboard[i][1] = ROMS[1][i];
                clipboard[i][2] = ROMS[2][i];
                clipboard[i][3] = ROMS[3][i];
                clipboard[i][4] = ROMS[4][i];
                clipboard[i][5] = ROMS[5][i];
                clipboard[i][6] = ROMS[6][i];
                clipboard[i][7] = ROMS[7][i];
                clipboard[i][8] = ROMS[8][i];
                clipboard[i][9] = ROMS[9][i];
                clipboard[i][10] = ROMS[10][i];
                clipboard[i][11] = ROMS[11][i];
                clipboard[i][12] = ROMS[12][i];
                clipboard[i][13] = ROMS[13][i];
        }

        update_display();
        send_msg("Last action: Cycles copied.");
}

void do_reset(void){
        int i, j;
        bool exit = false;
        
        for(i = 0; i < CYCLES_PER_INSTR; i++){
                if(fmain->list_cycle->Selected[i] == true){
                        from1 = instr_nbr * CYCLES_PER_INSTR + i;
                        for(j = i; j < CYCLES_PER_INSTR; j++){
                                if(fmain->list_cycle->Selected[j] == false){
                                        to1 = instr_nbr * CYCLES_PER_INSTR + j - 1;
                                        exit = true;
                                        break;
                                }
                        }
                }
                if(exit == true) break;
        }

        for(i = from1; i <= to1; i++){
                strcpy(info_clip[i], info[i]);
                reset_lists(i);
        }

        update_display();

        send_msg("Last action: Cycles reset.");
}

void do_paste(void){
        int i, j;

        from2 = instr_nbr * CYCLES_PER_INSTR + fmain->list_cycle->ItemIndex;

        for(i = from2; i <= from2 + to1 - from1; i++){
                strcpy(info[i], info_clip[i - (from2 - from1)]);
                ROMS[0][i] = clipboard[i - (from2 - from1)][0];
                ROMS[1][i] = clipboard[i - (from2 - from1)][1];
                ROMS[2][i]= clipboard[i - (from2 - from1)][2];
                ROMS[3][i]= clipboard[i - (from2 - from1)][3];
                ROMS[4][i] = clipboard[i - (from2 - from1)][4];
                ROMS[5][i] = clipboard[i - (from2 - from1)][5];
                ROMS[6][i] = clipboard[i - (from2 - from1)][6];
                ROMS[7][i] = clipboard[i - (from2 - from1)][7];
                ROMS[8][i] = clipboard[i - (from2 - from1)][8];
                ROMS[9][i] = clipboard[i - (from2 - from1)][9];
                ROMS[10][i] = clipboard[i - (from2 - from1)][10];
                ROMS[11][i] = clipboard[i - (from2 - from1)][11];
                ROMS[12][i] = clipboard[i - (from2 - from1)][12];
                ROMS[13][i] = clipboard[i - (from2 - from1)][13];
        }
        update_display();

        send_msg("Last action: Cycles pasted.");
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Reset1Click(TObject *Sender)
{
        do_reset();        
}
//---------------------------------------------------------------------------




void show_error(_ERROR e);


void convert_constant(){
	char *s = string_constant;
	char *t = token;
	
	if(token_type == CHAR_CONST){
		t++;
		if(*t == '\\'){
			t++;
			switch(*t){
				case '0':
					*s++ = '\0';
					break;
				case 'a':
					*s++ = '\a';
					break;
				case 'b':
					*s++ = '\b';
					break;	
				case 'f':
					*s++ = '\f';
					break;
				case 'n':
					*s++ = '\n';
					break;
				case 'r':
					*s++ = '\r';
					break;
				case 't':
					*s++ = '\t';
					break;
				case 'v':
					*s++ = '\v';
					break;
				case '\\':
					*s++ = '\\';
					break;
				case '\'':
					*s++ = '\'';
					break;
				case '\"':
					*s++ = '\"';
			}
		}
		else{
			*s++ = *t;
		}
	}
	else if(token_type == STRING_CONST){
		t++;
		while(*t != '\"' && *t){
			if(*t == '\\'){
				t++;
				switch(*t){
					case '0':
						*s = '\0';
						break;
					case 'a':
						*s = '\a';
						break;
					case 'b':
						*s = '\b';
						break;	
					case 'f':
						*s = '\f';
						break;
					case 'n':
						*s = '\n';
						break;
					case 'r':
						*s = '\r';
						break;
					case 't':
						*s = '\t';
						break;
					case 'v':
						*s = '\v';
						break;
					case '\\':
						*s = '\\';
						break;
					case '\'':
						*s = '\'';
						break;
					case '\"':
						*s = '\"';
				}
			}
			else *s = *t;
			s++;
			t++;
		}
	}
	
	*s = '\0';
}

char isdelim(char c){
	if(strchr("#+-*/%[](){};,<>=!&|~.", c)) return 1;
	else return 0;
}

char is_idchar(char c){
	return(isalpha(c) || c == '_');
}

void get_token(void){
	char *t;
	// skip blank spaces

	*token = '\0';
	tok = NOTOK;
	t = token;
	
	while(isspace(*prog) || *prog == '\n') prog++;

	if(*prog == '\0'){
		token_type = END;
		return;
	}

	if(*prog == '\''){
		*t++ = '\'';
		prog++;
		if(*prog == '\\'){
			*t++ = '\\';
			prog++;
			*t++ = *prog++;
		}
		else *t++ = *prog++;
		
		if(*prog != '\'') show_error(SINGLE_QUOTE_EXPECTED);

		*t++ = '\'';
		prog++;
		token_type = CHAR_CONST;
		*t = '\0';
		convert_constant(); // converts this string token with quotation marks to a non quotation marks string, and also converts escape sequences to their real bytes
	}
	else if(*prog == '\"'){
		*t++ = '\"';
		prog++;
		while(*prog != '\"' && *prog) *t++ = *prog++;
		if(*prog != '\"') show_error(DOUBLE_QUOTE_EXPECTED);
		*t++ = '\"';
		prog++;
		token_type = STRING_CONST;
		*t = '\0';
		convert_constant(); // converts this string token qith quotation marks to a non quotation marks string, and also converts escape sequences to their real bytes
	}
	else if(isdigit(*prog)){
		while(isdigit(*prog)) *t++ = *prog++;
		if(*prog == '.'){
			*t++ = '.';
			prog++;
			while(isdigit(*prog)) *t++ = *prog++;
			if(*prog == 'D'){
				prog++;
				token_type = DOUBLE_CONST;
			}
			else
				token_type = FLOAT_CONST;
		}
		else token_type = INTEGER_CONST;
	}

	else if(isdelim(*prog)){
		token_type = DELIMITER;	
		
		if(*prog == '#'){
			*t++ = *prog++;
			tok = DIRECTIVE;
		}
		else if(*prog == '['){
			*t++ = *prog++;
			tok = OPENING_BRACKET;
		}
		else if(*prog == ']'){
			*t++ = *prog++;
			tok = CLOSING_BRACKET;
		}
		else if(*prog == '{'){
			*t++ = *prog++;
			tok = OPENING_BRACE;
		}
		else if(*prog == '}'){
			*t++ = *prog++;
			tok = CLOSING_BRACE;
		}
		else if(*prog == '='){
			*t++ = *prog++;
			if (*prog == '='){
				*t++ = *prog++;
				tok = EQUAL;
			}
			else tok = ATTRIBUTION;
		}
		else if(*prog == '&'){
			*t++ = *prog++;
			if(*prog == '&'){
				*t++ = *prog++;
				tok = LOGICAL_AND;
			}
			else tok = POINTER_REF;
		}
		else if(*prog == '|'){
			*t++ = *prog++;
			if (*prog == '|'){
				*t++ = *prog++;
				tok = LOGICAL_OR;
			}
			else tok = BITWISE_OR;
		}
		else if(*prog == '~'){
			*t++ = *prog++;
			tok = BITWISE_NOT;
		}
		else if(*prog == '<'){
			*t++ = *prog++;
			if (*prog == '='){
				*t++ = *prog++;
				tok = LESS_THAN_OR_EQUAL;
			}
			else tok = LESS_THAN;
		}
		else if(*prog == '>'){
			*t++ = *prog++;
			if (*prog == '='){
				*t++ = *prog++;
				tok = GREATER_THAN_OR_EQUAL;
			}
			else tok = GREATER_THAN;
		}
		else if(*prog == '!'){
			*t++ = *prog++;
			if(*prog == '='){
				*t++ = *prog++;
				tok = NOT_EQUAL;
			}
			else tok = LOGICAL_NOT;
		}
		else if(*prog == '+'){
			*t++ = *prog++;
			if(*prog == '+'){
				*t++ = *prog++;
				tok = INCREMENT;
			}
			else tok = PLUS;
		}
		else if(*prog == '-'){
			*t++ = *prog++;
			if(*prog == '-'){
				*t++ = *prog++;
				tok = DECREMENT;
			}
			else if(*prog == '>'){
				*t++ = *prog++;
				tok = ARROW;
			}
			else tok = MINUS;
		}
		else if(*prog == '*'){
			*t++ = *prog++;
			tok = ASTERISK;
		}
		else if(*prog == '/'){
			*t++ = *prog++;
			tok = DIVISION;
		}
		else if(*prog == '%'){
			*t++ = *prog++;
			tok = MOD;
		}
		else if(*prog == '('){
			*t++ = *prog++;
			tok = OPENING_PAREN;
		}
		else if(*prog == ')'){
			*t++ = *prog++;
			tok = CLOSING_PAREN;
		}
		else if(*prog == ';'){
			*t++ = *prog++;
			tok = SEMICOLON;
		}
		else if(*prog == ','){
			*t++ = *prog++;
			tok = COMMA;
		}
		else if(*prog == '.'){
			*t++ = *prog++;
			tok = DOT;
		}
	}

	*t = '\0';
}

void show_error(_ERROR e){
	int line = 1;
	char *t = pbuf;

	puts(error_table[e]);
	
	while(t < prog){
		t++;
		if(*t == '\n') line++;
	}
	
	printf("line number: %d\n", line);
	printf("near: %s", token);
	system("pause");

	exit(0);
}






























void __fastcall Tfmain::Button10Click(TObject *Sender)
{

        CloseHandle(hSerial);
        memo_com_out->Lines->Add(edtport->Text + " closed.");



}
//---------------------------------------------------------------------------









void __fastcall Tfmain::Button26Click(TObject *Sender)
{
        memo_com_out->Clear();
        memo_com_out->SetFocus();        
}
//---------------------------------------------------------------------------































void __fastcall Tfmain::FormDestroy(TObject *Sender)
{
        int main_tab_index;
        TIniFile *ini;
        int i;

        ini = new TIniFile(GetCurrentDir() + "\\config.ini");

        ini->WriteInteger("main", "main_tab_index", PageControl2->TabIndex);

        
        delete ini;


}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button30Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, GetCurrentDir().c_str(), NULL,  NULL, SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------















void __fastcall Tfmain::Button32Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, "C:\\Program Files\\HxD\\HxD.exe", NULL,  NULL, SW_SHOWNORMAL);
}
//---------------------------------------------------------------------------







void __fastcall Tfmain::CalculateAvgCyclesperInstruction1Click(
      TObject *Sender)
{
        int i, j;
        float count = 0.0;
        float average;

        for(i = 2; i < 256; i++){
                for(j = 63; j >= 0; j--){
                        if((ROMS[0][i * 64 + j] & 0x03) == 0x02){
                                count = count + (float)(j+1);
                                f_prompt->memo_prompt_out->Lines->Add(IntToStr(i) + ":" + IntToStr(j+1));
                                break;
                        }
                }
        }

        average = (count + 2) / 255.0; // the +2 accounts for fetch

        f_prompt->memo_prompt_out->Lines->Add(FloatToStr(average));
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::GenerateTASMTable1Click(TObject *Sender)
{
        FILE *fp;
        int i;
        char inst[NBR_INSTRUCTIONS][128];
        char *p, *p2;
        String s;
        int len;

        if(Application->MessageBoxA("Generate table?", "Confirm", MB_YESNO | MB_ICONQUESTION) == IDYES){

            fp = fopen("minicomputer.tab", "w");

            for(i = 0; i < NBR_INSTRUCTIONS; i++){
                    strcpy(inst[i], instr_names[i]);
            }

            for(i = 0; i < NBR_INSTRUCTIONS; i++){
                    len = 1;

                    p = strstr(inst[i], "i8");
                    if(p != NULL){
                            len++;
                            *p = '*';
                            *(p+1) = ' ';
                    }
                    p = strstr(inst[i], "u8");
                    if(p != NULL){
                            len++;
                            *p = '*';
                            *(p+1) = ' ';
                    }
                    p = strstr(inst[i], "i16");
                    if(p != NULL){
                            len = len + 2;
                            *p = '*';
                            *(p+1) = ' ';
                            *(p+2) = ' ';
                    }
                    p = strstr(inst[i], "u16");
                    if(p != NULL){
                            len = len + 2;
                            *p = '*';
                            *(p+1) = ' ';
                            *(p+2) = ' ';
                    }

                    fputs(inst[i], fp);
                    fputs("\t\t\t", fp);
                    fputs(hexstr(i).c_str(), fp);
                    fputs(("\t\t" + IntToStr(len)).c_str(), fp);
                    fputs("\t\t NOP \t\t 1", fp);
                    fputc('\n', fp);

            }
        
            fclose(fp);
        }        
}
//---------------------------------------------------------------------------

















void __fastcall Tfmain::Find1Click(TObject *Sender)
{
        ffind->Show();        
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::memo_text12Enter(TObject *Sender)
{
        focus_index = 1;
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::Sorted1Click(TObject *Sender)
{
        Sorted1->Checked = !Sorted1->Checked;
        ListBox2->Sorted = Sorted1->Checked;

}
//---------------------------------------------------------------------------


void __fastcall Tfmain::Directory1Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, GetCurrentDir().c_str(), NULL,  NULL, SW_SHOWNORMAL);        
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::Button15Click(TObject *Sender)
{
        ShellExecute(NULL, NULL, "C:\\MiniPro\\MiniPro.exe", NULL,  NULL, SW_SHOWNORMAL);        
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::Prompt1Click(TObject *Sender)
{
        f_prompt->Visible = true;        
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::Timer1Timer(TObject *Sender)
{
        char c[1024*128];
        unsigned long int i, k, w;
        int chars;
        int j;

        chars = StrToInt(edt_chars->Text);
        if(ReadFile(hSerial, c, chars, &i, NULL) != NULL){
                if(i > 0){
                        if(IdHTTPServer1->Active == true){
                            for(k = 0; k < i; k++){
                            	if(c[k] != 0x0D){
                            		textarea_data = textarea_data + c[k];
                                }

                            }
                            if(textarea_data.Length() >= 75000) textarea_data = "";
                        }
                        
                        if(telnet->Active == true){
                          	for(k = 0; k < telnet->Socket->ActiveConnections; k++){
								telnet->Socket->Connections[k]->SendBuf(c, i);

                            }
                        }
                }
        }
}
//---------------------------------------------------------------------------












void __fastcall Tfmain::ASCIITable1Click(TObject *Sender)
{
        Panel15->Visible = !Panel15->Visible;         
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::memo_text112Enter(TObject *Sender)
{
focus_index = 0;           
}
//---------------------------------------------------------------------------










void __fastcall Tfmain::FormShow(TObject *Sender)
{
        int i, j;
        int main_tab_index;
        TIniFile *ini;

        ini = new TIniFile(GetCurrentDir() + "\\config.ini");

        main_tab_index = ini->ReadInteger("main", "main_tab_index", 0);

        delete ini;

        PageControl2->ActivePage = PageControl2->Pages[main_tab_index];



        NEW();


        OpenRecent1->Click();

        
}
//---------------------------------------------------------------------------











void __fastcall Tfmain::m_com_inKeyDown(TObject *Sender, WORD &Key,
      TShiftState Shift)
{
        unsigned long int i;



        if(Key == VK_RETURN){
        	textarea_data = textarea_data + "\n\rSol-1 says: " + m_com_in->Text + "\n\r";
        m_com_in->Clear();
        m_com_in->SetFocus();
        }

}
//---------------------------------------------------------------------------










String fetchpage(String filename){
        FILE *fp;
        char html[1024 * 128];
        int i;

        i = 0;
        if((fp = fopen(filename.c_str(), "rb")) != NULL){
            while(!feof(fp)){
                    fread(html+i, sizeof(char), 1, fp);
                    i++;
            }
            html[i-1] = '\0';

            fclose(fp);
        }

        return AnsiString(html);
}



String toHTML(String s){
        int i;

        for(i = 1; i <= s.Length(); i++){
                if(s[i] == ' '){
                        s.Delete(i, 1);
                        s.Insert("&nbsp;", i);
                }
                else if(s[i] == '\n'){
                        s.Delete(i, 1);
                        s.Insert("<br>", i);
                }

        }
        return s;
}





void __fastcall Tfmain::FormActivate(TObject *Sender)
{
        FILE *fp;
        char html[1024 * 128];
        int i;

        i = 0;
        if((fp = fopen("web\\html_top.txt", "rb")) != NULL){
            while(!feof(fp)){
                    fread(html+i, sizeof(char), 1, fp);
                    i++;
            }
            html[i-1] = '\0';

            fclose(fp);
        }

        HTML = HTML + AnsiString(html);


        i = 0;
        if((fp = fopen("web\\html_bottom.txt", "rb")) != NULL){
            while(!feof(fp)){
                    fread(html+i, sizeof(char), 1, fp);
                    i++;
            }
            html[i-1] = '\0';

            fclose(fp);
        }

        HTMLbottom = AnsiString(html);

        Button11->Click();

}
//---------------------------------------------------------------------------














void __fastcall Tfmain::Button16Click(TObject *Sender)
{
        FILE *fp;
        char html[1024 * 128];
        int i;

        HTML = "";

        i = 0;
        if((fp = fopen("web\\html_top.txt", "rb")) != NULL){
            while(!feof(fp)){
                    fread(html+i, sizeof(char), 1, fp);
                    i++;
            }
            html[i-1] = '\0';

            fclose(fp);
        }

        HTML = HTML + AnsiString(html);


        i = 0;
        if((fp = fopen("web\\html_bottom.txt", "rb")) != NULL){
            while(!feof(fp)){
                    fread(html+i, sizeof(char), 1, fp);
                    i++;
            }
            html[i-1] = '\0';

            fclose(fp);
        }

        HTMLbottom = AnsiString(html);

        textarea_data = "";

        memo_textarea->Clear();
}
//---------------------------------------------------------------------------























void __fastcall Tfmain::IdHTTPServer1CommandGet(TIdPeerThread *AThread,
      TIdHTTPRequestInfo *RequestInfo, TIdHTTPResponseInfo *ResponseInfo)
{
    char c[1024*128];
    unsigned long int i, L, N;
    //String s;
    int pos;

    String param, value;
    String files;
    TSearchRec sr;
    String sleephtml = "";
    String doc;

    FILE *fp;
    char obj[1024*128];
    String hex_asm = "";
    String listing = "";
    String HTMLdoc= "";


    doc = RequestInfo->Document;

    if(doc == "/"){
        ResponseInfo->ContentType = "text/html";


        param = RequestInfo->Params[0].Text;
        pos = param.Pos("=");
        param = param.SubString(0, pos - 1);

        value = RequestInfo->Params[0].Text;
        pos = value.Pos("=") + 1;
        value = value.SubString(pos, value.Length() - pos);

        if(param == "download"){
                ResponseInfo->ContentType = IdHTTPServer1->MIMETable->GetFileMIMEType(value.Trim());

                IdHTTPServer1->ServeFile(AThread, ResponseInfo, value.Trim());

                memo_com_out->Lines->Add(RequestInfo->RemoteIP + " downloaded: " + value);

        }
        else if(param == "cpu_command"){
        	unsigned long h;

            strcpy(c, value.c_str());

            if(c[0] == 'c' && c[1] == 'l' && c[2] == 's'){
                textarea_data = "";
                ResponseInfo->ContentText = HTML + HTMLbottom + "</body></html>";
                return;
            }

            for(i = 0; i < strlen(c); i++){
                if(c[i] == 0x0A){
                        c[i] = 0x0D;
                        L = i + 1;

                        break;
                }
                else if(c[i] == 0x0D){
                        L = i + 1;

                        break;
                }
            }

            for(i = 0; i < strlen(c); i++){
                WriteFile(hSerial, &c[i], 1, &h, NULL);
                Sleep((unsigned int)1);
            }
            ResponseInfo->ContentText = HTML + HTMLbottom + "</body></html>";
            memo_com_out->Lines->Add(RequestInfo->RemoteIP + " sent: " + value);
        }
        else{
        	ResponseInfo->ContentText = HTML + HTMLbottom + "</body></html>";
        }
    }
    else{
        param = RequestInfo->Params[0].Text;
        pos = param.Pos("=");
        param = param.SubString(0, pos - 1);

        value = RequestInfo->Params[0].Text;
        pos = value.Pos("=") + 1;
        value = value.SubString(pos, value.Length() - pos);

        if(param == "assembly"){
            value = value.Trim();
            fp = fopen("asm\\online_asm.asm", "wb");
            fwrite(value.c_str(), sizeof(char), value.Length(), fp);
            fclose(fp);
            ShellExecute(NULL, NULL, "tasm.exe", " -1 -b online_asm.asm",  "asm", SW_SHOWNORMAL);

            Sleep((unsigned int)1000);
            N = 0;
            fp = fopen("asm\\online_asm.obj", "rb");
            fseek(fp, 0, SEEK_END);
            N = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            fread(obj, sizeof(char), N, fp);
            fclose(fp);
            hex_asm = "";
            for(i = 0; i < N; i++){
                    hex_asm = hex_asm + hexstr_char(obj[i]);
            }


            N = 0;
            fp = fopen("asm\\online_asm.lst", "rb");
            fseek(fp, 0, SEEK_END);
            N = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            fread(obj, sizeof(char), N, fp);
            fclose(fp);
            listing = "";
            for(i = 0; i < N; i++){
                    listing = listing + obj[i];
            }

            ResponseInfo->ContentText = "Machine code:<br><textarea cols=""150"" rows=""20"" class=""editor_green"">" + hex_asm + "</textarea><br><br>Listing:<br><textarea cols=""150"" rows=""40"" class=""editor_green"">" + listing + "</textarea></h2></body></html>";

            memo_com_out->Lines->Add(RequestInfo->RemoteIP + " requested the assembler.");
        }
        else if(doc == "/getdata"){

            ResponseInfo->ContentText = textarea_data;

        }
        else if(doc == "/directory"){
            TSearchRec SR;
            if(FindFirst(GetCurrentDir() + "\\web\\*.*", faArchive, SR) == 0){
                do{
                    ResponseInfo->ContentText = ResponseInfo->ContentText + "<a href=""http://sol.uk.ms?download=" + SR.Name + """>" + SR.Name + "</a>" + "<br>";
                }
                while(FindNext(SR) == 0);
                FindClose(SR);

            }

        }
        else{
            ResponseInfo->ContentType = "text/html";
            N = 0;
            doc = doc.Delete(1, 1);
            fp = fopen((GetCurrentDir() + "\\web\\" + doc).c_str(), "rb");
            fseek(fp, 0, SEEK_END);
            N = ftell(fp);
            fseek(fp, 0, SEEK_SET);
            fread(obj, sizeof(char), N, fp);
            fclose(fp);
            ResponseInfo->ContentText = AnsiString(obj);
        }
    }



    if(RequestInfo->RemoteIP != "192.168.0.1")
            memo_com_out->Lines->Add(RequestInfo->RemoteIP + " has connected...");
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::Button11Click(TObject *Sender)
{
    String comport;

        comport = edtport->Text;

        hSerial = CreateFile(comport.c_str(), GENERIC_READ | GENERIC_WRITE, 0, NULL, OPEN_EXISTING , FILE_ATTRIBUTE_NORMAL, NULL );

        if (hSerial == INVALID_HANDLE_VALUE){
            memo_com_out->Lines->Add("Error opening port.");
            CloseHandle(hSerial);
            return;
        }
        else
                memo_com_out->Lines->Add(AnsiString(comport) + " open.");

        if (!FlushFileBuffers(hSerial)){
                memo_com_out->Lines->Add("Error flushing port.");
                CloseHandle(hSerial);
                return;
        }

        dcbSerialParams.DCBlength = sizeof(dcbSerialParams);
        if (GetCommState(hSerial, &dcbSerialParams) == 0){
                memo_com_out->Lines->Add("Error getting device state.");
                CloseHandle(hSerial);
                return;
        }                                

        dcbSerialParams.BaudRate = StrToInt(edtbaud->Text);
        dcbSerialParams.ByteSize = StrToInt(edtdatabits->Text);
        dcbSerialParams.StopBits = StrToInt(edtstopbits->Text);
        dcbSerialParams.Parity = NOPARITY;

        if(SetCommState(hSerial, &dcbSerialParams) == 0){
                memo_com_out->Lines->Add("Error setting device parameters.");
                CloseHandle(hSerial);
                return;
        }

        
        timeouts.ReadIntervalTimeout = 0;
        timeouts.ReadTotalTimeoutConstant = StrToInt(edt_timeout->Text);
        timeouts.ReadTotalTimeoutMultiplier = 0;
        timeouts.WriteTotalTimeoutConstant = StrToInt(edt_timeout->Text);
        timeouts.WriteTotalTimeoutMultiplier = 0;

        if(SetCommTimeouts(hSerial, &timeouts) == 0){
            memo_com_out->Lines->Add("Error setting timeouts.");
            CloseHandle(hSerial);
        }
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button8Click(TObject *Sender)
{
    if(IdHTTPServer1->Active == true){
        IdHTTPServer1->Active = false;
        memo_com_out->Lines->Add("Server now OFF...");
        Button8->Caption = "Turn Server ON";
    }
    else{
        IdHTTPServer1->Active = true;
        memo_com_out->Lines->Add("Server now ON...");
        Button8->Caption = "Turn Server OFF";
    }
}
//---------------------------------------------------------------------------


void __fastcall Tfmain::Save1Click(TObject *Sender)
{
	FILE *fp;

        char name[STRING_LEN];
        char fullname[STRING_LEN];
        int pos;

        int val;
        int i, j, k;


        if(Application->MessageBoxA("Save file?", "Confirm save", MB_YESNO | MB_ICONQUESTION) == IDYES){
            strcpy(fullname, ExtractFileName(filename).c_str());
            strcpy(name, fullname);
            fp = fopen(name, "w+b");
            fwrite(info, sizeof(char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR * INFO_LEN, fp);
            fwrite(instr_names, sizeof(char), NBR_INSTRUCTIONS * STRING_LEN, fp);
            fclose(fp);

            for(i = 0; i < 15; i++){
                    strcpy(name, fullname);
                    strcat(name, IntToStr(i).c_str());
                    fp = fopen(name, "w+b");
                    fwrite(&ROMS[i], sizeof(unsigned char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR, fp);
                    fclose(fp);

            }

            
            if((fp = fopen("opcode_list.txt", "w+b")) != NULL){
    			fputs(ListBox2->Items->Text.c_str(), fp);
        		fclose(fp);
			}

        }	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::SaveAs1Click(TObject *Sender)
{
	WRITE();	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Open1Click(TObject *Sender)
{
	int i ;

        READ();

        cycle_nbr = 0;
        update_display();


        ListBox2->Clear();
        for(i = 0; i < 256; i++){

                fmain->ListBox2->Items->Add(instr_names[i]);


        }	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::OpenRecent1Click(TObject *Sender)
{
	FILE *fp;
        TIniFile *ini;
        String latest;
        char fullname[STRING_LEN], name[STRING_LEN];
        int pos;
        int val;
        int i, j, k;

        ini = new TIniFile(GetCurrentDir() + "\\config.ini");
        latest = ini->ReadString("general", "last_microcode_open", "");
        delete ini;

        strcpy(filename, latest.c_str());
        


        if(strcmp(filename, "") != 0){
            fmain->Caption = filename;
            fp = fopen(filename, "r+b");
            fread(info, sizeof(char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR * INFO_LEN, fp);
            fread(instr_names, sizeof(char), NBR_INSTRUCTIONS * STRING_LEN, fp);
            fclose(fp);

            for(i = 0; i < 15; i++){
                    strcpy(name, filename);
                    strcat(name, IntToStr(i).c_str());
                    fp = fopen(name, "r+b");
                    fread(&ROMS[i], sizeof(unsigned char), NBR_INSTRUCTIONS * CYCLES_PER_INSTR, fp);
                    fclose(fp);

            }


            fmain->ListBox2->Clear();
            for(i = 0; i < 256; i++){
                    fmain->list_names->Items->Add(hexstr(i) + ": " + instr_names[i]);

                    fmain->ListBox2->Items->Add(instr_names[i]);

            }



            cycle_nbr = 0;
            update_display();
        }	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::New1Click(TObject *Sender)
{
	NEW();
        memo_info->Clear();	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Copyinstruction1Click(TObject *Sender)
{
	int from;
    int i, j;


    if(PageControl2->TabIndex > 0) return;

    from_origin = list_names->ItemIndex * CYCLES_PER_INSTR;

    strcpy(instr_name_clip, instr_names[list_names->ItemIndex]);

    j = 0;
    for(i = from_origin; i < from_origin + 64; i++){
            strcpy(info_clip[j], info[i]);
            clipboard[j][0] = ROMS[0][i];
            clipboard[j][1] = ROMS[1][i];
            clipboard[j][2] = ROMS[2][i];
            clipboard[j][3] = ROMS[3][i];
            clipboard[j][4] = ROMS[4][i];
            clipboard[j][5] = ROMS[5][i];
            clipboard[j][6] = ROMS[6][i];
            clipboard[j][7] = ROMS[7][i];
            clipboard[j][8] = ROMS[8][i];
            clipboard[j][9] = ROMS[9][i];
            clipboard[j][10] = ROMS[10][i];
            clipboard[j][11] = ROMS[11][i];
            clipboard[j][12] = ROMS[12][i];
            clipboard[j][13] = ROMS[13][i];
            j++;
    }
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::PasteInstruction1Click(TObject *Sender)
{
	int from;
    int i, j;

    if(PageControl2->TabIndex > 0) return;
    
	from_dest = list_names->ItemIndex * CYCLES_PER_INSTR;

    strcpy(instr_names[from_origin / 64], instr_names[list_names->ItemIndex]);
    strcpy(instr_names[list_names->ItemIndex], instr_name_clip);

    j = from_origin;
    for(i = from_dest; i < from_dest + 64; i++){
            strcpy(info[j], info[i]);
            ROMS[0][j] = ROMS[0][i];
            ROMS[1][j] = ROMS[1][i];
            ROMS[2][j] = ROMS[2][i];
            ROMS[3][j] = ROMS[3][i];
            ROMS[4][j] = ROMS[4][i];
            ROMS[5][j] = ROMS[5][i];
            ROMS[6][j] = ROMS[6][i];
            ROMS[7][j] = ROMS[7][i];
            ROMS[8][j] = ROMS[8][i];
            ROMS[9][j] = ROMS[9][i];
            ROMS[10][j] = ROMS[10][i];
            ROMS[11][j] = ROMS[11][i];
            ROMS[12][j] = ROMS[12][i];
            ROMS[13][j] = ROMS[13][i];
            j++;
    }

    j = 0;
    for(i = from_dest; i < from_dest + 64; i++){
            strcpy(info[i], info_clip[j]);
            ROMS[0][i] = clipboard[j][0];
            ROMS[1][i] = clipboard[j][1];
            ROMS[2][i] = clipboard[j][2];
            ROMS[3][i] = clipboard[j][3];
            ROMS[4][i] = clipboard[j][4];
            ROMS[5][i] = clipboard[j][5];
            ROMS[6][i] = clipboard[j][6];
            ROMS[7][i] = clipboard[j][7];
            ROMS[8][i] = clipboard[j][8];
            ROMS[9][i] = clipboard[j][9];
            ROMS[10][i] = clipboard[j][10];
            ROMS[11][i] = clipboard[j][11];
            ROMS[12][i] = clipboard[j][12];
            ROMS[13][i] = clipboard[j][13];
            j++;
    }

    update_display();

}
//---------------------------------------------------------------------------







void __fastcall Tfmain::combo_alu_cf_out_invSelect(TObject *Sender)
{
	int index = combo_alu_cf_out_inv->ItemIndex;

    control_list->Checked[control_list->Items->IndexOf("alu_cf_out_inv")] = index == 1;

    write_cycle();
}
//---------------------------------------------------------------------------




void __fastcall Tfmain::N110Click(TObject *Sender)
{
	list_names->Columns = 1;
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N28Click(TObject *Sender)
{
	list_names->Columns = 2;	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N33Click(TObject *Sender)
{
	list_names->Columns = 3;	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N43Click(TObject *Sender)
{
	list_names->Columns = 4;	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::N53Click(TObject *Sender)
{
	list_names->Columns = 5;	
}
//---------------------------------------------------------------------------




void __fastcall Tfmain::MicrocodeEditor1Click(TObject *Sender)
{
	Panel2->Visible = !Panel2->Visible;	
}
//---------------------------------------------------------------------------





void __fastcall Tfmain::Button2Click(TObject *Sender)
{
	telnet->Open();	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::Button9Click(TObject *Sender)
{
	telnet->Close();	
}
//---------------------------------------------------------------------------

void __fastcall Tfmain::telnetClientConnect(TObject *Sender,
      TCustomWinSocket *Socket)
{
	Socket->SendText("Connected.");	
}
//---------------------------------------------------------------------------





void __fastcall Tfmain::telnetClientRead(TObject *Sender,
      TCustomWinSocket *Socket)
{
	String s;
	char c[1024*128];
    unsigned long int i, L, N;
    //String s;
    int pos;

    Socket->ReceiveBuf(c, 1024*2);

    for(i = 0; i < strlen(c); i++){
            if(c[i] == 0x0A){
                    c[i] = 0x0D;
                    L = i + 1;
                    break;
            }
            else if(c[i] == 0x0D){
                    L = i + 1;
                    break;
            }
    }

    unsigned long h;
    for(i = 0; i < strlen(c); i++){
        WriteFile(hSerial, &c[i], 1, &h, NULL);
    }
}
//---------------------------------------------------------------------------



void __fastcall Tfmain::ReadOnly1Click(TObject *Sender)
{
	ReadOnly1->Checked = !ReadOnly1->Checked;
    read_only = ReadOnly1->Checked;
}
//---------------------------------------------------------------------------


