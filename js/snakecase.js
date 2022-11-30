function snakecase(str) {
    str = str ?? '';
    return (str.match(/[a-zA-Z]{1,}/g) ?? []).join('_').toLowerCase();
}