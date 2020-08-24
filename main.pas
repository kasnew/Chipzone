unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, sqldb, db, mssqlconn, sqlite3conn, FileUtil,
  DateTimePicker, LR_DBSet, LR_Class, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Menus, DBGrids, MaskEdit, Zakaz, Sklad, zlibar, Grids, Buttons,
  ExtCtrls, ComCtrls, Types, MouseAndKeyInput, Ipfilebroker, IniFiles, settings;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TBitBtn;
    Button2: TBitBtn;
    Button3: TBitBtn;
    Button4: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TToggleBox;
    CheckBox3: TCheckBox;
    CheckBox5: TCheckBox;
    DataSource1: TDataSource;
    DateTimePicker1: TDateTimePicker;
    DateTimePicker2: TDateTimePicker;
    DateTimePicker3: TDateTimePicker;
    DateTimePicker4: TDateTimePicker;
    DateTimePicker5: TDateTimePicker;
    DateTimePicker6: TDateTimePicker;
    DBGrid1: TDBGrid;
    Edit1: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    frDBDataSet1: TfrDBDataSet;
    frReport1: TfrReport;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox6: TGroupBox;
    ImageList1: TImageList;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label27: TLabel;
    Label28: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    MenuItem21: TMenuItem;
    MenuItem23: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioGroup1: TRadioGroup;
    SQLite3Connection1: TSQLite3Connection;
    SQLQuery1: TSQLQuery;
    SQLQuery2: TSQLQuery;
    SQLTransaction1: TSQLTransaction;
    Timer1: TTimer;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure DBGrid1CellClick();
    procedure DBGrid1DblClick(Sender: TObject);
    procedure DBGrid1KeyDown(Sender: TObject; var Key: Word);
    procedure DBGrid1MouseDown(Sender: TObject; Button: TMouseButton);
    procedure DBGrid1PrepareCanvas(sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: char);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure MenuItem10Click(Sender: TObject);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem15Click(Sender: TObject);
    procedure MenuItem17Click(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private

  public
    ID_remont,rec_pos,numberreport,predohranitel:integer;
    os,basename:string;

  end;

var
  MaxRect: TRect;
  Form1: TForm1;
  ID_edit,last_NUM, NewTop, NewHeight,koef_heith:integer;
  new_record,autoupdate,trigger_form:boolean;
  IniF:TINIFile;
  path_program,path_backups:string;
  procedure finstat;
  procedure find;
  procedure size_columns;
  procedure rem_connect;
  procedure save_reserv;


implementation
 uses newwork;
{$R *.lfm}

{ TForm1 }

//архивирование базы данных
procedure save_reserv;
var
  Time:Tdatetime;
  Zar: TZlibWriteArchive;
  Stream: TMemoryStream;
  s:string;
begin
  Stream := TMemoryStream.Create;
  Zar := TZlibWriteArchive.Create;
  Zar.OutStream := Stream;
  Time:=now();
  Zar.InputFiles.Add(form1.basename);
  Zar.CreateArchive;

  if form1.os='windows' then s:=ExtractFilePath(ParamStr(0))+'\backup_database'
  else s:=ExtractFilePath(ParamStr(0))+'/backup_database';

  if ForceDirectories(s)=false then CreateDir(s);

  if form1.os='windows' then s:=s+'\' else s:=s+'/';

  Stream.SaveToFile(s+FormatDatetime('yy.MM.dd.hh.mm.ss',Time)+'.backup');

  Zar.Free;
  Stream.Free;
end;
//размер колонок таблицы
procedure size_columns;
begin
      with form1.DBGrid1 do
      begin
          Width:=form1.Width;
          Columns[0].Width:=0;//ID
          Columns[1].Width:=0;//Стоимость - чистая работа
          Columns[2].Width:=0;//Описание неисправности
          Columns[3].Width:=0;//Выполненая работа
          Columns[4].Width:=70;//Квитанция
          Columns[5].Width:=form1.Width-765;//Наименование техники
          Columns[6].Width:=165;//Имя
          Columns[7].Width:=90;//Телефон
          //Columns[7].DisplayFormat:='###,###, ##, ##000-000-00-00';
          Columns[8].Width:=110;//Начало ремонта
          Columns[9].Width:=100;//Конец ремонта
          Columns[10].Width:=50;//Сумма
          Columns[11].Width:=0;//Оплачено
          Columns[12].Width:=160;//Примечание
          Columns[13].Width:=0;//Перезвонить
          Columns[14].Width:=0;//Доход
      end;
end;
//подключение к базе данных
procedure rem_connect;
begin
      form1.SQLQuery1.Active:=false;
      form1.SQLite3Connection1.Connected:=false;
      form1.SQLite3Connection1.Connected:=true;
      form1.SQLQuery1.Sql.Clear;
      form1.SQLQuery1.SQL.add('select ID,  Стоимость, Описание_неисправности, Выполнено, Квитанция, Наименование_техники, Имя_заказчика, Телефон, Начало_ремонта, Конец_ремонта, Сумма, Оплачено, Примечание, Перезвонить,Доход from Ремонт ORDER BY Начало_ремонта DESC, Квитанция DESC');

      form1.SQLQuery1.Active:=true;
      size_columns;
      form1.SQLQuery1.First;
      last_NUM:=form1.SQLQuery1.FieldByName('Квитанция').AsInteger;
      form1.GroupBox1.Caption:='Список техники ['+inttostr(form1.SQLQuery1.RecordCount)+']';
end;
//вывод фин статистика за выбранный период
procedure finstat;
var Year, Month, Day: Word;
begin
    if form1.CheckBox5.Checked=true then
    begin
        // подсчет финансовой статистики по дате с расходниками и чистой работы, и додхода с расходников
        form1.sqlQuery2.Active:=false;
        form1.sqlQuery2.SQL.Clear;
        form1.sqlQuery2.SQL.Add('Select sum(Стоимость), sum(Сумма), sum(Доход)  from Ремонт where Оплачено=:sost');
        form1.sqlQuery2.ParamByName('sost').Value:=true;

        if form1.RadioButton4.Checked=true then //сегодня
        begin
             form1.SQLQuery2.SQL.Add(' and Конец_ремонта=:date');
             form1.sqlQuery2.ParamByName('date').AsDate:=Date;
        end else
        if form1.RadioButton5.Checked=true then //текущий месяц
        begin
              DecodeDate(Now, Year, Month, Day);
              form1.SQLQuery2.SQL.Add(' and (Конец_ремонта>=:date1 and Конец_ремонта<=:date2)');
              form1.sqlQuery2.ParamByName('date1').AsDate:=EncodeDate(Year, Month, 1);
              form1.sqlQuery2.ParamByName('date2').AsDate:=date;
        end else
        if form1.RadioButton6.Checked=true then //выбранный период
        begin
              form1.SQLQuery2.SQL.Add(' and (Конец_ремонта>=:date1 and Конец_ремонта<=:date2)');
              form1.sqlQuery2.ParamByName('date1').AsDate:=form1.DateTimePicker5.Date;
              form1.sqlQuery2.ParamByName('date2').AsDate:=form1.DateTimePicker6.Date;
        end;

        form1.sqlQuery2.Active:=true;
        //вывод фин статистики
        if form1.sqlQuery2.Fields[0].Value<>null then form1.Edit10.Text:=floattostr(form1.sqlQuery2.Fields[0].Value)
        else form1.edit10.Text:='0';

        if form1.sqlQuery2.Fields[1].Value<>null then form1.Edit11.Text:=floattostr(form1.sqlQuery2.Fields[1].Value)
        else form1.edit11.Text:='0';

        if form1.sqlQuery2.Fields[2].Value<>null then form1.Edit12.Text:=FloatToStr(trunc(form1.sqlQuery2.Fields[2].AsFloat*100)/100)
        else form1.edit12.Text:='0';
    end
    else
    begin
          form1.Edit10.Text:='0';
          form1.Edit11.Text:='0';
          form1.edit12.Text:='0';
    end;
    form1.Edit13.Text:=FloatToStrf(strtofloat(form1.edit10.text)+strtofloat(form1.edit12.text),ffFixed,8,2);
end;
//включение фильтров поиска
procedure find;
begin
     if form1.CheckBox2.Checked=true then
     begin

         //обманка - по сути вывод полного списка, к которому будем добавлять фильтры
           form1.SQLQuery1.Active:=false;
           form1.SQLQuery1.SQL.Clear;
           form1.SQLQuery1.SQL.add('select ID,  Стоимость, Описание_неисправности, Выполнено, Квитанция, Наименование_техники, Имя_заказчика, Телефон, Начало_ремонта, Конец_ремонта, Сумма, Оплачено, Примечание, Перезвонить, Доход from Ремонт where ID>=0');

           //фильтр "возвраты", если включен, то остальные не нужны
           if form1.CheckBox1.checked=true then form1.SQLQuery1.SQL.add(' and Сумма<0') else
           //фильтр "перезвонить", если включен, то остальные фильтры не нужны
           if form1.checkbox3.Checked=true then
                begin
                     form1.SQLQuery1.SQL.add(' and Перезвонить=:sost3');
                     form1.SQLQuery1.Params.ParamByName('sost3').Value:=true;
                end
                     else
                begin
                     //----------------------------------------------------------------
                     //определение состояния оплаты
                     //если нужны только оплаченные, то дополнительные фильтры
                     if form1.RadioButton2.Checked=True then
                     begin
                          form1.SQLQuery1.SQL.add(' AND Оплачено=:sost');
                          form1.SQLQuery1.ParamByName('sost').AsBoolean:=true;
                          form1.SQLQuery1.SQL.Add(' and (Конец_ремонта>=:date3 and Конец_ремонта<=:date4)');
                          form1.SQLQuery1.ParamByName('date3').AsDate:=form1.DateTimePicker3.Date;
                          form1.SQLQuery1.ParamByName('date4').AsDate:=form1.DateTimePicker4.Date;
                     end
                     else
                     if form1.RadioButton3.Checked=True then
                     begin
                          //если нужны не оплаченные то по дате поступления
                          form1.SQLQuery1.SQL.add(' AND Оплачено=:sost');
                          form1.SQLQuery1.ParamByName('sost').AsBoolean:=false;
                          form1.SQLQuery1.SQL.Add(' and (Начало_ремонта>=:date1 and Начало_ремонта<=:date2)');
                          form1.SQLQuery1.ParamByName('date1').AsDate:=form1.DateTimePicker1.Date;
                          form1.SQLQuery1.ParamByName('date2').AsDate:=form1.DateTimePicker2.Date;
                     end;
                     //---------------------------------------------------------------
                     if form1.Edit2.Text<>'' then form1.SQLQuery1.SQL.add(' and Имя_заказчика LIKE'''+'%'+form1.edit2.text+'%'+'''');
                     if form1.Edit1.Text<>'' then form1.SQLQuery1.SQL.add(' and Квитанция='+form1.edit1.text);
                     if form1.Edit3.Text<>'' then form1.SQLQuery1.SQL.add(' and Телефон LIKE'''+'%'+form1.edit3.text+'%'+'''');
                     if form1.Edit4.Text<>'' then form1.SQLQuery1.SQL.add(' and Наименование_техники LIKE'''+'%'+form1.edit4.text+'%'+'''');
                     if form1.Edit5.Text<>'' then form1.SQLQuery1.SQL.add(' and Сумма='+form1.edit5.text);
                     if form1.Edit6.Text<>'' then form1.SQLQuery1.SQL.add(' and Примечание LIKE'''+'%'+form1.edit6.text+'%'+'''');
                end;
           form1.SQLQuery1.SQL.add(' ORDER BY Начало_ремонта DESC, Квитанция DESC');

           form1.SQLQuery1.Active:=true;

           size_columns;
           form1.GroupBox1.Caption:='Список техники ['+inttostr(form1.SQLQuery1.RecordCount)+']';
     end
end;

//кнопка "выход"
procedure TForm1.Button3Click(Sender: TObject);
begin
     form1.Close;
end;
//добавление квитанции
procedure TForm1.Button1Click(Sender: TObject);
begin
     SQLQuery1.First;
     form4.edit1.Text:=inttostr(last_NUM+1);
     Form4.ShowModal;
end;
//удаление квитанции
procedure TForm1.Button2Click(Sender: TObject);
begin
     if MessageDlg('Удаление квитанции', 'Удалить запись?', mtConfirmation, [mbYes, mbNo],0) = mrYes then
     begin
            SQLQuery2.Active:=false;
            SQLQuery2.SQL.Clear;
            SQLQuery2.SQL.Add('Update Расходники set №_квитанции=0, Наличие=:sost, Квитанция=0 where Квитанция=:delete');
            SQLQuery2.ParamByName('delete').AsInteger:=ID_remont;
            SQLQuery2.ParamByName('sost').AsBoolean:=true;
            SQLQuery2.ExecSQL;

            SQLQuery1.Delete;//удаление выделенной записи из базы "Услуги"
            sqlquery1.ApplyUpdates;// отправляем изменения в базу
            SQLTransaction1.Commit;//без этого не работает

            rem_connect;
            finstat;//пересчет финансовой статистики
      end;
end;

//очистка фильтров поиска
procedure TForm1.Button4Click(Sender: TObject);
begin
     if CheckBox2.Checked=true then
     begin
          CheckBox2.Checked:=false;
          rem_connect;
     end;
     CheckBox1.Checked:=false;
     checkbox3.Checked:=false;
     edit1.Text:='';edit2.Text:='';edit3.Text:='';edit4.Text:='';edit5.Text:='';edit6.Text:='';
     RadioButton1.Checked:=true;
     DateTimePicker1.Date:=strtodate('01.01.2017');
     DateTimePicker2.Date:=date;
     DateTimePicker3.Date:=strtodate('01.01.2017');
     DateTimePicker4.Date:=date;
end;

//включение фильтра поиска
procedure TForm1.CheckBox2Click(Sender: TObject);
begin
     if form1.CheckBox2.Checked=true then
     begin
          find;
          GroupBox2.Color:=clGray;
          CheckBox2.Color:=clRed;
     end
     else
     begin
          rem_connect;
          GroupBox2.Color:=clSkyBlue;
          CheckBox2.Color:=clDefault;
     end;
end;

//включение статистики
procedure TForm1.CheckBox5Click(Sender: TObject);
begin
     finstat;
end;
//получиние ID выбранной записи
procedure TForm1.DBGrid1CellClick();
var phone_str:string;
begin
     if SQLQuery1.RecordCount<>0 then
     ID_remont:=SQLQuery1.FieldValues['ID'];
     rec_pos:=SQLQuery1.RecNo;
     //показ номера телефона через дефис
     phone_str:=SQLQuery1.FieldByName('Телефон').Asstring;
     phone_str:=copy(phone_str,0,3)+'-'+copy(phone_str,4,3)+'-'+copy(phone_str,7,2)+'-'+copy(phone_str,9,2);
     DBGrid1.Hint:=phone_str;
end;

//открытие квитанции
procedure TForm1.DBGrid1DblClick(Sender: TObject);
begin
     Form2.ShowModal;
end;

//удаление квитанции кнопкой "Delete"
procedure TForm1.DBGrid1KeyDown(Sender: TObject; var Key: Word);
begin
      if key = 46 then Button2.Click;
end;
//выделение правым кликом
procedure TForm1.DBGrid1MouseDown(Sender: TObject; Button: TMouseButton);
begin
  if Button = mbRight then MouseInput.Click(mbLeft,[],Mouse.CursorPos.X,Mouse.CursorPos.Y);
end;

//закраска таблицы
procedure TForm1.DBGrid1PrepareCanvas(sender: TObject);
begin
      //Полосатая заливка
      if odd(TDBGrid(Sender).DataSource.Dataset.RecNo) then TDBGrid(Sender).Canvas.Brush.Color :=RGBToColor(161,161,161);
      //красим оплаченные
      IF TDBGrid(Sender).DataSource.DataSet.FieldByName('Оплачено').AsBoolean = true then TDBGrid(Sender).Canvas.Brush.Color:=RGBToColor(46,139,87);
      //Красим "Позвонить"
      IF TDBGrid(Sender).DataSource.DataSet.FieldByName('Перезвонить').AsBoolean = true then TDBGrid(Sender).Canvas.Brush.Color:=RGBToColor(255,69,0);
      //Красим "Возвраты"
      IF TDBGrid(Sender).DataSource.DataSet.FieldByName('Сумма').AsFloat <0 then TDBGrid(Sender).Canvas.Brush.Color:=RGBToColor(116,137,202);
end;
//Отключение фильтров при их редактировании
procedure TForm1.Edit1Change(Sender: TObject);
begin
  if CheckBox2.Checked=true then
      begin
          CheckBox2.Checked:=false;
          rem_connect;
      end;
end;

//активация поиска по Enter
procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: char);
begin
     if Key=#13 then begin checkbox2.Checked:=true; CheckBox2Click(Self);end;
end;

//создание формы
procedure TForm1.FormCreate(Sender: TObject);
var oldOS:string;
begin
     //проверка версии ОС
     {$ifdef linux}os:='linux';{$endif}
     {$ifdef windows}os:='windows';{$endif}
     path_program:=extractfilepath(paramstr(0));
     if os='windows' then path_backups:=path_program+'backup_database\' else path_backups:=path_program+'backup_database/';

     //считывание настроек
     IF(FileExists(path_program+'settings.ini'))then
     begin
          Inif:=TiniFile.Create(path_program+'settings.ini');
          oldOS:=IniF.ReadString('base','lastos','');
          if oldOS=os then begin
                                basename:=inif.ReadString('base','folder','');
                                autoupdate:=StrToBool(inif.ReadString('updates','checking',''));
                                koef_heith:=StrToInt(inif.ReadString('base','koef_height',''));
                           end
          else
              begin
                    basename:=path_program + '1.sqlite';
                    inif.WriteBool('Base','parrentfolder',true);
                    inif.WriteString('base','folder',path_program+'1.sqlite');
                    inif.WriteString('base','lastOS',form1.os);
                    inif.WriteString('base','koef_height','0');
                    showmessage('Внимание, первый запуск в новой ОС! Выбран путь к базе по умолчанию!');
              end;
          inif.Free;
     end
     else begin
               Inif:=TiniFile.Create(path_program+'settings.ini');
               inif.WriteBool('Base','parrentfolder',true);
               inif.WriteString('base','folder',path_program+'1.sqlite');
               inif.WriteString('base','lastOS',form1.os);
               inif.WriteBool('Updates','checking',false);
               inif.WriteString('base','koef_height','0');
               inif.Free;
               basename:=path_program + '1.sqlite';
               ShowMessage('Файл настроек не найден, настройки сброшены по умолчанию');
          end;
     //////////////////////////////////////////////////////////////
       //считывание разрешения экрана и установка размера формы
     if not trigger_form then
         begin
              MaxRect := Monitor.WorkareaRect;
              NewHeight := MaxRect.Height;
              //NewTop := MaxRect.Width;

              SetBounds(0, NewTop, Width, NewHeight-koef_heith);
              trigger_form:=true;
         end;
//     ShowMessage(inttostr(Left));
     predohranitel:=0;
     save_reserv;
     //подключение к базе даных
     SQLite3Connection1.DatabaseName:=basename;
     SQLite3Connection1.Connected:=true;
     rem_connect;
     ID_remont:=1;//по умолчанию присвоим значение идентификатору выбраной записи

     //если записей нет, то деактивация кнопки "удалить"
     if SQLQuery1.RecordCount=0 then Button2.Enabled:=false;
     DateTimePicker1.Date:=strtodate('01.01.2017');
     DateTimePicker2.Date:=date;
     DateTimePicker3.Date:=strtodate('01.01.2017');
     DateTimePicker4.Date:=date;
     DateTimePicker5.Date:=strtodate('01.01.2017');
     DateTimePicker6.Date:=date;
     //задержка всплывающего номера телефона текущей позиции
     Application.HintHidePause:=100000;
end;
//активация кнопки "добавить" при открытии программы
procedure TForm1.FormShow(Sender: TObject);
begin
     Button1.SetFocus;
end;

//Отчет "Оплачено"
procedure TForm1.MenuItem10Click(Sender: TObject);
begin
     SQLQuery2.Active:=false;
     SQLQuery2.sql.Clear;
     SQLQuery2.SQL.Add('Select * from Ремонт where Оплачено=:sost');
     SQLQuery2.ParamByName('sost').AsBoolean:=true;
     SQLQuery2.SQL.Add(' and (Конец_ремонта>=:date3 and Конец_ремонта<=:date4)');
     SQLQuery2.ParamByName('date3').AsDate:=form1.DateTimePicker3.Date;
     SQLQuery2.ParamByName('date4').AsDate:=form1.DateTimePicker4.Date;
     SQLQuery2.SQL.add(' ORDER BY Конец_ремонта, Квитанция');
     SQLQuery2.Active:=true;
     frReport1.LoadFromFile('report_month.lrf');
     frReport1.ShowReport;
end;
//Отчет "расходники"
procedure TForm1.MenuItem11Click(Sender: TObject);
begin
     SQLQuery2.Active:=false;
     SQLQuery2.sql.Clear;
     SQLQuery2.SQL.Add('Select * from Расходники where Наличие=:sost');
     SQLQuery2.ParamByName('sost').AsBoolean:=false;
     SQLQuery2.SQL.Add(' and (Дата_продажи>=:date3 and Дата_продажи<=:date4)');
     SQLQuery2.ParamByName('date3').AsDate:=form1.DateTimePicker3.Date;
     SQLQuery2.ParamByName('date4').AsDate:=form1.DateTimePicker4.Date+1; //хз почему нужно +1
     SQLQuery2.SQL.add(' ORDER BY Квитанция');
     SQLQuery2.Active:=true;
     frReport1.LoadFromFile('report_rashodnik.lrf');
     frReport1.ShowReport;
end;
//отчет "клиент"
procedure TForm1.MenuItem12Click(Sender: TObject);
begin
     form1.SQLQuery2.Active:=false;
     form1.SQLQuery2.sql.Clear;
     form1.SQLQuery2.SQL.Add('select * from Ремонт where ID='+inttostr(form1.ID_remont));
     form1.SQLQuery2.Active:=true;
     form1.frReport1.LoadFromFile('report_klient.lrf');
     form1.frReport1.ShowReport;
end;



//копирование квитанции по контексту, возврат
procedure TForm1.MenuItem15Click(Sender: TObject);
var phone, name1, tech, kvit: string;
  summa,dohod:Double;
begin
     phone:=SQLQuery1.FieldByName('Телефон').AsString;
     name1:=SQLQuery1.FieldByName('Имя_заказчика').AsString;
     tech:=sqlQuery1.FieldByName('Наименование_техники').AsString;
     kvit:=sqlQuery1.FieldByName('Квитанция').AsString;
     summa:=sqlQuery1.FieldByName('Сумма').AsFloat;
     dohod:=sqlQuery1.FieldByName('Доход').AsFloat;;

     with SQLQuery1 do
     begin
          Append;
          FieldByName('Квитанция').AsString:=inttostr(last_NUM+1);
          FieldByName('Начало_ремонта').AsDateTime:=date;
          FieldByName('Конец_ремонта').AsDateTime:=date;
          FieldByName('Телефон').AsString:=phone;
          FieldByName('Имя_заказчика').AsString:=name1;
          FieldByName('Оплачено').AsBoolean:=false;
          FieldByName('Перезвонить').AsBoolean:=false;
          FieldByName('Выполнено').AsString:='Принято в '+TimeToStr(Now);

          if ((Sender as TMenuItem).Caption='Имя+телефон+техника')or((Sender as TMenuItem).Caption='Возврат') then
          FieldByName('Наименование_техники').AsString:=tech;

          if (Sender as TMenuItem).Caption='Возврат' then
          begin
               FieldByName('Примечание').AsString:='Возврат по '+kvit;
               FieldByName('Стоимость').AsFloat:=dohod*(-1);
               FieldByName('Сумма').AsFloat:=summa*(-1);
               FieldByName('Оплачено').AsBoolean:=true;
               SQLQuery2.Active:=false;
               SQLQuery2.SQL.Clear;
               SQLQuery2.SQL.Add('INSERT INTO Расходники (Приход,Поставщик,Накладная,Код_товара,Наименование_расходника,Курс,Цена_уе,Вход,Наличие) SELECT Приход,Поставщик,Накладная,Код_товара,Наименование_расходника,Курс,Цена_уе,Вход,:sost FROM Расходники WHERE Квитанция=:copy');
               SQLQuery2.ParamByName('copy').AsInteger:=ID_remont;
               SQLQuery2.ParamByName('sost').AsBoolean:=true;
               SQLQuery2.ExecSQL;
          end;

          UpdateRecord;
          Post;// записываем данные
          ApplyUpdates;// отправляем изменения в базу
     end;
     SQLTransaction1.Commit;

     form1.FormCreate(Self);

     if form1.CheckBox2.Checked=true then find;
     if form1.CheckBox5.Checked=true then finstat;

     Button1.SetFocus;
end;

//Удаление через контекстное меню
procedure TForm1.MenuItem17Click(Sender: TObject);
begin
  Button2Click(Self);
end;
//Контекстное меню "Перезвонить"
procedure TForm1.MenuItem19Click(Sender: TObject);
begin
     SQLQuery1.Edit;
     sqlQuery1.FieldByName('Перезвонить').AsBoolean:=false;

     sqlQuery1.UpdateRecord;
     Sqlquery1.Post;// записываем данные
     sqlquery1.ApplyUpdates;// отправляем изменения в базу
     SQLTransaction1.Commit;

     form1.FormCreate(Self);

     if form1.CheckBox2.Checked=true then find;
     if form1.CheckBox5.Checked=true then finstat;

     SQLQuery1.RecNo:=rec_pos;
end;
//Поиск квитанций по текущему номеру телефона
procedure TForm1.MenuItem20Click(Sender: TObject);
var s:string;
begin
     s:=SQLQuery1.FieldByName('Телефон').AsString;
     button4.OnClick(Self);
     edit3.Text:=s;
     CheckBox2.Checked:=true;
     CheckBox2.OnClick(Self);
end;

//открытие склада
procedure TForm1.MenuItem2Click(Sender: TObject);
begin
     form1.Visible:=false;
     form6.ShowModal;
end;

//распаковка резервной копии БД
procedure TForm1.MenuItem5Click(Sender: TObject);
Var
  ArchStream: TMemoryStream;
  FileStream: TMemoryStream;
  ZReadArc: TZlibReadArchive;
  X: Integer;
  DestPath: String;
begin
  OpenDialog1.Execute;
  if OpenDialog1.FileName<>'' then
      begin
           ArchStream := TMemoryStream.Create;
           FileStream := TmemoryStream.Create;

           ArchStream.LoadFromFile(OpenDialog1.FileName);

           ZReadArc:= TZlibReadArchive.Create(ArchStream);
           DestPath := 'backup_database';
           for X := 0 to ZReadArc.Count -1 do
           begin
           ZReadArc.ExtractFileToStream(X, FileStream);
           FileStream.SaveToFile(DestPath+ZReadArc.FilesInArchive[X].FilePath+'/'+ZReadArc.FilesInArchive[X].FIleName);
           FileStream.Position := 0;
           FileStream.Size := 0;
           end;
           ZReadArc.Free;
           ArchStream.Free;
           FileStream.Free;
           ShowMessage('Распаковка завершена!');
      end;
end;

procedure TForm1.MenuItem6Click(Sender: TObject);
begin
     form3.ShowModal;
end;

//Контекстное меню "Оплачено"
procedure TForm1.MenuItem9Click(Sender: TObject);
begin
          SQLQuery1.Edit;
          sqlQuery1.FieldByName('Оплачено').AsBoolean:=true;
          sqlQuery1.FieldByName('Конец_ремонта').AsDateTime:=Date;

          sqlQuery1.UpdateRecord;
          Sqlquery1.Post;// записываем данные
          sqlquery1.ApplyUpdates;// отправляем изменения в базу

          form2.SQLQuery4.Active:=false;
          form2.SQLQuery4.SQL.Clear;
          form2.SQLQuery4.SQL.Add('Update Расходники set №_квитанции=:numWORK where Квитанция='+inttostr(form1.ID_remont));
          form2.SQLQuery4.ParamByName('numWORK').Value:=sqlQuery1.FieldByName('Квитанция').AsString;
          form2.SQLQuery4.ExecSQL;

          form2.SQLQuery4.Active:=false;
          form2.SQLQuery4.SQL.Clear;
          form2.SQLQuery4.SQL.Add('Update Расходники set Дата_продажи=:date where Квитанция='+inttostr(form1.ID_remont));
          form2.SQLQuery4.ParamByName('date').Value:=Date;
          form2.SQLQuery4.ExecSQL;

          SQLTransaction1.Commit;

          form1.SQLQuery1.Active:=false;
          form1.SQLQuery1.Active:=true;
          form1.FormCreate(Self);

          if form1.CheckBox2.Checked=true then find else rem_connect;
          if form1.CheckBox5.Checked=true then finstat;

          Button1.SetFocus;
          SQLQuery1.RecNo:=rec_pos;
end;

//убрать подсветку даты при фильтре "все"
procedure TForm1.RadioButton1Click(Sender: TObject);
begin
  if RadioButton1.Checked=true then begin groupbox4.Color:=clSkyBlue;groupbox6.color:=clSkyBlue;end;
end;
//подсветка дат "оплачено"
procedure TForm1.RadioButton2Click(Sender: TObject);
begin
  if RadioButton2.Checked=true then begin groupbox4.color:=clSkyBlue;groupbox6.color:=clRed;end;
end;
//подсветка дат "Неоплачено"
procedure TForm1.RadioButton3Click(Sender: TObject);
begin
  if RadioButton3.Checked=true then begin groupbox4.color:=clRed;groupbox6.color:=clSkyBlue;end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
     form1.Caption:='Сервис центр "ЧипЗона" v. 3.6          '+ TimeToStr(Time);
end;

end.

