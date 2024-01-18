let
  getProblemsAPIResult = (base_url as text, next_url as text, qty as text, nextPageKey as text, currentList as list) => 
  let
    apiResult = if nextPageKey = ""
    then Json.Document(Web.Contents("https://{envid}.live.dynatrace.com/",
      [
        RelativePath = next_url,
        Query = 
          [
            pageSize = qty,
            problemSelector = "problemFilterIds(xxx)",
            from = "now-7d"
          ],
          Headers=[Accept="application/json; charset=utf-8", Authorization="Api-Token dt0c01.xxx"]
      ]
      ))
    else Json.Document(Web.Contents("https://{envid}.live.dynatrace.com/",
      [
        RelativePath = next_url,
        Query = 
          [
            nextPageKey = nextPageKey
          ],
          Headers=[Accept="application/json; charset=utf-8", Authorization="Api-Token dt0c01.xxx"]
      ]
      )),
    newList = List.Combine({currentList, apiResult[problems]}),
    hasNext_tmp = apiResult[nextPageKey], 
    hasNext = try if hasNext_tmp is null
    then try apiResult[nextPageKeyError]
    else try apiResult[nextPageKey],
    returnList = if hasNext[HasError]
    then newList
    else @getProblemsAPIResult(base_url, next_url, qty, apiResult[nextPageKey], newList)
  in
    returnList,
  problemslist = getProblemsAPIResult("https://{envid}.live.dynatrace.com", "/api/v2/problems", "200", "", {}),
    #"Converted to table" = Table.FromList(problemslist, Splitter.SplitByNothing(), null, null, ExtraValues.Error),
    #"Expanded Column1" = Table.ExpandRecordColumn(#"Converted to table", "Column1", {"problemId", "displayId", "title", "impactLevel", "severityLevel", "status", "affectedEntities", "impactedEntities", "rootCauseEntity", "managementZones", "entityTags", "problemFilters", "startTime", "endTime"}, {"Column1.problemId", "Column1.displayId", "Column1.title", "Column1.impactLevel", "Column1.severityLevel", "Column1.status", "Column1.affectedEntities", "Column1.impactedEntities", "Column1.rootCauseEntity", "Column1.managementZones", "Column1.entityTags", "Column1.problemFilters", "Column1.startTime", "Column1.endTime"})
 in
  #"Expanded Column1"