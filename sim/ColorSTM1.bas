Attribute VB_Name = "Module2"
Sub ColorSTM1()
Attribute ColorSTM1.VB_ProcData.VB_Invoke_Func = "q\n14"

    Dim Frame_Name As Range
    Dim Data As Range
    Dim Col_Index As Range
    Dim Row_Index As Range
    
    Dim POH As Range
    Dim Au_Ptr As Range
    Dim RSOH As Range
    Dim MSOH As Range
    
    Dim Frame_Border As Range
    Dim Frames_num As Integer
    Dim i As Integer
    Dim base_frame As Integer
    Dim lastRow As Long
    Dim frameCount As Integer
    
    ' Set the base frame start row
    base_frame = 1
    
    ' Find the last row in column A
    lastRow = Cells(Rows.Count, "A").End(xlUp).Row
    
    ' Count the number of frames based on "STM" prefix
    frameCount = (lastRow + 1) / 11
    
    ' Loop through to create the frames
    For i = 0 To frameCount - 1
        Set Frame_Name = Range("A" & (base_frame + i * 11))
        Set Data = Range("L" & (base_frame + i * 11) & ":JK" & (base_frame + i * 11 + 9)) ' Adjusted to include the last row
        Set Col_Index = Range("B" & (base_frame + i * 11) & ":JK" & (base_frame + i * 11))
        Set Row_Index = Range("A" & (base_frame + i * 11) & ":A" & (base_frame + i * 11 + 9)) ' Adjusted to include the last row
        Set Frame_Border = Range("B" & (base_frame + i * 11 + 1) & ":JK" & (base_frame + i * 11 + 9)) ' Adjusted to include the last row
        
        Set POH = Range("K" & (base_frame + i * 11 + 1) & ":K" & (base_frame + i * 11 + 9)) ' Adjusted to include the last row
        Set RSOH = Range("B" & (base_frame + i * 11 + 1) & ":J" & (base_frame + i * 11 + 4)) ' Adjusted to include the last row
        Set MSOH = Range("B" & (base_frame + i * 11 + 5) & ":J" & (base_frame + i * 11 + 9)) ' Adjusted to include the last row
        Set Au_Ptr = Range("B" & (base_frame + i * 11 + 4) & ":J" & (base_frame + i * 11 + 4)) ' Adjusted to include the last row
        
        ' Highlight the ranges
        Frame_Name.Font.Bold = True
        
        Data.Interior.Color = &HCCF2FF
        Col_Index.Interior.Color = RGB(255, 230, 153)
        Row_Index.Interior.Color = RGB(255, 230, 153)
        Frame_Name.Interior.Color = RGB(255, 205, 45)
        
        POH.Interior.Color = RGB(248, 203, 173)
        MSOH.Interior.Color = RGB(155, 194, 230)
        RSOH.Interior.Color = &HFA6148
        Au_Ptr.Interior.Color = &HFFC23B
        
        ' Center align all cells in the ranges
        Frame_Border.HorizontalAlignment = xlCenter
        Frame_Border.VerticalAlignment = xlCenter
        
        Col_Index.HorizontalAlignment = xlCenter
        Col_Index.VerticalAlignment = xlCenter
        
        Row_Index.HorizontalAlignment = xlCenter
        Row_Index.VerticalAlignment = xlCenter
        
        ' Make cells square (adjusting height to match width)
        Dim col As Range
        For Each col In Frame_Border.Columns
            col.ColumnWidth = 8
            col.RowHeight = col.Width
        Next col
        
        For Each col In Col_Index.Columns
            col.ColumnWidth = 8
            col.RowHeight = col.Width
        Next col
        
        For Each col In Row_Index.Columns
            col.ColumnWidth = 15
        Next col
        
        ' Add borders for Data
        With Frame_Border.Borders
            .LineStyle = xlContinuous
            .Weight = xlThin
            .Color = RGB(0, 0, 0) ' Black color
        End With
        
        ' Add borders for Col_Index
        With Col_Index.Borders
            .LineStyle = xlContinuous
            .Weight = xlMedium
            .Color = RGB(0, 0, 0) ' Black color
        End With
        
        ' Add borders for Row_Index
        With Row_Index.Borders
            .LineStyle = xlContinuous
            .Weight = xlMedium
            .Color = RGB(0, 0, 0) ' Black color
        End With
    Next i

End Sub
