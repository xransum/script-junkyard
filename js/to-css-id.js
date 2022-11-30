function toCssId(text) {
    let str = text;
    return str.replace(/\W+/g, '-');
}