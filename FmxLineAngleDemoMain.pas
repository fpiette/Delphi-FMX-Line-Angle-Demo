{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       François PIETTE @ Overbyte.be
Creation:     November 18, 2020
Description:  A simple demo showing how to create a GUI with FMX to let
              the user draw two intersecting lines and then compute and
              show the angle between the two lines.
              Compiled with Delphi 10.4.1
License:      This program is published under MOZILLA PUBLIC LICENSE V2.0;
              you may not use this file except in compliance with the License.
              You may obtain a copy of the License at
              https://www.mozilla.org/en-US/MPL/2.0/
Version:      1.00
History:


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit FmxLineAngleDemoMain;

interface

uses
    System.SysUtils, System.Types,    System.UITypes,
    System.Classes,  System.Variants, System.Math,
    FMX.Types,   FMX.Controls, FMX.Forms,   FMX.Graphics,
    FMX.Objects, FMX.StdCtrls, FMX.Dialogs, FMX.Controls.Presentation;

type
    TIntersectingLines = record
        PtI : TPointF;  // Where the lines intersect
        Pt1 : TPointF;  // End of line 1
        Pt2 : TPointF;  // End of line 1
    end;

    TFmxLineAngleDemoMainForm = class(TForm)
        HelpLabel: TLabel;
        MouseXYLabel: TLabel;
        DrawPanel: TPanel;
        AngleLabel: TLabel;
        MousePosLabel: TLabel;
        procedure FormCreate(Sender: TObject);
        procedure DrawPanelMouseMove(Sender: TObject;
                                     Shift: TShiftState;
                                     X, Y: Single);
        procedure DrawPanelMouseUp(Sender : TObject;
                                   Button : TMouseButton;
                                   Shift  : TShiftState;
                                   X, Y   : Single);
        procedure DrawPanelPaint(Sender      : TObject;
                                 Canvas      : TCanvas;
                                 const ARect : TRectF);
        procedure DrawPanelMouseLeave(Sender: TObject);
        procedure ComputeAngle(PtI : TPointF;
                               Pt1 : TPointF;
                               Pt2 : TPointF);
    private
        FIntersectLines : TIntersectingLines;
        FPointCount     : Integer;
        FMousePos       : TPointF;
        FAngle          : Single;    // Degrees
        FAngle1         : Single;    // Degrees
        FAngle2         : Single;    // Degrees
    end;

var
  FmxLineAngleDemoMainForm: TFmxLineAngleDemoMainForm;

implementation

{$R *.fmx}

procedure TFmxLineAngleDemoMainForm.FormCreate(Sender: TObject);
begin
    AngleLabel.Text    := '';
    MouseXYLabel.Text  := '-';
end;

procedure TFmxLineAngleDemoMainForm.DrawPanelMouseLeave(Sender: TObject);
begin
    MouseXYLabel.Text  := '-';
end;

procedure TFmxLineAngleDemoMainForm.DrawPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y:
    Single);
begin
    FMousePos := PointF(X, Y);
    MouseXYLabel.Text := X.ToString + ', ' + Y.ToString;
    if FPointCount = 1 then begin
       FIntersectLines.Pt1 := FMousePos;
       ComputeAngle(FIntersectLines.PtI, FIntersectLines.Pt1, FMousePos);
    end
    else if FPointCount = 2 then begin
       FIntersectLines.Pt2 := FMousePos;
       ComputeAngle(FIntersectLines.PtI, FIntersectLines.Pt1, FMousePos);
    end;

    DrawPanel.Repaint;
end;

procedure TFmxLineAngleDemoMainForm.DrawPanelMouseUp(
    Sender : TObject;
    Button : TMouseButton;
    Shift  : TShiftState;
    X, Y   : Single);
begin
    case FPointCount of
    0: begin
           FIntersectLines.PtI := PointF(X, Y);
           HelpLabel.Text           := 'Click on end of vector 1';
           Inc(FPointCount);
       end;
    1: begin
           FIntersectLines.Pt1 := PointF(X, Y);
           HelpLabel.Text        := 'Click on end of vector 2';
           Inc(FPointCount);
       end;
    2: begin
           FIntersectLines.Pt2 := PointF(X, Y);
           ComputeAngle(FIntersectLines.PtI,
                        FIntersectLines.Pt1,
                        FIntersectLines.Pt2);
           HelpLabel.Text        := 'Click on vector intersection';
           Inc(FPointCount);
       end;
    3: begin
           FIntersectLines.PtI   := PointF(X, Y);
           FPointCount           := 1;
           AngleLabel.Text       := '';
           HelpLabel.Text        := 'Click on end of vector 1';
       end;
    else
           ShowMessage('Missing case-of');
           HelpLabel.Text     := 'Program error';
           FPointCount        := 0;
    end;
    DrawPanel.Repaint;
