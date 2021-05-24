//---------------------------------------------------------------------------

#include <vcl.h>
#include "global.h"
#pragma hdrstop

#include "bookmark.h"
#include "sim.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
Tfmark *fmark;

//---------------------------------------------------------------------------
__fastcall Tfmark::Tfmark(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall Tfmark::Button2Click(TObject *Sender)
{
        fmark->Close();        
}
//---------------------------------------------------------------------------
void __fastcall Tfmark::Button1Click(TObject *Sender)
{
        fmain->bookmarks[fmain->bookmark_tos].start = fmain->memo_text11->SelStart;
        strcpy(fmain->bookmarks[fmain->bookmark_tos].name, edt_mark->Text.c_str());
        fmain->list_mark->Items->Add(edt_mark->Text + ":" + IntToStr(fmain->bookmarks[fmain->bookmark_tos].start));
        fmain->bookmark_tos = fmain->bookmark_tos + 1;

        fmark->Close();
}
//---------------------------------------------------------------------------
void __fastcall Tfmark::FormShow(TObject *Sender)
{
        edt_mark->SetFocus();
}
//---------------------------------------------------------------------------
