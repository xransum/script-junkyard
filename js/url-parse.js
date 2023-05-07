// Function for deconstructing a URL to its components, necessary for getting 
// client identifier, urls hostname[:port], and the absolute URL.
// Example: 
//     getUrlProperties('example.com/search?q=abc&encoding=utf-8')
function getUrlProperties(url) {
    // Use the DOM to avoid having to use regex.
    let a = document.createElement("a");
    a.href = url;
    
    // anchors href property will automatically expand out the full URL, though in IE 
    // the other fields are not updated so you get 'hostname = "", protocol = "", etc.' 
    // for relative URLs. So, setting the href to the full URL updates all the fields,
    // so the following is a flex tape fix for IE.
    a.href = a.href; // Not a joke...
    
    // Can't use host property, since IE quietly assumes port :443 when one isn't given.
    const host = a.hostname + (a.port ? ":" + a.port : "");
    const endpoint = a.protocol + "//" + host;
    let pathname = a.pathname || "";
    
    // IE9.0 and below do not include the leading slash
    if (pathname && pathname[0] != "/") {
        pathname = "/" + pathname;
    }
    
    const urlProps = {
        // Turns a relative URL to absolute.
        absoluteUrl: a.href,
        host: host,
        endpoint: endpoint,
        base: endpoint + pathname,
        query: a.search,
        fragment: a.hash,
    };
    
    return urlProps;
}

// Given a url and query parameter, return the url with all occurrences of the query 
// parameter removed, if it is present. Otherwise return the unaltered url.
function removeQueryParam(urlProps, paramName) {
    var parts = urlProps.query.split("&");
    if (parts[0].charAt(0) == "?") {
        parts[0] = parts[0].substring(1);
    }
    var remainingParts = new Array();
    for (var i = 0; i < parts.length; i++) {
        var p = parts[i];
        if (!p) {
            // Handling extraneous leading/trailing '&'s, or double ampersands
            continue;
        }
        var keyVal = p.split("=");
        if (keyVal[0] == paramName) {
            // parameter to remove
            continue;
        }
        remainingParts.push(p);
    }
    var newQuery = "?" + remainingParts.join("&");
    var updatedQueryStr = overwriteQueryStr(urlProps, newQuery);
    return updatedQueryStr;
}

// Get the URL with the new query string.
function overwriteQueryStr(urlProps, newQueryStr) {
    return urlProps.base + newQueryStr + urlProps.fragment;
}

// For a given query string, append a query parameter and value to the query string.
function appendQueryParam(queryStr, queryParameter, queryValue) {
    var queryArg = queryParameter + "=" + queryValue;
    var newQuery = null;
    if (queryStr.indexOf("?") == -1) {
        newQuery = "?" + queryArg;
    } else {
        newQuery = queryStr + "&" + queryArg;
    }
    return newQuery;
}

// Update query string for a url with a query parameter and value.
function appendQueryString(urlProps, queryParameter, queryValue) {
    var queryStr = appendQueryParam(
        urlProps.query,
        queryParameter,
        queryValue
    );
    var newQuery = overwriteQueryStr(urlProps, queryStr);
    return newQuery;
}

// Parse URL query string and return it as an object
// Example:
//     getQueryParams(getUrlProperties('example.com/search?q=abc&encoding=utf-8'))
function getQueryParams(urlProps) {
    if (Object.prototype.toString.call(urlProps) === "[object String]") {
        urlProps = getUrlProperties(urlProps);
    }
    
    let queryObj = {};
    if (urlProps.query) {
        var parts = urlProps.query.split("&");
        if (parts[0].charAt(0) == "?") {
            parts[0] = parts[0].substring(1);
        }
        
        var remainingParts = new Array();
        for (var i = 0; i < parts.length; i++) {
            var p = parts[i];
            if (!p) {
                // Handling extraneous leading/trailing '&'s, or 
                // double ampersands
                continue;
            }
            
            var keyVal = p.split("=");
            queryObj[keyVal[0]] = keyVal[1];
        }
    }
    
    return queryObj;
}
