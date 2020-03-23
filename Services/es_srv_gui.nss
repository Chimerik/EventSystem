/*
    ScriptName: es_srv_gui.nss
    Created by: Daz

    Description: An EventSystem Service that provides various GUI functionality
*/

//void main() {}

#include "es_inc_core"

const string GUI_LOG_TAG                    = "GUI";
const string GUI_SCRIPT_NAME                = "es_srv_gui";
const string GUI_FONT_WINDOW_NAME           = "fnt_esgui";
const float GUI_PRELOAD_DELAY               = 5.0f;
const int GUI_PRELOAD_POSTSTRING_START_ID   = 10000;

const string GUI_WINDOW_TOP_LEFT            = "a";
const string GUI_WINDOW_TOP_RIGHT           = "c";
const string GUI_WINDOW_TOP_MIDDLE          = "b";
const string GUI_WINDOW_MIDDLE_LEFT         = "d";
const string GUI_WINDOW_MIDDLE_RIGHT        = "f";
const string GUI_WINDOW_MIDDLE_BLANK        = "i";
const string GUI_WINDOW_BOTTOM_LEFT         = "h";
const string GUI_WINDOW_BOTTOM_RIGHT        = "g";
const string GUI_WINDOW_BOTTOM_MIDDLE       = "e";

const int GUI_COLOR_WHITE                   = 0xFFFFFFFF;
const int GUI_COLOR_RED                     = 0xFF0000FF;

void GUI_PreloadFont(string sFont);
void GUI_Clear(object oPlayer, int nID);
void GUI_ClearRange(object oPlayer, int nStartID, int nEndID);
int GUI_CalculateStringLength(string sMessage, string sFont = "fnt_console");
int GUI_DrawWindow(object oPlayer, int nId, int nAnchor, int nX, int nY, int nWidth, int nHeight, float fLifetime = 1.0f);
int GUI_DrawConversationWindow(object oPlayer, int nId, int nWidth, int nHeight, float fLifetime = 1.0f);

// @Load
void GUI_Load(string sServiceScript)
{
    ES_Core_SubscribeEvent_Object(sServiceScript, EVENT_SCRIPT_MODULE_ON_CLIENT_ENTER);
}

// @EventHandler
void GUI_EventHandler(string sServiceScript, string sEvent)
{
    if (StringToInt(sEvent) == EVENT_SCRIPT_MODULE_ON_CLIENT_ENTER)
    {
        object oPlayer = GetEnteringObject();
        object oDataObject = ES_Util_GetDataObject(GUI_SCRIPT_NAME);

        int nNumPreloadableFonts = ES_Util_StringArray_Size(oDataObject, "PreloadFonts");

        int i;
        for (i = 0; i < nNumPreloadableFonts; i++)
        {
            string sFont = ES_Util_StringArray_At(oDataObject, "PreloadFonts", i);
            DelayCommand(GUI_PRELOAD_DELAY, PostString(oPlayer, "a", 0, 0, SCREEN_ANCHOR_TOP_LEFT, 1.0f, 0xFFFFFFF00, 0xFFFFFF00, GUI_PRELOAD_POSTSTRING_START_ID + i, sFont));
        }
    }
}

void GUI_PreloadFont(string sFont)
{
    object oDataObject = ES_Util_GetDataObject(GUI_SCRIPT_NAME);

    if (ES_Util_StringArray_Contains(oDataObject, "PreloadFonts", sFont) == -1)
    {
        ES_Util_Log(GUI_LOG_TAG, "Adding '" + sFont + "' to Preload List");

        ES_Util_StringArray_Insert(oDataObject, "PreloadFonts", sFont);
    }
}

void GUI_Clear(object oPlayer, int nID)
{
    PostString(oPlayer, "", 0, 0, SCREEN_ANCHOR_TOP_LEFT, 0.01f, 0xFFFFFF00, 0xFFFFFF00, nID);
}