end;

procedure TFmxLineAngleDemoMainForm.DrawPanelPaint(
    Sender      : TObject;
    Canvas      : TCanvas;
    const ARect : TRectF);
var
    StartAngle : Single;
begin
    Canvas.BeginScene;
    try
        Canvas.Stroke.Kind      := TBrushKind.Solid;
        Canvas.Stroke.Thickness := 1;
        if FPointCount = 1 then begin
           // Paint cross at intersection point
           Canvas.Stroke.Color     := TAlphaColorRec.Black;
           Canvas.DrawLine(
                FIntersectLines.PtI + Pointf(+10, +10),
                FIntersectLines.PtI + Pointf(-10, -10),
                100);
           Canvas.DrawLine(
                FIntersectLines.PtI + PointF(-10, +10),
                FIntersectLines.PtI + PointF(+10, -10),
                100);
           // Paint line from intersection point to mouse position
           Canvas.Stroke.Color     := TAlphaColorRec.Red;
           Canvas.DrawLine(
                FIntersectLines.PtI,
                FMousePos,
                100);
        end;
        if FPointCount >= 2 then begin
           // Paint line from intersection point to vector1 position
           Canvas.Stroke.Color     := TAlphaColorRec.Red;
           Canvas.DrawLine(FIntersectLines.PtI, FIntersectLines.Pt1, 100);

           // Paint arc
           // It starts at vector1 angle and ends at mouse position angle
           Canvas.Stroke.Color     := TAlphaColorRec.Blue;
           if FAngle1 >= 0 then
               StartAngle := 360.0 - FAngle1
           else
               StartAngle := -FAngle1;
           Canvas.DrawArc(
                FIntersectLines.PtI,
                PointF(20.0, 20.0),
                StartAngle,
                FAngle,
                100);
            if FPointCount = 2 then begin
               // Paint line from intersection point to mouse position
               Canvas.Stroke.Color     := TAlphaColorRec.Lime;
               Canvas.DrawLine(FIntersectLines.PtI, FMousePos, 100);
            end;
        end;
        if FPointCount >= 3 then begin
           // Paint line from intersection point to vector2 position
           Canvas.Stroke.Color     := TAlphaColorRec.Lime;
           Canvas.DrawLine(FIntersectLines.PtI, FIntersectLines.Pt2, 100);
        end;
    finally
        Canvas.EndScene;
    end;
end;

function RadToDeg(A : Single) : Single;
begin
    Result := 180.0 / PI * A;
end;

// Compute angle in degrees between two intersecting line segments
// There are 3 computed angles returned in FAngle, FAngle1 and FAngle2
// FAngle is the angle between the first and second line segments
// FAngle1 is the angle between the first line segment and the X-axis
// FAngle2 is the angle between the second line segment and the X-axis
procedure TFmxLineAngleDemoMainForm.ComputeAngle(
    PtI : TPointF;    // Intersection point
    Pt1 : TPointF;    // End of line segment 1
    Pt2 : TPointF);   // End of line segment 2
var
    H          : Single;
    Buf        : String;
begin
    // Y coordinates in the drawing and mouse position are inverted:
    // The zero is on top while usually in math we use zero at bottom
    // Here we invert all Y coordinates to be like usual in math.
    // This will gives angles results as a mathematician expect while
    // looking at the drwaing.
    H       := DrawPanel.Height;
    FAngle1 := RadToDeg(ArcTan2((H - Pt1.Y) - (H - PtI.Y), Pt1.X - PtI.X));
    FAngle2 := RadToDeg(ArcTan2((H - Pt2.Y) - (H - PtI.Y), Pt2.X - PtI.X));

    if FAngle2 <= FAngle1 then
        FAngle := FAngle1 - FAngle2
    else
        FAngle := 360.0 + FAngle1 - FAngle2;

    // Display the angles on screen
    if FPointCount <= 0 then
        Buf := '';
    if FPointCount >= 1 then
        Buf := 'Angle1=' + FAngle1.ToString(TFloatFormat.ffFixed, 5, 2);
    if FPointCount >= 2 then
        Buf := 'Angle=' + FAngle.ToString(TFloatFormat.ffFixed, 5, 2) +
               '  ' + Buf + '  ' +
               'Angle2=' + FAngle2.ToString(TFloatFormat.ffFixed, 5, 2);
    AngleLabel.Text := Buf;
end;

end.
