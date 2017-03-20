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
    AddIntKeyMenuItem: TMenuItem;
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
    procedure AddIntKeyMenuItemClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MenuItemNewPlistClick(Sender: TObject);
    procedure MakeNewFile;
    procedure OpenPlistMenuItemClick(Sender: TObject);
    procedure SaveMenuItemClick(Sender: TObject);
    procedure SavePlist;
    procedure OpenPlist;
    procedure ClearEditView;
    procedure UpdateTreeView(a_PlistParametr: array of PlistParametr);
    procedure ClearMassiveAndList;
    procedure AddParametrKeyName(out KeyName: string);
    procedure AddParametrKeyValue(out ParametrValue:string);
    procedure AddParametrInteger;
  private
    { private declarations }
  public
    { public declarations }

  end;

var
  MainForm: TMainForm;
  p_PlistParam: ^PlistParametr; // переменная-указатель параметра в plist'e
  a_PlistParametr: array of PlistParametr; // массив параметров plist'ов
  s_ErrorMessage: string; // строка ошибки
  sl_PlistStrings: TStringList; // массив строк plist'а
implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.AddParametrInteger;
//процедура добавления параметра с значением integer
begin
   { 0. Проверяем на какой мы закладке 
     0.1. Если мы на закладке synedit проверяем что фокус на edit'e иначе выходим
     0.2. Если мы на закладке дерева проверяем что выбран ли элемент иначе выходим
     0.3. Ввыводим сообщение что фокус должен быть на одном из элементов
     0.4. Вызываем окно ввода названия параметра
     0.5. Если не введено название выходим и выводим сообщение что не введено название файла
     0.6. Если название введено то вызываем окно для ввода значения параметра
     0.7. Если значение параметра не введено то выходим и выводим сообщение что не введено значение параметра
     0.8. Выделяем памать для массива записей

     1. Добавление параметра когда он первый в плисте
     1.1. Добавляем новую запись параметров в массив
     1.2. Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру
     1.3. Если выбран таб строковой то добавляем две строки и вставляем туда данные по параметру 
     2. Добавление параметра когда он добавляется после парамтра
     2.1. Если выбрана закладка дерева то добавляем в дерево два новых элемента с данными после выбранного параметра
     2.2. Если выбрана закладка synedit то добавляем две строки с данными после выбранного 
параметра
     3. Добавление параметра в словарь(dict) или массив(array)
     3.1. Если выбрана закладка дерева то добавляем в дерево в подветку два новых элемента с данными после выбранного параметра
     3.2. Если выбрана закладка synedit то добавляем две строки с данными после выбранного 
параметра
     4. Если добавляется второй и последующие параметры, то в цикле ищем выбранные в дереве или synedit'e параметр и добавляем в массив запись нового параметра после выбраного

    }
end;

procedure TMainForm.AddParametrKeyValue(out ParametrValue:string);
begin
   if not InputQuery('Parametr Value', 'Enter Value of Parametr', ParametrValue) then exit;
end;

procedure TMainForm.AddParametrKeyName(out KeyName: string);
begin
  if not InputQuery('Key Name', 'Enter name of key', KeyName) then exit;
  //ShowMessage('Entered key: '  +  KeyName);
end;

procedure TMainForm.ClearMassiveAndList;
// процедура очистки масива параметров и массива строк 
begin
   if sl_PlistStrings.Count <> 0 then begin
      sl_PlistStrings.Clear;
   end;
   if Length(a_PlistParametr) <> 0 then begin
      SetLength(a_PlistParametr, 0);
   end;
end;

procedure  TMainForm.UpdateTreeView(a_PlistParametr: array of PlistParametr);
// процедура обновления дерева 
var i: integer;
    Node, childNode, tempNode: TTreeNode;
begin
   TreeView.Items.BeginUpdate;
   Node:=TreeView.Items.Add(nil,'plist');
   childNode := Node;
   for i:=0 to (Length(a_PlistParametr)-1) do begin
      New(p_PlistParam);
      p_PlistParam^ := a_PlistParametr[i];
      if (a_PlistParametr[i].type_parm = dict) or
         (a_PlistParametr[i].type_parm = aray) then begin
          if (a_PlistParametr[i].Name = 'end array') or
              (a_PlistParametr[i].Name = 'end dict')  then begin
              TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
              //childNode.Data:= a_PlistParametr[i];
              childNode := childNode.Parent;
          end else begin
            if  a_PlistParametr[i].value <> '' then  begin
              childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].value, p_PlistParam);
            end else begin
              childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
            end;
          end;
          tempNode := childNode;
      end else if a_PlistParametr[i].value <> '' then begin
          childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
          TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].value, p_PlistParam);
          childNode := tempNode;
      end else begin
          TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
      end;
   end;
   TreeView.Items.EndUpdate;
end;

procedure TMainForm.ClearEditView;
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
     ClearMassiveAndList;

     s_ErrorMessage := '';
     err := 0;
     // загружаем файл в стриг лист
     sl_PlistStrings.LoadFromFile(OpenDialog.FileName);

    // Проверяем на валидность файл
    err := CheckPlist(sl_PlistStrings, s_ErrorMessage);
    if err = 0 then begin
      // Загружаем файл в SynEdit
      SynEdit.Lines.LoadFromFile(OpenDialog.FileName);
      //Задаем размер масиву a_PlistParametr
      setLength(a_PlistParametr, sl_PlistStrings.Count -4);
      // Разбиваем файл на параметры
      GroupPlistParametrs(sl_PlistStrings,a_PlistParametr);
      // Загружаем параметры в дерево
      UpdateTreeView(a_PlistParametr);
    end else begin
      // выдаем ошибку на экран о проблеме в стринг листе
      ShowMessage(s_ErrorMessage);
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
  ClearEditView;

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

procedure TMainForm.OpenPlistMenuItemClick(Sender: TObject);
begin
  OpenPlist;
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
   if Screen.Height < MainForm.Height then begin
      MainForm.Height := Screen.Height;
   end else begin
      MainForm.Height := 720;
   end;
   if Screen.Width < MainForm.Width then begin
      MainForm.Width := Screen.Width;
   end else begin
      MainForm.Width := 1150;
   end;
  //выделяем память для указателя
  New(p_PlistParam);
  //выделяем память для буферного стринглиста
  sl_PlistStrings := TStringList.Create;
  //выделяем память под массив пораметров
  SetLength(a_PlistParametr, 0);
end;

procedure TMainForm.AddIntKeyMenuItemClick(Sender: TObject);
// Процедура нажатия на кнопку добавления числового параметра в меню
// var s_KeyName, s_ParametrValue: string;
begin
  {Вызваем процедуру добавления числового параметра}

  {s_KeyName := '';
  AddParametrKeyName(s_KeyName);
  if s_KeyName <> '' then begin
    s_ParametrValue := '';
    AddParametrKeyValue(s_ParametrValue);

  end; }

end;


end.

