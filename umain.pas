unit uMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit, SynHighlighterHTML,
  Forms, Controls, Graphics, Dialogs, Menus, ExtCtrls, ComCtrls,
  LCLType,

  uPlistRead, uEditKey;

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
    AddKeyStringMenuItem: TMenuItem;
    AddKeyBoolMenuItem: TMenuItem;
    AddKeyDateMenuItem: TMenuItem;
    AddKeyDictMenuItem: TMenuItem;
    AddKeyArrayMenuItem: TMenuItem;
    AddKeyDataMenuItem: TMenuItem;
    AddDictMenuItem: TMenuItem;
    AddArrayMenuItem: TMenuItem;
    SaveASMenuItem: TMenuItem;
    SaveDialog: TSaveDialog;
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
    procedure AddKeyBoolMenuItemClick(Sender: TObject);
    procedure AddKeyDateMenuItemClick(Sender: TObject);
    procedure AddKeyDictMenuItemClick(Sender: TObject);
    procedure AddKeyStringMenuItemClick(Sender: TObject);
    procedure CloseMenuItemClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuItemNewPlistClick(Sender: TObject);
    procedure MakeNewFile;
    procedure OpenPlistMenuItemClick(Sender: TObject);
    procedure PageControlChange(Sender: TObject);
    procedure SaveMenuItemClick(Sender: TObject);
    procedure SavePlist;
    procedure OpenPlist;
    procedure ClearEditView;
    procedure UpdateTreeView(a_PlistParametr: array of PlistParametr);
    procedure ClearMassiveAndList;
    procedure AddParametrKeyName(out KeyName: string);
    procedure AddParametrKeyValue(b_isInt:boolean; out ParametrValue:string);
    procedure AddParametrIntegerOrStringInTreeView(b_isInt:boolean);
    procedure AddParametrDateInTreeView;
    procedure AddParametrBooleanInTreeView;
    procedure AddParametrDictInTreeView;
    procedure AddDictInTreeView;

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
  LogString: TStringList; // массив строк логирования программы
  StartPath: string; //Строка пути к программе
implementation

{$R *.lfm}

{ TMainForm }

procedure TMainForm.AddParametrBooleanInTreeView;
//процедура добавления параметра с значением Boolean в TreeView
var s_ElementSelected, s_KeyName, s_ParametrValue: string;
    b_isTreeElementSelected: boolean;
    Node, ParentNode, ChildNode: TTreeNode;
    CurentPlistParametr, TempPlistParametr : PlistParametr;
    i: integer;
begin
  LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Процедура добавления параметра с значением date в TreeView.');
  s_ParametrValue := '';
  s_ElementSelected := '';
  LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Проверяем первый ли это элемент в pliste');
  if b_FirstParametr then begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Присваеваем переменной ParentNode выбранный в дереве элемент.');
      ParentNode := TreeView.Selected;
      b_isTreeElementSelected := true;
      LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Увеличеваем размер массива записей на один.');
      SetLength(a_PlistParametr, 1);
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end else begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Присваеваем переменной s_ElementSelected строку из выбраного в дереве элемента.');
      s_ElementSelected := TreeView.Selected.Text;
      b_isTreeElementSelected := true;
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end;
  LogString.Add(DateTimeToStr(Now) + ': AddParametrBooleanInTreeView. Выставлям ключ b_EditMode в режим добавления date.');
  b_isEditMode := 2;

  LogString.Add(DateTimeToStr(Now) + ': AddParametrBooleanInTreeView. Изменяем форму Editkey для добавления ключа с датой');
  LogString.Add(DateTimeToStr(Now) + ': AddParametrBooleanInTreeView. Показваем форму Editkey');
  if EditKeyForm.ShowModal = mrOK then begin
     LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Проверяем все ли поля заполнены после нажатия Ок на форме Editkey');
     if EditKeyForm.KeyEdit.Text = '' then begin
       LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Если не заполнены пол показваем алерт что не введено и возвращаемся к п.5');
       ShowMessage('Значение параметра не введено. Заполните поле: Имя параметра.');
       exit;
     end;
  end else begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Если не заполнены пол показваем алерт что не введено и возвращаемся к п.5');
    ShowMessage('Отмена ввода.');
    exit;
  end;
  LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Если поля заполнены то создаем новую запись  PlistParametr и добавляем туда заполненый параметр.');
  s_KeyName := EditKeyForm.KeyEdit.Text;
  if EditKeyForm.KeyBooleanCheckBox.Checked then s_ParametrValue := 'true'
  else s_ParametrValue := 'false';
  if b_FirstParametr then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Добавляем новую запись параметров в массив.');
    with a_PlistParametr[0] do begin
      Name := s_KeyName;
      type_parm:= bool;
      level := 0;
      position:= 3;
      value:= s_ParametrValue;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру.');
    p_PlistParam^ := a_PlistParametr[0];
    ParentNode := TreeView.Items.AddChildObjectFirst(TreeView.Selected, s_KeyName, p_PlistParam);
    ChildNode :=  TreeView.Items.AddChildObject(ParentNode, s_ParametrValue, p_PlistParam);
    b_FirstParametr := false;
  end else begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Запоминаем выбранный узел считаем его за радительский.');
    ParentNode:= TreeView.Selected;
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Считываем record из выбраной ячейки.');
    TempPlistParametr:= PlistParametr(ParentNode.Data^);
    LogString.Add(DateTimeToStr(Now) +': AddParametrBooleanInTreeView. Заполняем данными новую record.');
    CurentPlistParametr.Name:= s_KeyName;
    CurentPlistParametr.type_parm:= date;
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
    Node := TreeView.Items.FindNodeWithText(s_KeyName);
    Node.ExpandParents;
  end;
