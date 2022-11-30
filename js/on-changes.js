function onchanges(target) {
    target = target ?? document.body;

    // For more filtering rules check MutationObserver documentation.
    // Documentation: https://developer.mozilla.org/en-US/docs/Web/API/MutationObserver/observe

    function changeWatcher(fn, options) {
        let watcher = new MutationObserver(function() {
            return fn.apply(target, arguments);
        });

      	watcher.observe(target, options);
        return watcher;
    }

    function attributeChanges(callback, options) {
        options = options ?? {};

        return changeWatcher(callback, {
            attributes: true,
            ...options,
        })
    }

    function childChanges(callback, options) {
        options = options ?? {};

        return changeWatcher(callback, {
            childList: true,
            ...options,
        })
    }

    function subtreeChanges(callback, options) {
        options = options ?? {};

        return changeWatcher(callback, {
            childList: true,
            subtree: true,
            ...options,
        })
    }

    return {
        attrs: attributeChanges,
        children: childChanges,
        subtree: subtreeChanges,
    }
}
