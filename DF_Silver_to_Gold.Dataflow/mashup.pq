[DefaultOutputDestinationSettings = [DestinationDefinition = [Kind = "Reference", QueryName = "DefaultDestination", IsNewTarget = true], UpdateMethod = [Kind = "Replace"], DestinationTypeSettings = [Kind = "Table"]], StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[BindToDefaultDestination = true]
shared Aircraft = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "aircraft_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"name", "Aircraft"}})
in
  #"Renamed columns";
[BindToDefaultDestination = true]
shared Airlines = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "airlines_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"name", "Airline"}})
in
  #"Renamed columns";
[BindToDefaultDestination = true]
shared Airports = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "airports_delta", ItemKind = "Table"]}[Data],
  #"Merged queries" = Table.NestedJoin(#"Navigation 2", {"time_zone_id"}, time_zones_delta, {"id"}, "time_zones_delta", JoinKind.LeftOuter),
  #"Removed columns" = Table.RemoveColumns(#"Merged queries", {"time_zone_id"}),
  #"Expanded time_zones_delta" = Table.ExpandTableColumn(#"Removed columns", "time_zones_delta", {"utc_offset", "name"}, {"time_zone_utc_offset", "time_zone_name"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded time_zones_delta", {"city_id"}, cities_delta, {"id"}, "cities_delta", JoinKind.LeftOuter),
  #"Removed columns 1" = Table.RemoveColumns(#"Merged queries 1", {"city_id"}),
  #"Expanded cities_delta" = Table.ExpandTableColumn(#"Removed columns 1", "cities_delta", {"country_id", "name"}, {"city_country_id", "city_name"}),
  #"Merged queries 2" = Table.NestedJoin(#"Expanded cities_delta", {"city_country_id"}, countries_delta, {"id"}, "countries_delta", JoinKind.LeftOuter),
  #"Removed columns 2" = Table.RemoveColumns(#"Merged queries 2", {"city_country_id"}),
  #"Expanded countries_delta" = Table.ExpandTableColumn(#"Removed columns 2", "countries_delta", {"name"}, {"country_name"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded countries_delta", {{"latitude", "Latitude"}, {"longitude", "Longitude"}, {"name", "Airport"}, {"time_zone_utc_offset", "Time Zone UTC Offset"}, {"time_zone_name", "Time Zone"}, {"city_name", "City"}, {"country_name", "Country"}})
in
  #"Renamed columns";
shared cities_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "cities_delta", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared countries_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "countries_delta", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[BindToDefaultDestination = true]
shared #"Flight Status" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "flight_status_types_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"name", "Flight Status Type"}})
in
  #"Renamed columns";
shared headline_types_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "headline_types_delta", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[BindToDefaultDestination = true]
shared Headlines = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "headlines_delta", ItemKind = "Table"]}[Data],
  #"Merged queries" = Table.NestedJoin(#"Navigation 2", {"headline_type_id"}, headline_types_delta, {"id"}, "headline_types_delta", JoinKind.LeftOuter),
  #"Removed columns" = Table.RemoveColumns(#"Merged queries", {"headline_type_id"}),
  #"Expanded headline_types_delta" = Table.ExpandTableColumn(#"Removed columns", "headline_types_delta", {"name"}, {"headline_type"}),
  #"Renamed columns" = Table.RenameColumns(#"Expanded headline_types_delta", {{"airline_name", "Airline"}, {"location", "Location"}, {"date", "Date"}, {"info", "Headline"}, {"headline_type", "Headline Type"}})
in
  #"Renamed columns";
shared schedules_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "schedules_delta", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
[BindToDefaultDestination = true]
shared #"Flight Types" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "service_types_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"name", "Flight Type"}})
in
  #"Renamed columns";