end;

procedure TMainForm.AddParametrDictInTreeView;
//процедура добавления параметра dict в TreeView
var s_ElementSelected, s_KeyName, s_ParametrValue: string;
    b_isTreeElementSelected: boolean;
    Node, ParentNode, ChildNode: TTreeNode;
    CurentPlistParametr, TempPlistParametr : PlistParametr;
    i, i_TempPosition, i_TempLevel: integer;

    //i_CountTreeItem, tmp_CountTreeItem: integer;
begin
  LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Процедура добавления параметра с значением date в TreeView.');
  s_ParametrValue := '';
  s_ElementSelected := '';
  LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Проверяем первый ли это элемент в pliste');
  if b_FirstParametr then begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Присваеваем переменной ParentNode выбранный в дереве элемент.');
      ParentNode := TreeView.Selected;
      b_isTreeElementSelected := true;
      LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Увеличеваем размер массива записей на один.');
      SetLength(a_PlistParametr, 3);
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end else begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Присваеваем переменной s_ElementSelected строку из выбраного в дереве элемента.');
      s_ElementSelected := TreeView.Selected.Text;
      b_isTreeElementSelected := true;
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end;

  //i_CountTreeItem := TreeView.Items.Count;

  LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Вызываем окно ввода названия параметра.');
  AddParametrKeyName(s_KeyName);
  if s_KeyName = '' then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Если значение параметра не введено то выходим и выводим сообщение что не введено значение параметра.');
    ShowMessage('Значение параметра не введено');
    exit;
  end;

  if b_FirstParametr then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Добавляем новую запись параметров в массив.');
    with a_PlistParametr[0] do begin
      Name := s_KeyName;
      type_parm:= key;
      level := 0;
      position:= 3;
      value:= s_ParametrValue;
    end;
    with a_PlistParametr[1] do begin
      Name := 'dictkey';
      type_parm:= dict;
      level := 1;
      position:= 4;
      value:= 'dict';
    end;
    with a_PlistParametr[2] do begin
      Name := 'end dict';
      type_parm:= dict;
      level := 1;
      position:= 3;
      value:= '/dict';
    end;

    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру.');
    p_PlistParam^ := a_PlistParametr[0];
    ParentNode := TreeView.Items.AddChildObjectFirst(TreeView.Selected, s_KeyName, p_PlistParam);
    p_PlistParam^ := a_PlistParametr[1];
    ChildNode :=  TreeView.Items.AddChildObject(ParentNode, a_PlistParametr[1].value, p_PlistParam);
    p_PlistParam^ := a_PlistParametr[2];
    ChildNode :=  TreeView.Items.AddChildObject(ParentNode, a_PlistParametr[2].Name, p_PlistParam);
    b_FirstParametr := false;
  end else begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Запоминаем выбранный узел считаем его за радительский.');
    Node:= TreeView.Selected;
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView. Считываем record из выбраной ячейки.');
    TempPlistParametr:= PlistParametr(Node.Data^);
    LogString.Add(DateTimeToStr(Now) +': AddParametrDictInTreeView . Заполняем данными новую record.');
    CurentPlistParametr.Name:= s_KeyName;
    CurentPlistParametr.type_parm:= key;
    CurentPlistParametr.value:= s_ParametrValue;
    CurentPlistParametr.level:= TempPlistParametr.level;
    CurentPlistParametr.position:= TempPlistParametr.position + 1;
    p_PlistParam^ := CurentPlistParametr;
    TreeView.BeginUpdate;
    if (s_ElementSelected = 'dict') or (s_ElementSelected = 'array') or (s_ElementSelected = 'plist') then begin
      ParentNode := TreeView.Items.AddChildObjectFirst(Node, s_KeyName, p_PlistParam);
      if s_ElementSelected = 'plist' then begin
        CurentPlistParametr.position :=  3;
      end else begin
        CurentPlistParametr.position := TempPlistParametr.position + 1;
      end;
    end else begin
       ParentNode := TreeView.Items.InsertObject(Node, s_KeyName, p_PlistParam);
       CurentPlistParametr.position:= TempPlistParametr.position;
    end;
    i_TempPosition := CurentPlistParametr.position;
    i_TempLevel := CurentPlistParametr.level;

    setLength(a_PlistParametr, (Length(a_PlistParametr)+1));
    for i:= 0 to (Length(a_PlistParametr)-1) do begin
      if CurentPlistParametr.position = a_PlistParametr[i].position then begin
        TempPlistParametr:= a_PlistParametr[i];
        a_PlistParametr[i]:= CurentPlistParametr;
        CurentPlistParametr:= TempPlistParametr;
        CurentPlistParametr.position:= CurentPlistParametr.position + 1;
      end;
    end;

    CurentPlistParametr.Name:= 'dictkey';
    CurentPlistParametr.type_parm:= dict;
    CurentPlistParametr.value:= 'dict';
    CurentPlistParametr.level := i_TempLevel + 1;
    CurentPlistParametr.position := i_TempPosition + 1;
    p_PlistParam^ := CurentPlistParametr;
    ChildNode := TreeView.Items.AddChildObject(ParentNode, CurentPlistParametr.value, p_PlistParam);

    i_TempPosition := CurentPlistParametr.position;
    i_TempLevel := i_TempLevel + 1;
    setLength(a_PlistParametr, (Length(a_PlistParametr)+1));
    for i:= 0 to (Length(a_PlistParametr)-1) do begin
      if CurentPlistParametr.position = a_PlistParametr[i].position then begin
        TempPlistParametr:= a_PlistParametr[i];
        a_PlistParametr[i]:= CurentPlistParametr;
        CurentPlistParametr:= TempPlistParametr;
        CurentPlistParametr.position:= CurentPlistParametr.position + 1;
      end;
    end;

    CurentPlistParametr.Name:= 'end dict';
    CurentPlistParametr.type_parm:= dict;
    CurentPlistParametr.value:= '/dict';
    CurentPlistParametr.level := i_TempPosition - 1;
    CurentPlistParametr.position := i_TempPosition + 1;
    p_PlistParam^ := CurentPlistParametr;
    ChildNode := TreeView.Items.AddChildObject(ParentNode, CurentPlistParametr.Name, p_PlistParam);
    TreeView.EndUpdate;

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
    Node := TreeView.Items.FindNodeWithText(s_KeyName);
    if Node = nil then TreeView.FullExpand
    else Node.ExpandParents;
  end;
