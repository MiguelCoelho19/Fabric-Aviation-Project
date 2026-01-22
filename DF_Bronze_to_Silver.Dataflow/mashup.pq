[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "aircraft_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared aircraft_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "aircraft_delta", ItemKind = "Table"]}[Data],
  #"Removed duplicates" = Table.Distinct(#"Navigation 2", {"aircraft_code"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed duplicates", {{"aircraft_code", "id"}, {"aircraft_name", "name"}, {"airline_equip_code", "icao_code"}}),
  #"Filtered rows" = Table.SelectRows(#"Renamed columns", each ([name] <> null))
in
  #"Filtered rows";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "airlines_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared airlines_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "airlines_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns" = Table.RenameColumns(#"Navigation 2", {{"airline_id", "id"}, {"airline_id_icao", "icao_code"}, {"airline_name", "name"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns", {"icao_code"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"id"})
in
  #"Removed duplicates";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "airports_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared airports_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "airports_delta", ItemKind = "Table"]}[Data],
  #"Removed duplicates" = Table.Distinct(#"Navigation 2", {"airport_code"}),
  #"Removed columns" = Table.RemoveColumns(#"Removed duplicates", {"location_type", "utc_offset", "country_code"}),
  #"Merged queries 1" = Table.NestedJoin(#"Removed columns", {"time_zone_id"}, time_zones_delta, {"name"}, "time_zones_delta", JoinKind.LeftOuter),
  #"Expanded time_zones_delta" = Table.ExpandTableColumn(#"Merged queries 1", "time_zones_delta", {"id"}, {"time_zones_delta.id"}),
  #"Removed columns 1" = Table.RemoveColumns(#"Expanded time_zones_delta", {"time_zone_id"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Removed columns 1", {{"time_zones_delta.id", "time_zone_id"}, {"airport_code", "id"}, {"city_code", "city_id"}, {"airport_name", "name"}})
in
  #"Renamed columns 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "cities_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared cities_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "cities_delta", ItemKind = "Table"]}[Data],
  #"Renamed columns 1" = Table.RenameColumns(#"Navigation 2", {{"city_code", "id"}, {"country_code", "country_id"}}),
  #"Removed columns" = Table.RemoveColumns(#"Renamed columns 1", {"utc_offset", "time_zone_id"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Removed columns", {{"city_name", "name"}})
in
  #"Renamed columns 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "countries_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared countries_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "countries_delta", ItemKind = "Table"]}[Data],
  #"Removed duplicates" = Table.Distinct(#"Navigation 2", {"country_code"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed duplicates", {{"country_code", "id"}, {"country_name", "name"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "time_zones_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared time_zones_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "cities_delta", ItemKind = "Table"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 2", {"city_code", "country_code", "city_name"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns", {{"time_zone_id", "time_zone_name"}}),
  #"Removed duplicates" = Table.Distinct(#"Renamed columns", {"time_zone_name"}),
  #"Added index" = Table.AddIndexColumn(#"Removed duplicates", "Index", 1, 1, Int64.Type),
  #"Marked key columns" = Table.AddKey(#"Added index", {"Index"}, false),
  #"Renamed columns 1" = Table.RenameColumns(#"Marked key columns", {{"Index", "id"}, {"time_zone_name", "name"}})
in
  #"Renamed columns 1";
shared airlines_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "airlines_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared aircraft_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "aircraft_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared countries_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "countries_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared time_zones_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "time_zones_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared cities_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "cities_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared airports_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "airports_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "headlines_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared headlines_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "avherald_delta", ItemKind = "Table"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each [type] <> "News"),
  #"Removed duplicates" = Table.Distinct(#"Filtered rows", {"headline"}),
  #"Merged queries" = Table.NestedJoin(#"Removed duplicates", {"type"}, headline_types_delta, {"name"}, "headline_types_delta", JoinKind.LeftOuter),
  #"Expanded headline_types_delta" = Table.ExpandTableColumn(#"Merged queries", "headline_types_delta", {"id"}, {"type_id"}),
  #"Removed columns" = Table.RemoveColumns(#"Expanded headline_types_delta", {"type"}),
  #"Split column by delimiter" = Table.SplitColumn(#"Removed columns", "headline", Splitter.SplitTextByEachDelimiter({" on "}, QuoteStyle.Csv), {"headline.1", "headline.2"}),
  #"Split column by delimiter 1" = Table.SplitColumn(#"Split column by delimiter", "headline.2", Splitter.SplitTextByEachDelimiter({","}, QuoteStyle.Csv), {"headline.3", "headline.4"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Split column by delimiter 1", "st", "", Replacer.ReplaceText, {"headline.3"}),
  #"Replaced value" = Table.ReplaceValue(#"Replaced value 1", "nd", "", Replacer.ReplaceText, {"headline.3"}),
  #"Replaced value 2" = Table.ReplaceValue(#"Replaced value", "rd", "", Replacer.ReplaceText, {"headline.3"}),
  #"Replaced value 3" = Table.ReplaceValue(#"Replaced value 2", "th", "", Replacer.ReplaceText, {"headline.3"}),
  #"Replaced value 4" = Table.ReplaceValue(#"Replaced value 3", "h", "", Replacer.ReplaceText, {"headline.3"}),
  #"Changed column type" = Table.TransformColumnTypes(#"Replaced value 4", {{"headline.3", type date}}),
  #"Replaced value 13" = Table.ReplaceValue(#"Changed column type", "  ", " ", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 5" = Table.ReplaceValue(#"Replaced value 13", " at ", "|at ", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 6" = Table.ReplaceValue(#"Replaced value 5", " near ", "|near ", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 7" = Table.ReplaceValue(#"Replaced value 6", " enroute", "|enroute", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 8" = Table.ReplaceValue(#"Replaced value 7", " over ", "|over ", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 9" = Table.ReplaceValue(#"Replaced value 8", " neear ", "|near ", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 10" = Table.ReplaceValue(#"Replaced value 9", " nroute", "|enroute", Replacer.ReplaceText, {"headline.1"}),
  #"Replaced value 11" = Table.ReplaceValue(#"Replaced value 10", " ner ", "|near ", Replacer.ReplaceText, {"headline.1"}),
  #"Split column by delimiter 2" = Table.SplitColumn(#"Replaced value 11", "headline.1", Splitter.SplitTextByDelimiter("|"), {"headline.2", "headline.5"}),
  #"Replaced value 14" = Table.ReplaceValue(#"Split column by delimiter 2", null, "Unknown", Replacer.ReplaceValue, {"headline.5"}),
  #"Split column by delimiter 4" = Table.ExpandListColumn(Table.TransformColumns(#"Replaced value 14", {{"headline.2", Splitter.SplitTextByDelimiter(" and "), let itemType = (type nullable text) meta [Serialized.Text = true] in type {itemType}}}), "headline.2"),
  #"Split column by delimiter 3" = Table.SplitColumn(#"Split column by delimiter 4", "headline.2", Splitter.SplitTextByEachDelimiter({" "}, QuoteStyle.Csv, true), {"headline.6", "headline.7"}),
  #"Renamed columns" = Table.RenameColumns(#"Split column by delimiter 3", {{"headline.5", "location"}, {"headline.3", "date"}, {"headline.7", "aircraft_icao_code"}, {"headline.6", "airline_name"}, {"headline.4", "info"}, {"type_id", "headline_type_id"}}),
  #"Filtered rows 1" = Table.SelectRows(#"Renamed columns", each ([aircraft_icao_code] <> null)),
  #"Merged queries 1" = Table.NestedJoin(#"Filtered rows 1", {"aircraft_icao_code"}, aircraft_delta, {"icao_code"}, "aircraft_delta", JoinKind.LeftOuter),
  #"Expanded aircraft_delta" = Table.ExpandTableColumn(#"Merged queries 1", "aircraft_delta", {"id"}, {"aircraft_id"}),
  #"Removed columns 1" = Table.RemoveColumns(#"Expanded aircraft_delta", {"aircraft_icao_code"}),
  #"Filtered rows 2" = Table.SelectRows(#"Removed columns 1", each ([aircraft_id] <> null))
in
  #"Filtered rows 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "headline_types_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared headline_types_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "avherald_delta", ItemKind = "Table"]}[Data],
  #"Filtered rows" = Table.SelectRows(#"Navigation 2", each ([type] <> "News")),
  #"Removed columns" = Table.RemoveColumns(#"Filtered rows", {"headline"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"type"}),
  #"Added index" = Table.AddIndexColumn(#"Removed duplicates", "Index", 1, 1, Int64.Type),
  #"Renamed columns" = Table.RenameColumns(#"Added index", {{"type", "name"}, {"Index", "id"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "schedules_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared schedules_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "schedules_delta", ItemKind = "Table"]}[Data],
  #"Inserted Merged Column" = Table.AddColumn(#"Navigation 2", "id", each Text.Combine({[mc_flight_no], ";",[dep_time]}), type text),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted Merged Column", {{"end_date", type date}, {"start_date", type date}, {"arr_time", type datetime}, {"dep_time", type datetime}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed column type", {"oc_flight_no"}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Removed columns", "oc_airline2", each if [oc_airline] = null then [mc_airline] else [oc_airline]), {{"oc_airline2", type text}}),
  #"Reordered columns" = Table.ReorderColumns(#"Added custom", {"duration", "dep_airport", "dep_time", "arr_airport", "arr_time", "mc_airline", "mc_flight_no", "oc_airline2", "oc_airline", "aircraft", "days", "start_date", "end_date"}),
  #"Removed columns 1" = Table.RemoveColumns(#"Reordered columns", {"oc_airline"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns 1", {{"oc_airline2", "oc_airline"}}),
  #"Replaced value" = Table.ReplaceValue(#"Renamed columns", "1", "Monday, ", Replacer.ReplaceText, {"days"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", "2", "Tuesday, ", Replacer.ReplaceText, {"days"}),
  #"Replaced value 2" = Table.ReplaceValue(#"Replaced value 1", "3", "Wednesday, ", Replacer.ReplaceText, {"days"}),
  #"Replaced value 3" = Table.ReplaceValue(#"Replaced value 2", "4", "Thursday, ", Replacer.ReplaceText, {"days"}),
  #"Replaced value 4" = Table.ReplaceValue(#"Replaced value 3", "5", "Friday, ", Replacer.ReplaceText, {"days"}),
  #"Replaced value 5" = Table.ReplaceValue(#"Replaced value 4", "6", "Saturday, ", Replacer.ReplaceText, {"days"}),
  #"Replaced value 6" = Table.ReplaceValue(#"Replaced value 5", "7", "Sunday, ", Replacer.ReplaceText, {"days"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Replaced value 6", {{"dep_airport", "dep_airport_id"}, {"arr_airport", "arr_airport_id"}, {"mc_airline", "mc_airline_id"}, {"mc_flight_no", "flight_number"}, {"oc_airline", "oc_airline_id"}, {"aircraft", "aircraft_id"}, {"dep_time", "dep_local_time"}, {"arr_time", "arr_local_time"}}),
  #"Removed columns 2" = Table.RemoveColumns(#"Renamed columns 1", {"mc_airline_id"}),
  #"Renamed columns 2" = Table.RenameColumns(#"Removed columns 2", {{"oc_airline_id", "airline_id"}}),
  #"Replaced value 7" = Table.ReplaceValue(#"Renamed columns 2", "P", "", Replacer.ReplaceText, {"duration"}),
  #"Replaced value 8" = Table.ReplaceValue(#"Replaced value 7", "T", "", Replacer.ReplaceText, {"duration"}),
  #"Split column by position" = Table.SplitColumn(#"Replaced value 8", "days", Splitter.SplitTextByPositions({0, 2}, true), {"days", "days.2"}),
  #"Removed columns 3" = Table.RemoveColumns(#"Split column by position", {"days.2"}),
  #"Filtered rows" = Table.SelectRows(#"Removed columns 3", each List.Contains({"FAO", "DRS", "FRA", "LIS", "OPO", "MUC"}, [dep_airport_id])),
  #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each List.Contains({"FAO", "DRS", "FRA", "LIS", "OPO", "MUC"}, [arr_airport_id])),
  #"Merged queries" = Table.NestedJoin(#"Filtered rows 1", {"dep_airport_id"}, airports_delta, {"id"}, "airports_delta", JoinKind.LeftOuter),
  #"Expanded airports_delta" = Table.ExpandTableColumn(#"Merged queries", "airports_delta", {"time_zone_id"}, {"dep_time_zone_id"}),
  #"Merged queries 1" = Table.NestedJoin(#"Expanded airports_delta", {"dep_time_zone_id"}, time_zones_delta, {"id"}, "time_zones_delta", JoinKind.LeftOuter),
  #"Expanded time_zones_delta" = Table.ExpandTableColumn(#"Merged queries 1", "time_zones_delta", {"utc_offset"}, {"time_zones_delta.utc_offset"}),
  #"Removed columns 4" = Table.RemoveColumns(#"Expanded time_zones_delta", {"dep_time_zone_id"}),
  #"Merged queries 2" = Table.NestedJoin(#"Removed columns 4", {"arr_airport_id"}, airports_delta, {"id"}, "airports_delta", JoinKind.LeftOuter),
  #"Expanded airports_delta 1" = Table.ExpandTableColumn(#"Merged queries 2", "airports_delta", {"time_zone_id"}, {"arr_time_zone_id"}),
  #"Merged queries 3" = Table.NestedJoin(#"Expanded airports_delta 1", {"arr_time_zone_id"}, time_zones_delta, {"id"}, "time_zones_delta", JoinKind.LeftOuter),
  #"Renamed columns 3" = Table.RenameColumns(#"Merged queries 3", {{"time_zones_delta.utc_offset", "dep_offset"}}),
  #"Removed columns 5" = Table.RemoveColumns(#"Renamed columns 3", {"arr_time_zone_id"}),
  #"Expanded time_zones_delta 1" = Table.ExpandTableColumn(#"Removed columns 5", "time_zones_delta", {"utc_offset"}, {"utc_offset"}),
  #"Reordered columns 1" = Table.ReorderColumns(#"Expanded time_zones_delta 1", {"duration", "dep_airport_id", "arr_airport_id", "flight_number", "airline_id", "aircraft_id", "days", "start_date", "end_date", "dep_offset", "utc_offset", "dep_local_time", "arr_local_time"}),
  #"Renamed columns 4" = Table.RenameColumns(#"Reordered columns 1", {{"utc_offset", "arr_offset"}}),
  #"Added custom 1" = Table.AddColumn(#"Renamed columns 4", "dep_time", each DateTimeZone.FromText(
    DateTime.ToText([dep_local_time], "yyyy-MM-ddTHH:mm:ss") & [dep_offset]
  )),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Added custom 1", {{"dep_time", type datetime}}),
  #"Removed columns 6" = Table.RemoveColumns(#"Changed column type 1", {"dep_offset", "dep_local_time"}),
  #"Added custom 2" = Table.TransformColumnTypes(Table.AddColumn(#"Removed columns 6", "arr_time", each DateTimeZone.FromText(
    DateTime.ToText([arr_local_time], "yyyy-MM-ddTHH:mm:ss") & [arr_offset]
  )), {{"arr_time", type datetime}}),
  #"Removed columns 7" = Table.RemoveColumns(#"Added custom 2", {"arr_offset", "arr_local_time"}),
  #"Renamed columns 5" = Table.RenameColumns(#"Removed columns 7", {{"flight_number", "flight_id"}}),
  #"Removed columns 8" = Table.RemoveColumns(#"Renamed columns 5", {"airline_id", "aircraft_id", "flight_id", "dep_airport_id", "arr_airport_id", "duration"})
