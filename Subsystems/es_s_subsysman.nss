/*
    ScriptName: es_s_subsysman.nss
    Created by: Daz

    Required NWNX Plugins:
        @NWNX[]

    Description:
*/

//void main() {}

#include "es_inc_core"
#include "es_srv_concom"

const string SUBSYSTEM_MANAGER_LOG_TAG      = "SubsystemManager";
const string SUBSYSTEM_MANAGER_SCRIPT_NAME  = "es_s_subsysman";

const float SUBSYSTEM_MANAGER_IGNORE_TIME   = 2.5f;

// @Load
void SubsystemManager_Load(string sSubsystemScript)
{
    ES_Core_SubscribeEvent_NWNX(sSubsystemScript, "NWNX_ON_RESOURCE_MODIFIED");
}

// @EventHandler
void SubsystemManager_EventHandler(string sSubsystemScript, string sEvent)
{
    if (sEvent == "NWNX_ON_RESOURCE_MODIFIED")
    {
        string sAlias = ES_Util_GetEventData_NWNX_String("ALIAS");
        int nType = ES_Util_GetEventData_NWNX_Int("TYPE");

        if (sAlias == "NWNX" && nType == NWNX_UTIL_RESREF_TYPE_NSS)
        {
            string sResRef = ES_Util_GetEventData_NWNX_String("RESREF");

            if (GetStringLeft(sResRef, 5) == "es_s_")
            {
                object oDataObject = ES_Util_GetDataObject(SUBSYSTEM_MANAGER_SCRIPT_NAME);
                object oSubsystem = ES_Core_GetComponentDataObject(sResRef, FALSE);

                if (GetIsObjectValid(oSubsystem))
                {
                    if (GetLocalInt(oDataObject, sResRef))
                        return;

                    SetLocalInt(oDataObject, sResRef, TRUE);
                    DelayCommand(SUBSYSTEM_MANAGER_IGNORE_TIME, DeleteLocalInt(oDataObject, sResRef));

                    string sScriptFlags = GetLocalString(oSubsystem, "Flags");

                    if (FindSubString(sScriptFlags, "HotSwap") != -1)
                    {
                        ES_Util_Log(SUBSYSTEM_MANAGER_LOG_TAG, "Detected changes for Subsystem '" + sResRef + "', recompiling EventHandler", FALSE);

                        ES_Core_Component_ExecuteFunction(sResRef, "Unload");

                        ES_Util_SuppressLog(TRUE);
                        ES_Core_Component_Initialize(sResRef, ES_CORE_COMPONENT_TYPE_SUBSYSTEM);
                        ES_Core_Component_CheckHash(sResRef);
                        ES_Util_SuppressLog(FALSE);

                        ES_Core_Component_ExecuteFunction(sResRef, "Load");

                    }
                }
            }
        }
    }
}