end;

procedure TMainForm.AddDictInTreeView(ParentNode: TTreeNode);
// Процедура добавления тега <dict></dict> в TreeView
var s_ElementSelected:string;
    b_isTreeElementSelected: boolean;
    Node, ParentNode, ChildNode: TTreeNode;
    CurentPlistParametr, TempPlistParametr : PlistParametr;
    i: integer;
begin
  LogString.Add(DateTimeToStr(Now) +': AddDictInTreeView. Процедура добавления тега <dict></dict> в TreeView.');
  if b_FirstParametr then begin
  try
     LogString.Add(DateTimeToStr(Now) +': AddDictInTreeView. Присваеваем переменной ParentNode выбранный в дереве элемент.');
     if ParentNode = nil then ParentNode := TreeView.Selected;
     b_isTreeElementSelected := true;
     LogString.Add(DateTimeToStr(Now) +': AddDictInTreeView. Увеличеваем размер массива записей на один.');
     SetLength(a_PlistParametr, 1);
  except
     LogString.Add(DateTimeToStr(Now) +': AddDictInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
     ShowMessage('Не выбран элемент куда добавлять параметр');
     b_isTreeElementSelected := false;
  end;
  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
  if not b_isTreeElementSelected then exit;

   // Проверяем выбран ли елемент за котрым будем добавлять тег dict если ParentNode не равен null
   // Проверяем первый ли параметр в plist'e
   // Если первый то добавляем новый dict сразу
   // Присваеваем переменной ParentNode выбранный в дереве элемент.
   // увеличеваем размер массива записей на один.
end;

procedure TMainForm.AddParametrDateInTreeView;
//процедура добавления параметра с значением date в TreeView
var s_ElementSelected, s_KeyName, s_ParametrValue: string;
    b_isTreeElementSelected: boolean;
    Node, ParentNode, ChildNode: TTreeNode;
    CurentPlistParametr, TempPlistParametr : PlistParametr;
    i: integer;
begin
  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Процедура добавления параметра с значением date в TreeView.');
  s_ParametrValue := '';
  s_ElementSelected := '';
  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Проверяем первый ли это элемент в pliste');
  if b_FirstParametr then begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Присваеваем переменной ParentNode выбранный в дереве элемент.');
      ParentNode := TreeView.Selected;
      b_isTreeElementSelected := true;
      LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Увеличеваем размер массива записей на один.');
      SetLength(a_PlistParametr, 1);
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end else begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Присваеваем переменной s_ElementSelected строку из выбраного в дереве элемента.');
      s_ElementSelected := TreeView.Selected.Text;
      b_isTreeElementSelected := true;
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end;

  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Выставлям ключ b_EditMode в режим добавления date.');
  b_isEditMode := 1;

  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Изменяем форму Editkey для добавления ключа с датой');
  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Показваем форму Editkey');
  if EditKeyForm.ShowModal = mrOK then begin
     LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Проверяем все ли поля заполнены после нажатия Ок на форме Editkey');
     if EditKeyForm.KeyEdit.Text = '' then begin
       LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если не заполнены пол показваем алерт что не введено и возвращаемся к п.5');
       ShowMessage('Значение параметра не введено. Заполните поле: Имя параметра.');
       exit;
     end;
  end else begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если не заполнены пол показваем алерт что не введено и возвращаемся к п.5');
    ShowMessage('Отмена ввода.');
    exit;
  end;
  LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если поля заполнены то создаем новую запись  PlistParametr и добавляем туда заполненый параметр.');
  s_KeyName := EditKeyForm.KeyEdit.Text;
  s_ParametrValue := FormatdateTime('yyyy-mm-dd"T"hh:mm:ss"Z"', EditKeyForm.DateTimePicker.DateTime);
  if b_FirstParametr then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Добавляем новую запись параметров в массив.');
    with a_PlistParametr[0] do begin
      Name := s_KeyName;
      type_parm:= date;
      level := 0;
      position:= 3;
      value:= s_ParametrValue;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру.');
    p_PlistParam^ := a_PlistParametr[0];
    ParentNode := TreeView.Items.AddChildObjectFirst(TreeView.Selected, s_KeyName, p_PlistParam);
    ChildNode :=  TreeView.Items.AddChildObject(ParentNode, s_ParametrValue, p_PlistParam);
    b_FirstParametr := false;
  end else begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Запоминаем выбранный узел считаем его за радительский.');
    ParentNode:= TreeView.Selected;
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView. Считываем record из выбраной ячейки.');
    TempPlistParametr:= PlistParametr(ParentNode.Data^);
    LogString.Add(DateTimeToStr(Now) +': AddParametrDateInTreeView . Заполняем данными новую record.');
    CurentPlistParametr.Name:= s_KeyName;
    CurentPlistParametr.type_parm:= date;
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
    Node := TreeView.Items.FindNodeWithText(s_KeyName);
    Node.ExpandParents;
  end;
end;


procedure TMainForm.AddParametrIntegerOrStringInTreeView(b_isInt:boolean);
//процедура добавления параметра с значением integer или string в TreeView
var s_ElementSelected, s_KeyName, s_ParametrValue: string;
    b_isTreeElementSelected: boolean;
    Node, ParentNode, ChildNode: TTreeNode;
    CurentPlistParametr, TempPlistParametr : PlistParametr;
    i: integer;
begin
  LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Процедура добавления параметра с значением integer или string в TreeView.');
  s_KeyName := '';
  s_ParametrValue := '';
  s_ElementSelected := '';
  LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Проверяем если идет добавление первого параметра, то фокуса на дереве может и не быть.');
  if b_FirstParametr then begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Присваеваем переменной ParentNode выбранный в дереве элемент.');
      ParentNode := TreeView.Selected;
      b_isTreeElementSelected := true;
      LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Увеличеваем размер массива записей на один.');
      SetLength(a_PlistParametr, 1);
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end else begin
    try
      LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Присваеваем переменной s_ElementSelected строку из выбраного в дереве элемента.');
      s_ElementSelected := TreeView.Selected.Text;
      b_isTreeElementSelected := true;
    except
      LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Выводим сообщение что в дереве не выбран элемент куда втавлять параметр.');
      ShowMessage('Не выбран элемент куда добавлять параметр');
      b_isTreeElementSelected := false;
    end;
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Если не выбрано место куда вставлять параметр выходим из процедуры.');
    if not b_isTreeElementSelected then exit;
  end;
  LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Вызываем окно ввода названия параметра.');
  AddParametrKeyName(s_KeyName);
  if s_KeyName = '' then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Если значение параметра не введено то выходим и выводим сообщение что не введено значение параметра.');
    ShowMessage('Значение параметра не введено');
    exit;
  end;
  AddParametrKeyValue(b_isInt, s_ParametrValue);
  LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Если название введено то вызываем окно для ввода значения параметра.');
  if s_ParametrValue = '' then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Если не введено название выходим и выводим сообщение что не введено название файла.');
    ShowMessage('Имя параметра не введено');
    exit;
  end;
  if b_FirstParametr then begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Добавляем новую запись параметров в массив.');
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
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру.');
    p_PlistParam^ := a_PlistParametr[0];
    ParentNode := TreeView.Items.AddChildObjectFirst(TreeView.Selected, s_KeyName, p_PlistParam);
    ChildNode :=  TreeView.Items.AddChildObject(ParentNode, s_ParametrValue, p_PlistParam);
    b_FirstParametr := false;
  end else begin
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Запоминаем выбранный узел считаем его за радительский.');
    ParentNode:= TreeView.Selected;
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Считываем record из выбраной ячейки.');
    TempPlistParametr:= PlistParametr(ParentNode.Data^);
    LogString.Add(DateTimeToStr(Now) +': AddParametrIntegerOrStringInTreeView. Заполняем данными новую record.');
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
    Node := TreeView.Items.FindNodeWithText(s_KeyName);
    Node.ExpandParents;
  end;
    {
     1.2. Если выбран таб дерева то добавляем два новых элемента в дерево и вставляем туда данные по параметру
     1.3. Если выбран таб строковой то добавляем две строки и вставляем туда данные по параметру 
     2. Добавление параметра когда он добавляется после парамтра
     2.1. Если выбрана закладка дерева то добавляем в дерево два новых элемента с данными после выбранного параметра
     2.2. Если выбрана закладка synedit то добавляем две строки с данными после выбранного параметра
     3. Добавление параметра в словарь(dict) или массив(array)
     3.1. Если выбрана закладка дерева то добавляем в дерево в подветку два новых элемента с данными после выбранного параметра
     3.2. Если выбрана закладка synedit то добавляем две строки с данными после выбранного параметра
     4. Если добавляется второй и последующие параметры, то в цикле ищем выбранные в дереве или synedit'e параметр и добавляем в массив запись нового параметра после выбраного
    }
end;

procedure TMainForm.AddParametrKeyValue(b_isInt:boolean;out ParametrValue:string);
begin
   LogString.Add(DateTimeToStr(Now) +': AddParametrKeyValue. Проверяем добовляем ли мы парамметр integer.');
   if b_isInt then begin
      LogString.Add(DateTimeToStr(Now) +': AddParametrKeyValue. Показываем окно ввода параметра integer.');
      if not InputQuery('Числовое название', 'Введите числовое значение параметра', ParametrValue) then exit;
   end else begin
      LogString.Add(DateTimeToStr(Now) +': AddParametrKeyValue. Показываем окно ввода параметра string.');
      if not InputQuery('Parametr Value', 'Enter Value of Parametr', ParametrValue) then exit;
   end;
end;

procedure TMainForm.AddParametrKeyName(out KeyName: string);
begin
  LogString.Add(DateTimeToStr(Now) +': AddParametrKeyName. Показываем окно ввода названия параметра.');
  if not InputQuery('Название параметра:', 'Введите название параметра', KeyName) then exit;
  //ShowMessage('Entered key: '  +  KeyName);
end;

procedure TMainForm.ClearMassiveAndList;
// процедура очистки масива параметров и массива строк 
begin
   LogString.Add(DateTimeToStr(Now) +': ClearMassiveAndList. Проверяем заполнен ли sl_PlistStrings.');
   if sl_PlistStrings.Count <> 0 then begin
     LogString.Add(DateTimeToStr(Now) +': ClearMassiveAndList. Очищаем sl_PlistStrings.');
     sl_PlistStrings.Clear;
   end;
   LogString.Add(DateTimeToStr(Now) +': ClearMassiveAndList. Проверяем что масив a_PlistParamter не пуст.');
   if Length(a_PlistParametr) <> 0 then begin
     LogString.Add(DateTimeToStr(Now) +': ClearMassiveAndList. Обнуляем массав.');
     SetLength(a_PlistParametr, 0);
   end;
end;

procedure  TMainForm.UpdateTreeView(a_PlistParametr: array of PlistParametr);
// процедура обновления дерева 
var i: integer;
    Node, childNode, tempNode: TTreeNode;
begin
  LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Запуск процедуры обновления дерева.');
  TreeView.Items.BeginUpdate;
  LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Присваеваем переменной Node первого элемента в дереве.');
  Node:=TreeView.Items.Add(nil,'plist');
  LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Присваеваем переменной childNode то что в Node.');
  childNode := Node;
  LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Запускаем в цикле добавление параетров из plist.');
  for i:=0 to (Length(a_PlistParametr)-1) do begin
    LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Выделяем память для переменной p_PlistParam.');
    New(p_PlistParam);
    LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Присваеваем переменной p_PlistParam адрес ячеки где записана запись a_PlistParam[' + IntToStr(i) + '].');
    p_PlistParam^ := a_PlistParametr[i];
    LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Проверяем если тип параметра dict или array.');
    if (a_PlistParametr[i].type_parm = dict) or
       (a_PlistParametr[i].type_parm = aray) then begin
      LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Проверяем что параметр завершения dict или array.');
      if (a_PlistParametr[i].Name = 'end array') or
         (a_PlistParametr[i].Name = 'end dict')  then begin
        LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Добовлем в дерево обьект: .' + a_PlistParametr[i].Name);
        TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
        LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Присваиваем childNode радительское node.');
        if  childNode.Parent <> Node then childNode := childNode.Parent;
      end else begin
        LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если имя параметра не dict end или array end, то проверяем заполнена ли value.');
        if  a_PlistParametr[i].value <> '' then  begin
          LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если value не пустое, то добовлем в дерево обьект: .' + a_PlistParametr[i].value);
          childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].value, p_PlistParam);
        end else begin
          LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если value пустое, то добовлем в дерево обьект: .' + a_PlistParametr[i].Name);
          childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
        end;
      end;
      LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Присваеваем tempNode текущий ChildNode.');
      tempNode := childNode;
      LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если тип параметра не dict или array, то проверяем заполнена ли value.');
    end else if a_PlistParametr[i].value <> '' then begin
      LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если value не пустое, то добовлем в дерево обьект: .' + a_PlistParametr[i].Name);
      childNode := TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
      LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если value не пустое, то добовлем в дерево обьект: .' + a_PlistParametr[i].value);
      TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].value, p_PlistParam);
      childNode := tempNode;
    end else begin
      LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Если value пустое, то добовлем в дерево обьект: .' + a_PlistParametr[i].Name);
      TreeView.Items.AddChildObject(childNode, a_PlistParametr[i].Name, p_PlistParam);
    end;
  end;
  LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Открываем все дерево');
  TreeView.FullExpand;
  LogString.Add(DateTimeToStr(Now) +': UpdateTreeView. Завершаем обновление дерева параметров.');
  TreeView.Items.EndUpdate;
