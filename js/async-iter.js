function* iter(arr) {
    let i = 0;
    while (i < arr.length) {
        yield Promise.resolve(arr[i], i);
        i++;
    }
}