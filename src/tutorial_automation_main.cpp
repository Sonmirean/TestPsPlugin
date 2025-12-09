
// SDK uses deprecated auto_ptr

#include <SPBasic.h>
#include <SPInterf.h>

#include <PIActionsPlugin.h>

#include <string.h>
#include <assert.h>

#include <DialogUtilitiesWin.cpp>
#include <PIDLLInstance.cpp>
#include <PIUSuites.cpp>
#include <PIUtilities.cpp>

//#include <imgui.h>

SPBasicSuite* sSPBasic = NULL;

SPErr UninitializePlugin()
{
	PIUSuitesRelease();
	return kSPNoError;
}


DLLExport SPAPI SPErr AutoPluginMain(const char* caller, const char* selector, void* message)
{
	SPErr status = kSPNoError;

	SPMessageData* basicMessage = (SPMessageData*)message;

	sSPBasic = basicMessage->basic;

	if (sSPBasic->IsEqual(caller, kSPInterfaceCaller)) {
		if (sSPBasic->IsEqual(selector, kSPInterfaceAboutSelector)) {
			//DoAbout(basicMessage->self, AboutID);
		}

		if (sSPBasic->IsEqual(selector, kSPInterfaceStartupSelector)) {
			return kSPNoError;
		}

		if (sSPBasic->IsEqual(selector, kSPInterfaceShutdownSelector)) {
			status = UninitializePlugin();
		}
	}

	if (sSPBasic->IsEqual(caller, kPSPhotoshopCaller)) {
		if (sSPBasic->IsEqual(selector, kPSDoIt)) {
			//ImGui::ShowDemoWindow();
		}
	}

	return status;
}