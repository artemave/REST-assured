$(function(){
    $('a.delete_link').click(function() {
        var f = $('<form>', { action: this.href, method: 'post' });
        f.append( $('<input>', { type: 'hidden', name: '_method', value: 'delete' }) );
        f.appendTo("body");
        f.submit();

        return false;
    });
});
