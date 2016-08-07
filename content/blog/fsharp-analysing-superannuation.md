+++
date = "2016-09-14"
draft = false

categories = ["blog"]

title = "Visualising Australian Super Performance with F#"
description = "Visualising Australian super performance using FSharp.Data and FSharp.Charting"
+++

[Australian Super Performance graphs](https://www.australiansuper.com/investments-and-performance/superannuation-performance/investmentsperformancedaily.aspx) 
are available on their website, but just as a simple exercise, lets replicate their graph, using FSharp.Charting.

<sub>Graph generated from [Australian Super Website](https://www.australiansuper.com)</sub>
![alt text](/images/AuSuper-SuperPerformanceDaily.png "AU Super graph generated from their website")

Below is a screenshot of the associated cumulative % change for the period, for the investments shown in the graph above:

![alt text](/images/AuSuper-SuperPerformanceDaily-Legend.png "AU Super graph legend")

First create a paket dependencies file:

<sub>*paket.dependencies*<sub>
``` fsharp
source https://nuget.org/api/v2

nuget FSharp.Data
nuget FSharp.Charting
```

Run the following command to generate an include script, so you only need to include 1 file, rather than all dependencies.

`paket generate-include-scripts`

```
c:\Src\FSharpData>paket generate-include-scripts
Paket version 3.8.0.0
generating scripts for framework net46
1 second - ready.
```

Then the following script can be executed using fsi.exe `fsi.exe auSuper.fsx` 

<sub>*auSuper.fsx*</sub>
``` fsharp
#load "paket-files/include-scripts/net451/include.main.group.fsx"
open System
open FSharp.Data
open FSharp.Charting

let urlBase = "https://www.australiansuper.com/layouts/sublayouts/CRCAS/InvestmentsGraphs/DailyRatesChartData.ashx?"
let numDays = -30.0
let startDate = DateTime.Now.AddDays(numDays).ToString("dd/MM/yyyy")
let endDate = DateTime.Now.ToString("dd/MM/yyyy")
let fileName = "DailyRate.csv"

let url = urlBase + "start=" + startDate + "&end=" + endDate + "&cumulative=False&superType=Super&truncateDecimalPlaces=False&outputFilename=" + fileName
//printfn "%s" url
let csv = CsvFile.Load(url)

//Available rows
//Rate Date,High Growth,Balanced,Socially Aware,Indexed Diversified,Conservative Balanced,Stable,Capital Guaranteed,Australian Shares,International Shares,Property,Diversified Fixed Interest,Cash

let dates = DateTime.Now.AddDays(numDays - 2.0) :: [ for row in csv.Rows -> (row.["Rate Date"].AsDateTime()) ]
let data (rowName: string) = [ for row in csv.Rows -> (row.[rowName].AsFloat()) ] |> List.scan (+) 0.0 |> List.zip dates

let chartData (rowName: string) = Chart.Line(data rowName, Name=rowName)

Chart.Combine(
    [chartData "Balanced";
    chartData "High Growth";
    chartData "Property";
    chartData "Australian Shares";
    chartData "International Shares";]).ShowChart()
```

And we get this nice graph:
![alt text](/images/auSuperPlotExample.png "A sample of AU Super over 1 month")