end;

procedure TMainForm.ClearEditView;
begin
  LogString.Add(DateTimeToStr(Now) +': ClearEditView. Запукаем процедура очистки дерева и синедита.');
  TreeView.Items.Clear;
  SynEdit.Lines.Clear;
end;

procedure TMainForm.OpenPlist; 
var err : integer; 
begin
  LogString.Add(DateTimeToStr(Now) +': OpenPlist. Открываеем open dialog.');
  if OpenDialog.execute then begin
    LogString.Add(DateTimeToStr(Now) +': OpenPlist. Если файл выбран очищаем treeview и synedit.');
    ClearEditView;
    LogString.Add(DateTimeToStr(Now) +': OpenPlist. Чистим TSrigList и масивы с параметрами.');
    ClearMassiveAndList;
    s_ErrorMessage := '';
    err := 0;
    LogString.Add(DateTimeToStr(Now) +': OpenPlist. Загружаем файл в стриг лист.');
    sl_PlistStrings.LoadFromFile(OpenDialog.FileName);
    LogString.Add(DateTimeToStr(Now) +': OpenPlist. Проверяем на валидность файл.');
    err := CheckPlist(sl_PlistStrings, s_ErrorMessage);
    if err = 0 then begin
      LogString.Add(DateTimeToStr(Now) +': OpenPlist. Загружаем файл в SynEdit.');
      SynEdit.Lines.LoadFromFile(OpenDialog.FileName);
      LogString.Add(DateTimeToStr(Now) +': OpenPlist. Задаем размер масиву a_PlistParametr.');
      setLength(a_PlistParametr, sl_PlistStrings.Count -4);
      LogString.Add(DateTimeToStr(Now) +': OpenPlist. Разбиваем файл на параметры.');
      err := GroupPlistParametrs(sl_PlistStrings,a_PlistParametr);
      setLength(a_PlistParametr, err);
      LogString.Add(DateTimeToStr(Now) +': OpenPlist. Загружаем параметры в дерево.');
      UpdateTreeView(a_PlistParametr);
      LogString.Add(DateTimeToStr(Now) +': OpenPlist. Так как параметры уже есть устанавливаем правильно переменную b_FirstParametr.');
      b_FirstParametr := false;
    end else begin
      LogString.Add(DateTimeToStr(Now) +': OpenPlist. Выдаем ошибку на экран о проблеме в стринг листе.');
      ShowMessage(s_ErrorMessage);
    end;
  end;
