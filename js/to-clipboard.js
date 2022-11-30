function toClipboard(value) {
    let text = value;
    const onCopySuccess = function() {
        console.debug('Successfully copied to clipboard.');
        return;
    };
    const onCopyError = function(e) {
        console.error(e);
        return;
    };
    
    if (typeof value !== 'string') {
        text = JSON.stringify(text);
    }
    
    if (!navigator.clipboard) {
        let textArea = document.createElement("textarea");
        textArea.value = text;
        
        // Avoid scrolling to bottom
        textArea.style.top = "0";
        textArea.style.left = "0";
        textArea.style.position = "fixed";
        
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        try {
            onCopySuccess(document.execCommand('copy'));
        } catch (e) {
            onCopyError(e);
        }
        
        document.body.removeChild(textArea);
    }
    
    navigator.clipboard.writeText(text).then(onCopySuccess, onCopyError);
    
    return;
}