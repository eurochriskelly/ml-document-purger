xquery version "1.0-ml";

import module namespace json="http://marklogic.com/xdmp/json" at "/MarkLogic/json/json.xqy";

declare variable $URI as xs:string? external := "";

declare function local:main(
  $uris as xs:string*
) as xs:string
{
  try {
    for $uri in $uris
    return xdmp:document-delete($uri)
    ,
    "SUCCESS: Delete batch starting at [" || $uris[1] || "] completed!"
  } catch ($err) {
    let $code := $err//*:code/xs:string(.)
    let $_ := xdmp:log($err)
    return "FAILURE: Delete batch starting at [" || $uris[1] || "] with batch size [" || count($uris) || "] failed with code [" || $code || "]. See Application log for complete error message."
  }
};

local:main(fn:tokenize($URI, ';'))