end;

procedure TMainForm.SavePlist;
begin
  LogString.Add(DateTimeToStr(Now) +': SavePlist. Если мы на табе с деревеом, то конвертируем в stringlist параметры и их сохраняем');
  if PageControl.ActivePage = TabSheetTreeView then begin
    sl_PlistStrings.Clear;
    ConvertRecordToStringlist(a_PlistParametr, sl_PlistStrings);
    SynEdit.Lines.Clear;
    SynEdit.Lines.AddStrings(sl_PlistStrings);
  end;
  LogString.Add(DateTimeToStr(Now) +': SavePlist. Открываем SaveDialog');
  if SaveDialog.Execute then begin
    LogString.Add(DateTimeToStr(Now) +': SavePlist. Сохраняем из SynEdit все линии');
    SynEdit.Lines.SaveToFile(SaveDialog.filename);
  end;
end;

procedure TMainForm.MakeNewFile;
begin
  LogString.Add(DateTimeToStr(Now) +': MakeNewFile. Очищаем treeview и synedit');
  ClearEditView;

  LogString.Add(DateTimeToStr(Now) +': MakeNewFile. Проверяем что все мосивы пусты и если мосивы и TStringLists не пусты то очищаем все TSringlist и масивы.');
  ClearMassiveAndList;

  LogString.Add(DateTimeToStr(Now) +': MakeNewFile. Дисейблим кнопки Save в меню и на тулбаре');
  //SaveMenuItem.Enabled:= false;

  LogString.Add(DateTimeToStr(Now) +': MakeNewFile. В treeview добовляем корень plist');
  TreeView.Items.Add(nil,'plist');

  LogString.Add(DateTimeToStr(Now) + ': MakeNewFile. В synedit добавляем начальный шаблон плиста');
  SynEdit.Lines.Add(c_HEADER1);
  SynEdit.Lines.Add(c_HEADER2);
  SynEdit.Lines.Add(c_BEGINPLIST);
  SynEdit.Lines.Add('');
  SynEdit.Lines.Add('');
  SynEdit.Lines.Add(c_ENDPLIST);

  LogString.Add(DateTimeToStr(Now) + ': MakeNewFile. Если находимся в treeview ставим фокус на корне');
  if PageControl.ActivePage = TabSheetTreeView then begin
    TreeView.SetFocus;
  end else begin
    LogString.Add(DateTimeToStr(Now) + ': MakeNewFile. Если находися в synedit ставим фокус на 4 пустую строку');
    if PageControl.ActivePage = TabSheetSynEdit then begin
      SynEdit.SetFocus;
    end;
  end;
  LogString.Add(DateTimeToStr(Now) +': MakeNewFile. Устанавливаем переменную что добавляться будет первый параметр');
  b_FirstParametr := true;
