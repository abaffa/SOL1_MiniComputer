//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
//---------------------------------------------------------------------------
USEFORM("sim.cpp", fmain);
USEFORM("find.cpp", ffind);
USEFORM("unit_prompt.cpp", f_prompt);
//---------------------------------------------------------------------------
WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
{
	try
	{
		Application->Initialize();
		Application->Title = "Microcode Builder";
                 Application->CreateForm(__classid(Tfmain), &fmain);
		Application->CreateForm(__classid(Tffind), &ffind);
		Application->CreateForm(__classid(Tf_prompt), &f_prompt);
		Application->Run();
	}
	catch (Exception &exception)
	{
		Application->ShowException(&exception);
	}
	catch (...)
	{
		try
		{
			throw Exception("");
		}
		catch (Exception &exception)
		{
			Application->ShowException(&exception);
		}
	}
	return 0;
}
//---------------------------------------------------------------------------
