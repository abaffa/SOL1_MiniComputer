//---------------------------------------------------------------------------

#ifndef simH
#define simH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <Grids.hpp>
#include <ComCtrls.hpp>
#include <Menus.hpp>
#include <Buttons.hpp>
#include <ToolWin.hpp>
#include <Graphics.hpp>
#include <CheckLst.hpp>
#include <ValEdit.hpp>
#include "CGAUGES.h"
#include <Outline.hpp>
#include <FileCtrl.hpp>
#include <OleCtnrs.hpp>
#include <Dialogs.hpp>
#include <AppEvnts.hpp>
#include "trayicon.h"
#include "CGRID.h"
#include "PERFGRAP.h"
#include <ActnList.hpp>
#include <ActnMan.hpp>
#include <ScktComp.hpp>
#include <MPlayer.hpp>
#include <IdBaseComponent.hpp>
#include <IdComponent.hpp>
#include <IdMappedPortTCP.hpp>
#include <IdTCPServer.hpp>
#include <Sockets.hpp>
#include <IdHTTP.hpp>
#include <IdTCPClient.hpp>
#include <IdTCPConnection.hpp>
#include <IdTelnet.hpp>
#include <IdTelnetServer.hpp>
#include <IdHTTPServer.hpp>
#include "SHDocVw_OCX.h"
#include <OleServer.hpp>
#include <DB.hpp>
#include <DBTables.hpp>
#include <DBCtrls.hpp>
#include <DBGrids.hpp>
#include <IdTrivialFTPServer.hpp>
#include <IdUDPBase.hpp>
#include <IdUDPServer.hpp>
#include <IdIMAP4Server.hpp>
#include <IdSimpleServer.hpp>
//---------------------------------------------------------------------------
class Tfmain : public TForm
{
__published:	// IDE-managed Components
        TOpenDialog *OpenDialog1;
        TSaveDialog *SaveDialog2;
        TPopupMenu *PopupMenu1;
        TMenuItem *Copy1;
        TMenuItem *Paste1;
        TMenuItem *Insert1;
        TPopupMenu *PopupMenu2;
        TMenuItem *microcodetype1;
        TMenuItem *offset1;
        TMenuItem *branch1;
        TMenuItem *prefetch1;
        TMenuItem *postfetch1;
        TMenuItem *conditioncode1;
        TMenuItem *MDRSource1;
        TMenuItem *ZBus1;
        TMenuItem *DataBus1;
        TMenuItem *MDRSourceOut1;
        TMenuItem *Low1;
        TMenuItem *High1;
        TMenuItem *MARSource1;
        TMenuItem *ZBus2;
        TMenuItem *PC1;
        TMenuItem *N3;
        TMenuItem *N4;
        TMenuItem *ALUAInput1;
        TMenuItem *ALuB1;
        TMenuItem *ALUOperation1;
        TMenuItem *al1;
        TMenuItem *ah1;
        TMenuItem *bl1;
        TMenuItem *bh1;
        TMenuItem *cl1;
        TMenuItem *ch1;
        TMenuItem *mdrl1;
        TMenuItem *mdrh1;
        TMenuItem *tdrl1;
        TMenuItem *tdrh1;
        TMenuItem *immediate1;
        TMenuItem *Addition1;
        TMenuItem *Subtraction1;
        TMenuItem *And1;
        TMenuItem *Or1;
        TMenuItem *Xor1;
        TMenuItem *N5;
        TMenuItem *A1;
        TMenuItem *B1;
        TMenuItem *N6;
        TMenuItem *ALUCFInSrc1;
        TMenuItem *vcc1;
        TMenuItem *gnd1;
        TMenuItem *CF1;
        TMenuItem *CF2;
        TMenuItem *UCF1;
        TMenuItem *UCF2;
        TMenuItem *N7;
        TMenuItem *ZFInSrc1;
        TMenuItem *KeepZF1;
        TMenuItem *ALUZF1;
        TMenuItem *ALUZFZF1;
        TPanel *Panel1;
        TPageControl *PageControl2;
        TTabSheet *TabSheet2;
        TPanel *Panel2;
        TPanel *Panel4;
        TTabSheet *TabSheet9;
        TMenuItem *N8;
        TMenuItem *N9;
        TMenuItem *Shift1;
        TMenuItem *N11;
        TMenuItem *N21;
        TMenuItem *N31;
        TMenuItem *N41;
        TMenuItem *N51;
        TMenuItem *N101;
        TMenuItem *N10;
        TMenuItem *Reset1;
        TMenuItem *ShiftLeft1;
        TMenuItem *N12;
        TMenuItem *N22;
        TMenuItem *N32;
        TMenuItem *N42;
        TMenuItem *N52;
        TMenuItem *N102;
        TPanel *Panel15;
        TPanel *Panel10;
        TGroupBox *GroupBox2;
        TComboBox *combo_type;
        TComboBox *combo_cond;
        TComboBox *combo_flags_src;
        TEdit *edt_integer;
        TButton *Button19;
        TButton *Button20;
        TGroupBox *GroupBox1;
        TComboBox *combo_zbus;
        TGroupBox *GroupBox3;
        TComboBox *combo_of_in;
        TComboBox *combo_sf_in;
        TComboBox *combo_cf_in;
        TComboBox *combo_zf_in;
        TGroupBox *GroupBox4;
        TComboBox *combo_aluAmux;
        TComboBox *combo_aluBmux;
        TGroupBox *GroupBox5;
        TComboBox *combo_mdr_src_out;
        TComboBox *combo_mdr_src;
        TGroupBox *GroupBox6;
        TComboBox *combo_uof;
        TComboBox *combo_usf;
        TComboBox *combo_ucf;
        TComboBox *combo_uzf;
        TGroupBox *GroupBox7;
        TComboBox *combo_aluop;
        TComboBox *combo_alu_cf_in;
        TPanel *Panel5;
        TTabSheet *TabSheet1;
        TPanel *Panel23;
        TPanel *Panel27;
        TButton *Button11;
        TLabeledEdit *edtbaud;
        TLabeledEdit *edtport;
        TLabeledEdit *edtdatabits;
        TLabeledEdit *edtstopbits;
        TButton *Button10;
        TOpenDialog *OpenDialog2;
        TMemo *memo_com_out;
        TButton *Button26;
        TPopupMenu *PopupMenu3;
        TMenuItem *Bookmark1;
        TStatusBar *StatusBar1;
        TMainMenu *MainMenu1;
        TMenuItem *File1;
        TMenuItem *New1;
        TMenuItem *Open1;
        TMenuItem *Save1;
        TMenuItem *SaveAs1;
        TMenuItem *Tools1;
        TMenuItem *CalculateAvgCyclesperInstruction1;
        TMemo *Memo1;
        TMenuItem *N2;
        TMenuItem *GenerateTASMTable1;
        TMenuItem *COM1;
        TMenuItem *N13;
        TMenuItem *Options1;
        TSaveDialog *SaveDialog1;
        TFontDialog *FontDialog1;
        TMenuItem *N15;
        TMenuItem *Copy2;
        TMenuItem *Copy3;
        TMenuItem *SelectAll1;
        TMenuItem *N16;
        TMenuItem *Find1;
        TPopupMenu *PopupMenu4;
        TMenuItem *Sorted1;
        TMenuItem *N17;
        TMenuItem *Wordwrap1;
        TMenuItem *Open3;
        TMenuItem *Directory1;
        TMenuItem *Hexeditor1;
        TMenuItem *Programmer1;
        TMenuItem *Commandprompt1;
        TMenuItem *Calculator1;
        TMenuItem *Notepad1;
        TButton *Button1;
        TButton *Button17;
        TButton *Button14;
        TButton *Button18;
        TSpeedButton *SpeedButton7;
        TButton *Button15;
        TBitBtn *BitBtn2;
        TButton *Button32;
        TButton *Button4;
        TButton *Button3;
        TButton *Button30;
        TBitBtn *BitBtn1;
        TButton *Button13;
        TButton *Button12;
        TButton *Button7;
        TButton *Button6;
        TButton *Button5;
        TMenuItem *View1;
        TMenuItem *Prompt1;
        TMenuItem *Openport1;
        TMenuItem *Closeport1;
        TMenuItem *N23;
        TMenuItem *Clearterminal1;
        TMenuItem *N24;
        TMenuItem *Sendfile1;
        TTimer *Timer1;
        TMenuItem *N25;
        TMenuItem *N26;
        TMenuItem *N19;
        TMenuItem *ASCIITable1;
        TMenuItem *N27;
        TMenuItem *Open4;
        TMenuItem *Save3;
        TMenuItem *SaveAs3;
        TMenuItem *Assemble2;
        TMemo *m_com_in;
        TIdHTTPServer *IdHTTPServer1;
        TButton *Button16;
    TMemo *memo_textarea;
    TSplitter *Splitter3;
    TButton *Button8;
	TLabeledEdit *edt_timeout;
	TLabeledEdit *edt_chars;
	TMenuItem *OpenRecent1;
	TMenuItem *Microcodeedit1;
	TMenuItem *Copyinstruction1;
	TMenuItem *PasteInstruction1;
	TGroupBox *GroupBox8;
	TComboBox *combo_mar_src;
	TComboBox *combo_alu_cf_out_inv;
	TGroupBox *GroupBox9;
	TComboBox *combo_shift_src;
	TListBox *ListBox2;
	TMenuItem *N14;
	TMenuItem *MicrocodeInstructioncolumns1;
	TMenuItem *N110;
	TMenuItem *N28;
	TMenuItem *N33;
	TMenuItem *N43;
	TMenuItem *N53;
	TPanel *Panel8;
	TPanel *Panel9;
	TCheckListBox *control_list;
	TPanel *Panel3;
	TMemo *memo_info;
	TMemo *memo_name;
	TListBox *list_cycle;
	TSplitter *Splitter2;
	TMenuItem *MicrocodeEditor1;
	TListBox *list_names;
	TSplitter *Splitter1;
	TServerSocket *telnet;
	TButton *Button2;
	TButton *Button9;
	TMenuItem *Settings1;
	TMenuItem *MicrocodeEditor2;
	TMenuItem *ReadOnly1;
	TMenuItem *Options2;
        void __fastcall Button3Click(TObject *Sender);
        void __fastcall Button4Click(TObject *Sender);
        void __fastcall Button34Click(TObject *Sender);
        void __fastcall SpeedButton7Click(TObject *Sender);
        void __fastcall Button5Click(TObject *Sender);
        void __fastcall Button6Click(TObject *Sender);
        void __fastcall Button7Click(TObject *Sender);
        void __fastcall Button12Click(TObject *Sender);
        void __fastcall Button13Click(TObject *Sender);
        void __fastcall control_listClickCheck(TObject *Sender);
        void __fastcall memo_infoKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall memo_infoKeyUp(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall list_cycleClick(TObject *Sender);
        void __fastcall combo_typeSelect(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall Button17Click(TObject *Sender);
        void __fastcall Button18Click(TObject *Sender);
        void __fastcall Button20Click(TObject *Sender);
        void __fastcall Button19Click(TObject *Sender);
        void __fastcall combo_aluAmuxSelect(TObject *Sender);
        void __fastcall combo_aluBmuxSelect(TObject *Sender);
        void __fastcall combo_aluopSelect(TObject *Sender);
        void __fastcall Copy1Click(TObject *Sender);
        void __fastcall Paste1Click(TObject *Sender);
        void __fastcall BitBtn1Click(TObject *Sender);
        void __fastcall BitBtn2Click(TObject *Sender);
        void __fastcall combo_condSelect(TObject *Sender);
        void __fastcall combo_alu_cf_inSelect(TObject *Sender);
        void __fastcall combo_mdr_srcSelect(TObject *Sender);
        void __fastcall combo_mar_srcSelect(TObject *Sender);
        void __fastcall combo_zf_inSelect(TObject *Sender);
        void __fastcall combo_cf_inSelect(TObject *Sender);
        void __fastcall combo_sf_inSelect(TObject *Sender);
        void __fastcall combo_of_inSelect(TObject *Sender);
        void __fastcall list_namesClick(TObject *Sender);
        void __fastcall memo_nameChange(TObject *Sender);
        void __fastcall combo_flags_srcSelect(TObject *Sender);
        void __fastcall combo_mdr_src_outSelect(TObject *Sender);
        void __fastcall combo_shift_srcSelect(TObject *Sender);
        void __fastcall combo_zbusSelect(TObject *Sender);
        void __fastcall combo_uzfSelect(TObject *Sender);
        void __fastcall combo_ucfSelect(TObject *Sender);
        void __fastcall combo_usfSelect(TObject *Sender);
        void __fastcall combo_uofSelect(TObject *Sender);
        void __fastcall N11Click(TObject *Sender);
        void __fastcall N21Click(TObject *Sender);
        void __fastcall N31Click(TObject *Sender);
        void __fastcall N41Click(TObject *Sender);
        void __fastcall N51Click(TObject *Sender);
        void __fastcall N101Click(TObject *Sender);
        void __fastcall StringGrid2KeyPress(TObject *Sender, char &Key);
        void __fastcall StringGrid2SelectCell(TObject *Sender, int ACol,
          int ARow, bool &CanSelect);
        void __fastcall list_cycleKeyPress(TObject *Sender, char &Key);
        void __fastcall Reset1Click(TObject *Sender);
        void __fastcall Button10Click(TObject *Sender);
        void __fastcall Button26Click(TObject *Sender);
        void __fastcall FormDestroy(TObject *Sender);
        void __fastcall Button30Click(TObject *Sender);
        void __fastcall Button32Click(TObject *Sender);
        void __fastcall CalculateAvgCyclesperInstruction1Click(
          TObject *Sender);
        void __fastcall GenerateTASMTable1Click(TObject *Sender);
        void __fastcall Find1Click(TObject *Sender);
        void __fastcall memo_text12Enter(TObject *Sender);
        void __fastcall Sorted1Click(TObject *Sender);
        void __fastcall Directory1Click(TObject *Sender);
        void __fastcall Button15Click(TObject *Sender);
        void __fastcall Prompt1Click(TObject *Sender);
        void __fastcall Timer1Timer(TObject *Sender);
        void __fastcall ASCIITable1Click(TObject *Sender);
        void __fastcall memo_text112Enter(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
        void __fastcall m_com_inKeyDown(TObject *Sender, WORD &Key,
          TShiftState Shift);
        void __fastcall FormActivate(TObject *Sender);
        void __fastcall Button16Click(TObject *Sender);
    void __fastcall IdHTTPServer1CommandGet(TIdPeerThread *AThread,
          TIdHTTPRequestInfo *RequestInfo,
          TIdHTTPResponseInfo *ResponseInfo);
    void __fastcall Button11Click(TObject *Sender);
    void __fastcall Button8Click(TObject *Sender);
	void __fastcall Save1Click(TObject *Sender);
	void __fastcall SaveAs1Click(TObject *Sender);
	void __fastcall Open1Click(TObject *Sender);
	void __fastcall OpenRecent1Click(TObject *Sender);
	void __fastcall New1Click(TObject *Sender);
	void __fastcall Copyinstruction1Click(TObject *Sender);
	void __fastcall PasteInstruction1Click(TObject *Sender);
	void __fastcall combo_alu_cf_out_invSelect(TObject *Sender);
	void __fastcall N110Click(TObject *Sender);
	void __fastcall N28Click(TObject *Sender);
	void __fastcall N33Click(TObject *Sender);
	void __fastcall N43Click(TObject *Sender);
	void __fastcall N53Click(TObject *Sender);
	void __fastcall MicrocodeEditor1Click(TObject *Sender);
	void __fastcall Button2Click(TObject *Sender);
	void __fastcall Button9Click(TObject *Sender);
	void __fastcall telnetClientConnect(TObject *Sender,
          TCustomWinSocket *Socket);
	void __fastcall telnetClientRead(TObject *Sender,
          TCustomWinSocket *Socket);
	void __fastcall ReadOnly1Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
	__fastcall Tfmain(TComponent* Owner);
        void write_cycle(void);

        struct{
                char name[128];
                int start;
        } bookmarks[256];
        int bookmark_tos;
};
//---------------------------------------------------------------------------
extern PACKAGE Tfmain *fmain;
//---------------------------------------------------------------------------
#endif