end;

procedure TMainForm.OpenPlistMenuItemClick(Sender: TObject);
begin
  LogString.Add(DateTimeToStr(Now) +': Нажали кнопку Open Plist в меню');
  OpenPlist;
end;

procedure TMainForm.PageControlChange(Sender: TObject);
begin
  LogString.Add(DateTimeToStr(Now) +': PageControlChange. Вызов процедуру если меняем таб c TreeView на SynEdit или наоборот.');
  LogString.Add(DateTimeToStr(Now) +': PageControlChange. Вызываем очистку View.');
  ClearEditView;
  if PageControl.ActivePage = TabSheetTreeView then begin
    LogString.Add(DateTimeToStr(Now) +': PageControlChange. При переходе на TreeView вызываем процедуру обновления TreeView.');
    UpdateTreeView(a_PlistParametr);
  end else begin
    LogString.Add(DateTimeToStr(Now) +': PageControlChange. При переходе на Synedit проверяем, что sl_PlistString не пуст');
    if sl_PlistStrings.Count > 0 then begin
      LogString.Add(DateTimeToStr(Now) +': PageControlChange. Очищаем sl_PlistString так как он не пустой.');
      sl_PlistStrings.Clear;
    end;
    LogString.Add(DateTimeToStr(Now) +': PageControlChange. Проверяем что конвертация записи параметров в Stringlist прошла успешно.');
    if ConvertRecordToStringlist(a_PlistParametr, sl_PlistStrings) = 0 then begin
      LogString.Add(DateTimeToStr(Now) +': PageControlChange. Добовляем строки из sl_PlistStrings в SynEdit.');
      //SynEdit.Lines.Clear;
      SynEdit.Lines.AddStrings(sl_PlistStrings);
    end;
  end;
