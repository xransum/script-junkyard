function stringToId(text) {
    let str = text;
    return str.toLowerCase().replace(/\W+/g, '-').replace(/\-{2,}/g, '-').replace(/^\-+|\-+$/g, '');
}
