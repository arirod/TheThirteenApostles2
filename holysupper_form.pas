{
     *** lab ***
     pode conter erros de logica e implementacao
     use por conta e risco
}
unit holysupper_form;

{$mode delphi}{$H+}

interface

uses
  Classes,
  SysUtils,
  SQLDB,
  SQLite3Conn,
  Forms,
  Controls,
  Graphics,
  Dialogs,
  StdCtrls,
  DBGrids,
  Buttons,
  TypInfo,
  DB;

type

  { THackQueryState }
  THackQueryState = class(TDataSet)
  private
    FState: TDataSetState;
  published
    property State : TDataSetState read FState write SetState;
  end;

  { Tholy_supperForm }

  Tholy_supperForm = class(TForm)
    btnAfterInsertEvent: TBitBtn;
    Button1: TButton;
    btnCreateDatabase: TButton;
    DataSource1: TDataSource;
    DBGrid1: TDBGrid;
    procedure btnCreateDatabaseClick(Sender: TObject);
    procedure btnAfterInsertEventClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure displaystatus;
    procedure MyAfterInsert(DataSet: TDataSet);

  public

  end;

var
  holy_supperForm: Tholy_supperForm;
  AQuery         : TSQLQuery;

implementation

{$R *.lfm}

{ Tholy_supperForm }

procedure Tholy_supperForm.displaystatus;
begin
  if Assigned(AQuery) then
    Button1.Caption := Format('DataSet State: %s', [GetEnumName(TypeInfo(TDataSetState),
    Ord(Self.DBGrid1.DataSource.DataSet.State))]);

end;

procedure Tholy_supperForm.MyAfterInsert(DataSet: TDataSet);
begin
  if DataSet.State = dsinsert then
    ShowMessage('do what?...')
  else
    ShowMessage('nothing to do...');

  AQuery.Cancel;
end;

{ THackQueryState }
procedure Tholy_supperForm.Button1Click(Sender: TObject);
begin
  // falta fazer typecast
  if DBGrid1.DataSource.DataSet.State in [dsBrowse, dsEdit] then
    THackQueryState(AQuery).State := dsInsert
  else
    THackQueryState(AQuery).State := dsBrowse;

  displaystatus;
end;

procedure Tholy_supperForm.btnCreateDatabaseClick(Sender: TObject);
var
  AConnection  : TSQLite3Connection;
  ATransaction : TSQLTransaction;
  nameArr      : array[0..12] of string = ('Pedro', 'Tiago', 'João', 'André', 'Filipe', 'Bartolomeu', 'Mateus', 'Tomé', 'Tiago2', 'Tadeu', 'Simão', 'Zelote','Judas Iscariotes');
  i: integer;
begin
  AConnection              := TSQLite3Connection.Create(nil);
  AConnection.DatabaseName := ':memory:';
  //*
  ATransaction             := TSQLTransaction.Create(AConnection);
  AConnection.Transaction  := ATransaction;
  AConnection.Open;
  ATransaction.StartTransaction;
  AConnection.ExecuteDirect(
    'create table dummytable (id integer not null, fullname varchar(60), constraint pkkey primary key (ID));');

  ATransaction.Commit;

  for i:= Low(nameArr) to High(nameArr) do
  begin
    AConnection.ExecuteDirect('insert into dummytable (fullname) values ( '+QuotedStr(nameArr[i])+');');
  end;

  AQuery              := TSQLQuery.Create(nil);
  AQuery.AfterInsert  := MyAfterInsert;
  AQuery.DataBase     := AConnection;
  DataSource1.DataSet := AQuery;
  AQuery.SQL.Clear;
  AQuery.SQL.Text     := ('select * from dummytable' );
  AQuery.Open;
  {
  ATransaction.Commit;
  AConnection.Close;
  ATransaction.Free;
  AConnection.Free;
  }
  displaystatus;
  DBGrid1.SetFocus;
end;

procedure Tholy_supperForm.btnAfterInsertEventClick(Sender: TObject);
begin
  MyAfterInsert(AQuery);
end;

end.
