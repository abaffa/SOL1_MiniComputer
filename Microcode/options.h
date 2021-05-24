//---------------------------------------------------------------------------

#ifndef optionsH
#define optionsH
//---------------------------------------------------------------------------
#include <Classes.hpp>
#include <Controls.hpp>
#include <StdCtrls.hpp>
#include <Forms.hpp>
#include <ExtCtrls.hpp>
#include <Dialogs.hpp>
//---------------------------------------------------------------------------
class Tfoptions : public TForm
{
__published:	// IDE-managed Components
        TGroupBox *GroupBox1;
        TGroupBox *GroupBox2;
        TCheckBox *CheckBox1;
        TPanel *Panel1;
        TButton *Button2;
        TButton *Button15;
        TFontDialog *FontDialog1;
        TButton *Button1;
        TColorDialog *ColorDialog1;
        TButton *Button3;
        void __fastcall Button2Click(TObject *Sender);
private:	// User declarations
public:		// User declarations
        __fastcall Tfoptions(TComponent* Owner);
};
//---------------------------------------------------------------------------
extern PACKAGE Tfoptions *foptions;
//---------------------------------------------------------------------------
#endif