end;

procedure TMainForm.SaveMenuItemClick(Sender: TObject);
begin
  LogString.Add(DateTimeToStr(Now) +': Нажата кнопка Save Plist в меню. Вызываем процедуру сохранения plist');
  SavePlist;
end;

procedure TMainForm.MenuItemNewPlistClick(Sender: TObject);
begin
  LogString.Add(DateTimeToStr(Now) +': Нажата кнопка New Plist в меню. Вызываем процедуру создания нового plist.');
  MakeNewFile;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  // выделяем память для логирования
  LogString := TStringList.Create;
  LogString.Add('----> Запуск программы <----' + DateTimeToStr(Now));

  LogString.Add(DateTimeToStr(Now) + ': Определяем путь к програме');
  StartPath := ExtractFileDir(ParamStr(0));
  if StartPath[Length(StartPath)] <> '\' then begin
    StartPath := StartPath + '\';
  end;

  LogString.Add(DateTimeToStr(Now) + ': Проверка что приложение влезит на экран');
  if Screen.Height < MainForm.Height then begin
    MainForm.Height := Screen.Height;
  end else begin
    MainForm.Height := 700;
  end;
  if Screen.Width < MainForm.Width then begin
    MainForm.Width := Screen.Width;
  end else begin
    MainForm.Width := 1150;
  end;
  LogString.Add(DateTimeToStr(Now) + ': Выделение памяти для переменных p_PlistParam, sl_PlistStrings,a_PlistParametr.');
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
  LogString.Add(DateTimeToStr(Now) + ': AddIntKeyMenuItemClick. Нажатие на кнопку AddIntKey в меню.');
  //0. Проверяем на какой мы закладке
  if PageControl.ActivePage = TabSheetSynEdit then begin
     LogString.Add(DateTimeToStr(Now) + ' AddIntKeyMenuItemClick. Если мы на закладке synedit проверяем что фокус на edite иначе выходим');
     if Synedit.Focused then begin
       LogString.Add(DateTimeToStr(Now) + ' AddIntKeyMenuItemClick. Вызываем процедуру добавления числового параметра');
       Showmessage('Должна вызватся функция добавления но пока она не реализована :(');
     end else begin
       LogString.Add(DateTimeToStr(Now) +': AddIntKeyMenuItemClick. Показываем алерт что не выбрано место куда вставлять параметр.');
       ShowMessage('Выберете место куда вставлять новый параметр.');
       exit;
     end;
  end else begin
     if PageControl.ActivePage = TabSheetTreeView then begin
       LogString.Add(DateTimeToStr(Now) +': AddIntKeyMenuItemClick. Вызов процедуры AddParametrIntegerOrStringInTreeView()');
       AddParametrIntegerOrStringInTreeView(true);
     end else begin
       LogString.Add(DateTimeToStr(Now) +': AddIntKeyMenuItemClick. Показываем алерт что не выбрано место в TreeView куда вставлять параметр.');
       ShowMessage('Выберете место куда вставлять новый параметр.');
       exit;
     end;
  end;
