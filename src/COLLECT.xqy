xquery version "1.0-ml";

declare namespace canon = 'http://www.macquarie.com/canon/v1';
declare option xdmp:mapping "false";

declare variable $CUTOFF_DATE as xs:string? external := '2024-04-01T00:00:00.000Z';
declare variable $LIMIT as xs:string? external := '20000';

declare function local:main() as item()+
{
  xdmp:log((
    "Collecting URIs for documents with sent date before: ",
    "Cutoff date: ", $CUTOFF_DATE,
    "Limit: ", $LIMIT
  ))
  ,
  let $lim := xs:integer($LIMIT)
  let $uris := cts:uris((), (), cts:path-range-query(
     '/some/path', "<", $CUTOFF_DATE
  ))[1 to $lim]
  return (count($uris), $uris)
};

local:main()
