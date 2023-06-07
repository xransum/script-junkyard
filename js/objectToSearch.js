/**
 * Convert an Object into a URL search string
 * @param searchObj - The object containing search attributes
 * @returns {string}
*/
function objectToSearch(searchObj) {
    var result = '';
    Object.entries(searchObj).forEach(([key, value]) => {
        if (Object.prototype.toString.call(value) == '[object Array]') {
            value.forEach(subValue => {
                subValue = !!subValue ? subValue : '';
                result += `${key}[]=${subValue}`;
            })
        }
        else {
            value = !!value ? value : '';
            result += `${key}=${value}`;
        }
    });
    
    return !!result ? `?${result}` : result;
}
