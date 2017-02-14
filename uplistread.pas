unit uPlistRead;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

const c_HEADER1 = '<?xml version="1.0" encoding="UTF-8"?>';
      c_HEADER2 = '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">';
      c_BEGINPLIST = '<plist version="1.0">';
      c_ENDPLIST = '</plist>';
      c_BEGINDICT = '<dict>';
      c_ENDDICT = '</dict>';
      c_BIGINKEY = '<key>';
      c_ENDKEY = '</key>';
      c_BEGINARRAY = '<array>';
      c_ENDARRAY = '</array>';
      c_BEGINSTRING = '<string>';
      c_ENDSTRING = '</string>';
      c_BEGININTEGER = '<integer>';
      c_ENDINTEGER = '</integer>';
      c_BEGINDATE = '<date>';
      c_ENDDATE = '</date>';
      c_BEGINDATA = '<data>';
      c_ENDDATA = '</data>';
      c_BEGINREAL = '<real>';
      c_ENDREAL = '</real>';

type
    tParam  = (dict, bool, date , int, str, aray, data, key);
    PlistParametr = record
       Name: string;
       type_parm: tParam;
       level: integer;
       position: integer;
       value: variant;
    end;

// конвертация record в stringlist для синхронизации дерева с synmemo
function ConvertRecordToStringlist(a_PlistParametr: array of PlistParametr; out plist:TStringList):integer;
// проверка plist на валидность
function CheckPlist(plist:TStringList; out s_Problem: string):integer;
// групирование параметпров для дальнейшего постраения дерева
function GroupPlistParametrs(plist:TStringList; out a_PlistParametr: array of PlistParametr): integer;
// функция обновления TreeView
//procedure UpdateTreeView(a_PlistParametr: array of PlistParametr;out TreeView:TTreeView);

implementation

function ConvertRecordToStringlist(a_PlistParametr: array of PlistParametr; out plist:TStringList):integer;
var i : integer;
    param: string;
begin
    result := 0;
    // добавления загаловка и начала plist'a
    plist.Add(c_HEADER1);
    plist.Add(c_HEADER2);
    plist.Add(c_BEGINPLIST);

    // цикл преобразования record'ов в строки
    for i := 0 to (length(a_PlistParametr)-1) do begin
      param := '';
      if (a_PlistParametr[i].type_parm = dict) or
         (a_PlistParametr[i].type_parm = aray) then begin
        if  a_PlistParametr[i].value <> '' then param := '<' +  a_PlistParametr[i].value + '>'
        else  param :=  c_BIGINKEY +  a_PlistParametr[i].Name + c_ENDKEY;
      end;
      if a_PlistParametr[i].type_parm = bool then begin
         param :=  c_BIGINKEY +  a_PlistParametr[i].Name + c_ENDKEY;
         plist.Add(param);
         param := '<' +  a_PlistParametr[i].value + '/>';
      end;
      if a_PlistParametr[i].type_parm = date then begin
         param :=  c_BIGINKEY +  a_PlistParametr[i].Name + c_ENDKEY;
         plist.Add(param);
         param := c_BEGINDATE +  a_PlistParametr[i].value + c_ENDDATE;
      end;
      if a_PlistParametr[i].type_parm = int then begin
         param :=  c_BIGINKEY +  a_PlistParametr[i].Name + c_ENDKEY;
         plist.Add(param);
         param := c_BEGININTEGER +  a_PlistParametr[i].value + c_ENDINTEGER;
      end;
      if a_PlistParametr[i].type_parm = str then begin
         param :=  c_BIGINKEY +  a_PlistParametr[i].Name + c_ENDKEY;
         plist.Add(param);
         param := c_BEGINSTRING +  a_PlistParametr[i].value + c_ENDSTRING;
      end;
      if a_PlistParametr[i].type_parm = data then begin
         param :=  c_BIGINKEY +  a_PlistParametr[i].Name + c_ENDKEY;
         plist.Add(param);
         param := c_BEGINDATA +  a_PlistParametr[i].value + c_ENDDATA;
      end;
      if param <> '' then plist.Add(param);
    end;

    //добовление завершения plist'a
    plist.Add(c_ENDPLIST);
