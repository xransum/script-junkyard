/**
 * Convert URL search string and convert to an object
 * @param searchStr - URL search/query string
 * @returns {Object}
*/
function searchToObject(searchStr) {
    var str = decodeURIComponent(searchStr);
    var items = str.replace(/^\?/g, '').split(/\&/g);
    var result = {};
    items.filter(i => i).forEach(item => {
        var [akey, value, ..._] = item.split(/=(.*)/s);
        var bkey = akey;
        if (akey.match(/\[\]/g)) {
            bkey = bkey.replace(/\[\]$/g, '');
            value = [value];
        }
        
        if(!value) {
            value = null;
        }
        
        if (!result.hasOwnProperty(bkey)) {
            result[bkey] = null;
            if (Object.prototype.toString.call(value) == '[object Array]') {
                result[bkey] = [];
            }
        }
        
        if (Object.prototype.toString.call(value) == '[object Array]') {
            result[bkey] = result[bkey].concat(value);
        }
        else {
            result[bkey] = value;
        }
    })
    
    return result;
}