void GUI_ClearRange(object oPlayer, int nStartID, int nEndID)
{
    int i;
    for(i = nStartID; i < nEndID; i++)
    {
        GUI_Clear(oPlayer, i);
    }
}

int GUI_CalculateStringLength(string sMessage, string sFont = "fnt_console")
{
    if (sFont == "fnt_console")
    {
        int nLength = GetStringLength(sMessage);
        int nPadding = ceil(((nLength / 4.5f) * 1.2f));

        return nLength + nPadding;
    }
    else
        return GetStringLength(sMessage);
}

int GUI_DrawWindow(object oPlayer, int nID, int nAnchor, int nX, int nY, int nWidth, int nHeight, float fLifetime = 10.0f)
{
    int nStartColor = 0xFFFFFFFF;
    int nEndColor   = 0xFFFFFFFF;

    string sTop = GUI_WINDOW_TOP_LEFT;
    string sMiddle = GUI_WINDOW_MIDDLE_LEFT;
    string sBottom = GUI_WINDOW_BOTTOM_LEFT;

    int i;
    for (i = 0; i < nWidth; i++)
    {
        sTop    += GUI_WINDOW_TOP_MIDDLE;
        sMiddle += GUI_WINDOW_MIDDLE_BLANK;
        sBottom += GUI_WINDOW_BOTTOM_MIDDLE;
    }

    sTop    += GUI_WINDOW_TOP_RIGHT;
    sMiddle += GUI_WINDOW_MIDDLE_RIGHT;
    sBottom += GUI_WINDOW_BOTTOM_RIGHT;

    PostString(oPlayer, sTop, nX, nY, nAnchor, fLifetime, nStartColor, nEndColor, nID++, GUI_FONT_WINDOW_NAME);
    for (i = 0; i < nHeight; i++)
    {
        PostString(oPlayer, sMiddle, nX, ++nY, nAnchor, fLifetime, nStartColor, nEndColor, nID++, GUI_FONT_WINDOW_NAME);
    }
    PostString(oPlayer, sBottom, nX, ++nY, nAnchor, fLifetime, nStartColor, nEndColor, nID++, GUI_FONT_WINDOW_NAME);

    return nID;
}

int GUI_DrawConversationWindow(object oPlayer, int nID, int nWidth, int nHeight, float fLifetime = 10.0f)
{
    int nX = 0, nY = 0;
    int nAnchor = SCREEN_ANCHOR_TOP_LEFT;
    int nStartColor = 0xFFFFFFFF;
    int nEndColor   = 0xFFFFFFFF;

    string sTop = GUI_WINDOW_MIDDLE_BLANK;
    string sMiddle = GUI_WINDOW_MIDDLE_BLANK;
    string sBottom = GUI_WINDOW_BOTTOM_MIDDLE;

    int i;
    for (i = 0; i < nWidth; i++)
    {
        sTop    += GUI_WINDOW_MIDDLE_BLANK;
        sMiddle += GUI_WINDOW_MIDDLE_BLANK;
        sBottom += GUI_WINDOW_BOTTOM_MIDDLE;
    }

    sTop    += GUI_WINDOW_MIDDLE_RIGHT;
    sMiddle += GUI_WINDOW_MIDDLE_RIGHT;
    sBottom += GUI_WINDOW_BOTTOM_RIGHT;

    PostString(oPlayer, sTop, nX, nY, nAnchor, fLifetime, nStartColor, nEndColor, nID++, GUI_FONT_WINDOW_NAME);
    for (i = 0; i < nHeight; i++)
    {
        PostString(oPlayer, sMiddle, nX, ++nY, nAnchor, fLifetime, nStartColor, nEndColor, nID++, GUI_FONT_WINDOW_NAME);
    }
    PostString(oPlayer, sBottom, nX, ++nY, nAnchor, fLifetime, nStartColor, nEndColor, nID++, GUI_FONT_WINDOW_NAME);

    return nID;
}
