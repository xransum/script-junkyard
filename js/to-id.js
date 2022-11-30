function toId(text) {
    let str = text;
    return str.toLowerCase().replace(/\W+/g, '-');
}