end;

procedure TMainForm.AddKeyBoolMenuItemClick(Sender: TObject);
begin
  AddParametrBooleanInTreeView;
end;

procedure TMainForm.AddKeyDateMenuItemClick(Sender: TObject);
begin
  AddParametrDateInTreeView;
end;

procedure TMainForm.AddKeyDictMenuItemClick(Sender: TObject);
begin
  AddParametrDictInTreeView;
end;

procedure TMainForm.AddKeyStringMenuItemClick(Sender: TObject);
begin
   LogString.Add(DateTimeToStr(Now) +': AddKeyStringMenuItemClick. Нажатие на кнопку AddStringKey в меню.');
   //0. Проверяем на какой мы закладке
   if PageControl.ActivePage = TabSheetSynEdit then begin
     LogString.Add(DateTimeToStr(Now) +': AddKeyStringMenuItemClick. Если мы на закладке synedit проверяем что фокус на edite иначе выходим.');
     if Synedit.Focused then begin
        LogString.Add(DateTimeToStr(Now) +': AddKeyStringMenuItemClick. Вызываем процедуру добавления числового параметра');
        Showmessage('Должна вызватся функция добавления но пока она не реализована :(');
      end else begin
        LogString.Add(DateTimeToStr(Now) +': AddKeyStringMenuItemClick. Показываем алерт что не выбрано место куда вставлять параметр.');
        ShowMessage('Выберете место куда вставлять новый параметр.');
        exit;
      end;
   end else begin
      if PageControl.ActivePage = TabSheetTreeView then begin
        LogString.Add(DateTimeToStr(Now) +': AddKeyStringMenuItemClick. Вызываем процедуру добавления строкового параметра в дерево.');
        AddParametrIntegerOrStringInTreeView(false);
      end else begin
        LogString.Add(DateTimeToStr(Now) +': AddKeyStringMenuItemClick. Показываем алерт что не выбрано место куда вставлять параметр.');
        ShowMessage('Выберете место куда вставлять новый параметр.');
        exit;
      end;
   end;
end;

procedure TMainForm.CloseMenuItemClick(Sender: TObject);
begin
  LogString.Add(DateTimeToStr(Now) +': Вызов процедуры закрытия приложения.');
  MainForm.Close;
end;

procedure TMainForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
 if Application.MessageBox('Вы уверены что хотите выйти?',
                           'Внимание!', MB_YESNO) = id_Yes then begin
    if sl_PlistStrings <> Nil then begin
      sl_PlistStrings.Free;
    end;
   if LogString <> Nil then begin
    LogString.Add(DateTimeToStr(Now) +': Закрытие Программы.');
    LogString.SaveToFile(StartPath + 'SmartPlistEditor.log');
    LogString.Free;
   end;
     CloseAction := caFree;
   end else begin
     CloseAction := caNone;
   end;
end;

end.