end;

function CheckPlist(plist: TStringList; out s_Problem: string): integer;
var i,j, p,
  dict_beg, dict_end,
  key_beg, key_end,
  array_beg, array_end,
  string_beg, string_end,
  int_beg, int_end,
  date_beg, date_end: integer;
begin
  result:=0;
  s_Problem := '';
  dict_beg:=0; dict_end:=0;
  key_beg:=0; key_end:=0;
  array_beg:=0; array_end:=0;
  string_beg:=0; string_end:=0;
  int_beg:=0; int_end:=0;
  date_beg:=0; date_end := 0;
  p := Pos(c_HEADER1, plist.Strings[i]);
  //Проверить что первая строка <?xml version="1.0" encoding="UTF-8" ?>
  if p <> 0 then begin
     result := -1;
  end else begin
       //Проверить что вторая строка <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
       if plist.IndexOf(c_HEADER2) <> 1 then begin
          result := -2;
       end else begin
         //Проверка что третья строка <plist version="1.0"> и последняя </plist>
         if plist.IndexOf(c_BEGINPLIST) <> 2 then result := -3;
         if plist.IndexOf(c_ENDPLIST) <> (plist.Count-1) then result := -4;
       end;
   end;
  //Если один из верхних пунктов неверный то завершаем проверку и выводим в чем ошибка
  if result < 0 then begin
      if result = -1 then s_Problem := 'Не правильный заголовок plist файла должен быть: ' + c_HEADER1 + ' а не: ' + plist.Strings[0] + '.';
      if result = -2 then s_Problem := 'Не правильный заголовок plist файла должен быть: ' + c_HEADER1 + ' а не: ' + plist.Strings[1] + '.';
      if result = -3 then s_Problem := 'Не правильное начало plist параметров должено быть: ' + c_BEGINPLIST + ' а не: ' + plist.Strings[2] + '.';
      if result = -4 then begin
         s_Problem := '';
         for i:= 4 to (plist.Count-1) do begin
          if  Pos(c_ENDPLIST, plist.Strings[i]) <> 0 then  s_Problem := 'Завершение plist надено в строке: ' + plist.Strings[i] + '. Номер строки:' + IntToStr(i-1)+ '.';
         end;
         if s_Problem = '' then s_Problem := 'Завершение plist не найдено. Plist файл должен завершаться тегом: ' + c_ENDPLIST + '.';
      end;
  end else begin
    //Проверить что все <dict> заканчиваются </dict>
    //Проверить что все <key> заканчиваются </key>
    //Проверить что все <array> заканчиваются </array>
    //Проверить что все <string> заканчиваются </string>
    //Проверить что все <integer> заканчиваются </integer>
    //Проверить что все <date> заканчиваются </date>
     for i:=0 to (plist.Count-1) do begin
       if  Pos(c_BEGINDICT, plist.Strings[i]) <> 0 then dict_beg := dict_beg + 1;
       if  Pos(c_ENDDICT, plist.Strings[i]) <> 0 then dict_end:= dict_end + 1;
       if  Pos(c_BIGINKEY, plist.Strings[i]) <> 0 then key_beg := key_beg + 1;
       if  Pos(c_ENDKEY, plist.Strings[i]) <> 0 then key_end := key_end + 1;
       if  Pos(c_BEGINARRAY, plist.Strings[i]) <> 0 then array_beg := array_beg + 1;
       if  Pos(c_ENDARRAY, plist.Strings[i]) <> 0 then array_end := array_end + 1;
       if  Pos(c_BEGINSTRING, plist.Strings[i]) <> 0 then string_beg := string_beg + 1;
       if  Pos(c_ENDSTRING, plist.Strings[i]) <> 0 then string_end := string_end + 1;
       if  Pos(c_BEGININTEGER, plist.Strings[i]) <> 0 then int_beg := int_beg + 1;
       if  Pos(c_ENDINTEGER, plist.Strings[i]) <> 0 then int_end:= int_end + 1;
       if  Pos(c_BEGINDATE, plist.Strings[i]) <> 0 then date_beg := date_beg + 1;
       if  Pos(c_ENDDATE, plist.Strings[i]) <> 0 then date_end := date_end + 1;
    end;

    //Если не прошли проверку из п.5 - п.10 то  ищем какая из строк плохая и выводим ошибку
    if dict_beg <> dict_end then s_Problem := 'Несовподения тегов dict, начальных тегов: ' + IntToStr(dict_beg) + ' <> завершающих тегов: ' + IntToStr(dict_end);
    if key_beg <> key_end then begin
      s_Problem := 'Несовподения тегов key, начальных тегов: ' + IntToStr(key_beg) + ' <> завершающих тегов: ' + IntToStr(key_end);
      For i:=0 to (plist.Count-1) do begin
         if Pos('<key>', plist.Strings[i]) <> 0 then begin
            if Pos('</key>', plist.Strings[i]) = 0 then begin
               s_Problem := 'Строка с поблемой: ' + IntToStr(i+1) + ' ' +  plist.Strings[i];
            end;

         end;
      end;
    end;

    if array_beg <> array_end then s_Problem := 'Несовподения тегов array, начальных тегов: ' + IntToStr(array_beg) + ' <> завершающих тегов: ' + IntToStr(array_end);
    if string_beg <> string_end then s_Problem :='Несовподения тегов string, начальных тегов: ' + IntToStr(string_beg) + ' <> завершающих тегов: ' + IntToStr(string_end);
    if int_beg <> int_end then s_Problem := 'Несовподения тегов integer, начальных тегов: ' + IntToStr(int_beg) + ' <> ' + IntToStr(int_end);
    if date_beg <> date_end then s_Problem := 'Несовподения date ' + IntToStr(date_beg) + ' <> завершающих тегов: ' + IntToStr(date_end);

  //Разбиваем параметры на группы (если несколько новостей то делим их на части в каждой отдельная новость)

  //Проверить что нет дубликатов значений(параметров) в <key> (в новостях может быть дублирование в зависимости сколько новостей)



  end;

