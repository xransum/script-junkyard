function snakecaseObject(obj) {
    obj = obj ?? {};
    let newObj = {};
    for (let [k, v] of Object.entries(obj)) {
        newObj[snakeCase(k)] = v;
    }
    return newObj;
}