in
  #"Removed columns 8";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "status_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared status_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "status_delta", ItemKind = "Table"]}[Data],
  #"Inserted Merged Column" = Table.AddColumn(#"Navigation 2", "schedule_id", each Text.Combine({[mc_flight_number], ";",[dep_sc_local_time]}), type text),
  #"Changed column type" = Table.TransformColumnTypes(#"Inserted Merged Column", {{"dep_sc_local_time", type datetime}, {"dep_sc_utc_time", type datetime}, {"dep_es_local_time", type datetime}, {"dep_es_utc_time", type datetime}, {"dep_ac_local_time", type datetime}, {"dep_ac_utc_time", type datetime}, {"arr_sc_local_time", type datetime}, {"arr_sc_utc_time", type datetime}, {"arr_es_local_time", type datetime}, {"arr_es_utc_time", type datetime}, {"arr_ac_local_time", type datetime}, {"arr_ac_utc_time", type datetime}}),
  #"Replaced value" = Table.ReplaceValue(#"Changed column type", "abfss://85a5c217-5ffd-4fc8-a29e-97e1a49d9530@onelake.dfs.fabric.microsoft.com/4f909ca9-0c8b-420a-8995-81f1b427b6c0/Files/lufthansa/status/", "", Replacer.ReplaceText, {"source_file"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", ".json", "", Replacer.ReplaceText, {"source_file"}),
  #"Replaced value 2" = Table.ReplaceValue(#"Replaced value 1", "_", "T", Replacer.ReplaceText, {"source_file"}),
  MyCustomStep = Table.TransformColumns(#"Replaced value 2", {
    {"source_file", each Text.ReplaceRange(_, 13, 1, ":"), type text}
  }),
  #"Changed column type 1" = Table.TransformColumnTypes(MyCustomStep, {{"source_file", type datetime}}),
  #"Removed columns" = Table.RemoveColumns(#"Changed column type 1", {"dep_sc_local_time", "dep_es_local_time", "dep_ac_local_time", "arr_sc_local_time", "arr_es_local_time", "arr_ac_local_time"}),
  #"Added custom" = Table.TransformColumnTypes(Table.AddColumn(#"Removed columns", "dep_time", each if [dep_ac_utc_time] <> null then [dep_ac_utc_time]
