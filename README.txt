根据你安装的Notepad++是32bit还是64bit的选择性编译。

将编译好的插件放到"你的安装路径\Notepad++\plugins"目录。

然后在在Notepad++菜单->插件->我的一些处理工具  或者点击 工具栏上的“向上三角型”

以下几个功能都必须首先在Notepad++编辑框选择一段文本：

【Delphi常量转Go】


const
  { Local Memory Flags }

  LMEM_FIXED = 0;
  {$EXTERNALSYM LMEM_FIXED}
  LMEM_MOVEABLE = 2;
  {$EXTERNALSYM LMEM_MOVEABLE}
  LMEM_NOCOMPACT = $10;
  {$EXTERNALSYM LMEM_NOCOMPACT}
  LMEM_NODISCARD = $20;
  {$EXTERNALSYM LMEM_NODISCARD}
  LMEM_ZEROINIT = $40;
  {$EXTERNALSYM LMEM_ZEROINIT}
  LMEM_MODIFY = $80;
  {$EXTERNALSYM LMEM_MODIFY}
  LMEM_DISCARDABLE = $F00;
  {$EXTERNALSYM LMEM_DISCARDABLE}
  LMEM_VALID_FLAGS = $F72;
  {$EXTERNALSYM LMEM_VALID_FLAGS}
  LMEM_INVALID_HANDLE = $8000;
  {$EXTERNALSYM LMEM_INVALID_HANDLE}

  LHND = LMEM_MOVEABLE or LMEM_ZEROINIT;
  {$EXTERNALSYM LHND}
  LPTR = LMEM_FIXED or LMEM_ZEROINIT;
  {$EXTERNALSYM LPTR}

  NONZEROLPTR = LMEM_FIXED;
  {$EXTERNALSYM NONZEROLPTR}


【Delphi Winapi翻译至Go】

// 示例，必须按照这种，后面要有dll名或者dll名的常量，如"version"，再就是name。

function GetFileVersionInfo(lptstrFilename: LPWSTR; dwHandle, dwLen: DWORD; lpData: Pointer): BOOL; stdcall; external version name 'GetFileVersionInfoW';

【Delphi结构转Go】


  TPenData = record
    Handle: HPen;
    Color: TColor;
    Width: Integer;
    Style: TPenStyle;
  end;

【Delphi枚举转Go】

TPenStyle = (psSolid, psDash, psDot, psDashDot, psDashDotDot, psClear, psInsideFrame, psUserStyle, psAlternate);