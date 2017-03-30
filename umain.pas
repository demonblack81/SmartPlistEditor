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
    procedure AddParametrKeyValue(b_isInt:boolean; out ParametrValue:string);
    procedure AddParametrIntegerOrStringInTreeView(b_isInt:boolean);
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
  b_FirstParametr: boolean; // первый ли параметр
implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.AddParametrIntegerOrStringInTreeView(b_isInt:boolean);
//процедура добавления параметра с значением integer или string в TreeView
var s_ElementSelected, s_KeyName, s_ParametrValue: string;
    b_isTreeElementSelected: boolean;
    Node, ParentNode, ChildNode: TTreeNode;
    CurentPlistParametr, TempPlistParametr : PlistParametr;
    i: integer;
begin
    s_KeyName := '';
    s_ParametrValue := '';
    s_ElementSelected := '';
    // Проверяем если идет добавление первого параметра то фокуса на дереве может и не быть
    if b_FirstParametr then begin
      // Выделяем памать для массива записей
       try
         ParentNode := TreeView.Selected;
         b_isTreeElementSelected := true;
         SetLength(a_PlistParametr, 1);
       finally
         ShowMessage('Не выбран елемент куда добавлять параметр');
         b_isTreeElementSelected := false;
       end;
       if not b_isTreeElementSelected then exit;
    end else begin
     try
        s_ElementSelected := TreeView.Selected.Text;
        b_isTreeElementSelected := true;
      finally
         ShowMessage('Не выбран елемент куда добавлять параметр');
         b_isTreeElementSelected := false;
      end;
      if not b_isTreeElementSelected then exit;
    end;
    // Вызываем окно ввода названия параметра
    AddParametrKeyName(s_KeyName);
    if s_KeyName = '' then begin
       //Если значение параметра не введено то выходим и выводим сообщение что не введено значение параметра
       ShowMessage('Значение параметра не введено');
       exit;
    end;
    AddParametrKeyValue(b_isInt, s_ParametrValue);
    //Если название введено то вызываем окно для ввода значения параметра
    if s_ParametrValue = '' then begin
       //Если не введено название выходим и выводим сообщение что не введено название файла
       ShowMessage('Имя параметра не введено');
       exit;
    end;
    if b_FirstParametr then begin
      // Добавляем новую запись параметров в массив
      with a_PlistParametr[0] do begin
         Name := s_KeyName;
         if b_isInt then begin
           type_parm:= int;
         end else  begin
           type_parm:= str;
         end;
         level := 0;
         position:= 3;
         value:= s_ParametrValue;
      end;
      //Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру
      p_PlistParam^ := a_PlistParametr[0];
      ParentNode := TreeView.Items.AddChildObjectFirst(TreeView.Selected, s_KeyName, p_PlistParam);
      ChildNode :=  TreeView.Items.AddChildObject(ParentNode, s_ParametrValue, p_PlistParam);
      b_FirstParametr := false;
    end else begin
      // запоминаем выбранный узел считаем его за радительский
     ParentNode:= TreeView.Selected;
     //считываем record из выбраной ячейки
     TempPlistParametr:= PlistParametr(ParentNode.Data^);
     // заполняем данными новую record
     CurentPlistParametr.Name:= s_KeyName;
     if b_isInt then begin
       CurentPlistParametr.type_parm:= int;
     end else begin
       CurentPlistParametr.type_parm:= str;
     end;
     CurentPlistParametr.value:= s_ParametrValue;
     CurentPlistParametr.level:= TempPlistParametr.level;
     CurentPlistParametr.position:= TempPlistParametr.position + 1;
     p_PlistParam^ := CurentPlistParametr;
     //
     if (s_ElementSelected = 'dict') or (s_ElementSelected = 'array') or (s_ElementSelected = 'plist') then begin
        ParentNode := TreeView.Items.AddChildObjectFirst(TreeView.Selected, s_KeyName, p_PlistParam);
        ChildNode :=  TreeView.Items.AddChildObject(ParentNode, s_ParametrValue, p_PlistParam);
        if s_ElementSelected = 'plist' then begin
            CurentPlistParametr.position :=  3;
        end else begin
            CurentPlistParametr.position := TempPlistParametr.position + 1;
        end;
     end else begin
        ParentNode := TreeView.Items.InsertObject(TreeView.Selected, s_KeyName, p_PlistParam);
        ChildNode :=  TreeView.Items.AddChildObject(ParentNode, s_ParametrValue, p_PlistParam);
        CurentPlistParametr.position:= TempPlistParametr.position;
     end;
     setLength(a_PlistParametr, (Length(a_PlistParametr)+1));
     for i:= 0 to (Length(a_PlistParametr)-1) do begin
          if CurentPlistParametr.position = a_PlistParametr[i].position then begin
            TempPlistParametr:= a_PlistParametr[i];
            a_PlistParametr[i]:= CurentPlistParametr;
            CurentPlistParametr:= TempPlistParametr;
            CurentPlistParametr.position:= CurentPlistParametr.position + 1;
          end;
     end;
     Dispose(p_PlistParam);
     TreeView.Items.Clear;
     UpdateTreeView(a_PlistParametr);
    { TreeView.Items.BeginUpdate;
     Node := TreeView.Items.Add(nil,'plist');
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
          Node := childNode;
      end else if a_PlistParametr[i].value <> '' then begin
          childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
          TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].value, p_PlistParam);
          childNode := Node;
      end else begin
          TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
      end;

     end;
    TreeView.Items.EndUpdate;  }
    Node := TreeView.Items.FindNodeWithText(s_KeyName);
    Node.ExpandParents;
    end;
    {
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

procedure TMainForm.AddParametrKeyValue(b_isInt:boolean;out ParametrValue:string);
begin
   if b_isInt then begin
      if not InputQuery('Числовое название', 'Введите числовое значение параметра', ParametrValue) then exit;
   end else begin
      if not InputQuery('Parametr Value', 'Enter Value of Parametr', ParametrValue) then exit;
   end;
end;

procedure TMainForm.AddParametrKeyName(out KeyName: string);
begin
  if not InputQuery('Название параметра:', 'Введите название параметра', KeyName) then exit;
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
      MainForm.Height := 710;
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
begin
   //0. Проверяем на какой мы закладке
   if PageControl.ActivePage = TabSheetSynEdit then begin
      // 0.1. Если мы на закладке synedit проверяем что фокус на edit'e иначе выходим
      if Synedit.Focused then begin
        // вызываем процедуру добавления числового параметра
      end else begin
        ShowMessage('Выберете место куда вставлять новый параметр.');
        exit;
      end;
   end else begin
      if PageControl.ActivePage = TabSheetTreeView then begin
        //вызываем процедуру добавления числового параметра в дерево
      end else begin
           ShowMessage('Выберете место куда вставлять новый параметр.');
           exit;
      end;
   end;
  {Вызваем процедуру добавления числового параметра}



end;


end.