else if [dep_es_utc_time] <> null then [dep_es_utc_time] else [dep_sc_utc_time]), {{"dep_time", type datetime}}),
  #"Removed columns 1" = Table.RemoveColumns(#"Added custom", {"dep_es_utc_time", "dep_ac_utc_time"}),
  #"Added custom 1" = Table.TransformColumnTypes(Table.AddColumn(#"Removed columns 1", "arr_time", each if [arr_ac_utc_time] <> null then [arr_ac_utc_time]
else if [arr_es_utc_time] <> null then [arr_es_utc_time] else [arr_sc_utc_time]), {{"arr_time", type datetime}}),
  #"Reordered columns" = Table.ReorderColumns(#"Added custom 1", {"source_file", "dep_airport", "dep_time", "dep_time_status_code", "dep_time_status", "arr_airport", "arr_time", "arr_sc_utc_time", "arr_es_utc_time", "arr_ac_utc_time", "arr_time_status_code", "arr_time_status", "mc_airline_id", "mc_flight_number", "oc_airline_id", "oc_flight_number", "aircraft_code", "aircraft_registration", "flight_status_code", "flight_status", "service_type"}),
  #"Removed columns 2" = Table.RemoveColumns(#"Reordered columns", {"arr_es_utc_time", "arr_ac_utc_time"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed columns 2", {{"dep_airport", "dep_airport_id"}, {"arr_airport", "arr_airport_id"}}),
  #"Merged queries" = Table.NestedJoin(#"Renamed columns", {"service_type"}, service_types_delta, {"name"}, "service_types_delta", JoinKind.LeftOuter),
  #"Expanded service_types_delta" = Table.ExpandTableColumn(#"Merged queries", "service_types_delta", {"id"}, {"service_type_id"}),
  #"Removed columns 3" = Table.RemoveColumns(#"Expanded service_types_delta", {"service_type"}),
  #"Merged queries 1" = Table.NestedJoin(#"Removed columns 3", {"flight_status"}, flight_status_types_delta, {"name"}, "flight_status_types_delta", JoinKind.LeftOuter),
  #"Expanded flight_status_types_delta" = Table.ExpandTableColumn(#"Merged queries 1", "flight_status_types_delta", {"id"}, {"flight_status_type_id"}),
  #"Removed columns 4" = Table.RemoveColumns(#"Expanded flight_status_types_delta", {"flight_status", "flight_status_code"}),
  #"Merged queries 2" = Table.NestedJoin(#"Removed columns 4", {"dep_time_status_code"}, time_status_types_delta, {"id"}, "time_status_types_delta", JoinKind.LeftOuter),
  #"Expanded time_status_types_delta" = Table.ExpandTableColumn(#"Merged queries 2", "time_status_types_delta", {"id"}, {"dep_time_status_type_id"}),
  #"Removed columns 5" = Table.RemoveColumns(#"Expanded time_status_types_delta", {"dep_time_status_code", "dep_time_status"}),
  #"Merged queries 3" = Table.NestedJoin(#"Removed columns 5", {"arr_time_status_code"}, time_status_types_delta, {"id"}, "time_status_types_delta", JoinKind.LeftOuter),
  #"Expanded time_status_types_delta 1" = Table.ExpandTableColumn(#"Merged queries 3", "time_status_types_delta", {"id"}, {"arr_time_status_type_id"}),
  #"Removed columns 6" = Table.RemoveColumns(#"Expanded time_status_types_delta 1", {"arr_time_status_code", "arr_time_status", "mc_airline_id", "mc_flight_number"}),
  #"Renamed columns 1" = Table.RenameColumns(#"Removed columns 6", {{"oc_airline_id", "airline_id"}, {"oc_flight_number", "flight_number"}}),
  #"Removed columns 7" = Table.RemoveColumns(#"Renamed columns 1", {"aircraft_registration"}),
  #"Filtered rows" = Table.SelectRows(#"Removed columns 7", each List.Contains({"FAO", "DRS", "FRA", "LIS", "OPO", "MUC"}, [arr_airport_id])),
  #"Filtered rows 1" = Table.SelectRows(#"Filtered rows", each List.Contains({"FAO", "DRS", "FRA", "LIS", "OPO", "MUC"}, [dep_airport_id])),
  #"Renamed columns 2" = Table.RenameColumns(#"Filtered rows 1", {{"flight_number", "flight_id"}, {"aircraft_code", "aircraft_id"}, {"source_file", "source_time"}}),
  #"Removed columns 8" = Table.RemoveColumns(#"Renamed columns 2", {"flight_id"}),
  #"Sorted rows" = Table.Sort(#"Removed columns 8", {{"source_time", Order.Descending}}),
  Custom = Table.Buffer(#"Sorted rows"),
  #"Removed duplicates" = Table.Distinct(Custom, {"schedule_id"})
in
  #"Removed duplicates";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "time_status_types_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared time_status_types_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "status_delta", ItemKind = "Table"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 2", {"dep_airport", "dep_sc_local_time", "dep_sc_utc_time", "dep_es_local_time", "dep_es_utc_time", "dep_ac_local_time", "dep_ac_utc_time", "arr_airport", "arr_sc_local_time", "arr_sc_utc_time", "arr_es_local_time", "arr_es_utc_time", "arr_ac_local_time", "arr_ac_utc_time", "aircraft_registration", "aircraft_code", "oc_flight_number", "oc_airline_id", "mc_flight_number", "mc_airline_id", "source_file", "flight_status_code", "flight_status", "service_type", "arr_time_status", "arr_time_status_code"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"dep_time_status_code"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed duplicates", {{"dep_time_status_code", "id"}, {"dep_time_status", "name"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "flight_status_types_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared flight_status_types_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "status_delta", ItemKind = "Table"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 2", {"dep_airport", "dep_sc_local_time", "dep_sc_utc_time", "dep_es_local_time", "dep_es_utc_time", "dep_ac_local_time", "dep_ac_utc_time", "arr_airport", "arr_sc_local_time", "arr_sc_utc_time", "arr_es_local_time", "arr_es_utc_time", "arr_ac_local_time", "arr_ac_utc_time", "arr_time_status_code", "aircraft_registration", "aircraft_code", "oc_flight_number", "oc_airline_id", "mc_flight_number", "mc_airline_id", "source_file", "dep_time_status_code", "dep_time_status", "arr_time_status", "service_type"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"flight_status_code"}),
  #"Renamed columns" = Table.RenameColumns(#"Removed duplicates", {{"flight_status_code", "id"}, {"flight_status", "name"}})
in
  #"Renamed columns";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "service_types_delta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared service_types_delta = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "4f909ca9-0c8b-420a-8995-81f1b427b6c0"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "status_delta", ItemKind = "Table"]}[Data],
  #"Removed columns" = Table.RemoveColumns(#"Navigation 2", {"dep_airport", "dep_sc_local_time", "dep_sc_utc_time", "dep_es_local_time", "dep_es_utc_time", "dep_ac_local_time", "dep_ac_utc_time", "arr_airport", "arr_sc_local_time", "arr_sc_utc_time", "arr_es_local_time", "arr_es_utc_time", "arr_ac_local_time", "arr_ac_utc_time", "arr_time_status_code", "aircraft_registration", "aircraft_code", "oc_flight_number", "oc_airline_id", "mc_flight_number", "mc_airline_id", "source_file", "dep_time_status_code", "dep_time_status", "arr_time_status", "flight_status_code", "flight_status"}),
  #"Removed duplicates" = Table.Distinct(#"Removed columns", {"service_type"}),
  #"Added index" = Table.AddIndexColumn(#"Removed duplicates", "Index", 1, 1, Int64.Type),
  #"Renamed columns" = Table.RenameColumns(#"Added index", {{"Index", "id"}, {"service_type", "name"}})
in
  #"Renamed columns";
shared headline_types_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "headline_types_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared headlines_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "headlines_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared time_status_types_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "time_status_types_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared schedules_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "schedules_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared status_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "status_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared flight_status_types_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "flight_status_types_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared service_types_delta_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "85a5c217-5ffd-4fc8-a29e-97e1a49d9530"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "166afb6c-39f8-40af-a22c-068c27ac4b8a"]}[Data],
  TableNavigation = Navigation_2{[Id = "service_types_delta", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
