$(function () {
    $.fn.tagcloud.defaults = {
        size:{start:1, end:2, unit:'em'},
        color:{start:'#777777', end:'#11CC00'}
    };
    $('#tag_cloud a').tagcloud();


    //$(".post #content").css('min-height', $("#sidebar").height() + 90 + 'px');

    //$("#post .excerpt").addClass("table-bordered");
});