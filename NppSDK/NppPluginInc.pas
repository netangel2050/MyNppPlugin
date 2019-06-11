{***************************************************************************}
{                                                                           }
{       功能：Npp插件开发                                                   }
{       名称：NppPluginLib.pas                                              }
{       版本：1.0                                                           }
{       环境：Win7 Sp1 32bit                                                }
{       工具：Delphi 7                                                      }
{       日期：2013/4/20 4:01:38                                             }
{       作者：ying32                                                        }
{       QQ  ：396506155                                                     }
{       MSN ：ying_32@live.cn                                               }
{       E-mail：yuanfen3287@vip.qq.com                                      }
{       Website：http://www.ying32.tk                                       }
{       版权所有 (C) 2013-2013 ying32.tk All Rights Reserved                }
{                                                                           }
{---------------------------------------------------------------------------}
{                                                                           }
{       备注：翻译来自Empty                                                 }
{                                                                           }
{                                                                           }
{                                                                           }
{***************************************************************************}

unit NppPluginInc;

{$I Notpad_Plugin.inc}

interface

uses
  Windows, Messages, Scintilla;


(* 以下为自己定义的的些与原NPP定义兼容的类型 *)  
type
  UCHAR   = {$IFDEF UNICODE}WideChar{$ElSE}AnsiChar{$ENDIF};
  TCHAR   = UCHAR;
  PTCHAR  = {$IFDEF UNICODE}PWideChar{$ELSE}PAsniChar{$ENDIF};
  PPTCHAR = {$IFDEF UNICODE}PPWideChar{$ELSE}PPAnsiChar{$ENDIF};


(* 以下常量翻译取自 menuCmdID.h *)
const
  IDM = 40000;

  IDM_FILE = IDM + 1000;
        IDM_FILE_NEW                  = IDM_FILE + 1;
        IDM_FILE_OPEN                 = IDM_FILE + 2;
        IDM_FILE_CLOSE                = IDM_FILE + 3;
        IDM_FILE_CLOSEALL             = IDM_FILE + 4;
        IDM_FILE_CLOSEALL_BUT_CURRENT = IDM_FILE + 5;
        IDM_FILE_SAVE                 = IDM_FILE + 6;
        IDM_FILE_SAVEALL              = IDM_FILE + 7;
        IDM_FILE_SAVEAS               = IDM_FILE + 8;
        IDM_FILE_ASIAN_LANG           = IDM_FILE + 9;
        IDM_FILE_PRINT                = IDM_FILE + 10;
        IDM_FILE_PRINTNOW             = 1001;
        IDM_FILE_EXIT                 = IDM_FILE + 11;
        IDM_FILE_LOADSESSION          = IDM_FILE + 12;
        IDM_FILE_SAVESESSION          = IDM_FILE + 13;
        IDM_FILE_RELOAD               = IDM_FILE + 14;
        IDM_FILE_SAVECOPYAS           = IDM_FILE + 15;
        IDM_FILE_DELETE               = IDM_FILE + 16;
        IDM_FILE_RENAME               = IDM_FILE + 17;

        // A mettre ?jour si on ajoute nouveau menu item dans le menu "File"
        IDM_FILEMENU_LASTONE = IDM_FILE_RENAME;

  IDM_EDIT = IDM + 2000;
        IDM_EDIT_CUT                      = IDM_EDIT + 1;
        IDM_EDIT_COPY                     = IDM_EDIT + 2;
        IDM_EDIT_UNDO                     = IDM_EDIT + 3;
        IDM_EDIT_REDO                     = IDM_EDIT + 4;
        IDM_EDIT_PASTE                    = IDM_EDIT + 5;
        IDM_EDIT_DELETE                   = IDM_EDIT + 6;
        IDM_EDIT_SELECTALL                = IDM_EDIT + 7;

        IDM_EDIT_INS_TAB                  = IDM_EDIT + 8;
        IDM_EDIT_RMV_TAB                  = IDM_EDIT + 9;
        IDM_EDIT_DUP_LINE                 = IDM_EDIT + 10;
        IDM_EDIT_TRANSPOSE_LINE           = IDM_EDIT + 11;
        IDM_EDIT_SPLIT_LINES              = IDM_EDIT + 12;
        IDM_EDIT_JOIN_LINES               = IDM_EDIT + 13;
        IDM_EDIT_LINE_UP                  = IDM_EDIT + 14;
        IDM_EDIT_LINE_DOWN                = IDM_EDIT + 15;
        IDM_EDIT_UPPERCASE                = IDM_EDIT + 16;
        IDM_EDIT_LOWERCASE                = IDM_EDIT + 17;

        IDM_EDIT_BLOCK_COMMENT            = IDM_EDIT + 22;
        IDM_EDIT_STREAM_COMMENT           = IDM_EDIT + 23;
        IDM_EDIT_TRIMTRAILING             = IDM_EDIT + 24;

        IDM_EDIT_RTL                      = IDM_EDIT + 26;
        IDM_EDIT_LTR                      = IDM_EDIT + 27;
        IDM_EDIT_SETREADONLY              = IDM_EDIT + 28;
        IDM_EDIT_FULLPATHTOCLIP           = IDM_EDIT + 29;
        IDM_EDIT_FILENAMETOCLIP           = IDM_EDIT + 30;
        IDM_EDIT_CURRENTDIRTOCLIP         = IDM_EDIT + 31;

        IDM_EDIT_CLEARREADONLY            = IDM_EDIT + 33;
        IDM_EDIT_COLUMNMODE               = IDM_EDIT + 34;
        IDM_EDIT_BLOCK_COMMENT_SET        = IDM_EDIT + 35;
        IDM_EDIT_BLOCK_UNCOMMENT          = IDM_EDIT + 36;

        IDM_EDIT_AUTOCOMPLETE             = 50000 + 0;
        IDM_EDIT_AUTOCOMPLETE_CURRENTFILE = 50000 + 1;
        IDM_EDIT_FUNCCALLTIP              = 50000 + 2;

        //Belong to MENU FILE
        IDM_OPEN_ALL_RECENT_FILE   = IDM_EDIT + 40;
        IDM_CLEAN_RECENT_FILE_LIST = IDM_EDIT + 41;

        IDM_SEARCH = IDM + 3000;

        IDM_SEARCH_FIND                    = IDM_SEARCH + 1;
        IDM_SEARCH_FINDNEXT                = IDM_SEARCH + 2;
        IDM_SEARCH_REPLACE                 = IDM_SEARCH + 3;
        IDM_SEARCH_GOTOLINE                = IDM_SEARCH + 4;
        IDM_SEARCH_TOGGLE_BOOKMARK         = IDM_SEARCH + 5;
        IDM_SEARCH_NEXT_BOOKMARK           = IDM_SEARCH + 6;
        IDM_SEARCH_PREV_BOOKMARK           = IDM_SEARCH + 7;
        IDM_SEARCH_CLEAR_BOOKMARKS         = IDM_SEARCH + 8;
        IDM_SEARCH_GOTOMATCHINGBRACE       = IDM_SEARCH + 9;
        IDM_SEARCH_FINDPREV                = IDM_SEARCH + 10;
        IDM_SEARCH_FINDINCREMENT           = IDM_SEARCH + 11;
        IDM_SEARCH_FINDINFILES             = IDM_SEARCH + 13;
        IDM_SEARCH_VOLATILE_FINDNEXT       = IDM_SEARCH + 14;
        IDM_SEARCH_VOLATILE_FINDPREV       = IDM_SEARCH + 15;
        IDM_SEARCH_CUTMARKEDLINES          = IDM_SEARCH + 18;
        IDM_SEARCH_COPYMARKEDLINES         = IDM_SEARCH + 19;
        IDM_SEARCH_PASTEMARKEDLINES        = IDM_SEARCH + 20;
        IDM_SEARCH_DELETEMARKEDLINES       = IDM_SEARCH + 21;
        IDM_SEARCH_MARKALLEXT1             = IDM_SEARCH + 22;
        IDM_SEARCH_UNMARKALLEXT1           = IDM_SEARCH + 23;
        IDM_SEARCH_MARKALLEXT2             = IDM_SEARCH + 24;
        IDM_SEARCH_UNMARKALLEXT2           = IDM_SEARCH + 25;
        IDM_SEARCH_MARKALLEXT3             = IDM_SEARCH + 26;
        IDM_SEARCH_UNMARKALLEXT3           = IDM_SEARCH + 27;
        IDM_SEARCH_MARKALLEXT4             = IDM_SEARCH + 28;
        IDM_SEARCH_UNMARKALLEXT4           = IDM_SEARCH + 29;
        IDM_SEARCH_MARKALLEXT5             = IDM_SEARCH + 30;
        IDM_SEARCH_UNMARKALLEXT5           = IDM_SEARCH + 31;
        IDM_SEARCH_CLEARALLMARKS           = IDM_SEARCH + 32;

  IDM_VIEW = IDM + 4000;
        //	IDM_VIEW_TOOLBAR_HIDE			       =   IDM_VIEW + 1;
        IDM_VIEW_TOOLBAR_REDUCE            = IDM_VIEW + 2;
        IDM_VIEW_TOOLBAR_ENLARGE           = IDM_VIEW + 3;
        IDM_VIEW_TOOLBAR_STANDARD          = IDM_VIEW + 4;
        IDM_VIEW_REDUCETABBAR              = IDM_VIEW + 5;
        IDM_VIEW_LOCKTABBAR                = IDM_VIEW + 6;
        IDM_VIEW_DRAWTABBAR_TOPBAR         = IDM_VIEW + 7;
        IDM_VIEW_DRAWTABBAR_INACIVETAB     = IDM_VIEW + 8;
        IDM_VIEW_POSTIT                    = IDM_VIEW + 9;
        IDM_VIEW_TOGGLE_FOLDALL            = IDM_VIEW + 10;
        IDM_VIEW_USER_DLG                  = IDM_VIEW + 11;
        IDM_VIEW_LINENUMBER                = IDM_VIEW + 12;
        IDM_VIEW_SYMBOLMARGIN              = IDM_VIEW + 13;
        IDM_VIEW_FOLDERMAGIN               = IDM_VIEW + 14;
        IDM_VIEW_FOLDERMAGIN_SIMPLE        = IDM_VIEW + 15;
        IDM_VIEW_FOLDERMAGIN_ARROW         = IDM_VIEW + 16;
        IDM_VIEW_FOLDERMAGIN_CIRCLE        = IDM_VIEW + 17;
        IDM_VIEW_FOLDERMAGIN_BOX           = IDM_VIEW + 18;
        IDM_VIEW_ALL_CHARACTERS            = IDM_VIEW + 19;
        IDM_VIEW_INDENT_GUIDE              = IDM_VIEW + 20;
        IDM_VIEW_CURLINE_HILITING          = IDM_VIEW + 21;
        IDM_VIEW_WRAP                      = IDM_VIEW + 22;
        IDM_VIEW_ZOOMIN                    = IDM_VIEW + 23;
        IDM_VIEW_ZOOMOUT                   = IDM_VIEW + 24;
        IDM_VIEW_TAB_SPACE                 = IDM_VIEW + 25;
        IDM_VIEW_EOL                       = IDM_VIEW + 26;
        IDM_VIEW_EDGELINE                  = IDM_VIEW + 27;
        IDM_VIEW_EDGEBACKGROUND            = IDM_VIEW + 28;
        IDM_VIEW_TOGGLE_UNFOLDALL          = IDM_VIEW + 29;
        IDM_VIEW_FOLD_CURRENT              = IDM_VIEW + 30;
        IDM_VIEW_UNFOLD_CURRENT            = IDM_VIEW + 31;
        IDM_VIEW_FULLSCREENTOGGLE          = IDM_VIEW + 32;
        IDM_VIEW_ZOOMRESTORE               = IDM_VIEW + 33;
        IDM_VIEW_ALWAYSONTOP               = IDM_VIEW + 34;
        IDM_VIEW_SYNSCROLLV                = IDM_VIEW + 35;
        IDM_VIEW_SYNSCROLLH                = IDM_VIEW + 36;
        IDM_VIEW_EDGENONE                  = IDM_VIEW + 37;
        IDM_VIEW_DRAWTABBAR_CLOSEBOTTUN    = IDM_VIEW + 38;
        IDM_VIEW_DRAWTABBAR_DBCLK2CLOSE    = IDM_VIEW + 39;
        IDM_VIEW_REFRESHTABAR              = IDM_VIEW + 40;
        IDM_VIEW_WRAP_SYMBOL               = IDM_VIEW + 41;
        IDM_VIEW_HIDELINES                 = IDM_VIEW + 42;
        IDM_VIEW_DRAWTABBAR_VERTICAL       = IDM_VIEW + 43;
        IDM_VIEW_DRAWTABBAR_MULTILINE      = IDM_VIEW + 44;
        IDM_VIEW_DOCCHANGEMARGIN           = IDM_VIEW + 45;

        IDM_VIEW_FOLD = IDM_VIEW + 50;
        IDM_VIEW_FOLD_1 = IDM_VIEW_FOLD + 1;
        IDM_VIEW_FOLD_2 = IDM_VIEW_FOLD + 2;
        IDM_VIEW_FOLD_3 = IDM_VIEW_FOLD + 3;
        IDM_VIEW_FOLD_4 = IDM_VIEW_FOLD + 4;
        IDM_VIEW_FOLD_5 = IDM_VIEW_FOLD + 5;
        IDM_VIEW_FOLD_6 = IDM_VIEW_FOLD + 6;
        IDM_VIEW_FOLD_7 = IDM_VIEW_FOLD + 7;
        IDM_VIEW_FOLD_8 = IDM_VIEW_FOLD + 8;

        IDM_VIEW_UNFOLD = IDM_VIEW + 60;
        IDM_VIEW_UNFOLD_1 = IDM_VIEW_UNFOLD + 1;
        IDM_VIEW_UNFOLD_2 = IDM_VIEW_UNFOLD + 2;
        IDM_VIEW_UNFOLD_3 = IDM_VIEW_UNFOLD + 3;
        IDM_VIEW_UNFOLD_4 = IDM_VIEW_UNFOLD + 4;
        IDM_VIEW_UNFOLD_5 = IDM_VIEW_UNFOLD + 5;
        IDM_VIEW_UNFOLD_6 = IDM_VIEW_UNFOLD + 6;
        IDM_VIEW_UNFOLD_7 = IDM_VIEW_UNFOLD + 7;
        IDM_VIEW_UNFOLD_8 = IDM_VIEW_UNFOLD + 8;

        IDM_VIEW_GOTO_ANOTHER_VIEW       = 10001;
          IDM_VIEW_CLONE_TO_ANOTHER_VIEW = 10002;
          IDM_VIEW_GOTO_NEW_INSTANCE     = 10003;
          IDM_VIEW_LOAD_IN_NEW_INSTANCE  = 10004;

        IDM_VIEW_SWITCHTO_OTHER_VIEW       = IDM_VIEW + 72;

  IDM_FORMAT = IDM + 5000;
        IDM_FORMAT_TODOS          = IDM_FORMAT + 1;
        IDM_FORMAT_TOUNIX         = IDM_FORMAT + 2;
        IDM_FORMAT_TOMAC          = IDM_FORMAT + 3;
        IDM_FORMAT_ANSI           = IDM_FORMAT + 4;
        IDM_FORMAT_UTF_8          = IDM_FORMAT + 5;
        IDM_FORMAT_UCS_2BE        = IDM_FORMAT + 6;
        IDM_FORMAT_UCS_2LE        = IDM_FORMAT + 7;
        IDM_FORMAT_AS_UTF_8       = IDM_FORMAT + 8;
        IDM_FORMAT_CONV2_ANSI     = IDM_FORMAT + 9;
        IDM_FORMAT_CONV2_AS_UTF_8 = IDM_FORMAT + 10;
        IDM_FORMAT_CONV2_UTF_8    = IDM_FORMAT + 11;
        IDM_FORMAT_CONV2_UCS_2BE  = IDM_FORMAT + 12;
        IDM_FORMAT_CONV2_UCS_2LE  = IDM_FORMAT + 13;

  IDM_LANG = IDM + 6000;
        IDM_LANGSTYLE_CONFIG_DLG = IDM_LANG + 1;
        IDM_LANG_C               = IDM_LANG + 2;
        IDM_LANG_CPP             = IDM_LANG + 3;
        IDM_LANG_JAVA            = IDM_LANG + 4;
        IDM_LANG_HTML            = IDM_LANG + 5;
        IDM_LANG_XML             = IDM_LANG + 6;
        IDM_LANG_JS              = IDM_LANG + 7;
        IDM_LANG_PHP             = IDM_LANG + 8;
        IDM_LANG_ASP             = IDM_LANG + 9;
        IDM_LANG_CSS             = IDM_LANG + 10;
        IDM_LANG_PASCAL          = IDM_LANG + 11;
        IDM_LANG_PYTHON          = IDM_LANG + 12;
        IDM_LANG_PERL            = IDM_LANG + 13;
        IDM_LANG_OBJC            = IDM_LANG + 14;
        IDM_LANG_ASCII           = IDM_LANG + 15;
        IDM_LANG_TEXT            = IDM_LANG + 16;
        IDM_LANG_RC              = IDM_LANG + 17;
        IDM_LANG_MAKEFILE        = IDM_LANG + 18;
        IDM_LANG_INI             = IDM_LANG + 19;
        IDM_LANG_SQL             = IDM_LANG + 20;
        IDM_LANG_VB              = IDM_LANG + 21;
        IDM_LANG_BATCH           = IDM_LANG + 22;
        IDM_LANG_CS              = IDM_LANG + 23;
        IDM_LANG_LUA             = IDM_LANG + 24;
        IDM_LANG_TEX             = IDM_LANG + 25;
        IDM_LANG_FORTRAN         = IDM_LANG + 26;
        IDM_LANG_SH              = IDM_LANG + 27;
        IDM_LANG_FLASH           = IDM_LANG + 28;
        IDM_LANG_NSIS            = IDM_LANG + 29;
        IDM_LANG_TCL             = IDM_LANG + 30;
        IDM_LANG_LISP            = IDM_LANG + 31;
        IDM_LANG_SCHEME          = IDM_LANG + 32;
        IDM_LANG_ASM             = IDM_LANG + 33;
        IDM_LANG_DIFF            = IDM_LANG + 34;
        IDM_LANG_PROPS           = IDM_LANG + 35;
        IDM_LANG_PS              = IDM_LANG + 36;
        IDM_LANG_RUBY            = IDM_LANG + 37;
        IDM_LANG_SMALLTALK       = IDM_LANG + 38;
        IDM_LANG_VHDL            = IDM_LANG + 39;
        IDM_LANG_CAML            = IDM_LANG + 40;
        IDM_LANG_KIX             = IDM_LANG + 41;
        IDM_LANG_ADA             = IDM_LANG + 42;
        IDM_LANG_VERILOG         = IDM_LANG + 43;
        IDM_LANG_AU3             = IDM_LANG + 44;
        IDM_LANG_MATLAB          = IDM_LANG + 45;
        IDM_LANG_HASKELL         = IDM_LANG + 46;
        IDM_LANG_INNO            = IDM_LANG + 47;
        IDM_LANG_CMAKE           = IDM_LANG + 48;
        IDM_LANG_YAML            = IDM_LANG + 49;

        IDM_LANG_EXTERNAL        = IDM_LANG + 50;
        IDM_LANG_EXTERNAL_LIMIT  = IDM_LANG + 79;

        IDM_LANG_USER            = IDM_LANG + 80; //46080
        IDM_LANG_USER_LIMIT      = IDM_LANG + 110; //46110

  IDM_ABOUT = IDM + 7000;
        IDM_HOMESWEETHOME = IDM_ABOUT + 1;
        IDM_PROJECTPAGE   = IDM_ABOUT + 2;
        IDM_ONLINEHELP    = IDM_ABOUT + 3;
        IDM_FORUM         = IDM_ABOUT + 4;
        IDM_PLUGINSHOME   = IDM_ABOUT + 5;
        IDM_UPDATE_NPP    = IDM_ABOUT + 6;
        IDM_WIKIFAQ       = IDM_ABOUT + 7;
        IDM_HELP          = IDM_ABOUT + 8;

  IDM_SETTING = IDM + 8000;
        IDM_SETTING_TAB_SIZE                = IDM_SETTING + 1;
        IDM_SETTING_TAB_REPLCESPACE         = IDM_SETTING + 2;
        IDM_SETTING_HISTORY_SIZE            = IDM_SETTING + 3;
        IDM_SETTING_EDGE_SIZE               = IDM_SETTING + 4;
        IDM_SETTING_IMPORTPLUGIN            = IDM_SETTING + 5;
        IDM_SETTING_IMPORTSTYLETHEMS        = IDM_SETTING + 6;

        IDM_SETTING_TRAYICON                = IDM_SETTING + 8;
        IDM_SETTING_SHORTCUT_MAPPER         = IDM_SETTING + 9;
        IDM_SETTING_REMEMBER_LAST_SESSION   = IDM_SETTING + 10;
        IDM_SETTING_PREFERECE               = IDM_SETTING + 11;

        IDM_SETTING_AUTOCNBCHAR = IDM_SETTING + 15;

  // Menu macro
  IDM_MACRO_STARTRECORDINGMACRO   = IDM_EDIT + 18;
  IDM_MACRO_STOPRECORDINGMACRO    = IDM_EDIT + 19;
  IDM_MACRO_PLAYBACKRECORDEDMACRO = IDM_EDIT + 21;
  IDM_MACRO_SAVECURRENTMACRO      = IDM_EDIT + 25;
  IDM_MACRO_RUNMULTIMACRODLG      = IDM_EDIT + 32;

  IDM_EXECUTE                     = IDM + 9000;



(* 以下定义翻译来源于 Notepad_plus_msgs.h *)  
type
  TLangType = (L_TXT  , L_PHP    , L_C, L_CPP, L_CS     , L_OBJC   , L_JAVA     , L_RC    ,
               L_HTML , L_XML    , L_MAKEFILE, L_PASCAL , L_BATCH  , L_INI      , L_NFO   , L_USER,
               L_ASP  , L_SQL    , L_VB      , L_JS     , L_CSS    , L_PERL     , L_PYTHON, L_LUA,
               L_TEX  , L_FORTRAN, L_BASH    , L_FLASH  , L_NSIS   , L_TCL      , L_LISP  , L_SCHEME,
               L_ASM  , L_DIFF   , L_PROPS   , L_PS     , L_RUBY   , L_SMALLTALK, L_VHDL  , L_KIX, L_AU3,
               L_CAML , L_ADA    , L_VERILOG , L_MATLAB , L_HASKELL, L_INNO     , L_SEARCHRESULT,
               L_CMAKE, L_YAML   , L_EXTERNAL);

  TWinVer = (WV_UNKNOWN, WV_WIN32S, WV_95, WV_98, WV_ME, WV_NT, WV_W2K, WV_XP, WV_S2003, WV_XPX64, WV_VISTA, WV_WIN7);

  TSessionInfo = record
   	sessionFilePathName : PTCHAR;
	 	nbFile              : Integer;
	 	files               : PPTCHAR;
  end;


  // void WM_ADDTOOLBARICON(UINT funcItem[X]._cmdID, toolbarIcons icon);
  TToolbarIcons = record
    hToolbarBmp  : HBITMAP;
    hToolbarIcon : HICON;
  end;

	// BOOL NPPM_MSGTOPLUGIN(TCHAR *destModuleName, CommunicationInfo *info);
	// 插件成功发送消息，返回值为true。
	// 如果destmodule或信息为空，则返回值为false
	TCommunicationInfo = record
			internalMsg   : Cardinal;
			srcModuleName : PTCHAR;
			info          : Pointer ; // 定义插件
	end;

const
  TLangTypeStr : array[TLangType] of string =
              ('TXT', 'PHP', 'C', 'C++', 'C#', 'OBJC','JAVA', 'Rc',
               'HTML', 'XML', 'MakeFile', 'Pascal', 'Batch', 'INI', 'NFO', 'USER',
               'ASP', 'SQL', 'VB', 'JavaScript', 'CSS', 'Perl', 'Python', 'Lua',
               'Tex', 'Fortran', 'Bash', 'Flash', 'Nsis', 'Tcl', 'Lisp', 'Scheme',
               'ASM', 'Diff', 'Props', 'Ps', 'Ruby', 'SmallTalk', 'Vhdl', 'Kix', 'Au3',
               'CAML', 'Ada', 'Verilog', 'Matlab', 'Haskell', 'INNO', 'SearchResult',
               'CMake', 'Yaml', '自定义');
               
  TWinVerStr : array[TWinVer] of string =
            ('未知版本', 'Windows32 Server', 'Windows95', 'Windows98', 'Windows Me',
             'Windows NT', 'Windows 2000', 'Windows XP', 'Windows Server 2003',
             'Windows XP 64bit', 'Windows Vista', 'Windows 7');


 // 可以在这里找到如何使用这些消息的信息 : http://notepad-plus.sourceforge.net/uk/plugins-HOWTO.php
 NPPMSG  = (WM_USER + 1000);

	 NPPM_GETCURRENTSCINTILLA  = (NPPMSG + 4);
	 NPPM_GETCURRENTLANGTYPE   = (NPPMSG + 5);
	 NPPM_SETCURRENTLANGTYPE   = (NPPMSG + 6);

	 NPPM_GETNBOPENFILES			 = (NPPMSG + 7);
		 ALL_OPEN_FILES		         =	0;
		 PRIMARY_VIEW		         =	1;
		 SECOND_VIEW			     =	2;

	 NPPM_GETOPENFILENAMES	   = (NPPMSG + 8);


	 NPPM_MODELESSDIALOG		   = (NPPMSG + 12);
		 MODELESSDIALOGADD		   = 0;
		 MODELESSDIALOGREMOVE	   = 1;

	 NPPM_GETNBSESSIONFILES    = (NPPMSG + 13);
	 NPPM_GETSESSIONFILES      = (NPPMSG + 14);
	 NPPM_SAVESESSION          = (NPPMSG + 15);
	 NPPM_SAVECURRENTSESSION   = (NPPMSG + 16);



	 NPPM_GETOPENFILENAMESPRIMARY = (NPPMSG + 17);
	 NPPM_GETOPENFILENAMESSECOND  = (NPPMSG + 18);
	
	 NPPM_CREATESCINTILLAHANDLE   = (NPPMSG + 20);
	 NPPM_DESTROYSCINTILLAHANDLE  = (NPPMSG + 21);
	 NPPM_GETNBUSERLANG           = (NPPMSG + 22);

	 NPPM_GETCURRENTDOCINDEX      = (NPPMSG + 23);
		 MAIN_VIEW = 0;
		 SUB_VIEW  = 1;

	 NPPM_SETSTATUSBAR = (NPPMSG + 24);
		 STATUSBAR_DOC_TYPE     = 0;
		 STATUSBAR_DOC_SIZE     = 1;
		 STATUSBAR_CUR_POS      = 2;
		 STATUSBAR_EOF_FORMAT   = 3;
		 STATUSBAR_UNICODE_TYPE = 4;
		 STATUSBAR_TYPING_MODE  = 5;

	 NPPM_GETMENUHANDLE       = (NPPMSG + 25);
		 NPPPLUGINMENU          = 0;

	 NPPM_ENCODESCI           = (NPPMSG + 26);
	 // ASCII文件到Unicode
	 // int NPPM_ENCODESCI(MAIN_VIEW/SUB_VIEW, 0);
	 // 返回新的UnicodeMode
	
	 NPPM_DECODESCI = (NPPMSG + 27);
	 // ASCII文件到Unicode
	 // int NPPM_ENCODESCI(MAIN_VIEW/SUB_VIEW, 0);
	 // 返回新的UnicodeMode

	 NPPM_ACTIVATEDOC = (NPPMSG + 28);
	 // void NPPM_ACTIVATEDOC(int view, int index2Activate);

	 NPPM_LAUNCHFINDINFILESDLG = (NPPMSG + 29);
	 // void NPPM_LAUNCHFINDINFILESDLG(TCHAR * dir2Search, TCHAR * filtre);

	 NPPM_DMMSHOW = (NPPMSG + 30);
	 NPPM_DMMHIDE	= (NPPMSG + 31);
	 NPPM_DMMUPDATEDISPINFO = (NPPMSG + 32);
   // void NPPM_DMMxxx(0, tTbData->hClient);

	 NPPM_DMMREGASDCKDLG         = (NPPMSG + 33);
	 //void NPPM_DMMREGASDCKDLG(0, &tTbData);

	 NPPM_LOADSESSION            = (NPPMSG + 34);
	 //void NPPM_LOADSESSION(0, const TCHAR* file name);

	 NPPM_DMMVIEWOTHERTAB        = (NPPMSG + 35);
	 //void WM_DMM_VIEWOTHERTAB(0, tTbData->pszName);

	 NPPM_RELOADFILE             = (NPPMSG + 36);
	 //BOOL NPPM_RELOADFILE(BOOL withAlert, TCHAR *filePathName2Reload);

	 NPPM_SWITCHTOFILE           = (NPPMSG + 37);
	 //BOOL NPPM_SWITCHTOFILE(0, TCHAR *filePathName2switch);

	 NPPM_SAVECURRENTFILE        = (NPPMSG + 38);
	 //BOOL WM_SWITCHTOFILE(0, 0);

	 NPPM_SAVEALLFILES           = (NPPMSG + 39);
	 //BOOL NPPM_SAVEALLFILES(0, 0);

	 NPPM_SETMENUITEMCHECK       = (NPPMSG + 40);
	 //void WM_PIMENU_CHECK(UINT	funcItem[X]._cmdID, TRUE/FALSE);

	 NPPM_ADDTOOLBARICON         = (NPPMSG + 41);
     // 添加 ToolbarIcon

	 NPPM_GETWINDOWSVERSION      = (NPPMSG + 42);
	 // winVer NPPM_GETWINDOWSVERSION(0, 0);

	 NPPM_DMMGETPLUGINHWNDBYNAME = (NPPMSG + 43);
	 // HWND WM_DMM_GETPLUGINHWNDBYNAME(const TCHAR *windowName, const TCHAR *moduleName);
	 // 如果moduleName为 NULL，则返回NULL
	 // 如果moduleName为 NULL, 然而找到的第一个窗口句柄匹配的moduleName将被退回
	
	 NPPM_MAKECURRENTBUFFERDIRTY    = (NPPMSG + 44);
	 // BOOL NPPM_MAKECURRENTBUFFERDIRTY(0, 0);

	 NPPM_GETENABLETHEMETEXTUREFUNC = (NPPMSG + 45);
	 // BOOL NPPM_GETENABLETHEMETEXTUREFUNC(0, 0);

	 NPPM_GETPLUGINSCONFIGDIR       = (NPPMSG + 46);
	 // void NPPM_GETPLUGINSCONFIGDIR(int strLen, TCHAR *str);

	 NPPM_MSGTOPLUGIN               = (NPPMSG + 47);
	 // BOOL NPPM_MSGTOPLUGIN(TCHAR *destModuleName, CommunicationInfo *info);

	 NPPM_MENUCOMMAND = (NPPMSG + 48);
	 // void NPPM_MENUCOMMAND(0, int cmdID);
	 // 取消 //#include "menuCmdID.h"
	 // 在这个文件的开头，然后使用命令在的"menuCmdID.h"文件中定义的符号
	 // 访问所有的Notepad++菜单命令项
	
	 NPPM_TRIGGERTABBARCONTEXTMENU = (NPPMSG + 49);
	 // void NPPM_TRIGGERTABBARCONTEXTMENU(int view, int index2Activate);

	 NPPM_GETNPPVERSION = (NPPMSG + 50);
	 // int NPPM_GETNPPVERSION(0, 0);
	 // 返回版本
	 // 如 : v4.6
	 // HIWORD(version); == 4
	 // LOWORD(version); == 6

	 NPPM_HIDETABBAR = (NPPMSG + 51);
	 // BOOL NPPM_HIDETABBAR(0, BOOL hideOrNot);
	 // 如果hideornot设置为true TAB Bar 将被隐藏，否则，它会显示。
	 // 返回值: 先前的状态值

	 NPPM_ISTABBARHIDDEN = (NPPMSG + 52);
   // BOOL NPPM_ISTABBARHIDDEN(0, 0);
	 // 返回值 : TRUE 如果TAB Bar隐藏, 然而返回 FALSE

	 NPPM_GETPOSFROMBUFFERID = (NPPMSG + 57);
	 // INT NPPM_GETPOSFROMBUFFERID(INT bufferID, 0);
   // Return VIEW|INDEX from a buffer ID. -1 if the bufferID non existing
	 //
   // VIEW takes 2 highest bits and INDEX = (0 based); takes the rest = (30 bits);
   // Here's the values for the view :
	 //  MAIN_VIEW 0
	 //  SUB_VIEW  1

	 NPPM_GETFULLPATHFROMBUFFERID = (NPPMSG + 58);
	// INT NPPM_GETFULLPATHFROMBUFFERID(INT bufferID, TCHAR *fullFilePath);
	// Get full path file name from a bufferID. 
	// Return -1 if the bufferID non existing, otherwise the number of TCHAR copied/to copy
	// User should call it with fullFilePath be NULL to get the number of TCHAR = (not including the nul character);,
	// allocate fullFilePath with the return values + 1, then call it again to get  full path file name

	 NPPM_GETBUFFERIDFROMPOS  = (NPPMSG + 59);
	//wParam: Position of document
	//lParam: View to use, 0 = Main, 1 = Secondary
	//Returns 0 if invalid

	 NPPM_GETCURRENTBUFFERID  = (NPPMSG + 60);
	//Returns active Buffer

	 NPPM_RELOADBUFFERID      = (NPPMSG + 61);
	//Reloads Buffer
	//wParam: Buffer to reload
	//lParam: 0 if no alert, else alert


	 NPPM_GETBUFFERLANGTYPE   = (NPPMSG + 64);
	//wParam: BufferID to get LangType from
	//lParam: 0
	//Returns as int, see LangType. -1 on error

	 NPPM_SETBUFFERLANGTYPE   = (NPPMSG + 65);
	//wParam: BufferID to set LangType of
	//lParam: LangType
	//Returns TRUE on success, FALSE otherwise
	//use int, see LangType for possible values
	//L_USER and L_EXTERNAL are not supported

	 NPPM_GETBUFFERENCODING = (NPPMSG + 66);
	//wParam: BufferID to get encoding from
	//lParam: 0
	//returns as int, see UniMode. -1 on error

	 NPPM_SETBUFFERENCODING = (NPPMSG + 67);
	//wParam: BufferID to set encoding of
	//lParam: format
	//Returns TRUE on success, FALSE otherwise
	//use int, see UniMode
	//Can only be done on new, unedited files

	 NPPM_GETBUFFERFORMAT   = (NPPMSG + 68);
	//wParam: BufferID to get format from
	//lParam: 0
	//returns as int, see formatType. -1 on error

	 NPPM_SETBUFFERFORMAT   = (NPPMSG + 69);
	//wParam: BufferID to set format of
	//lParam: format
	//Returns TRUE on success, FALSE otherwise
	//use int, see formatType

{
	 NPPM_ADDREBAR          = (NPPMSG + 57);
	// BOOL NPPM_ADDREBAR(0, REBARBANDINFO *);
	// Returns assigned ID in wID value of struct pointer
	 NPPM_UPDATEREBAR = (NPPMSG + 58);
	// BOOL NPPM_ADDREBAR(INT ID, REBARBANDINFO *);
	//Use ID assigned with NPPM_ADDREBAR
	 NPPM_REMOVEREBAR = (NPPMSG + 59);
	// BOOL NPPM_ADDREBAR(INT ID, 0);
	//Use ID assigned with NPPM_ADDREBAR
}

	 NPPM_HIDETOOLBAR        = (NPPMSG + 70);
	// BOOL NPPM_HIDETOOLBAR(0, BOOL hideOrNot);
	// if hideOrNot is set as TRUE then tool bar will be hidden
	// otherwise it'll be shown.
	// return value : the old status value

	 NPPM_ISTOOLBARHIDDEN    = (NPPMSG + 71);
	// BOOL NPPM_ISTOOLBARHIDDEN(0, 0);
	// returned value : TRUE if tool bar is hidden, otherwise FALSE

	 NPPM_HIDEMENU           = (NPPMSG + 72);
	// BOOL NPPM_HIDEMENU(0, BOOL hideOrNot);
	// if hideOrNot is set as TRUE then menu will be hidden
	// otherwise it'll be shown.
	// return value : the old status value

	 NPPM_ISMENUHIDDEN       = (NPPMSG + 73);
	// BOOL NPPM_ISMENUHIDDEN(0, 0);
	// returned value : TRUE if menu is hidden, otherwise FALSE

	 NPPM_HIDESTATUSBAR      = (NPPMSG + 74);
	// BOOL NPPM_HIDESTATUSBAR(0, BOOL hideOrNot);
	// if hideOrNot is set as TRUE then STATUSBAR will be hidden
	// otherwise it'll be shown.
	// return value : the old status value

	 NPPM_ISSTATUSBARHIDDEN  = (NPPMSG + 75);
	// BOOL NPPM_ISSTATUSBARHIDDEN(0, 0);
	// returned value : TRUE if STATUSBAR is hidden, otherwise FALSE

	 NPPM_GETSHORTCUTBYCMDID = (NPPMSG + 76);
	// BOOL NPPM_GETSHORTCUTBYCMDID(int cmdID, ShortcutKey *sk);
	// get your plugin command current mapped shortcut into sk via cmdID
	// You may need it after getting NPPN_READY notification
	// returned value : TRUE if this function call is successful and shorcut is enable, otherwise FALSE

	 NPPM_DOOPEN             = (NPPMSG + 77);
	// BOOL NPPM_DOOPEN(0, const TCHAR *fullPathName2Open);
	// fullPathName2Open indicates the full file path name to be opened.
	// The return value is TRUE = (1); if the operation is successful, otherwise FALSE = (0);.

   VAR_NOT_RECOGNIZED  = 0;
   FULL_CURRENT_PATH   = 1;
   CURRENT_DIRECTORY   = 2;
   FILE_NAME           = 3;
   NAME_PART           = 4;
   EXT_PART            = 5;
   CURRENT_WORD        = 6;
   NPP_DIRECTORY       = 7;
   CURRENT_LINE        = 8;
   CURRENT_COLUMN      = 9;


	RUNCOMMAND_USER  = (WM_USER + 3000);
	 NPPM_GETFULLCURRENTPATH	=	(RUNCOMMAND_USER + FULL_CURRENT_PATH);
	 NPPM_GETCURRENTDIRECTORY	= (RUNCOMMAND_USER + CURRENT_DIRECTORY);
	 NPPM_GETFILENAME		      =	(RUNCOMMAND_USER + FILE_NAME);
	 NPPM_GETNAMEPART		      =	(RUNCOMMAND_USER + NAME_PART);
	 NPPM_GETEXTPART		      =	(RUNCOMMAND_USER + EXT_PART);
	 NPPM_GETCURRENTWORD      =	(RUNCOMMAND_USER + CURRENT_WORD);
	 NPPM_GETNPPDIRECTORY	    =	(RUNCOMMAND_USER + NPP_DIRECTORY);
	// BOOL NPPM_GETXXXXXXXXXXXXXXXX(size_t strLen, TCHAR *str);
	// where str is the allocated TCHAR array,
	//	     strLen is the allocated array size
	// The return value is TRUE when get generic_string operation success
	// Otherwise = (allocated array size is too small); FALSE

	 NPPM_GETCURRENTLINE	  =	(RUNCOMMAND_USER + CURRENT_LINE);
	// INT NPPM_GETCURRENTLINE(0, 0);
	// return the caret current position line
	 NPPM_GETCURRENTCOLUMN	=	(RUNCOMMAND_USER + CURRENT_COLUMN);
	// INT NPPM_GETCURRENTCOLUMN(0, 0);
	// return the caret current position column

// Notification code
 NPPN_FIRST = 1000;
	 NPPN_READY = (NPPN_FIRST + 1); // To notify plugins that all the procedures of launchment of notepad++ are done.
	//scnNotification->nmhdr.code = NPPN_READY;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = 0;

	 NPPN_TBMODIFICATION = (NPPN_FIRST + 2); // To notify plugins that toolbar icons can be registered
	//scnNotification->nmhdr.code = NPPN_TB_MODIFICATION;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = 0;

	 NPPN_FILEBEFORECLOSE = (NPPN_FIRST + 3); // To notify plugins that the current file is about to be closed
	//scnNotification->nmhdr.code = NPPN_FILEBEFORECLOSE;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;

	 NPPN_FILEOPENED = (NPPN_FIRST + 4); // To notify plugins that the current file is just opened
	//scnNotification->nmhdr.code = NPPN_FILEOPENED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;

	 NPPN_FILECLOSED = (NPPN_FIRST + 5); // To notify plugins that the current file is just closed
	//scnNotification->nmhdr.code = NPPN_FILECLOSED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;

	 NPPN_FILEBEFOREOPEN = (NPPN_FIRST + 6); // To notify plugins that the current file is about to be opened
	//scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;
	
	 NPPN_FILEBEFORESAVE = (NPPN_FIRST + 7); // To notify plugins that the current file is about to be saved
	//scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;
	
	 NPPN_FILESAVED = (NPPN_FIRST + 8); // To notify plugins that the current file is just saved
	//scnNotification->nmhdr.code = NPPN_FILESAVED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;

	 NPPN_SHUTDOWN = (NPPN_FIRST + 9); // To notify plugins that Notepad++ is about to be shutdowned.
	//scnNotification->nmhdr.code = NPPN_SHUTDOWN;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = 0;

	 NPPN_BUFFERACTIVATED = (NPPN_FIRST + 10); // To notify plugins that a buffer was activated = (put to foreground);.
	//scnNotification->nmhdr.code = NPPN_BUFFERACTIVATED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = activatedBufferID;

	 NPPN_LANGCHANGED = (NPPN_FIRST + 11); // To notify plugins that the language in the current doc is just changed.
	//scnNotification->nmhdr.code = NPPN_LANGCHANGED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = currentBufferID;

	 NPPN_WORDSTYLESUPDATED = (NPPN_FIRST + 12); // To notify plugins that user initiated a WordStyleDlg change.
	//scnNotification->nmhdr.code = NPPN_WORDSTYLESUPDATED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = currentBufferID;

	 NPPN_SHORTCUTREMAPPED = (NPPN_FIRST + 13); // To notify plugins that plugin command shortcut is remapped.
	//scnNotification->nmhdr.code = NPPN_SHORTCUTSREMAPPED;
	//scnNotification->nmhdr.hwndFrom = ShortcutKeyStructurePointer;
	//scnNotification->nmhdr.idFrom = cmdID;
		//where ShortcutKeyStructurePointer is pointer of struct ShortcutKey:
		//struct ShortcutKey {
		//	bool _isCtrl;
		//	bool _isAlt;
		//	bool _isShift;
		//	UCHAR _key;
		//};

	 NPPN_FILEBEFORELOAD = (NPPN_FIRST + 14); // To notify plugins that the current file is about to be loaded
	//scnNotification->nmhdr.code = NPPN_FILEBEFOREOPEN;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = NULL;

	 NPPN_FILELOADFAILED = (NPPN_FIRST + 15);  // To notify plugins that file open operation failed
	//scnNotification->nmhdr.code = NPPN_FILEOPENFAILED;
	//scnNotification->nmhdr.hwndFrom = hwndNpp;
	//scnNotification->nmhdr.idFrom = BufferID;

	 NPPN_READONLYCHANGED = (NPPN_FIRST + 16);  // To notify plugins that current document change the readonly status,
	//scnNotification->nmhdr.code = NPPN_READONLYCHANGED;
	//scnNotification->nmhdr.hwndFrom = bufferID;
	//scnNotification->nmhdr.idFrom = docStatus;
		// where bufferID is BufferID
		//       docStatus can be combined by DOCSTAUS_READONLY and DOCSTAUS_BUFFERDIRTY

		 DOCSTAUS_READONLY    = 1;
		 DOCSTAUS_BUFFERDIRTY = 2;

	 NPPN_DOCORDERCHANGED = (NPPN_FIRST + 16);  // To notify plugins that document order is changed
	//scnNotification->nmhdr.code = NPPN_DOCORDERCHANGED;
	//scnNotification->nmhdr.hwndFrom = newIndex;
	//scnNotification->nmhdr.idFrom = BufferID;


(* 以下定义翻译来源于 PluginInterface.h *)  

const
  nbChar = 64;

type
  // PFuncGetName
  PFUNCGETNAME = function:PTCHAR;cdecl;
  
  TNppData = record
	   _nppHandle             : HWND;
	   _scintillaMainHandle   : HWND;
	   _scintillaSecondHandle : HWND;
  end;
  // PFuncSetInfo
  PFUNCSETINFO   = procedure(NppData: TNppData);cdecl;
  // PFuncPluginCmd
  PFUNCPLUGINCMD = procedure;cdecl;
  // PBeNotified
  PBENOTIFIED    = procedure(var SCNotification: TSCNotification);cdecl;
  // PMessageProc
  PMESSAGEPROC   = function(iMessage: UINT; wParam: WPARAM; lParam: LPARAM):LRESULT;cdecl;

  PShortcutKey = ^TShortcutKey;
  TShortcutKey = record
    _isCtrl  : Boolean;
    _isAlt   : Boolean;
    _isShift : Boolean;
    _key     : Byte;
  end;

  PFuncItem = ^TFuncItem;
  TFuncItem = record
    _itemName   : array[0..nbChar - 1] of UCHAR;
    _pFunc      : PFUNCPLUGINCMD;
    _cmdID      : Integer;
    _init2Check : Boolean;
    _pShKey     : PShortcutKey;
  end;

  // PFuncGetFuncAarray
  PFUNCGETFUNCSARRAY = function(var nbF: Integer):PFuncItem;cdecl;



(* 以下翻译来源于 Docking.h*)
const
    CAPTION_TOP         = TRUE;
    CAPTION_BOTTOM      = FALSE;

    //   defines for docking manager
    CONT_LEFT         = 0;
    CONT_RIGHT        = 1;
    CONT_TOP          = 2;
    CONT_BOTTOM       = 3;
    DOCKCONT_MAX      = 4;

    // mask params for plugins of internal dialogs
    DWS_ICONTAB      =  $00000001;      // Icon for tabs are available
    DWS_ICONBAR      =  $00000002;      // Icon for icon bar are available (currently not supported)
    DWS_ADDINFO      =  $00000004;      // Additional information are in use
    DWS_PARAMSALL    =  (DWS_ICONTAB or DWS_ICONBAR or DWS_ADDINFO);

    // default docking values for first call of plugin
    DWS_DF_CONT_LEFT       = (CONT_LEFT  shl 28);   // default docking on left
    DWS_DF_CONT_RIGHT      = (CONT_RIGHT  shl 28);  // default docking on right
    DWS_DF_CONT_TOP        = (CONT_TOP  shl 28);    // default docking on top
    DWS_DF_CONT_BOTTOM     = (CONT_BOTTOM shl 28);  // default docking on bottom
    DWS_DF_FLOATING        = $80000000;             // default state is floating

    HIT_TEST_THICKNESS     = 20;
    SPLITTER_WIDTH         = 4;


   DMM_MSG                     = $5000;
    DMM_CLOSE                  = (DMM_MSG + 1);
    DMM_DOCK                   = (DMM_MSG + 2);
    DMM_FLOAT                  = (DMM_MSG + 3);
    DMM_DOCKALL                = (DMM_MSG + 4);
    DMM_FLOATALL               = (DMM_MSG + 5);
    DMM_MOVE                   = (DMM_MSG + 6);
    DMM_UPDATEDISPINFO         = (DMM_MSG + 7);
    DMM_GETIMAGELIST           = (DMM_MSG + 8);
    DMM_GETICONPOS             = (DMM_MSG + 9);
    DMM_DROPDATA               = (DMM_MSG + 10);
    DMM_MOVE_SPLITTER          = (DMM_MSG + 11);
  DMM_CANCEL_MOVE              = (DMM_MSG + 12);
  DMM_LBUTTONUP                = (DMM_MSG + 13);

  DMN_FIRST   = 1050;
  DMN_CLOSE   = (DMN_FIRST + 1);
 //nmhdr.code = DWORD(DMN_CLOSE, 0));
 //nmhdr.hwndFrom = hwndNpp;
 //nmhdr.idFrom = ctrlIdNpp;

  // 貌似无法收到相对应的Dock除Left外，Float完全无反应
  DMN_DOCK    = (DMN_FIRST + 2);
  DMN_FLOAT   = (DMN_FIRST + 3);
 //nmhdr.code = DWORD(DMN_XXX, int newContainer);
 //nmhdr.hwndFrom = hwndNpp;
 //nmhdr.idFrom = ctrlIdNpp;


type
   TtTbData = record
      hClient    : HWND;      // client Window Handle
      pszName    : PTCHAR;     // name of plugin (shown in window)
      dlgID      : Integer;   // a funcItem provides the function pointer to start a dialog. Please parse here these ID
      // user modifications
      uMask      : UINT;      // mask params: look to above defines
      hIconTab   : HICON;     // icon for tabs
      pszAddInfo : PTCHAR;    // for plugin to display additional informations
      // internal data, do not use !!!
      rcFloat    : TRECT;     // floating position
      iPrevCont  : Integer;   // stores the privious container (toggling between float and dock)
      pszModuleName : PTCHAR;  // it's the plugin file name. It's used to identify the plugin
  end;

  TtDockMgr = record
     hWnd : HWND;              // the docking manager wnd
     rcRegion :array[0..DOCKCONT_MAX - 1] of TRect;      // position of docked dialogs
  end;







  // 重新封装这几个函数是为了方便在非UNICODE环境下编写Notepad++ UNICODE版本的插件
  // 以便在 ANSI和UNICODE版本之前切换编译环境，从而不需要重新更改代码！
  function _lstrcpy(lpString1, lpString2: PTCHAR):PTCHAR;
  function _GetModuleFileName(hModule: HINST; lpFilename: PTCHAR; nSize: DWORD):Cardinal;
  function _LoadImage(hInst: HINST; ImageName: PTCHAR; ImageType: UINT; X, Y: Integer; Flags: UINT): HBITMAP;
implementation

function _lstrcpy(lpString1, lpString2: PTCHAR):PTCHAR;
begin
  Result := {$IFDEF UNICODE}lstrcpyW{$ELSE}lstrcpyA{$ENDIF}(lpString1, lpString2);
end;

function _GetModuleFileName(hModule: HINST; lpFilename: PTCHAR; nSize: DWORD):Cardinal;
begin
  Result := {$IFDEF UNICODE}GetModuleFileNameW{$ELSE}GetModuleFileNameA{$ENDIF}(hModule, lpFilename, nSize);
end;

function _LoadImage(hInst: HINST; ImageName: PTCHAR; ImageType: UINT; X, Y: Integer; Flags: UINT): HBITMAP;
begin
  Result := {$IFDEF UNICODE}LoadImageW{$ELSE}LoadImageA{$ENDIF}(hInst, ImageName, ImageType, X, Y, Flags);
end;


end.
