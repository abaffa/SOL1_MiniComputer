//---------------------------------------------------------------------------

#ifndef bookmarkH
#define bookmarkH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
//---------------------------------------------------------------------------
class Tfmark : public TForm
{
__published:	// IDE-managed Components
        TLabeledEdit *edt_mark;
        TButton *Button1;
        TButton *Button2;
        void __fastcall Button2Click(TObject *Sender);
        void __fastcall Button1Click(TObject *Sender);
        void __fastcall FormShow(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall Tfmark(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tfmark *fmark;
//---------------------------------------------------------------------------
#endif