end;

function GroupPlistParametrs(plist:TStringList; out a_PlistParametr: array of PlistParametr): integer;
var i, numarray, begpos, endpos, lev, newpos: integer;
    s : string;
    m_PlistParametr: array of PlistParametr;
begin
     result:=0;
     numarray := plist.Count-4;
     setLength(m_PlistParametr, numarray);
     numarray := 0;
     newpos:= 3;
     lev := 1;
     i := 3;
     while i <=  (plist.Count-1) do begin
         if Pos(c_BEGINDICT, plist.strings[i])<> 0  then begin
           lev := lev +1;
           if  (Pos(c_BIGINKEY, plist.Strings[i-1]) <> 0) or
               (Pos(c_BIGINKEY, plist.Strings[i-2]) <> 0) then begin
               with  m_PlistParametr[numarray] do begin
                  Name := 'dictkey';
                  type_parm:= dict;
                  level := lev;
                  position:= newpos;
                  value:= 'dict';
               end;
               m_PlistParametr[numarray-1].type_parm:=dict;
               numarray := numarray + 1;
               newpos:= newpos + 1;
           end else begin
               with  m_PlistParametr[numarray] do begin
                     Name := 'dict';
                     type_parm:= dict;
                     level := lev;
                     position:= newpos;
                     value:= 'dict';
               end;
               numarray := numarray + 1;
               newpos:= newpos + 1;
           end;
         end;
         if Pos(c_ENDDICT, plist.strings[i])<> 0  then begin
            lev := lev - 1;
            with  m_PlistParametr[numarray] do begin
                   Name := 'end dict';
                   type_parm:= dict;
                   level := lev;
                   position:= newpos;
                   value:= '/dict';
            end;
            numarray := numarray + 1;
            newpos:= newpos + 1;
         end;
         if Pos(c_BEGINARRAY, plist.strings[i])<> 0  then begin
           lev := lev +1;
           if  (Pos(c_BIGINKEY, plist.Strings[i-1]) <> 0) or
               (Pos(c_BIGINKEY, plist.Strings[i-2]) <> 0) then begin
               with  m_PlistParametr[numarray] do begin
                  Name := 'arraykey';
                   type_parm:= aray;
                   level := lev;
                   position:= newpos;
                   value:= 'array';
               end;
               m_PlistParametr[numarray-1].type_parm:=aray;
               numarray := numarray + 1;
               newpos:= newpos + 1;
           end else begin
               with  m_PlistParametr[numarray] do begin
                  Name := 'array';
                   type_parm:= aray;
                   level := lev;
                   position:= newpos;
                   value:= 'array';
               end;
               numarray := numarray + 1;
               newpos:= newpos + 1;
           end;
         end;
         if Pos(c_ENDARRAY, plist.strings[i])<> 0  then begin
            lev := lev - 1;
            with m_PlistParametr[numarray] do begin
                 Name := 'end array';
                 type_parm:= aray;
                 level := lev;
                 position:= newpos;
                 value:= '/array';
             end;
             numarray := numarray + 1;
             newpos:= newpos + 1;
         end;
         if Pos(c_BEGININTEGER, plist.Strings[i]) <> 0 then begin
            begpos :=  Pos(c_BEGININTEGER, plist.Strings[i]);
            endpos :=  Pos('</', plist.Strings[i]);
            s := copy(plist.Strings[i], begpos+9, endpos-(begpos+9));
            with  m_PlistParametr[numarray] do begin
                  Name := s;
                  type_parm:= int;
                  level := lev;
                  position:= newpos;
                  value:= '';
            end;
            numarray := numarray + 1;
            newpos:= newpos + 1;
         end;
         if Pos(c_BEGINSTRING, plist.Strings[i]) <> 0 then begin
            begpos :=  Pos(c_BEGINSTRING, plist.Strings[i]);
            endpos :=  Pos('</', plist.Strings[i]);
            s := copy(plist.Strings[i], begpos+8, endpos-(begpos+8));
            with  m_PlistParametr[numarray] do begin
                  Name := s;
                  type_parm:= str;
                  level := lev;
                  position:= newpos;
                  value:= '';
            end;
            numarray := numarray + 1;
            newpos:= newpos + 1;
         end;
          if Pos(c_BEGINDATE, plist.Strings[i]) <> 0 then begin
            begpos :=  Pos(c_BEGINDATE, plist.Strings[i]);
            endpos :=  Pos('</', plist.Strings[i]);
            s := copy(plist.Strings[i], begpos+6, endpos-(begpos+6));
            with  m_PlistParametr[numarray] do begin
                  Name := s;
                  type_parm:= date;
                  level := lev;
                  position:= newpos;
                  value:= '';
            end;
            numarray := numarray + 1;
            newpos:= newpos + 1;
         end;
         if Pos(c_BEGINDATA, plist.Strings[i]) <> 0 then begin
            begpos :=  Pos(c_BEGINDATA, plist.Strings[i]);
            endpos :=  Pos('</', plist.Strings[i]);
            s := copy(plist.Strings[i], begpos+6, endpos-(begpos+6));
            with  m_PlistParametr[numarray] do begin
                  Name := s;
                  type_parm:= data;
                  level := lev;
                  position:= newpos;
                  value:= '';
            end;
            numarray := numarray + 1;
            newpos:= newpos + 1;
         end;
         if Pos(c_BIGINKEY, plist.Strings[i]) <> 0 then begin
            begpos :=  Pos(c_BIGINKEY, plist.Strings[i]);
            endpos :=  Pos('</', plist.Strings[i]);
            s := copy(plist.Strings[i], begpos+5, endpos-(begpos+5));
            with   m_PlistParametr[numarray] do begin
                  Name := s;
                  position := newpos;
                  level := lev;
                  type_parm:=key;
                  value:='';
            end;
            if (Pos('<true/>', plist.Strings[i+1]) <> 0) or
                (Pos('<true />',  plist.Strings[i+1]) <> 0) then begin
                m_PlistParametr[numarray].type_parm:=bool;
                m_PlistParametr[numarray].value:='true';
                newpos:= newpos + 1;
                i := i + 1;
            end;
            if (Pos('<false/>', plist.Strings[i+1]) <> 0) or
               (Pos('<false />',  plist.Strings[i+1]) <> 0) then begin
               m_PlistParametr[numarray].type_parm:=bool;
               m_PlistParametr[numarray].value:='false';
               newpos:= newpos + 1;
               i := i + 1;
            end;
            if Pos(c_BEGININTEGER, plist.Strings[i+1]) <> 0 then begin
              begpos :=  Pos(c_BEGININTEGER, plist.Strings[i+1]);
              endpos :=  Pos('</', plist.Strings[i+1]);
              s := copy(plist.Strings[i+1], begpos+9, endpos-(begpos+9));
              m_PlistParametr[numarray].type_parm:=int;
              m_PlistParametr[numarray].value:=s;
              newpos:= newpos + 1;
              i := i + 1;
            end;
            if Pos(c_BEGINSTRING, plist.Strings[i+1]) <> 0 then begin
              begpos :=  Pos(c_BEGINSTRING, plist.Strings[i+1]);
              endpos :=  Pos('</', plist.Strings[i+1]);
              s := copy(plist.Strings[i+1], begpos+8, endpos-(begpos+8));
              m_PlistParametr[numarray].type_parm:=str;
              m_PlistParametr[numarray].value:=s;
              newpos:= newpos + 1;
              i := i + 1;
            end;
            if Pos(c_BEGINDATE, plist.Strings[i+1]) <> 0 then begin
              begpos :=  Pos(c_BEGINDATE, plist.Strings[i+1]);
              endpos :=  Pos('</', plist.Strings[i+1]);
              s := copy(plist.Strings[i+1], begpos+6, endpos-(begpos+6));
              m_PlistParametr[numarray].type_parm:=date;
              m_PlistParametr[numarray].value:=s;
              newpos:= newpos + 1;
              i := i + 1;
            end;
            if Pos(c_BEGINDATA, plist.Strings[i+1]) <> 0 then begin
              begpos :=  Pos(c_BEGINDATA, plist.Strings[i+1]);
              endpos :=  Pos('</', plist.Strings[i+1]);
              s := copy(plist.Strings[i+1], begpos+6, endpos-(begpos+6));
              m_PlistParametr[numarray].type_parm:=data;
              m_PlistParametr[numarray].value:=s;
              newpos:= newpos + 1;
              i := i + 1;
            end;
            numarray := numarray + 1;
         end;
         i := i + 1;
     end;
    { setLength(a_PlistParametr, numarray);
     setLength(m_PlistParametr, numarray);     }
     for i := 0 to numarray do begin
        a_PlistParametr[i] := m_PlistParametr[i];
     end;
     result := numarray;
     //a_PlistParametr := m_PlistParametr;//Copy(m_PlistParametr, 0, numarray);
end;

{procedure UpdateTreeView(a_PlistParametr: array of PlistParametr;out TreeView:TTreeView);
var i: integer;
    Node, childNode, tempNode: TTreeNode;
    p_PlistParam: ^PlistParametr;
begin
    //TreeView.Items.Clear;
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
end;        }

end.

