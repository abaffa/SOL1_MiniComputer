//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "options.h"
#include "sim.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
Tfoptions *foptions;
//---------------------------------------------------------------------------
__fastcall Tfoptions::Tfoptions(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------
void __fastcall Tfoptions::Button2Click(TObject *Sender)
{
        foptions->Close();        
}
//---------------------------------------------------------------------------











