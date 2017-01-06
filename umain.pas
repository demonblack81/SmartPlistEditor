unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterHTML,
  Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, ComCtrls,

  uPlistRead;

type

  { TMainForm }

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    CloseMenuItem: TMenuItem;
    ClosePlistMenuItem: TMenuItem;
    EditMenuItem: TMenuItem;
    AddKeyMenuItem: TMenuItem;
    MenuItem1: TMenuItem;
    SaveASMenuItem: TMenuItem;
    SaveMenuItem: TMenuItem;
    OpenDialog: TOpenDialog;
    OpenPlistMenuItem: TMenuItem;
    MenuItemNewPlist: TMenuItem;
    MenuItemFile: TMenuItem;
    PageControl: TPageControl;
    StatusBar: TStatusBar;
    SynEdit: TSynEdit;
    SynHTMLSyn: TSynHTMLSyn;
    TabSheetTreeView: TTabSheet;
    TabSheetSynEdit: TTabSheet;
    ToolBar: TToolBar;
    TreeView: TTreeView;
    procedure FormCreate(Sender: TObject);
    procedure MenuItemNewPlistClick(Sender: TObject);
    procedure MakeNewFile;
    procedure SaveMenuItemClick(Sender: TObject);
    procedure SavePlist;
    procedure OpenPlist;
    procedure ClearEditView;
  private
    { private declarations }
  public
    { public declarations }

  end;

var
  MainForm: TMainForm;
  p_PlistParam: ^PlistParametr; // переменная-указатель параметра в plist'e
  a_PlistParametr: array of PlistParametr; // массив параметров plist'ов
  s_ErrorMessage: string;
  sl_PlistStrings: TStringList;
implementation

{$R *.lfm}

{ TMainForm }

procedure ClearEditView;
// процедура очистки дерева и синедита
begin 
  TreeView.Items.Clear;
  SynEdit.Lines.Clear;
end;

procedure TMainForm.OpenPlist; 
var err : integer; 
begin
    // 1.открываеем open dialog
  if OpenDialog.execute then begin
    //2. Если файл выбран очищаем treeview и synedit
     ClearEditView;
     // чистим TSrigList'ы и масивы с параметрами
     {  }
     if sl_PlistStrings.Count <> 0 then begin
        sl_PlistStrings.Clear;
     end; 
     if Length(a_PlistParametr) <> 0 then begin
        SetLength(a_PlistParametr, 0);
     end;
     s_ErrorMessage := '';
     err := 0;
     // загружаем файл в стриг лист
     sl_PlistStrings.LoadFromFile(OpenDialog.FileName);

    // Проверяем на валидность файл
    err := CheckPlist(sl_PlistStrings; s_ErrorMessage);
    if err = 0 then begin
      // Загружаем файл в SynEdit
      SynEdit.Lines.LoadFromFile(OpenDialog.FileName);
      // Разбиваем файл на параметры
      GroupPlistParametrs(sl_PlistStrings,a_PlistParametr);
      // Загружаем параметры в дерево

    end else begin
      // выдаем ошибку на экран о проблеме в стринг листе
      //ShowMessage(s_ErrorMessage);
    end;
   
  end;
end;

procedure TMainForm.SavePlist;
begin  
   // открываем SaveDialog
   // сохраняем из SynEdit все линии

   {If SaveDialog.excute then begin
       SynEdit.Lines.SaveToFile(SaveDialog.filename);
   End;}
end;

procedure TMainForm.MakeNewFile;
//var
begin
  //1.Очищаем treeview и synedit
  ClearEditView;

  //2.Проверяем что все мосивы пусты и если мосивы и TStringList's не пусты то очищаем все TSringlist и масивы
  {    }

  //3. Дисейблим кнопки Save в меню и на тулбаре
  SaveMenuItem.Enabled:= false;

  //4. В treeview добовляем корень plist
  TreeView.Items.Add(nil,'plist');

  //5. В synedit добавляем начальный шаблон плиста
  SynEdit.Lines.Add(c_HEADER1);
  SynEdit.Lines.Add(c_HEADER2);
  SynEdit.Lines.Add(c_BEGINPLIST);
  SynEdit.Lines.Add('');
  SynEdit.Lines.Add('');
  SynEdit.Lines.Add(c_ENDPLIST);

  //6. Если находимся в treeview ставим фокус на корне
  if PageControl.ActivePage = TabSheetTreeView then begin
    TreeView.SetFocus;
  end else begin
    //7. Если находися в synedit ставим фокус на 4 пустую строку
    if PageControl.ActivePage = TabSheetSynEdit then begin
      SynEdit.SetFocus;
    end;
  end;
end;

procedure TMainForm.SaveMenuItemClick(Sender: TObject);
begin
   SavePlist;
end;

procedure TMainForm.MenuItemNewPlistClick(Sender: TObject);
begin
  MakeNewFile;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  //выделяем память для указателя
  New(p_PlistParam);
  //выделяем память для буферного стринглиста
  sl_PlistStrings := TStringList.Create;
  //выделяем память под массив пораметров
  SetLength(a_PlistParametr, 0);
end;

end.

