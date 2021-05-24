//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop

#include "find.h"
#include "sim.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma resource "*.dfm"
Tffind *ffind;
//---------------------------------------------------------------------------
__fastcall Tffind::Tffind(TComponent* Owner)
        : TForm(Owner)
{
}
//---------------------------------------------------------------------------

int find_index = 0;

 