[BindToDefaultDestination = true]
shared Flights = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "status_delta", ItemKind = "Table"]}[Data],
  #"Merged queries" = Table.NestedJoin(#"Navigation 2", {"schedule_id"}, schedules_delta, {"id"}, "schedules_delta", JoinKind.LeftOuter),
  #"Expanded schedules_delta" = Table.ExpandTableColumn(#"Merged queries", "schedules_delta", {"dep_time", "arr_time"}, {"schedules_delta.dep_time", "schedules_delta.arr_time"}),
  #"Added custom" = Table.AddColumn(#"Expanded schedules_delta", "schedule_dep_time", each if [schedules_delta.dep_time] <> null then [schedules_delta.dep_time] else [dep_sc_utc_time]),
  #"Added custom 1" = Table.AddColumn(#"Added custom", "schedule_arr_time", each if[schedules_delta.arr_time] <> null then [schedules_delta.arr_time] else [arr_sc_utc_time]),
  #"Changed column type" = Table.TransformColumnTypes(#"Added custom 1", {{"schedule_dep_time", type datetime}, {"schedule_arr_time", type datetime}}),
  #"Sorted rows" = Table.Sort(#"Changed column type", {{"source_time", Order.Descending}}),
  #"Removed columns" = Table.RemoveColumns(#"Sorted rows", {"dep_sc_utc_time", "arr_sc_utc_time", "schedules_delta.dep_time", "schedules_delta.arr_time", "source_time"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns", {{"dep_time", "Departure Time"}, {"arr_time", "Arrival Time"}, {"schedule_dep_time", "Schedule Departure Time"}, {"schedule_arr_time", "Schedule Arrival Time"}}),
  #"Inserted Date" = Table.AddColumn(#"Renamed columns", "Date", each Date.From([Departure Time]), type date),
  #"Inserted Date 1" = Table.AddColumn(#"Inserted Date", "Date2", each Date.From([Arrival Time]), type date),
  #"Renamed columns 1" = Table.RenameColumns(#"Inserted Date 1", {{"Date", "Departure Date"}, {"Date2", "Arrival Date"}})
in
  #"Renamed columns 1";
[BindToDefaultDestination = true]
shared #"Flight Time Status" = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "time_status_types_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"name", "Flight Time Status"}})
in
  #"Renamed columns";
shared time_zones_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "time_zones_delta", ItemKind = "Table"]}[Data]
in
  #"Navigation 2";
shared DefaultDestination = Lakehouse.Contents([EnableFolding = false]){[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data]{[lakehouseId = "9258e090-c924-44d8-aca2-3ea81280380d"]}[Data];
[BindToDefaultDestination = true]
shared Dates = let
    // 1. Reference your existing tables and find the Min/Max
    // Replace "Table A" and "Table B" with your actual table names
    // Replace "OrderDate" and "ShipDate" with your actual column names
    MinDate = List.Min(Headlines[Date]),
    MaxDate = List.Max(Flights[Arrival Time]),

    // 2. Standardize to the start of the Min year and end of the Max year
    // This ensures you have full months/years for time intelligence
    StartDate = #date(Date.Year(MinDate), 1, 1),
    EndDate = #date(Date.Year(MaxDate), 12, 31),
    
    // 3. Generate the list of dates
    DayCount = Duration.Days(Duration.From(EndDate - StartDate)) + 1,
    Source = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
    
    // 4. Convert to Table and add attributes
    TableFromList = Table.FromList(Source, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    RenamedDate = Table.RenameColumns(TableFromList,{{"Column1", "Date"}}),
    ChangedType = Table.TransformColumnTypes(RenamedDate,{{"Date", type date}}),
    
    // 5. Add common columns
    AddYear = Table.AddColumn(ChangedType, "Year", each Date.Year([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddYear, "Month", each Date.MonthName([Date])& " " & Text.From(Date.Year([Date])), type text),
    AddMonthKey = Table.AddColumn(AddMonthName, "MonthKey", each (Date.Year([Date]) * 100) + Date.Month([Date]), Int64.Type),
    AddDay = Table.AddColumn(AddMonthKey, "Day", each Text.From(Date.Day([Date]))& " " & Date.MonthName([Date])& " " & Text.From(Date.Year([Date])), type text)
in
    AddDay;
